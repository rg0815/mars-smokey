import 'package:dio/dio.dart';
import 'package:ssds_app/api/models/room_model.dart';

import '../dio_system_client.dart';
import '../endpoints.dart';

class RoomApi {
  final DioSystemClient dioClient;

  RoomApi({required this.dioClient});

  Future<Response> createRoom(String buildingUnitId, RoomModel model) async {
    try {
      final response = await dioClient.post(
          "${Endpoints.rooms}/$buildingUnitId",
          data: model.toCreateJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getRoomById(String roomId) async {
    try {
      final response = await dioClient.get("${Endpoints.rooms}/$roomId");
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
