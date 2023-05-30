import 'package:dio/dio.dart';
import 'package:ssds_app/api/models/building_model.dart';
import 'package:ssds_app/api/models/requests/add_building_request.dart';

import '../dio_exception.dart';
import '../models/responses/response_model.dart';
import '../raw/building_api.dart';

class BuildingRepository {
  final BuildingApi buildingApi;

  BuildingRepository(this.buildingApi);

  Future<ResponseModel> createBuilding(String tenantId, AddBuildingRequest model) async {
    var responseModel = ResponseModel();

    try {
      final response = await buildingApi.createBuilding(tenantId, model);

      if (response.statusCode != 201) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = BuildingModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> getBuildingById(String buildingId) async {
    var responseModel = ResponseModel();

    try {
      final response = await buildingApi.getBuildingsById(buildingId);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = BuildingModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> updateBuilding(String buildingId, BuildingModel model) async {
    var responseModel = ResponseModel();

    try {
      final response = await buildingApi.updateBuilding(buildingId, model);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = BuildingModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> deleteBuilding(String buildingId) async {
    var responseModel = ResponseModel();

    try {
      final response = await buildingApi.deleteBuilding(buildingId);

      if (response.statusCode != 204) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }
      responseModel.data = "Deleted";
      responseModel.success = true;
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

}
