import 'package:ssds_app/api/models/base_entity_model.dart';
import 'package:ssds_app/api/models/building_unit_model.dart';
import 'package:ssds_app/api/models/smoke_detector_alarm_model.dart';

class FireAlarm extends BaseEntity{
  DateTime? startTime;
  DateTime? endTime;
  List<SmokeDetectorAlarmModel>? alarmedDetectors;
  bool? isProbableFalseAlarm;
  bool? wasFalseAlarm;
  String? buildingUnitId;
  BuildingUnitModel? buildingUnit;
  bool? isActive;

  FireAlarm({super.id,
    super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
    this.startTime,
    this.endTime,
    this.alarmedDetectors,
    this.isProbableFalseAlarm,
    this.wasFalseAlarm,
    this.buildingUnitId,
    this.buildingUnit,
    this.isActive});

  FireAlarm.fromJson(Map<String, dynamic> json){
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    startTime = DateTime.parse(json['startTime'].toString());
    endTime = DateTime.parse(json['endTime'].toString());
    if (json['alarmedDetectors'] != null) {
      alarmedDetectors = <SmokeDetectorAlarmModel>[];
      json['alarmedDetectors'].forEach((dynamic v) {
        alarmedDetectors!.add(SmokeDetectorAlarmModel.fromJson(v));
      });
    }
    isProbableFalseAlarm = json['isProbableFalseAlarm'];
    wasFalseAlarm = json['wasFalseAlarm'];
    buildingUnitId = json['buildingUnitId'];
    buildingUnit = json['buildingUnit'] != null
        ? BuildingUnitModel.fromJson(json['buildingUnit'])
        : null;
    isActive = json['isActive'];
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
    data['endTime'] = endTime;
    if (alarmedDetectors != null) {
      data['alarmedDetectors'] = alarmedDetectors!.map((v) => v.toJson()).toList();
    }
    data['isProbableFalseAlarm'] = isProbableFalseAlarm;
    data['wasFalseAlarm'] = wasFalseAlarm;
    data['buildingUnitId'] = buildingUnitId;
    data['buildingUnit'] = buildingUnit!.toJson();
    return data;
  }



}