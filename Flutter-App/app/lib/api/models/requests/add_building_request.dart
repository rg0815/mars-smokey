class AddBuildingRequest {
  String? name;
  String? description;
  String? street;
  String? city;
  String? zipCode;
  String? country;

  AddBuildingRequest();


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['buildingName'] = name;
    data['buildingDescription'] = description;
    data['street'] = street;
    data['city'] = city;
    data['zipCode'] = zipCode;
    data['country'] = country;
    return data;
  }
}
