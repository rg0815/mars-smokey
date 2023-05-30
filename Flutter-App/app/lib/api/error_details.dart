// ignore_for_file: constant_identifier_names

class ErrorDetails{
  String? message;
  ErrorType? errorCode;

  ErrorDetails({this.message, this.errorCode});

  ErrorDetails.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    errorCode = json['errorCode'] != null ? ErrorType.values.byName((json['errorCode'] as String)) : null;
  }
}

enum ErrorType {
  Unknown,
  InvalidCredentials,
  UserNotFound,
  UserAlreadyExists,
  InvalidEmail,
  InvalidPassword,
  InvalidModelState,
  InternalError,
  MailNotConfirmed,
  RefreshTokenExpired,
  InvalidRefreshToken,
  UserCreationFailed,
  InvalidToken,
  InvitationAlreadyAccepted,
  InvitationExpired,
  InvitationDeleted,
  FailedToCreateUser,
  InvalidTenantId,
  FailedToSendMail,
  FailedToChangePassword,
  TokenExpired,
  FailedToUpdateUser,
  InvitationNotFound,
  TenantAlreadyExists
}