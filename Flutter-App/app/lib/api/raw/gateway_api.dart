import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ssds_app/api/dio_system_client.dart';
import 'package:ssds_app/api/models/gateway_model.dart';

import '../endpoints.dart';

class GatewayApi {
  final DioSystemClient dioClient;

  GatewayApi({required this.dioClient});

  Future<Response> getGateways(String id, bool isBuildingUnitRequest) async {
    try {
      Response<dynamic> response;
      if (isBuildingUnitRequest) {
        response =
            await dioClient.get("${Endpoints.gateways}/buildingUnit/$id");
      } else {
        response = await dioClient.get("${Endpoints.gateways}/tenant/$id");
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getGatewayById(String gatewayId) async {
    try {
      final response = await dioClient.get("${Endpoints.gateways}/$gatewayId");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getGatewayByClientId(String clientId) async {
    try {
      final response =
          await dioClient.get("${Endpoints.gateways}/client/$clientId");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Future<Response> createGateway(String roomId, GatewayModel model) async {
  //   try {
  //     final response = await dioClient.post("${Endpoints.gateways}/$roomId",
  //         data: model.toCreateJson());
  //     return response;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<Response> deleteGateway(String gatewayId) async {
    try {
      final response =
          await dioClient.delete("${Endpoints.gateways}/$gatewayId");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateGateway(String gatewayId, GatewayModel model) async {
    try {
      final response = await dioClient.put("${Endpoints.gateways}/$gatewayId",
          data: model.toUpdateJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateGatewayByClientId(
      String clientId, GatewayModel model) async {
    try {
      final response = await dioClient.put(
          "${Endpoints.gateways}/client/$clientId",
          data: model.toUpdateJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> startPairing() async {
    try {
      final response =
          await dioClient.get("${Endpoints.gateways}/startPairing");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> stopPairing() async {
    try {
      final response = await dioClient.get("${Endpoints.gateways}/stopPairing");
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
