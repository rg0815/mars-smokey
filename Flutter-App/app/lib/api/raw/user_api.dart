import 'package:dio/dio.dart';
import 'package:ssds_app/api/endpoints.dart';
import 'package:ssds_app/api/dio_user_client.dart';
import 'package:ssds_app/api/models/user_invitation.dart';
import 'package:ssds_app/api/models/requests/change_password_model.dart';
import 'package:ssds_app/api/models/requests/register_model.dart';
import 'package:ssds_app/api/models/requests/reset_password_model.dart';

import '../../Screens/Password/components/password_reset_model.dart';

class UserApi {
  final DioUserClient dioClient;

  UserApi({required this.dioClient});

  Future<Response> getAllTenantUsers(String tenantId) async {
    try {
      final Response response = await dioClient.get(
        "${Endpoints.getTenantUsers}/$tenantId",
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> registerNewUser(
      RegisterModel model, String registrationToken) async {
    try {
      final Response response = await dioClient.post(
        Endpoints.registerUser
            .replaceFirst("{registrationToken}", registrationToken),
        data: model.toJson(),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> registerTenantAdmin(
      RegisterModel model, String tenantId) async {
    try {
      final Response response = await dioClient.post(
        "${Endpoints.registerTenantAdmin}/$tenantId",
        data: model.toJson(),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getInvitation(String invitationToken) async {
    try {
      final Response response =
          await dioClient.get("${Endpoints.invitation}/$invitationToken");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getAllInvitations() async {
    try {
      final Response response = await dioClient.get(
        Endpoints.invitation,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getTenantAdmins(String tenantId) async {
    try {
      final Response response = await dioClient.get(
        "${Endpoints.tenantAdmin}/$tenantId",
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateUser(RegisterModel model) async {
    try {
      final Response response = await dioClient.put(
        Endpoints.users,
        data: model.toJson(),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getMe() async {
    try {
      final Response response = await dioClient.get(Endpoints.userMe);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getUsers() async {
    try {
      final Response response = await dioClient.get(Endpoints.users);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> changePassword(ChangePasswordModel model) async {
    try {
      final Response response =
          await dioClient.put(Endpoints.changePassword, data: model.toJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> resetPassword(ResetPasswordModel model) async {
    try {
      final Response response =
          await dioClient.post(Endpoints.passwordReset, data: model.toJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> resetPasswordRequest(PasswordResetModel model) async {
    try {
      final Response response = await dioClient
          .post(Endpoints.passwordResetRequest, data: model.toJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> inviteUser(UserInvitation model, String? tenantId) async {
    try {
      if (tenantId != null) {
        return await dioClient.post("${Endpoints.invitation}/$tenantId",
            data: model.toCreateJson());
      }

      return await dioClient.post(Endpoints.invitation,
          data: model.toCreateJson());
    } catch (e) {
      rethrow;
    }
  }
}
