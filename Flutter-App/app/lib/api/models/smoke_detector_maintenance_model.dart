import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ssds_app/api/models/base_entity_model.dart';
import 'package:ssds_app/api/models/smoke_detector_model.dart';

class SmokeDetectorMaintenanceModel extends BaseEntity {
  DateTime? time;
  bool? isDustCleaned;
  bool? isCleaned;
  bool? isTested;
  bool? isBatteryReplaced;
  String? comment;
  String? userId;
  String? smokeDetectorId;
  SmokeDetectorModel? smokeDetector;
  String? signature;

  SmokeDetectorMaintenanceModel(
      {super.id,
      super.name,
      super.description,
      super.createdAt,
      super.updatedAt,
      this.time,
      this.isDustCleaned,
      this.isCleaned,
      this.isTested,
      this.isBatteryReplaced,
      this.comment,
      this.userId,
      this.smokeDetectorId,
      this.smokeDetector,
      this.signature});

  SmokeDetectorMaintenanceModel.fromJson(Map<String, dynamic> json) {
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    time = DateTime.parse(json['time'].toString());
    isDustCleaned = json['isDustCleaned'];
    isCleaned = json['isCleaned'];
    isTested = json['isTested'];
    isBatteryReplaced = json['isBatteryReplaced'];
    comment = json['comment'];
    userId = json['userId'];
    smokeDetectorId = json['smokeDetectorId'];
    smokeDetector = json['smokeDetector'] != null
        ? SmokeDetectorModel.fromJson(json['smokeDetector'])
        : null;
    signature = json['signature'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['description'] = super.description;
    data['createdDate'] = super.createdAt;
    data['updatedDate'] = super.updatedAt;
    data['time'] = time;
    data['isDustCleaned'] = isDustCleaned;
    data['isCleaned'] = isCleaned;
    data['isTested'] = isTested;
    data['isBatteryReplaced'] = isBatteryReplaced;
    data['comment'] = comment;
    data['userId'] = userId;
    data['smokeDetectorId'] = smokeDetectorId;
    data['smokeDetector'] =
        smokeDetector != null ? smokeDetector!.toJson() : null;
    data['signature'] = signature;
    return data;
  }

  Image getPngImage () {
    var decoded = base64Decode(signature!);
    return Image.memory(decoded);
  }

  toCreateJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isDustCleaned'] = isDustCleaned;
    data['isCleaned'] = isCleaned;
    data['isTested'] = isTested;
    data['isBatteryReplaced'] = isBatteryReplaced;
    data['comment'] = comment;
    data['signature'] = signature;
    return data;
  }
}
