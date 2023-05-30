import 'base_entity_model.dart';
import 'building_model.dart';

class TenantModel extends BaseEntity {
  List<BuildingModel>? buildings;

  TenantModel(
      {super.id,
      super.name,
      super.description,
      super.createdAt,
      super.updatedAt,
      this.buildings});

  TenantModel.fromJson(Map<String, dynamic> json) {
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());

    if (json['buildings'] != null) {
      buildings = <BuildingModel>[];
      json['buildings'].forEach((v) {
        buildings!.add(BuildingModel.fromJson(v));
      });
    }
    else{
      buildings = [];
    }
  }

  Map<String, dynamic> toCreateJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = super.name;
    data['description'] = super.description;
    return data;
  }

  @override
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['description'] = super.description;
    data['createdDate'] = super.createdAt;
    data['updatedDate'] = super.updatedAt;
    return data;
  }
}

