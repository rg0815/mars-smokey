import 'package:ssds_app/api/models/base_entity_model.dart';
import 'package:ssds_app/api/models/building_unit_model.dart';

class MqttConnectionData extends BaseEntity{
  String? username;
  String? password;
  String? buildingUnitId;
  BuildingUnitModel? buildingUnit;

  MqttConnectionData({super.id,
    super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
    this.username,
    this.password,
    this.buildingUnitId,
    this.buildingUnit});

  MqttConnectionData.fromJson(Map<String, dynamic> json){
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    username = json['username'];
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
    data['username'] = username;
    data['password'] = password;
    data['buildingUnitId'] = buildingUnitId;
    data['buildingUnit'] = buildingUnit?.toJson();
    return data;
  }
}