import 'package:dio/dio.dart';
import 'package:ssds_app/Screens/Password/components/password_reset_model.dart';
import 'package:ssds_app/api/error_details.dart';
import 'package:ssds_app/api/models/user_invitation.dart';
import 'package:ssds_app/api/models/requests/change_password_model.dart';
import 'package:ssds_app/api/models/requests/register_model.dart';
import 'package:ssds_app/api/models/requests/reset_password_model.dart';
import 'package:ssds_app/api/models/user_model.dart';
import 'package:ssds_app/api/raw/user_api.dart';
import 'package:ssds_app/api/dio_exception.dart';

import '../models/responses/response_model.dart';

class UserRepository {
  final UserApi userApi;

  UserRepository(this.userApi);

  Future<ResponseModel> getInvitation(String invitationToken) async {
    var responseModel = ResponseModel();

    try {
      final response = await userApi.getInvitation(invitationToken);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = UserInvitation.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> getAllInvitations() async {
    var responseModel = ResponseModel();

    try {
      final response = await userApi.getAllInvitations();

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      var list = List<UserInvitation>.from(
          response.data.map((x) => UserInvitation.fromJson(x)));

      responseModel.success = true;
      responseModel.data = list;
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> registerUser(
      RegisterModel model, String registrationToken) async {
    var responseModel = ResponseModel();

    try {
      final response = await userApi.registerNewUser(model, registrationToken);

      if (response.statusCode != 201) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = List<UserInvitation>.from(
          response.data.map((x) => UserInvitation.fromJson(x)));
      return responseModel;
    } on DioError catch (e) {
      if (e.response?.statusCode == 409) {
        responseModel.success = false;
        responseModel.errorMessage =
            "Es existiert bereits ein Benutzer mit dieser E-Mail-Adresse";
        return responseModel;
      }

      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> registerTenantAdmin(
      RegisterModel model, String tenantId) async {
    var responseModel = ResponseModel();
    responseModel.errorMessage = "";

    try {
      final response = await userApi.registerTenantAdmin(model, tenantId);

      if (response.statusCode != 201) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = UserModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;

      var errorDetails = ErrorDetails.fromJson(e.response?.data);
      if (errorDetails.errorCode == ErrorType.UserAlreadyExists) {
        responseModel.errorMessage =
            "Es existiert bereits ein Benutzer mit dieser E-Mail-Adresse.";
        return responseModel;
      }

      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> getTenantAdmins(String tenantId) async {
    var responseModel = ResponseModel();
    responseModel.errorMessage = "";

    try {
      final response = await userApi.getTenantAdmins(tenantId);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data =
          List<UserModel>.from(response.data.map((x) => UserModel.fromJson(x)));
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> editUser(RegisterModel model) async {
    var responseModel = ResponseModel();

    try {
      final response = await userApi.updateUser(model);

      if (response.statusCode != 200 && response.statusCode != 201) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = UserModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> getUser() async {
    var responseModel = ResponseModel();

    try {
      final response = await userApi.getMe();

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = UserModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;

      if (e.response?.statusCode == 401) {
        responseModel.errorMessage = "Anmeldung fehlgeschlagen";
      }

      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> changePassword(ChangePasswordModel model) async {
    var responseModel = ResponseModel();

    try {
      final response = await userApi.changePassword(model);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> resetPassword(ResetPasswordModel model) async {
    var responseModel = ResponseModel();

    try {
      final response = await userApi.resetPassword(model);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> resetPasswordRequest(PasswordResetModel model) async {
    var responseModel = ResponseModel();

    try {
      final response = await userApi.resetPasswordRequest(model);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> inviteUser(UserInvitation model, String? tenantId) async {
    var responseModel = ResponseModel();
    try {
      var response = await userApi.inviteUser(model, tenantId);
      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> getAllTenantUsers(String tenantId) async {
    var responseModel = ResponseModel();

    try {
      var response = await userApi.getAllTenantUsers(tenantId);
      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data =
          List<UserModel>.from(response.data.map((x) => UserModel.fromJson(x)));
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }
}
