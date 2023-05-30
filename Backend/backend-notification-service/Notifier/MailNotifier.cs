using backend_notification_service.Models;
using MailKit.Net.Smtp;
using MimeKit;
using NLog;

namespace backend_notification_service.Notifier;

public static class MailNotifier
{
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();

    public static bool SendMail(EmailNotificationRequestModel model)
    {
        try
        {
            Logger.Debug("Sending mail to {Email} with subject {Subject}", model.Recipient.Email, model.Subject);

            var notifierSettings = Program.NotifierSettings;
            var message = new MimeMessage();
            if (notifierSettings == null)
            {
                Logger.Error("Notifier settings are not configured or invalid");
                return false;
            }

            message.From.Add(new MailboxAddress(notifierSettings.Mail.FromName, notifierSettings.Mail.MailAddress
            ));
            message.To.Add(new MailboxAddress(model.Recipient.Name, model.Recipient.Email));
            message.Subject = model.Subject;

            message.Body = model.IsHtml
                ? new TextPart("html") {Text = model.Body}
                : new TextPart("plain") {Text = model.Body};

            if (model.IsHighPriority)
                message.Priority = MessagePriority.Urgent;

            using var client = new SmtpClient();
            client.Connect(notifierSettings.Mail.Host, notifierSettings.Mail.Port);
            if (notifierSettings.Mail.AuthNeeded)
                client.Authenticate(notifierSettings.Mail.MailAddress, notifierSettings.Mail.Password);
            client.Send(message);
            client.Disconnect(true);
            message.Dispose();
            client.Dispose();

            return true;
        }
        catch (Exception e)
        {
            Logger.Error(e);
            return false;
        }
    }
}