import 'package:dio/dio.dart';
import 'package:ssds_app/api/controller.dart';
import 'package:ssds_app/api/raw/building_api.dart';
import 'package:ssds_app/api/raw/fire_alarm_api.dart';
import 'package:ssds_app/api/raw/gateway_api.dart';
import 'package:ssds_app/api/raw/init_api.dart';
import 'package:ssds_app/api/raw/notification_api.dart';
import 'package:ssds_app/api/raw/tenant_api.dart';
import 'package:ssds_app/api/raw/user_api.dart';
import 'package:ssds_app/api/dio_user_client.dart';
import 'package:ssds_app/api/repositories/building_repository.dart';
import 'package:ssds_app/api/repositories/tenant_repository.dart';
import 'package:ssds_app/api/repositories/user_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:ssds_app/services/navigator_service.dart';

import '../api/dio_system_client.dart';
import '../api/raw/address_api.dart';
import '../api/raw/auth_api.dart';
import '../api/raw/building_unit_api.dart';
import '../api/raw/room_api.dart';
import '../api/raw/smoke_detector_api.dart';
import '../api/repositories/address_repository.dart';
import '../api/repositories/auth_repository.dart';
import '../api/repositories/building_unit_repository.dart';
import '../api/repositories/fire_alarm_repository.dart';
import '../api/repositories/gateway_repository.dart';
import '../api/repositories/init_repository.dart';
import '../api/repositories/notification_repository.dart';
import '../api/repositories/room_repository.dart';
import '../api/repositories/smoke_detector_repository.dart';

GetIt locator = GetIt.instance;

Future<void> setup() async {
  locator.registerLazySingleton(() => NavigationService());

  locator.registerSingleton(Dio(), instanceName: "userDioClient");
  locator.registerSingleton(Dio(), instanceName: "systemDioClient");
  locator.registerSingleton(
      DioUserClient(locator.get(instanceName: "userDioClient")));
  locator.registerSingleton(
      DioSystemClient(locator.get(instanceName: "systemDioClient")));

  locator.registerSingleton(AuthApi(dioClient: locator<DioUserClient>()));
  locator.registerSingleton(AuthRepository(locator.get<AuthApi>()));

  locator.registerSingleton(UserApi(dioClient: locator<DioUserClient>()));
  locator.registerSingleton(UserRepository(locator.get<UserApi>()));

  locator.registerSingleton(InitApi(dioClient: locator<DioUserClient>()));
  locator.registerSingleton(InitRepository(locator.get<InitApi>()));

  locator.registerSingleton(TenantApi(dioClient: locator<DioSystemClient>()));
  locator.registerSingleton(TenantRepository(locator.get<TenantApi>()));

  locator.registerSingleton(BuildingApi(dioClient: locator<DioSystemClient>()));
  locator.registerSingleton(BuildingRepository(locator.get<BuildingApi>()));

  locator.registerSingleton(
      BuildingUnitApi(dioClient: locator<DioSystemClient>()));
  locator.registerSingleton(
      BuildingUnitRepository(locator.get<BuildingUnitApi>()));

  locator.registerSingleton(AddressApi(dioClient: locator<DioSystemClient>()));
  locator.registerSingleton(AddressRepository(locator.get<AddressApi>()));

  locator.registerSingleton(RoomApi(dioClient: locator<DioSystemClient>()));
  locator.registerSingleton(RoomRepository(locator.get<RoomApi>()));

  locator.registerSingleton(GatewayApi(dioClient: locator<DioSystemClient>()));
  locator.registerSingleton(GatewayRepository(locator.get<GatewayApi>()));

  locator.registerSingleton(
      SmokeDetectorApi(dioClient: locator<DioSystemClient>()));
  locator.registerSingleton(SmokeDetectorRepository(
      smokeDetectorApi: locator.get<SmokeDetectorApi>()));

  locator.registerSingleton(NotificationApi(dioClient: locator<DioSystemClient>()));
  locator.registerSingleton(NotificationRepository(locator.get<NotificationApi>()));

  locator.registerSingleton(FireAlarmApi(dioClient: locator<DioSystemClient>()));
  locator.registerSingleton(FireAlarmRepository(locator.get<FireAlarmApi>()));
}
