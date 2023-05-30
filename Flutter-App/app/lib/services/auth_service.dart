import 'dart:developer' as developer;
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  String _jwt = "";
  String _username = "";

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal();

  /// Sets the JWT and extracts and sets the username from the JWT
  void setJwt(String jwt) {
    // TODO: load token into persistent storage to prevent having to log-in after closing the app
    _jwt = jwt;

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(jwt);

      _username = decodedToken['sub'];
    } on FormatException {
      _username = "";
      developer.log('Received invalid token!');
    }
  }

  String getJwt() {
    return _jwt;
  }

  String getUsername() {
    return _username;
  }
}
