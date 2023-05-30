import 'package:ssds_app/api/models/base_entity_model.dart';

import 'building_model.dart';

class AddressModel extends BaseEntity{
  String? street;
  String? city;
  String? zipCode;
  String? country;
  String? buildingId;

  AddressModel(
      {super.id,
      super.name,
      super.description,
      super.createdAt,
      super.updatedAt,
      this.street,
      this.city,
      this.zipCode,
      this.country,
      this.buildingId});

  AddressModel.fromJson(Map<String, dynamic> json){
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    street = json['street'];
    city = json['city'];
    zipCode = json['zipCode'];
    country = json['country'];
  }

  @override
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['description'] = super.description;
    data['createdDate'] = super.createdAt!.toIso8601String();
    data['updatedDate']= super.updatedAt!.toIso8601String();
    data['street'] = street;
    data['city'] = city;
    data['zipCode'] = zipCode;
    data['country'] = country;
    return data;
  }

  String toLocationString() {
    return '$street, $city, $zipCode, $country';
  }
}