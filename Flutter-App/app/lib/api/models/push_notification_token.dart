
import 'package:ssds_app/api/models/notification_setting_model.dart';

import 'base_entity_model.dart';

class PushNotificationTokenModel extends BaseEntity {
  String? notificationSettingId;
  NotificationSettingModel? notificationSetting;
  String? token;

  PushNotificationTokenModel({
    super.id,
    super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
    this.notificationSettingId,
    this.notificationSetting,
    this.token,
  });

  PushNotificationTokenModel.fromJson(Map<String, dynamic> json) {
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    notificationSettingId = json['notificationSettingId'];
    notificationSetting = json['notificationSetting'] != null
        ? NotificationSettingModel.fromJson(json['notificationSetting'])
        : null;
    token = json['token'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['notificationSettingId'] = notificationSettingId;
    // data['notificationSetting'] = notificationSetting?.toJson();
    data['token'] = token;
    return data;
  }
}