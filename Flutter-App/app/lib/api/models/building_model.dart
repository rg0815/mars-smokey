import 'package:ssds_app/api/models/address_model.dart';

import 'base_entity_model.dart';
import 'building_unit_model.dart';

class BuildingModel extends BaseEntity {
  AddressModel? address;
  List<BuildingUnitModel>? buildingUnits;
  String? tenantId;

  BuildingModel(
      {super.id,
      super.name,
      super.description,
      super.createdAt,
      super.updatedAt,
      this.address,
      this.buildingUnits,
      this.tenantId});

  BuildingModel.fromJson(Map<String, dynamic> json) {
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    address = json['address'] != null
        ? AddressModel.fromJson(json['address'])
        : null;
    if (json['buildingUnits'] != null) {
      buildingUnits = <BuildingUnitModel>[];
      json['buildingUnits'].forEach((v) {
        buildingUnits!.add(BuildingUnitModel.fromJson(v));
      });
    }else{
      buildingUnits = [];
    }
    tenantId = json['tenantId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['description'] = super.description;
    data['createdDate'] = super.createdAt!.toIso8601String();
    data['updatedDate'] = super.updatedAt!.toIso8601String();
    if (address != null) {
      data['address'] = address!.toJson();
    }
    if (buildingUnits != null) {
      data['buildingUnits'] =
          buildingUnits!.map((v) => v.toJson()).toList();
    }
    data['tenantId'] = tenantId;
    return data;
  }

  Map<String, dynamic> toUpdateJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = super.name;
    data['description'] = super.description;
    return data;
  }
}