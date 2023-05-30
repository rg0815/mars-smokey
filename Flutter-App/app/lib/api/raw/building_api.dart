import 'package:dio/dio.dart';
import 'package:ssds_app/api/dio_system_client.dart';
import 'package:ssds_app/api/models/requests/add_building_request.dart';

import '../endpoints.dart';
import '../models/building_model.dart';

class BuildingApi {
  final DioSystemClient dioClient;

  BuildingApi({required this.dioClient});

  Future<Response> getBuildingsById(String buildingId) async {
    try {
      final response =
          await dioClient.get("${Endpoints.buildings}/$buildingId");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateBuilding(
      String buildingId, BuildingModel model) async {
    try {
      final response = await dioClient.put("${Endpoints.buildings}/$buildingId",
          data: model.toUpdateJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createBuilding(
      String tenantId, AddBuildingRequest model) async {
    try {
      final response = await dioClient.post("${Endpoints.buildings}/$tenantId",
          data: model.toJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteBuilding(String buildingId) async {
    try {
      final response =
          await dioClient.delete("${Endpoints.buildings}/$buildingId");
      if (response.statusCode == 204) {
        response.data = "Deleted";
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
