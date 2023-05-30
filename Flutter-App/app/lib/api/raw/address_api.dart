import 'package:dio/dio.dart';
import 'package:ssds_app/api/dio_system_client.dart';

import '../endpoints.dart';
import '../models/address_model.dart';

class AddressApi{
  final DioSystemClient dioClient;

  AddressApi({required this.dioClient});

  Future<Response> updateAddress(String id, AddressModel model) async {
    try {
      if(model.name == null || model.name!.isEmpty) {
        model.name = model.street;
      }
      if(model.description == null || model.description!.isEmpty) {
        model.description = "${model.zipCode} ${model.city}";
      }


      final response = await dioClient.put("${Endpoints.address}/$id",
          data: model.toJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }
}