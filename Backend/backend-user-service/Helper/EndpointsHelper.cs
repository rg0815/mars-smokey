namespace backend_user_service.Helper;

public static class EndpointsHelper
{
#if DEBUG
    private const string UserServiceBaseUrl = "";
    public const string NotificationServiceBaseUrl = "";
#else
    public const string UserServiceBaseUrl = ""; //TODO: Change to production url
    public const string NotificationServiceBaseUrl = ""; //TODO: Change to production url
    
#endif

    // USER URL ACTIONS
    private const string ResetPassword = UserServiceBaseUrl + "/password-reset/";
    private const string ConfirmAccount = UserServiceBaseUrl + "/account-confirmation/";
    private const string AcceptInvitation = UserServiceBaseUrl + "/registerUser/";
    
    public static string GetResetPasswordUrl(Guid token) => ResetPassword + token;
    public static string GetConfirmAccountUrl(Guid token) => ConfirmAccount + token;
    public static string GetInvitationUrl(Guid token) => AcceptInvitation + token;



    // NOTIFICATION

    // --- Mail

    // private const string Mail = "/api/notification/mail";

    // public const string SendInvitationExistingUser = Mail + "/sendInvitationExistingUser";

    // public const string SendInvitationNewUser = Mail + "/sendInvitationNewUser";

    // public const string SendAccountConfirmation = Mail + "/sendAccountConfirmation";

    // public const string SendPasswordChanged = Mail + "/sendPasswordChanged";

    // public const string SendResetPassword = Mail + "/sendPasswordReset";
}