using Grpc.Core;
using Grpc.Net.Client;
using NLog;
using ssds_mail_notifications;

namespace backend_user_service.Service;

public static class NotificationService
{
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();
    private const string NotificationServiceUrl = "http://localhost:85";

    public static bool SendInvitationExistingUser(InvitationExistingUserRequest model)
    {
        var client =
            new MailNotificationService.MailNotificationServiceClient(GrpcChannel.ForAddress(NotificationServiceUrl));
        var res = client.SendInvitationExistingUser(model, GetHeaders());

        if (res is {Success: true}) return true;

        Logger.Error($"Error while sending invitation notification: {res.ErrorMessage}");
        return false;
    }

    public static bool SendInvitationNewUser(InvitationNewUserRequest model)
    {
        var client =
            new MailNotificationService.MailNotificationServiceClient(GrpcChannel.ForAddress(NotificationServiceUrl));
        var res = client.SendInvitationNewUser(model, GetHeaders());

        if (res is {Success: true}) return true;

        Logger.Error($"Error while sending invitation notification: {res.ErrorMessage}");
        return false;
    }

    public static bool SendAccountConfirmation(AccountConfirmationRequest model)
    {
        var client =
            new MailNotificationService.MailNotificationServiceClient(GrpcChannel.ForAddress(NotificationServiceUrl));
        var res = client.SendAccountConfirmation(model, GetHeaders());

        if (res is {Success: true}) return true;

        Logger.Error($"Error while sending account confirmation notification: {res.ErrorMessage}");
        return false;
    }

    public static bool SendPasswordChanged(PasswordChangeRequest model)
    {
        var client =
            new MailNotificationService.MailNotificationServiceClient(GrpcChannel.ForAddress(NotificationServiceUrl));
        var res = client.SendPasswordChange(model, GetHeaders());

        if (res is {Success: true}) return true;

        Logger.Error($"Error while sending password reset notification: {res.ErrorMessage}");
        return false;
    }

    public static bool SendPasswordReset(PasswordResetRequest model)
    {
        var client =
            new MailNotificationService.MailNotificationServiceClient(GrpcChannel.ForAddress(NotificationServiceUrl));
        var res = client.SendPasswordReset(model, GetHeaders());

        if (res is {Success: true}) return true;

        Logger.Error($"Error while sending password reset notification: {res.ErrorMessage}");
        return false;
    }

    private static Metadata GetHeaders()
    {
        var metadata = new Metadata();
        if (Program.JwtSettings == null) throw new Exception("JWT settings not found");
        var key = Program.JwtSettings.BackendValidationKey;
        metadata.Add("x-custom-backend-auth", key);
        return metadata;
    }
}