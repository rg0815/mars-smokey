import 'package:ssds_app/api/models/smoke_detector_model.dart';

import 'base_entity_model.dart';
import 'fire_alarm.dart';

class SmokeDetectorAlarmModel extends BaseEntity {
  DateTime? startTime;
  String? smokeDetectorId;
  SmokeDetectorModel? smokeDetector;
  String? fireAlarmId;
  FireAlarm? fireAlarm;

  SmokeDetectorAlarmModel(
      {super.id,
      super.name,
      super.description,
      super.createdAt,
      super.updatedAt,
      this.startTime,
      this.smokeDetectorId,
      this.smokeDetector,
      this.fireAlarm,
      this.fireAlarmId});

  SmokeDetectorAlarmModel.fromJson(Map<String, dynamic> json){
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    startTime = DateTime.parse(json['startTime'].toString());
    smokeDetectorId = json['smokeDetectorId'];
    smokeDetector = json['smokeDetector'] != null
        ? SmokeDetectorModel.fromJson(json['smokeDetector'])
        : null;
    fireAlarmId = json['fireAlarmId'];
    fireAlarm = json['fireAlarm'] != null
        ? FireAlarm.fromJson(json['fireAlarm'])
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
    data['startTime'] = startTime;
    data['smokeDetectorId'] = smokeDetectorId;
    data['smokeDetector'] = smokeDetector?.toJson();
    data['fireAlarmId'] = fireAlarmId;
    data['fireAlarm'] = fireAlarm?.toJson();
    return data;
  }
}