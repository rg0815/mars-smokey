import 'package:dio/dio.dart';
import 'package:ssds_app/api/raw/fire_alarm_api.dart';

import '../models/fire_alarm.dart';
import '../models/responses/response_model.dart';

class FireAlarmRepository {
  final FireAlarmApi fireAlarmApi;

  FireAlarmRepository(this.fireAlarmApi);

  Future<ResponseModel> stopAlarm(String fireAlarmId) async {
    var responseModel = ResponseModel();

    try {
      final response= await fireAlarmApi.stopAlarm(fireAlarmId);

      if(response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      return responseModel;
    } on DioError catch(e) {
      responseModel.success = false;
      responseModel.errorMessage = e.response?.statusMessage ?? e.message;
      return responseModel;
    }
  }

Future<ResponseModel> checkFireAlarmActive({String tenantId = ""})async{
    var responseModel = ResponseModel();

    try {
      final response = await fireAlarmApi.checkFireAlarmActive(tenantId: tenantId);

      if(response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = response.data;
      return responseModel;
    } on DioError catch(e) {
      responseModel.success = false;

      if(e.response?.statusCode == 404) {
        responseModel.data = false;
        responseModel.errorMessage = "No fire active";
        return responseModel;
      }

      responseModel.errorMessage = e.response?.statusMessage ?? e.message;
      return responseModel;
    }
  }

  Future<ResponseModel> getAllFireAlarms({String tenantId = ""}) async{
    var responseModel = ResponseModel();

    try {
      final response = await fireAlarmApi.getAllFireAlarms(tenantId: tenantId);

      if(response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = <FireAlarm>[];
      responseModel.data = List<FireAlarm>.from(response.data.map((x) => FireAlarm.fromJson(x)));

      return responseModel;
    } on DioError catch(e) {
      responseModel.success = false;
      responseModel.errorMessage = e.response?.statusMessage ?? e.message;
      return responseModel;
    }
  }

  Future<ResponseModel> getActiveFireAlarms({String tenantId =""}) async{
    var responseModel = ResponseModel();

    try {
      final response = await fireAlarmApi.getActiveFireAlarms(tenantId: tenantId);

      if(response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = <FireAlarm>[];
      responseModel.data = List<FireAlarm>.from(response.data.map((x) => FireAlarm.fromJson(x)));

      return responseModel;
    } on DioError catch(e) {
      responseModel.success = false;
      responseModel.errorMessage = e.response?.statusMessage ?? e.message;
      return responseModel;
    }
  }


}