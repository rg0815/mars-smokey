import 'package:ssds_app/api/models/base_entity_model.dart';
import 'package:ssds_app/api/models/building_unit_model.dart';

class ApiKeyModel extends BaseEntity {
  String? key;
  bool? isActive;
  DateTime? lastUsed;
  BuildingUnitModel? buildingUnit;

  ApiKeyModel(
      {super.id,
      super.name,
      super.description,
      super.createdAt,
      super.updatedAt,
      this.key,
      this.isActive,
      this.lastUsed,
      this.buildingUnit});

  ApiKeyModel.fromJson(Map<String, dynamic> json) {
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    key = json['key'];
    isActive = json['isActive'];
    lastUsed = DateTime.parse(json['lastUsed'].toString());
    buildingUnit = json['buildingUnit'] != null
        ? BuildingUnitModel.fromJson(json['buildingUnit'])
        : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['description'] = super.description;
    data['createdDate'] = super.createdAt;
    data['updatedDate'] = super.updatedAt;
    data['key'] = key;
    data['isActive'] = isActive;
    data['lastUsed'] = lastUsed;
    data['buildingUnit'] = buildingUnit != null ? buildingUnit!.toJson() : null;
    return data;
  }
}
