class RegisterModel{
  String email = '';
  String password = '';
  String firstName = '';
  String lastName = '';
  String tenantId = '';

  RegisterModel();
  RegisterModel.create(this.firstName, this.lastName, this.email, this.password);
  RegisterModel.createTenantAdmin(this.firstName, this.lastName, this.email, this.password, this.tenantId);


  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  Map<String, dynamic> toJsonAdmin() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'tenantId': tenantId
    };
  }
}