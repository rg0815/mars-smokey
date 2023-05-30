import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:ssds_app/api/endpoints.dart';
import 'package:ssds_app/components/snackbar/snackbar.dart';
import 'package:ssds_app/globals.dart' as globals;
import 'package:ssds_app/helper/auth.dart';
import 'package:ssds_app/helper/dialog_helper.dart';
import '../log_helper.dart';

class AuthInterceptor extends DefaultInterceptor {
  final logger = getLogger();

  @override
  void onError(err, handler) async {
    if (err.response?.statusCode == 401) {
      if (err.requestOptions.path == Endpoints.auth) {
        handler.next(err);
      }

      while (AppAuth.refreshing.isLocked) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      //check if token is still expired
      if (JwtDecoder.isExpired(AppAuth.getUser().accessToken!)) {
        logger.i("Token is expired");
        await AppAuth.refreshToken("onRequest - AuthInterceptor");
      }

      var bOptions = BaseOptions(
          baseUrl: err.requestOptions.baseUrl,
          connectTimeout: Endpoints.connectionTimeout,
          receiveTimeout: Endpoints.receiveTimeout,
          responseType: ResponseType.json,
          receiveDataWhenStatusError: true);
      var dio = Dio(bOptions);

      try {
        err.requestOptions.headers["Authorization"] =
            "Bearer ${AppAuth.getUser().accessToken!}";

        final opts = Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers);
        final cloneReq = await dio.request(err.requestOptions.path,
            options: opts,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters);
        return handler.resolve(cloneReq);

        // return super.onError(err, handler);
      } catch (e, st) {
        if (e is DioError && e.response?.statusCode == 401) {
          logger.e("Refresh Token Failed");
          await AppAuth.signOut();
          globals.navigatorKey.currentContext!.go("/login");
          return super.onError(err, handler);
        }
        print("ERROR: " + e.toString());
        print("STACK: " + st.toString());
        await AppAuth.signOut();
        globals.navigatorKey.currentContext!.go("/login");
        return super.onError(err, handler);
      }
    } else {
      return super.onError(err, handler);
    }
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.path == Endpoints.auth ||
        options.path == Endpoints.authRefresh ||
        options.path == Endpoints.passwordReset ||
        options.path == Endpoints.passwordResetRequest ||
        options.path == Endpoints.init ||
        (options.path.startsWith(Endpoints.registerTenantAdmin) &&
            options.method == "POST") ||
        (options.path == Endpoints.tenants && options.method == "POST") ||
        (options.path == Endpoints.users && options.method == "POST")) {
      logger.i(
          "Request without Auth: ${options.path} - Base: ${options.baseUrl}");
      return super.onRequest(options, handler);
    }

    if (AppAuth.getUser().accessToken != null &&
        JwtDecoder.isExpired(AppAuth.getUser().accessToken!)) {
      while (AppAuth.refreshing.isLocked) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      //check if token is still expired
      if (JwtDecoder.isExpired(AppAuth.getUser().accessToken!)) {
        logger.i("Token is expired");
        await AppAuth.refreshToken("onRequest - AuthInterceptor");
      }
    }

    options.headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer ${AppAuth.getUser().accessToken}"
    };
    return super.onRequest(options, handler);
  }
}

class DefaultInterceptor extends Interceptor {
  final logger = getLogger();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    logger.i(
        'REQUEST[${options.method}] => PATH: ${options.baseUrl} - ${options.uri} - ${options.path} | DATA => ${options.data} | JWT => ${options.headers}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.i(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.baseUrl} - ${response.requestOptions.uri} -  ${response.requestOptions.path} | DATA => ${response.data}');
    super.onResponse(response, handler);
    return;
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    logger.e(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.baseUrl} - ${err.requestOptions.uri} -  ${err.requestOptions.path} | SENT_DATA => ${err.requestOptions.data} | RECEIVED_DATA => ${err.response?.data}');

    if (err.type == DioErrorType.connectionTimeout) {
      logger.e("Connection Timeout");
      DialogHelper().displayErrorSnackBar(globals.navigatorKey.currentContext!,
          "Verbindung zum Server fehlgeschlagen", ContentType.failure);
      // globals.navigatorKey.currentContext!.go("/login");
    }

    return super.onError(err, handler);
  }
}
