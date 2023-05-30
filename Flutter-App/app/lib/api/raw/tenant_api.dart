import 'package:dio/dio.dart';
import 'package:ssds_app/api/models/tenant_model.dart';

import '../dio_system_client.dart';
import '../endpoints.dart';

class TenantApi {
  final DioSystemClient dioClient;

  TenantApi({required this.dioClient});

  Future<Response> createTenant(TenantModel model) async {
    try {
      final response =
          await dioClient.post(Endpoints.tenants, data: model.toCreateJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getTenants() async {
    try {
      final response = await dioClient.get(Endpoints.tenants);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getTenantById(String id) async {
    try {
      final response = await dioClient.get(Endpoints.tenants + "/" + id);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateTenant(String tenantId, TenantModel model) async {
    try {
      final response = await dioClient.put("${Endpoints.tenants}/$tenantId",
          data: model.toCreateJson());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteTenant(String id) async {
    try {
      final response = await dioClient.delete(Endpoints.tenants + "/" + id);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
