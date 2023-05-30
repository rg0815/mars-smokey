import 'package:dio/dio.dart';
import 'package:ssds_app/api/models/room_model.dart';

import '../dio_exception.dart';
import '../models/responses/response_model.dart';
import '../raw/room_api.dart';

class RoomRepository {
  final RoomApi roomApi;

  RoomRepository(this.roomApi);


  Future<ResponseModel> createRoom(String buildingUnitId, RoomModel model) async {
    var responseModel = ResponseModel();

    try {
      final response = await roomApi.createRoom(buildingUnitId, model);

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

  Future<ResponseModel> getRoomById(String roomId) async {
    var responseModel = ResponseModel();

    try {
      final response = await roomApi.getRoomById(roomId);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = RoomModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }


}