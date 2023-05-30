import 'package:dio/dio.dart';
import 'package:ssds_app/api/dio_system_client.dart';
import 'package:ssds_app/api/models/notification_setting_model.dart';

import '../endpoints.dart';

class NotificationApi {
  final DioSystemClient dioClient;

  NotificationApi({required this.dioClient});

  Future<Response> getNotificationSettingsByUserId(String userId) async {
    try {
      final response = await dioClient.get(
          "${Endpoints.notificationSettings}/$userId");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createNotificationSetting(String userId,
      NotificationSettingModel notification) async {
    try {
      final response = await dioClient.post(
          "${Endpoints.notificationSettings}/$userId",
          data: notification.toCreateJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }
}