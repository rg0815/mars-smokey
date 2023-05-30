import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import '../dio_exception.dart';
import '../error_details.dart';
import '../models/responses/response_model.dart';
import '../models/tenant_model.dart';
import '../raw/tenant_api.dart';

class TenantRepository {
  final TenantApi tenantApi;

  TenantRepository(this.tenantApi);

  Future<ResponseModel> createTenant(TenantModel model) async {
    var responseModel = ResponseModel();

    try {
      final response = await tenantApi.createTenant(model);


      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = TenantModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      var errorDetails = ErrorDetails.fromJson(e.response!.data);

      if (e.response!.statusCode == 400 &&
          errorDetails.errorCode == ErrorType.TenantAlreadyExists) {
        responseModel.errorMessage =
            "Es existiert bereits ein Mandant mit diesem Namen.";
        return responseModel;
      }

      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> getTenants() async {
    var responseModel = ResponseModel();

    try {
      final response = await tenantApi.getTenants();

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;

      var data = response.data as List;
      if (data.isEmpty) {
        responseModel.data = [];
      } else {
        responseModel.data =
            List<TenantModel>.from(data.map((e) => TenantModel.fromJson(e)));
      }
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> getTenantById(String id) async {
    var responseModel = ResponseModel();

    try {
      final response = await tenantApi.getTenantById(id);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = TenantModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> updateTenant(String tenantId, TenantModel model) async {
    var responseModel = ResponseModel();

    try {
      final response = await tenantApi.updateTenant(tenantId, model);

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = TenantModel.fromJson(response.data);
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;
      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      return responseModel;
    }
  }

  Future<ResponseModel> deleteTenant(String id) async {
    var responseModel = ResponseModel();

    try {
      final response = await tenantApi.deleteTenant(id);

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
