class Endpoints {
  Endpoints._();

  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration connectionTimeout = Duration(seconds: 10);

  static const baseUserPath = '/api/user';

  //Init
  static const String init = '$baseUserPath/initialize';

  // Auth
  static const String auth = '$baseUserPath/auth';
  static const String authRefresh = '$auth/refresh';
  static const String authRevoke = '$auth/revoke/{mail}';
  static const String authRevokeAll = '$auth/revoke-all';

  // Invitations
  static const String invitation = '$baseUserPath/invitation';

  // Passwords
  static const String _password = '$baseUserPath/password';
  static const String passwordReset = '$_password/reset';
  static const String passwordResetRequest = '$_password/request-reset';
  static const String changePassword = '$_password/change';

  // Users
  static const String users = baseUserPath;
  static const String registerUser =
      '$baseUserPath/register/{registrationToken}';
  static const String registerTenantAdmin =
      '$baseUserPath/register/tenant-admin';
  static const String userMe = '$baseUserPath/me';
  static const String tenantAdmin = '$baseUserPath/tenant-admin';
  static const String getTenantUsers = '$baseUserPath/tenant-users';

  // ------------------ System ------------------

  // Tenants
  static const String tenants = '/api/tenant';

  // Buildings
  static const String buildings = '/api/building';

  // BuildingUnits
  static const String buildingUnits = '/api/buildingUnit';

  // Address
  static const String address = '/api/address';

  // Rooms
  static const String rooms = '/api/room';

  // Gateways
  static const String gateways = '/api/gateway';

  // Smoke Detectors
  static const String smokeDetectors = '/api/smokeDetector';
  static const String smokeDetectorModels = '$smokeDetectors/models';
  static const String startPairingSmokeDetector = '$smokeDetectors/pairing/start';
  static const String stopPairingSmokeDetector = '$smokeDetectors/pairing/stop';
  static const String testAlarm = '$smokeDetectors/alarm/test';
  static const String stopTestAlarm = '$smokeDetectors/alarm/stop-test';
  static const String addMaintenance = '$smokeDetectors/maintenance';

  // Notification Settings
  static const String notificationSettings = '/api/NotificationSetting';

  // Fire Alarm
  static const String fireAlarm = '/api/FireAlarm';
  static const String checkFirealarm = '$fireAlarm/check';
  static const String stopFireAlarm = '$fireAlarm/stop';

}
