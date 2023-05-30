import '../user_model.dart';

class LoginResponseModel {
  String? accessToken;
  String? refreshToken;
  UserModel? user;

  LoginResponseModel(
      {this.accessToken,
      this.refreshToken,
      this.user});

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    user = UserModel.fromJson(json['appUser']);
  }
}
