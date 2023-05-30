import 'package:dio/dio.dart';
import 'package:ssds_app/api/models/requests/register_model.dart';

import '../dio_user_client.dart';
import '../endpoints.dart';

class InitApi {
  final DioUserClient dioClient;

  InitApi({required this.dioClient});

  Future<Response> initialize(RegisterModel model) async {
    try {
      final response =
          await dioClient.post(Endpoints.init, data: model.toJsonAdmin());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> isInitialized() async {
    try {
      final response = await dioClient.get(Endpoints.init);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
