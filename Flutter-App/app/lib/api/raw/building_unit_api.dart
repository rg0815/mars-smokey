import 'package:dio/dio.dart';
import 'package:ssds_app/api/models/building_unit_model.dart';

import '../dio_system_client.dart';
import '../endpoints.dart';

class BuildingUnitApi{
  final DioSystemClient dioClient;

  BuildingUnitApi({required this.dioClient});

  Future<Response> createBuildingUnit(String buildingId, BuildingUnitModel model) async {
    try {
      final response = await dioClient.post("${Endpoints.buildingUnits}/$buildingId", data: model.toCreateJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getBuildingUnitById(String buildingUnitId) async {
    try {
      final response = await dioClient.get("${Endpoints.buildingUnits}/$buildingUnitId");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getBuildingUnitsByTenant(String tenantId) async {
    try {
      final response = await dioClient.get("${Endpoints.buildingUnits}/tenant/$tenantId");
      return response;
    } catch (e) {
      rethrow;
    }
  }

}