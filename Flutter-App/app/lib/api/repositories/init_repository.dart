import 'package:dio/dio.dart';

import '../../log_helper.dart';
import '../dio_exception.dart';
import '../models/requests/register_model.dart';
import '../models/responses/response_model.dart';
import '../raw/init_api.dart';

class InitRepository {
  final InitApi initApi;
  final logger = getLogger();

  InitRepository(this.initApi);

  Future<ResponseModel> initialize(RegisterModel model) async {
    var responseModel = ResponseModel();

    try {
      final response = await initApi.initialize(model);

      if (response.statusCode != 200) {
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
      logger.e(responseModel.errorMessage);
      return responseModel;
    }
  }

  Future<ResponseModel> isInitialized() async {
    var responseModel = ResponseModel();

    try {
      final response = await initApi.isInitialized();

      if (response.statusCode != 200) {
        responseModel.success = false;
        responseModel.errorMessage = response.statusMessage;
        return responseModel;
      }

      responseModel.success = true;
      responseModel.data = response.data;
      return responseModel;
    } on DioError catch (e) {
      responseModel.success = false;

      if(e.response?.statusCode == 400){
        responseModel.errorMessage = "Die App wurde noch nicht initialisiert";
        return responseModel;
      }

      responseModel.errorMessage = DioExceptions.fromDioError(e).toString();
      logger.e(responseModel.errorMessage);
      return responseModel;
    }
  }
}
