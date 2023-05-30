class UserInvitation {
  String? id;
  String? registrationToken;
  String? invitedBy;
  String? email;
  List<String>? readAccess;
  List<String>? writeAccess;
  bool? isTenantAdmin;
  bool? isAccepted;
  DateTime? expirationDate;
  DateTime? acceptedDate;
  bool? isDeleted;
  String? tenantId;

  UserInvitation(
      {this.id,
      this.registrationToken,
      this.invitedBy,
      this.email,
      this.readAccess,
      this.writeAccess,
      this.isTenantAdmin,
      this.isAccepted,
      this.expirationDate,
      this.acceptedDate,
      this.isDeleted,
      this.tenantId});

  UserInvitation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    registrationToken = json['registrationToken'];
    invitedBy = json['invitedBy'];
    email = json['email'];
    readAccess = json['readAccess'].cast<String>();
    writeAccess = json['writeAccess'].cast<String>();
    isAccepted = json['isAccepted'];
    expirationDate =DateTime.parse(json['expirationDate'].toString());
    isDeleted = json['isDeleted'];
    tenantId = json['tenantId'];
    isTenantAdmin = json['isTenantAdmin'];
  }

  Map<String, dynamic> toCreateJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['tenantId'] = tenantId;
    data['readAccess'] = readAccess;
    data['writeAccess'] = writeAccess;
    data['isTenantAdmin'] = isTenantAdmin;
    return data;
  }
}
