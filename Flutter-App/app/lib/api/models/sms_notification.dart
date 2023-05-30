import 'package:ssds_app/api/models/automation_setting.dart';
import 'package:ssds_app/api/models/base_entity_model.dart';
import 'package:ssds_app/api/models/notification_setting_model.dart';

class SmsNotification extends BaseEntity{
  String? phoneNumber;
  String? notificationSettingId;
  NotificationSettingModel? notificationSetting;
  String? automationSettingId;
  AutomationSetting? automationSetting;

  SmsNotification({super.id,
    super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
    this.phoneNumber,
    this.notificationSettingId,
    this.notificationSetting,
    this.automationSettingId,
    this.automationSetting});

  SmsNotification.fromJson(Map<String, dynamic> json){
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    phoneNumber = json['phoneNumber'];
    notificationSettingId = json['notificationSettingId'];
    notificationSetting = json['notificationSetting'] != null ? NotificationSettingModel.fromJson(json['notificationSetting']) : null;
    automationSettingId = json['automationSettingId'];
    automationSetting = json['automationSetting'] != null ? AutomationSetting.fromJson(json['automationSetting']) : null;
  }

  @override
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['phoneNumber'] = phoneNumber;
    // data['notificationSettingId'] = notificationSettingId;
    // data['notificationSetting'] = notificationSetting != null ? notificationSetting!.toJson() : null;
    // data['automationSettingId'] = automationSettingId;
    // data['automationSetting'] = automationSetting != null ? automationSetting!.toJson() : null;
    return data;
  }
}