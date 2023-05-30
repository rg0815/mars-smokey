class RegisterTenantAdminModel{
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  String? tenantName;
  String? tenantDescription;

  RegisterTenantAdminModel({this.email, this.password, this.firstName, this.lastName, this.tenantName, this.tenantDescription});

  RegisterTenantAdminModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    tenantName = json['tenantName'];
    tenantDescription = json['tenantDescription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['tenantName'] = tenantName;
    data['tenantDescription'] = tenantDescription;
    return data;
  }
}