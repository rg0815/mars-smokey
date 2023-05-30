import 'package:ssds_app/api/dio_user_client.dart';
import 'package:dio/dio.dart';
import 'package:ssds_app/api/endpoints.dart';
import 'package:ssds_app/api/models/requests/login_model.dart';
import 'package:ssds_app/globals.dart' as globals;

import '../models/requests/login_refresh_model.dart';

class AuthApi {
  final DioUserClient dioClient;

  AuthApi({required this.dioClient});

  Future<Response> login(LoginModel model) async {
    try {
      final response =
          await dioClient.post(Endpoints.auth, data: model.toJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> loginRefresh(LoginRefreshModel model) async {
    try {
      var dio = Dio();
      dio
        ..options.baseUrl = globals.userServiceUrl
        ..options.connectTimeout = Endpoints.connectionTimeout
        ..options.receiveTimeout = Endpoints.receiveTimeout
        ..options.responseType = ResponseType.json
        ..options.receiveDataWhenStatusError = true;

      var resp = await dio.post(Endpoints.authRefresh, data: model.toJson());
      return resp;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> authRevoke(String mail) async {
    try {
      final response = await dioClient.post(
          Endpoints.authRevoke.replaceAll("{mail}", mail));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> authRevokeAll() async {
    try {
      final response = await dioClient.post(Endpoints.authRevokeAll);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
