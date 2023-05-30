import 'package:ssds_app/api/models/base_entity_model.dart';
import 'package:ssds_app/api/models/email_notification.dart';
import 'package:ssds_app/api/models/phone_call_notification.dart';
import 'package:ssds_app/api/models/sms_notification.dart';

import 'http_notification.dart';
import 'push_notification_token.dart';

class NotificationSettingModel extends BaseEntity {
  String? userId;
  bool? emailNotification;
  bool? smsNotification;
  bool? phoneCallNotification;
  bool? pushNotification;
  bool? httpNotification;
  UserEmailNotification? email;
  PhoneCallNotification? phoneNumber;
  SmsNotification? smsNumber;
  List<PushNotificationTokenModel>? pushNotificationTokens;
  List<HttpNotificationModel>? httpNotifications;

  NotificationSettingModel({
    super.id,
    super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
    this.userId,
    this.emailNotification,
    this.smsNotification,
    this.phoneCallNotification,
    this.pushNotification,
    this.httpNotification,
    this.email,
    this.phoneNumber,
    this.smsNumber,
    this.pushNotificationTokens,
    this.httpNotifications,
  });

  NotificationSettingModel.fromJson(Map<String, dynamic> json) {
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    userId = json['userId'];
    emailNotification = json['emailNotification'];
    smsNotification = json['smsNotification'];
    phoneCallNotification = json['phoneCallNotification'];
    pushNotification = json['pushNotification'];
    httpNotification = json['httpNotification'];
    email = json['email'] != null
        ? UserEmailNotification.fromJson(json['email'])
        : null;
    phoneNumber = json['phoneNumber'] != null
        ? PhoneCallNotification.fromJson(json['phoneNumber'])
        : null;
    smsNumber = json['smsNumber'] != null
        ? SmsNotification.fromJson(json['smsNumber'])
        : null;
    if (json['pushNotificationTokens'] != null) {
      pushNotificationTokens = <PushNotificationTokenModel>[];
      json['pushNotificationTokens'].forEach((v) {
        pushNotificationTokens?.add(PushNotificationTokenModel.fromJson(v));
      });
    }
    if (json['httpNotifications'] != null) {
      httpNotifications = <HttpNotificationModel>[];
      json['httpNotifications'].forEach((v) {
        httpNotifications?.add(HttpNotificationModel.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['description'] = super.description;
    data['createdAt'] = super.createdAt;
    data['updatedAt'] = super.updatedAt;
    data['userId'] = userId;
    data['emailNotification'] = emailNotification;
    data['smsNotification'] = smsNotification;
    data['phoneCallNotification'] = phoneCallNotification;
    data['pushNotification'] = pushNotification;
    data['httpNotification'] = httpNotification;
    data['email'] = email?.toJson();
    data['phoneNumber'] = phoneNumber?.toJson();
    data['smsNumber'] = smsNumber?.toJson();
    if (pushNotificationTokens != null) {
      data['pushNotificationTokens'] =
          pushNotificationTokens?.map((v) => v.toJson()).toList();
    }
    if (httpNotifications != null) {
      data['httpNotifications'] =
          httpNotifications?.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Map<String, dynamic> toCreateJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['emailNotification'] = emailNotification;
    data['smsNotification'] = smsNotification;
    data['phoneCallNotification'] = phoneCallNotification;
    data['pushNotification'] = pushNotification;
    data['httpNotification'] = httpNotification;
    data['email'] = email!.email;
    data['phoneNumber'] = phoneNumber!.phoneNumber;
    data['smsNumber'] = smsNumber!.phoneNumber;
    if (pushNotificationTokens != null) {
      data['pushNotificationTokens'] =
          pushNotificationTokens?.map((v) => v.token).toList();
    }
    if (httpNotifications != null) {
      data['httpNotifications'] =
          httpNotifications?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
