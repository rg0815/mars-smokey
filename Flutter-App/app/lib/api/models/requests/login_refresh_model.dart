class LoginRefreshModel {
  String? accessToken;
  String? refreshToken;

  LoginRefreshModel({required this.accessToken, required this.refreshToken});

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    return data;
  }


}