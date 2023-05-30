import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mutex/mutex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssds_app/api/models/requests/login_model.dart';
import 'package:ssds_app/api/repositories/auth_repository.dart';
import 'package:ssds_app/api/repositories/tenant_repository.dart';
import 'package:ssds_app/api/repositories/user_repository.dart';
import 'package:ssds_app/helper/multi_tenant_notifier.dart';

import '../api/models/requests/login_refresh_model.dart';
import '../api/models/responses/login_response_model.dart';
import '../api/models/tenant_model.dart';
import '../api/models/user_model.dart';
import '../components/snackbar/snackbar.dart';
import '../log_helper.dart';
import '../services/service_locator.dart';
import 'dialog_helper.dart';

class AppAuth {
  static final logger = getLogger();
  static final refreshing = Mutex();
  static UserModel _user = UserModel();
  static TenantModel? selectedTenant;
  static String? selectedTenantId;

  static bool _signedIn = false;

  static bool get signedIn => _signedIn;

  static Future<void> signOut() async {
    _user = UserModel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _signedIn = false;
  }

  static Future<bool> signIn(LoginModel model, BuildContext context) async {
    var res = await locator.get<AuthRepository>().login(model);

    if (!res.success! || res.data == null) {
      DialogHelper().displayErrorSnackBar(context,
          res.errorMessage ?? "Unbekannter Fehler.", ContentType.failure);
    } else {
      var loginResponse = res.data as LoginResponseModel;

      if (loginResponse.user == null) {
        DialogHelper().displayErrorSnackBar(
            context, "Benutzer nicht gefunden.", ContentType.failure);
        return false;
      }

      _user = loginResponse.user!;
      _user.accessToken = loginResponse.accessToken;
      _user.refreshToken = loginResponse.refreshToken;
      selectedTenantId = _user.tenantId;
      var resTenant = await locator.get<TenantRepository>().getTenantById(selectedTenantId!);
      AppAuth.selectedTenant = resTenant.data;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user", json.encode(_user.toJson()));
      _signedIn = true;

      if (_user.tenantId != null) {
        final myProvider = StateNotifierProvider((ref) {
          debugPrint("StateNotifierProvider called");
          debugPrint("set selected tenant: ${_user.tenantId}");
          ref.read(multiTenantProvider.notifier).setSelectedTenant(_user.tenantId!);
          return MultiTenantNotifier(ref);
        });


        // var test = multiTenantProvider.notifier;
        // test.select((value) => value.setSelectedTenant(_user.tenantId!));

        // final container = ProviderContainer();
        // container
        //     .read(multiTenantProvider.notifier)
        //     .setSelectedTenant(_user.tenantId!);
      }
    }

    return _signedIn;
  }

  static Future<bool> tryAutoLogin() async {
    logger.i("tryAutoLogin called");
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("user")) {
      logger.w("No user found in prefs");
      return false;
    }

    var userJson = prefs.getString("user");
    if (userJson == null) {
      logger.w("No user json found in prefs");
      return false;
    }

    print(userJson);

    var userMap = await json.decode(userJson);
    _user = UserModel.fromJson(userMap);

    if (_user == UserModel()) {
      logger.w("User is empty");
      return false;
    }

    if (_user.accessToken == null || _user.refreshToken == null) {
      logger.w("Token or refresh token is null");
      return false;
    }

    if (JwtDecoder.isExpired(_user.accessToken!)) {
      logger.i("Token expired, refreshing...");

      var res = await refreshToken("tryAutoLogin");

      if (!res) {
        return false;
      }
    }

    if (_user.tenantId != null) {
      var test = multiTenantProvider.notifier;
      test.select((value) => value.setSelectedTenant(_user.tenantId!));
    }

    selectedTenantId = _user.tenantId;
    var res = await locator.get<TenantRepository>().getTenantById(_user.tenantId!);
    if (!res.success! || res.data == null) {
      logger.e("Tenant not found");
      await signOut();
      return false;
    }
    selectedTenant = res.data as TenantModel;

    // await updateUser();

    _signedIn = true;
    return _signedIn;
  }

  static Future<bool> refreshToken(String calledMethod) async {
    await refreshing.acquire();

    logger.wtf("refreshToken called from $calledMethod");
    final prefs = await SharedPreferences.getInstance();

    if (_user.accessToken == null || _user.refreshToken == null) {
      //try to get user from shared prefs
      if (!prefs.containsKey("user")) {
        logger.e("Token or refresh token is null");
        await signOut();
        refreshing.release();
        return false;
      }

      var userJson = prefs.getString("user");
      if (userJson == null) {
        logger.e("Token or refresh token is null");
        await signOut();
        refreshing.release();
        return false;
      }

      var userMap = await json.decode(userJson);
      _user = UserModel.fromJson(userMap);

      if (_user.accessToken == null || _user.refreshToken == null) {
        logger.e("Token or refresh token is null");
        await signOut();
        refreshing.release();
        return false;
      }
    }
    var model = LoginRefreshModel(
        accessToken: _user.accessToken, refreshToken: _user.refreshToken!);
    var res = await locator.get<AuthRepository>().loginRefresh(model);
    if (!res.success! || res.data == null) {
      logger.e("Refresh token failed");
      await signOut();
      refreshing.release();
      throw Exception("Refresh token failed");
    }

    var loginResponse = res.data as LoginResponseModel;

    if (loginResponse.user == null) {
      logger.e("User is null");
      await signOut();
      refreshing.release();
      return false;
    }

    _user = loginResponse.user!;
    _user.accessToken = loginResponse.accessToken;
    _user.refreshToken = loginResponse.refreshToken;
    await prefs.setString("user", json.encode(_user.toJson()));
    logger.i("Refresh token success");
    refreshing.release();
    return true;
  }

  static Future<void> updateUser() async {
    var response = await locator.get<UserRepository>().getUser();
    if (response.success! && response.data != null) {
      _user = response.data as UserModel;

      //update shared prefs
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user", json.encode(_user.toJson()));
    }
  }

  static setUser(UserModel userModel) async {
    logger.d("Set user");
    _user = userModel;

    //update shared prefs
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user", json.encode(_user.toJson()));
  }

  static UserModel getUser() {
    if (_user == UserModel()) {
// try reload user
      tryAutoLogin();
    }

    return _user;
  }
}


extension Context on BuildContext {
  // Custom call a provider for reading method only
  // It will be helpful for us for calling the read function
  // without Consumer,ConsumerWidget or ConsumerStatefulWidget
  // Incase if you face any issue using this then please wrap your widget
  // with consumer and then call your provider

  T read<T>(ProviderBase<T> provider) {
    return ProviderScope.containerOf(this, listen: false).read(provider);
  }
}