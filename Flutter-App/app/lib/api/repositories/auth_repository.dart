import 'package:dio/dio.dart';
import 'package:ssds_app/api/models/requests/login_model.dart';
import 'package:ssds_app/api/models/requests/login_refresh_model.dart';
import 'package:ssds_app/api/models/responses/response_model.dart';
import '../../log_helper.dart';
import '../dio_exception.dart';
import '../models/responses/login_response_model.dart';
import '../raw/auth_api.dart';

class AuthRepository {
  final AuthApi authApi;
  final logger = getLogger();

  AuthRepository(this.authApi);

  Future<ResponseModel> login(LoginModel model) async {
    var responseModel = ResponseModel();

    try {
      final response = await authApi.login(model);

      if(response.statusCode != 200){
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = LoginResponseModel.fromJson(response.data);
      return responseModel;

    } on DioError catch (e) {
      if(e.response?.statusCode == 401){
        responseModel.success = false;

        if(e.response!.data == "Please confirm your mail first") {
          responseModel.errorMessage = "Bitte bestätigen Sie zuerst Ihre E-Mail";
        } else {
          responseModel.errorMessage = "Benutzername oder Passwort falsch";
        }
        return responseModel;
      }
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      logger.e(responseModel.errorMessage);
      return responseModel;
    }
  }

  Future<ResponseModel> loginRefresh(LoginRefreshModel model) async {
    var responseModel = ResponseModel();
    try {
      logger.d("loginRefresh: ${model.toJson()}");

      final response = await authApi.loginRefresh(model);
      if(response.statusCode != 200){
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = LoginResponseModel.fromJson(response.data);
      return responseModel;

    } on DioError catch (e) {
      if(e.response?.statusCode == 401){
        responseModel.success = false;
        responseModel.errorMessage = "Benutzername oder Passwort falsch";
        return responseModel;
      }

      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      logger.e(responseModel.errorMessage);
      return responseModel;
    }
  }
}
