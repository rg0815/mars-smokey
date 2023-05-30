class UserModel {
  String? id;
  String? email;
  String? firstName;
  String? lastName;
  String? accessToken;
  String? refreshToken;
  bool? isSuperAdmin;
  bool? isTenantAdmin;
  String? tenantId;
  List<String>? readAccess;
  List<String>? writeAccess;

  UserModel(
      {this.id,
      this.email,
      this.firstName,
      this.lastName,
      this.accessToken,
      this.refreshToken,
      this.isSuperAdmin,
      this.isTenantAdmin,
      this.tenantId,
      this.readAccess,
      this.writeAccess});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    isSuperAdmin = json['isSuperAdmin'];
    isTenantAdmin = json['isTenantAdmin'];
    tenantId = json['tenantId'];
    readAccess = [];
    writeAccess = [];

    if (json['readAccess'] != null) {
      json['readAccess'].forEach((v) {
        readAccess?.add(v);
      });
    }

    if (json['writeAccess'] != null) {
      json['writeAccess'].forEach((v) {
        writeAccess?.add(v);
      });
    }

    print("Name: $firstName $lastName");
    print("Read Access: $readAccess");
    print("Write Access: $writeAccess");
    print("Is Super Admin: $isSuperAdmin");
    print("Is Tenant Admin: $isTenantAdmin");
    print("Tenant Id: $tenantId");
    print("Access Token: $accessToken");
    print("Refresh Token: $refreshToken");
    print("Email: $email");
    print("Id: $id");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    data['isSuperAdmin'] = isSuperAdmin;
    data['isTenantAdmin'] = isTenantAdmin;
    data['tenantId'] = tenantId;
    data['readAccess'] = readAccess;
    data['writeAccess'] = writeAccess;
    return data;
  }
}
