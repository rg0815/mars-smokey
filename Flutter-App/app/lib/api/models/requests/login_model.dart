class LoginModel{
  String? mail;
  String? password;

  LoginModel({required this.mail, required this.password});

  LoginModel.fromJson(Map<String, dynamic> json){
    mail = json['mail'];
    password = json['password'];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mail'] = mail;
    data['password'] = password;
    return data;
  }


}