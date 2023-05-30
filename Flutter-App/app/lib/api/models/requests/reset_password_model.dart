class ResetPasswordModel{
  String resetToken = '';
  String email = '';
  String newPassword = '';

  ResetPasswordModel();
  ResetPasswordModel.create(this.resetToken, this.email, this.newPassword);

  ResetPasswordModel.fromJson(Map<String, dynamic> json){
    resetToken = json['token'];
    email = json['email'];
    newPassword = json['newPassword'];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = resetToken;
    data['email'] = email;
    data['newPassword'] = newPassword;
    return data;
  }

}