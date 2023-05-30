import 'package:ssds_app/api/models/http_header.dart';
import 'package:ssds_app/api/models/notification_setting_model.dart';

import 'automation_setting.dart';
import 'base_entity_model.dart';

class HttpNotificationModel extends BaseEntity {
  String? notificationSettingId;
  NotificationSettingModel? notificationSetting;

  String? automationSettingId;
  AutomationSetting? automationSetting;

  String? url;
  String? method;
  String? body;
  List<HttpHeader>? headers;

  HttpNotificationModel({
    super.id,
    super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
    this.notificationSettingId,
    this.notificationSetting,
    this.automationSettingId,
    this.automationSetting,
    this.url,
    this.method,
    this.body,
    this.headers,
  });

  HttpNotificationModel.fromJson(Map<String, dynamic> json) {
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    notificationSettingId = json['notificationSettingId'];
    notificationSetting = json['notificationSetting'] != null
        ? NotificationSettingModel.fromJson(json['notificationSetting'])
        : null;
    automationSettingId = json['automationSettingId'];
    automationSetting = json['automationSetting'] != null
        ? AutomationSetting.fromJson(json['automationSetting'])
        : null;
    url = json['url'];
    method = json['method'];
    body = json['body'];
    if (json['headers'] != null) {
      headers = <HttpHeader>[];
      json['headers'].forEach((v) {
        headers?.add(HttpHeader.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['method'] = method;
    data['body'] = body;
    if (headers != null) {
      data['headers'] = headers?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
