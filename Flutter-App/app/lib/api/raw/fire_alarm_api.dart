import 'package:dio/dio.dart';
import 'package:ssds_app/api/dio_system_client.dart';

import '../endpoints.dart';

class FireAlarmApi {
  final DioSystemClient dioClient;

  FireAlarmApi({required this.dioClient});

  Future<Response> checkFireAlarmActive({String tenantId = ""})async{
    try {

      if(tenantId == "") {
        final response = await dioClient.get(Endpoints.checkFirealarm);
        return response;
      }

      final response = await dioClient.get("${Endpoints.checkFirealarm}/$tenantId}");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getAllFireAlarms({String tenantId = ""}) async {
    try {

      if(tenantId == "") {
        final response = await dioClient.get(Endpoints.fireAlarm);
        return response;
      }

      final response = await dioClient.get("${Endpoints.fireAlarm}/$tenantId}");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getActiveFireAlarms({String tenantId = ""}) async {
    try {
      if(tenantId == "") {
        final response = await dioClient.get("${Endpoints.fireAlarm}/active");
        return response;
      }

      final response = await dioClient.get("${Endpoints.fireAlarm}/active/$tenantId}");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> stopAlarm(String fireAlarmId) async {
    try {
      final response =
          await dioClient.post("${Endpoints.stopFireAlarm}/$fireAlarmId");
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
