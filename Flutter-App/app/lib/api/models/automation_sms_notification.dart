import 'package:ssds_app/api/models/sms_notification.dart';

import 'automation_setting.dart';
import 'notification_setting_model.dart';

class AutomationSmsNotification extends SmsNotification{
  String? text;

  AutomationSmsNotification({super.id,
    super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
    super.phoneNumber,
    super.automationSetting,
    super.notificationSetting,
    super.notificationSettingId,
    super.automationSettingId,
    this.text});

  AutomationSmsNotification.fromJson(Map<String, dynamic> json){
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    super.phoneNumber = json['phoneNumber'];
    super.notificationSettingId = json['notificationSettingId'];
    super.notificationSetting = json['notificationSetting'] != null ? NotificationSettingModel.fromJson(json['notificationSetting']) : null;
    super.automationSettingId = json['automationSettingId'];
    super.automationSetting = json['automationSetting'] != null ? AutomationSetting.fromJson(json['automationSetting']) : null;
    text = json['text'];
  }

  @override
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['description'] = super.description;
    data['createdDate'] = super.createdAt;
    data['updatedDate'] = super.updatedAt;
    data['phoneNumber'] = super.phoneNumber;
    data['notificationSettingId'] = super.notificationSettingId;
    data['notificationSetting'] = super.notificationSetting != null ? super.notificationSetting!.toJson() : null;
    data['automationSettingId'] = super.automationSettingId;
    data['automationSetting'] = super.automationSetting != null ? super.automationSetting!.toJson() : null;
    data['text'] = text;
    return data;
  }


}