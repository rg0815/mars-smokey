import 'package:dio/dio.dart';

import '../dio_exception.dart';
import '../models/notification_setting_model.dart';
import '../models/responses/response_model.dart';
import '../raw/notification_api.dart';

class NotificationRepository {
  final NotificationApi notificationApi;

  NotificationRepository(this.notificationApi);

  Future<ResponseModel> getNotificationSettingsByUserId(String userId) async {
    var responseModel = ResponseModel();

    try {
      final response =
          await notificationApi.getNotificationSettingsByUserId(userId);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = NotificationSettingModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> AddOrUpdateNotificationSetting(
      String userId, NotificationSettingModel model) async {
    var responseModel = ResponseModel();

    try {
      final response =
          await notificationApi.createNotificationSetting(userId, model);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = NotificationSettingModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }
}
