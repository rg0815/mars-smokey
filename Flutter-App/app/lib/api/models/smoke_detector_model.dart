
import 'package:ssds_app/api/models/room_model.dart';
import 'package:ssds_app/api/models/smoke_detector_alarm_model.dart';
import 'package:ssds_app/api/models/smoke_detector_maintenance_model.dart';
import 'package:ssds_app/api/models/smoke_detector_model_model.dart';

import 'base_entity_model.dart';

class SmokeDetectorModel extends BaseEntity{
  SmokeDetectorModelModel? model;
  String? smokeDetectorModelId;
  String? rawTransmissionData;
  SmokeDetectorState? state;
  DateTime? lastBatteryReplacement;
  double? batteryLevel;
  bool? isBatteryLow;
  DateTime? lastMaintenance;
  List<SmokeDetectorAlarmModel>? events;
  List<SmokeDetectorMaintenanceModel>? maintenances;
  String? roomId;
  RoomModel? room;

  SmokeDetectorModel(
      {super.id,
      super.name,
      super.description,
      super.createdAt,
      super.updatedAt,
      this.model,
      this.smokeDetectorModelId,
      this.rawTransmissionData,
      this.state,
      this.lastBatteryReplacement,
      this.batteryLevel,
      this.isBatteryLow,
      this.lastMaintenance,
      this.events,
      this.maintenances,
      this.roomId,
      this.room});

  SmokeDetectorModel.fromJson(Map<String, dynamic> json){
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    model = json['smokeDetectorModel'] != null ? SmokeDetectorModelModel.fromJson(json['smokeDetectorModel']) : null;
    smokeDetectorModelId = json['smokeDetectorModelId'];
    rawTransmissionData = json['rawTransmissionData'];

    if(json['state'] != null) {
      state = SmokeDetectorState.values[json['state']];
    }

    lastBatteryReplacement = DateTime.parse(json['lastBatteryReplacement'].toString());
    batteryLevel = json['batteryLevel'];
    isBatteryLow = json['isBatteryLow'];
    lastMaintenance = DateTime.parse(json['lastMaintenance'].toString());

    if(json['events'] != null) {
      events = <SmokeDetectorAlarmModel>[];
      json['events'].forEach((v) {
        events!.add(SmokeDetectorAlarmModel.fromJson(v));
      });
    }

    if(json['maintenances'] != null) {
      maintenances = <SmokeDetectorMaintenanceModel>[];
      json['maintenances'].forEach((v) {
        maintenances!.add(SmokeDetectorMaintenanceModel.fromJson(v));
      });
    }

    roomId = json['roomId'];
    room = json['room'] != null ? RoomModel.fromJson(json['room']) : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['description'] = super.description;
    data['createdAt'] = super.createdAt;
    data['updatedAt'] = super.updatedAt;
    data['model'] = model;
    data['smokeDetectorModelId'] = smokeDetectorModelId;
    data['rawTransmissionData'] = rawTransmissionData;
    data['state'] = state;
    data['lastBatteryReplacement'] = lastBatteryReplacement;
    data['batteryLevel'] = batteryLevel;
    data['isBatteryLow'] = isBatteryLow;
    data['lastMaintenance'] = lastMaintenance;
    data['events'] = events;
    data['maintenances'] = maintenances;
    data['roomId'] = roomId;
    data['room'] = room;
    return data;
  }

  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = super.name;
    data['description'] = super.description;
    data['smokeDetectorModelId'] = smokeDetectorModelId;
    data['roomId'] = roomId;
    return data;
  }

  String toLocation() {
    return '${room!.buildingUnit!.building!.name} - ${room!.buildingUnit!.name} - ${room!.name}';
  }


}

enum SmokeDetectorState { normal, warning, alert }