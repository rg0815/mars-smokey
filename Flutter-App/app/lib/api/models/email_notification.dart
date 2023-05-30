import 'package:ssds_app/api/models/automation_setting.dart';
import 'package:ssds_app/api/models/base_entity_model.dart';
import 'package:ssds_app/api/models/notification_setting_model.dart';

class EmailNotification extends BaseEntity{
  String? email;

  EmailNotification({super.id,
    super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
    this.email});

  EmailNotification.fromJson(Map<String, dynamic> json){
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    email = json['email'];
  }

  @override
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['description'] = super.description;
    data['createdDate'] = super.createdAt;
    data['updatedDate'] = super.updatedAt;
    data['email'] = email;
    return data;
  }
}

class UserEmailNotification extends EmailNotification{
  String? notificationSettingId;
  NotificationSettingModel? notificationSetting;

  UserEmailNotification({super.id,
    super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
    super.email,
    this.notificationSettingId,
    this.notificationSetting});

  UserEmailNotification.fromJson(Map<String, dynamic> json){
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    super.email = json['email'];
    notificationSettingId = json['notificationSettingId'];
    notificationSetting = json['notificationSetting'] != null
        ? NotificationSettingModel.fromJson(json['notificationSetting'])
        : null;
  }

  @override
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['description'] = super.description;
    data['createdDate'] = super.createdAt;
    data['updatedDate'] = super.updatedAt;
    data['email'] = super.email;
    data['notificationSettingId'] = notificationSettingId;
    data['notificationSetting'] = notificationSetting?.toJson();
    return data;
  }
}

class AutomationEmailNotification extends EmailNotification{
  String? automationSettingId;
  AutomationSetting? automationSetting;
  String? subject;
  String? text;

  AutomationEmailNotification({super.id,
    super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
    super.email,
    this.automationSettingId,
    this.automationSetting,
    this.subject,
    this.text});

  AutomationEmailNotification.fromJson(Map<String, dynamic> json){
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    super.email = json['email'];
    automationSettingId = json['automationSettingId'];
    automationSetting = json['automationSetting'] != null
        ? AutomationSetting.fromJson(json['automationSetting'])
        : null;
    subject = json['subject'];
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
    data['email'] = super.email;
    data['automationSettingId'] = automationSettingId;
    data['automationSetting'] = automationSetting?.toJson();
    data['subject'] = subject;
    data['text'] = text;
    return data;
  }
}