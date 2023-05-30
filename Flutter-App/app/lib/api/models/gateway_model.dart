import 'package:ssds_app/api/models/base_entity_model.dart';

class GatewayModel extends BaseEntity {
  DateTime? lastContact;
  String? roomId;
  String? clientId;

  GatewayModel(
      {super.id,
      super.name,
      super.description,
      super.createdAt,
      super.updatedAt,
      this.lastContact,
      this.clientId,
      this.roomId});

  GatewayModel.fromJson(Map<String, dynamic> json) {
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    lastContact = DateTime.parse(json['lastContact'].toString());
    roomId = json['roomId'];
    clientId = json['clientId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['description'] = super.description;
    data['createdDate'] = super.createdAt;
    data['updatedDate'] = super.updatedAt;
    data['lastContact'] = lastContact;
    data['roomId'] = roomId;
    data['clientId'] = clientId;
    return data;
  }

  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = super.name;
    data['description'] = super.description;
    data['roomId'] = roomId;
    return data;
  }
}
