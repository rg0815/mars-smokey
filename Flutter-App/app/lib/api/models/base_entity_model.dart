class BaseEntity {
  String? id;
  String? name;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;

  BaseEntity(
      {this.id,
        this.name,
        this.description,
        this.createdAt,
        this.updatedAt});

  BaseEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    createdAt = DateTime.parse(json['createdAt'].toString());
    updatedAt = DateTime.parse(json['updatedAt'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['createdDate'] = createdAt;
    data['updatedDate'] = updatedAt;
    return data;
  }
}
