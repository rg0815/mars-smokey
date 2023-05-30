import 'package:ssds_app/api/models/base_entity_model.dart';
import 'package:ssds_app/api/models/smoke_detector_model.dart';

import 'building_unit_model.dart';
import 'gateway_model.dart';

class RoomModel extends BaseEntity{
  String? floor;
  List<GatewayModel>? gateways;
  List<SmokeDetectorModel>? smokeDetectors;
  String? buildingUnitId;
  BuildingUnitModel? buildingUnit;

  RoomModel(
      {super.id,
      super.name,
      super.description,
      super.createdAt,
      super.updatedAt,
      this.floor,
      this.gateways,
      this.smokeDetectors,
      this.buildingUnitId,
      this.buildingUnit});

  RoomModel.fromJson(Map<String, dynamic> json){
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    floor = json['floor'];
    if (json['gateways'] != null) {
      gateways = <GatewayModel>[];
      json['gateways'].forEach((v) {
        gateways!.add(GatewayModel.fromJson(v));
      });
    }
    if (json['smokeDetectors'] != null) {
      smokeDetectors = <SmokeDetectorModel>[];
      json['smokeDetectors'].forEach((v) {
        smokeDetectors!.add(SmokeDetectorModel.fromJson(v));
      });
    }
    buildingUnitId = json['buildingUnitId'];
    buildingUnit = json['buildingUnit'] != null ? BuildingUnitModel.fromJson(json['buildingUnit']) : null;
  }

  @override
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['description'] = super.description;
    data['createdDate'] = super.createdAt;
    data['updatedDate'] = super.updatedAt;
    data['floor'] = floor;
    if (gateways != null) {
      data['gateways'] = gateways!.map((v) => v.toJson()).toList();
    }
    if (smokeDetectors != null) {
      data['smokeDetectors'] = smokeDetectors!.map((v) => v.toJson()).toList();
    }
    data['buildingUnitId'] = buildingUnitId;
    data['buildingUnit'] = buildingUnit != null ? buildingUnit!.toJson() : null;
    return data;
  }

  Map<String, dynamic> toCreateJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = super.name;
    data['description'] = super.description;
    return data;
  }

}