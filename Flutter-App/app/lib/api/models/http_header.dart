import 'package:ssds_app/api/models/http_notification.dart';

import 'base_entity_model.dart';

class HttpHeader extends BaseEntity {
  String? httpNotificationId;
  HttpNotificationModel? httpNotification;
  String? key;
  String? value;

  HttpHeader({
    super.id,
    super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
    this.httpNotificationId,
    this.httpNotification,
    this.key,
    this.value,
  });

  HttpHeader.fromJson(Map<String, dynamic> json) {
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    httpNotificationId = json['httpNotificationId'];
    httpNotification = json['httpNotification'] != null
        ? HttpNotificationModel.fromJson(json['httpNotification'])
        : null;
    key = json['key'];
    value = json['value'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['value'] = value;
    return data;
  }
}
