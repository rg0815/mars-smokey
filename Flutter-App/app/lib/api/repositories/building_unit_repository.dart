import 'package:dio/dio.dart';

import '../dio_exception.dart';
import '../models/building_unit_model.dart';
import '../models/responses/response_model.dart';
import '../raw/building_unit_api.dart';

class BuildingUnitRepository {
  final BuildingUnitApi buildingUnitApi;

  BuildingUnitRepository(this.buildingUnitApi);

  Future<ResponseModel> getBuildingUnitsByTenant(String tenantId) async {
    var responseModel = ResponseModel();

    try {
      final response = await buildingUnitApi.getBuildingUnitsByTenant(tenantId);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;

      var data = response.data as List;
      if (data.isEmpty) {
        responseModel.data = <BuildingUnitModel>[];
      } else {
        responseModel.data = List<BuildingUnitModel>.from(
            data.map((e) => BuildingUnitModel.fromJson(e)));
      }

      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> createBuildingUnit(
      String buildingId, BuildingUnitModel model) async {
    var responseModel = ResponseModel();

    try {
      final response =
          await buildingUnitApi.createBuildingUnit(buildingId, model);

      if (response.statusCode != 201) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = response.data;
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> getBuildingUnitById(String buildingUnitId) async {
    var responseModel = ResponseModel();

    try {
      final response =
          await buildingUnitApi.getBuildingUnitById(buildingUnitId);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = BuildingUnitModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }
}
