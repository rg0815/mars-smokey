import 'package:ssds_app/api/models/base_entity_model.dart';
import 'package:ssds_app/api/models/http_notification.dart';
import 'package:ssds_app/api/models/phone_call_notification.dart';

import 'automation_sms_notification.dart';
import 'building_unit_model.dart';
import 'email_notification.dart';

class AutomationSetting extends BaseEntity {
  String? buildingUnitId;
  BuildingUnitModel? buildingUnit;
  List<HttpNotificationModel>? httpNotifications;
  List<AutomationEmailNotification>? emailNotifications;
  List<AutomationSmsNotification>? smsNotifications;
  List<PhoneCallNotification>? phoneCallNotifications;

  AutomationSetting(
      {super.id,
      super.name,
      super.description,
      super.createdAt,
      super.updatedAt,
      this.buildingUnitId,
      this.buildingUnit,
      this.httpNotifications,
      this.emailNotifications,
      this.smsNotifications,
      this.phoneCallNotifications});

  AutomationSetting.fromJson(Map<String, dynamic> json) {
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    buildingUnitId = json['buildingUnitId'];
    buildingUnit = json['buildingUnit'] != null
        ? BuildingUnitModel.fromJson(json['buildingUnit'])
        : null;
    if (json['httpNotifications'] != null) {
      httpNotifications = <HttpNotificationModel>[];
      json['httpNotifications'].forEach((dynamic v) {
        httpNotifications?.add(HttpNotificationModel.fromJson(v));
      });
    }
    if (json['emailNotifications'] != null) {
      emailNotifications = <AutomationEmailNotification>[];
      json['emailNotifications'].forEach((dynamic v) {
        emailNotifications?.add(AutomationEmailNotification.fromJson(v));
      });
    }
    if (json['smsNotifications'] != null) {
      smsNotifications = <AutomationSmsNotification>[];
      json['smsNotifications'].forEach((dynamic v) {
        smsNotifications?.add(AutomationSmsNotification.fromJson(v));
      });
    }
    if (json['phoneCallNotifications'] != null) {
      phoneCallNotifications = <PhoneCallNotification>[];
      json['phoneCallNotifications'].forEach((dynamic v) {
        phoneCallNotifications?.add(PhoneCallNotification.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['description'] = super.description;
    data['createdDate'] = super.createdAt;
    data['updatedDate'] = super.updatedAt;
    data['buildingUnitId'] = buildingUnitId;
    data['buildingUnit'] = buildingUnit?.toJson();
    data['httpNotifications'] =
        httpNotifications?.map((v) => v.toJson()).toList();
    data['emailNotifications'] =
        emailNotifications?.map((v) => v.toJson()).toList();
    data['smsNotifications'] =
        smsNotifications?.map((v) => v.toJson()).toList();
    data['phoneCallNotifications'] =
        phoneCallNotifications?.map((v) => v.toJson()).toList();
    return data;
  }
}

class PreAlarmAutomationSetting extends BaseEntity {
  String? buildingUnitId;
  BuildingUnitModel? buildingUnit;
  List<HttpNotificationModel>? httpNotifications;
  List<AutomationEmailNotification>? emailNotifications;
  List<AutomationSmsNotification>? smsNotifications;
  List<PhoneCallNotification>? phoneCallNotifications;

  PreAlarmAutomationSetting(
      {super.id,
      super.name,
      super.description,
      super.createdAt,
      super.updatedAt,
      this.buildingUnitId,
      this.buildingUnit,
      this.httpNotifications,
      this.emailNotifications,
      this.smsNotifications,
      this.phoneCallNotifications});

  PreAlarmAutomationSetting.fromJson(Map<String, dynamic> json) {
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    buildingUnitId = json['buildingUnitId'];
    buildingUnit = json['buildingUnit'] != null
        ? BuildingUnitModel.fromJson(json['buildingUnit'])
        : null;
    if (json['httpNotifications'] != null) {
      httpNotifications = <HttpNotificationModel>[];
      json['httpNotifications'].forEach((dynamic v) {
        httpNotifications?.add(HttpNotificationModel.fromJson(v));
      });
    }
    if (json['emailNotifications'] != null) {
      emailNotifications = <AutomationEmailNotification>[];
      json['emailNotifications'].forEach((dynamic v) {
        emailNotifications?.add(AutomationEmailNotification.fromJson(v));
      });
    }
    if (json['smsNotifications'] != null) {
      smsNotifications = <AutomationSmsNotification>[];
      json['smsNotifications'].forEach((dynamic v) {
        smsNotifications?.add(AutomationSmsNotification.fromJson(v));
      });
    }
    if (json['phoneCallNotifications'] != null) {
      phoneCallNotifications = <PhoneCallNotification>[];
      json['phoneCallNotifications'].forEach((dynamic v) {
        phoneCallNotifications?.add(PhoneCallNotification.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['description'] = super.description;
    data['createdDate'] = super.createdAt;
    data['updatedDate'] = super.updatedAt;
    data['buildingUnitId'] = buildingUnitId;
    data['buildingUnit'] = buildingUnit?.toJson();
    data['httpNotifications'] =
        httpNotifications?.map((v) => v.toJson()).toList();
    data['emailNotifications'] =
        emailNotifications?.map((v) => v.toJson()).toList();
    data['smsNotifications'] =
        smsNotifications?.map((v) => v.toJson()).toList();
    data['phoneCallNotifications'] =
        phoneCallNotifications?.map((v) => v.toJson()).toList();
    return data;
  }
}
