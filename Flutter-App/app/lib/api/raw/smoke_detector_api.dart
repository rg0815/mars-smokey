import 'package:dio/dio.dart';
import 'package:ssds_app/api/dio_system_client.dart';
import 'package:ssds_app/api/models/smoke_detector_maintenance_model.dart';
import 'package:ssds_app/api/models/smoke_detector_model.dart';

import '../endpoints.dart';

class SmokeDetectorApi {
  final DioSystemClient dioClient;

  SmokeDetectorApi({required this.dioClient});

  Future<Response> getSmokeDetectors(String tenantId) async {
    try {
      final response =
          await dioClient.get("${Endpoints.smokeDetectors}/tenant/$tenantId");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getSmokeDetectorById(String smokeDetectorId) async {
    try {
      final response =
          await dioClient.get("${Endpoints.smokeDetectors}/$smokeDetectorId");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateSmokeDetector(
      String smokeDetectorId, SmokeDetectorModel model) async {
    try {
      final response = await dioClient.put(
          "${Endpoints.smokeDetectors}/$smokeDetectorId",
          data: model.toUpdateJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteSmokeDetector(String smokeDetectorId) async {
    try {
      final response = await dioClient
          .delete("${Endpoints.smokeDetectors}/$smokeDetectorId");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getSmokeDetectorModels() async {
    try {
      final response =
          await dioClient.get("${Endpoints.smokeDetectors}/models");
      return response;
    } catch (e) {
      rethrow;
    }
  }



  Future<Response> testAlarm(String smokeDetectorId) async {
    try {
      final response =
          await dioClient.post("${Endpoints.testAlarm}/$smokeDetectorId");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> stopTestAlarm(String smokeDetectorId) async {
    try {
      final response =
          await dioClient.post("${Endpoints.stopTestAlarm}/$smokeDetectorId");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> startPairing(String gatewayId) async {
    try {
      final response = await dioClient
          .post("${Endpoints.startPairingSmokeDetector}/$gatewayId");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> stopPairing(String gatewayId) async {
    try {
      final response = await dioClient
          .post("${Endpoints.stopPairingSmokeDetector}/$gatewayId");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addMaintenance(String smokeDetectorId, SmokeDetectorMaintenanceModel model) async {
    try {
      final response = await dioClient
          .post("${Endpoints.addMaintenance}/$smokeDetectorId", data: model.toCreateJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

}
