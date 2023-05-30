import 'package:dio/dio.dart';

import '../dio_exception.dart';
import '../models/address_model.dart';
import '../models/responses/response_model.dart';
import '../raw/address_api.dart';

class AddressRepository {
  final AddressApi addressApi;

  AddressRepository(this.addressApi);

  Future<ResponseModel> updateAddress(String id, AddressModel model) async {
    var responseModel = ResponseModel();

    try {
      final response = await addressApi.updateAddress(id, model);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = AddressModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }
}