import 'package:dio/dio.dart';
import 'package:ssds_app/api/models/responses/response_model.dart';
import 'package:ssds_app/api/models/smoke_detector_maintenance_model.dart';

import '../models/smoke_detector_model.dart';
import '../models/smoke_detector_model_model.dart';
import '../raw/smoke_detector_api.dart';

class SmokeDetectorRepository {
  final SmokeDetectorApi smokeDetectorApi;

  SmokeDetectorRepository({required this.smokeDetectorApi});

  Future<ResponseModel> getSmokeDetectors(String tenantId) async {
    var responseModel = ResponseModel();

    try {
      final response = await smokeDetectorApi.getSmokeDetectors(tenantId);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = <SmokeDetectorModel>[];
      responseModel.data = List<SmokeDetectorModel>.from(
          response.data.map((x) => SmokeDetectorModel.fromJson(x)));

      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = e.response?.statusMessage ?? e.message;
      return responseModel;
    }
  }

  Future<ResponseModel> getSmokeDetectorById(String smokeDetectorId) async {
    var responseModel = ResponseModel();

    try {
      final response =
          await smokeDetectorApi.getSmokeDetectorById(smokeDetectorId);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = SmokeDetectorModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = e.response?.statusMessage ?? e.message;
      return responseModel;
    }
  }

  Future<ResponseModel> updateSmokeDetector(String smokeDetectorId, SmokeDetectorModel model) async {
    var responseModel = ResponseModel();

    try {
      final response =
          await smokeDetectorApi.updateSmokeDetector(smokeDetectorId, model);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = SmokeDetectorModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = e.response?.statusMessage ?? e.message;
      return responseModel;
    }
  }

  Future<ResponseModel> deleteSmokeDetector(String smokeDetectorId) async {
    var responseModel = ResponseModel();

    try {
      final response =
          await smokeDetectorApi.deleteSmokeDetector(smokeDetectorId);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = e.response?.statusMessage ?? e.message;
      return responseModel;
    }
  }

  Future<ResponseModel> getSmokeDetectorModels() async {
    var responseModel = ResponseModel();

    try {
      final response =
          await smokeDetectorApi.getSmokeDetectorModels();

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = <SmokeDetectorModel>[];
      responseModel.data = List<SmokeDetectorModelModel>.from(
          response.data.map((x) => SmokeDetectorModelModel.fromJson(x)));

      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = e.response?.statusMessage ?? e.message;
      return responseModel;
    }
  }

   Future<ResponseModel> testAlarm(String smokeDetectorId) async {
    var responseModel = ResponseModel();

    try {
      final response= await smokeDetectorApi.testAlarm(smokeDetectorId);

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

  Future<ResponseModel> stopTestAlarm(String smokeDetectorId) async {
    var responseModel = ResponseModel();

    try {
      final response= await smokeDetectorApi.stopTestAlarm(smokeDetectorId);

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

  Future<ResponseModel> startPairing(String gatewayId) async{
    var responseModel = ResponseModel();

    try {
      final response= await smokeDetectorApi.startPairing(gatewayId);

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

  Future<ResponseModel> stopPairing(String gatewayId) async{
    var responseModel = ResponseModel();

    try {
      final response= await smokeDetectorApi.stopPairing(gatewayId);

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

  Future<ResponseModel> addMaintenance(String smokeDetectorId, SmokeDetectorMaintenanceModel model) async{
    var responseModel = ResponseModel();

    try {
      final response= await smokeDetectorApi.addMaintenance(smokeDetectorId, model);

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

}