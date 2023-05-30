using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace Core.Helper;

public class ErrorDetails
{
    public string Message { get; set; }
    public ErrorCode ErrorCode { get; set; }

    public ErrorDetails()
    {
        Message = "An error occurred";
        ErrorCode = ErrorCode.Unknown;
    }


    public ErrorDetails(string message, ErrorCode errorCode)
    {
        Message = message;
        ErrorCode = errorCode;
    }

    public ErrorDetails(string message)
    {
        Message = message;
        ErrorCode = ErrorCode.Unknown;
    }
}

[JsonConverter(typeof(StringEnumConverter))]
public enum ErrorCode
{
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
    TenantAlreadyExists,
    InvalidRoom,
    InvalidBuildingUnit
}