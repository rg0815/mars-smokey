import 'package:dio/dio.dart';
import 'package:ssds_app/api/models/gateway_model.dart';

import '../dio_exception.dart';
import '../models/responses/response_model.dart';
import '../raw/gateway_api.dart';

class GatewayRepository {
  final GatewayApi gatewayApi;

  GatewayRepository(this.gatewayApi);

  Future<ResponseModel> getGateways(String id, bool isBuildingUnitRequest) async {
    var responseModel = ResponseModel();

    try {
      final response = await gatewayApi.getGateways(id, isBuildingUnitRequest);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
   responseModel.data = <GatewayModel>[];
   responseModel.data = List<GatewayModel>.from(response.data.map((x) => GatewayModel.fromJson(x)));



      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> getGatewayById(String gatewayId) async {
    var responseModel = ResponseModel();

    try {
      final response = await gatewayApi.getGatewayById(gatewayId);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = GatewayModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }


  Future<ResponseModel> getGatewayByClientId(String clientId) async {
    var responseModel = ResponseModel();

    try {
      final response = await gatewayApi.getGatewayByClientId(clientId);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = GatewayModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;

      if(e.response?.statusCode == 404){
        responseModel.errorMessage = "Das Gateway wurde nicht gefunden.";
        return responseModel;
      }

      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }
  // Future<ResponseModel> createGateway(String roomId, GatewayModel model) async {
  //   var responseModel = ResponseModel();
  //
  //   try {
  //     final response = await gatewayApi.createGateway(roomId, model);
  //
  //     if (response.statusCode != 201) {
  //       responseModel.success = false;
  //       responseModel.errorMessage = response.statusMessage;
  //       return responseModel;
  //     }
  //
  //     responseModel.success = true;
  //     responseModel.data = GatewayModel.fromJson(response.data);
  //     return responseModel;
  //   } on DioError catch (e) {
  //     responseModel.success = false;
  //     responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
  //     return responseModel;
  //   }
  // }

  Future<ResponseModel> updateGateway(
      String gatewayId, GatewayModel model) async {
    var responseModel = ResponseModel();

    try {
      final response = await gatewayApi.updateGateway(gatewayId, model);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = GatewayModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> updateGatewayByClientId(
      String clientId, GatewayModel model) async {
    var responseModel = ResponseModel();

    try {
      final response = await gatewayApi.updateGatewayByClientId(clientId, model);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = GatewayModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> deleteGateway(String gatewayId) async {
    var responseModel = ResponseModel();

    try {
      final response = await gatewayApi.deleteGateway(gatewayId);

      if (response.statusCode != 204) {
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

  Future<ResponseModel> startPairing() async {
    var responseModel = ResponseModel();

    try {
      final response = await gatewayApi.startPairing();

      if (response.statusCode != 204) {
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

  Future<ResponseModel> stopPairing() async {
    var responseModel = ResponseModel();

    try {
      final response = await gatewayApi.stopPairing();

      if (response.statusCode != 204) {
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
}
