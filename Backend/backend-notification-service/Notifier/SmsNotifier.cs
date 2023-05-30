using backend_notification_service.Models;
using NLog;
using Sms77.Api;
using Sms77.Api.Library;

namespace backend_notification_service.Notifier;

public static class SmsNotifier
{
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();

    public static bool SendSms(SmsNotificationRequestModel smsNotificationRequestModel)
    {
        var notifierSettings = Program.NotifierSettings;

        try
        {
            var client = new Client(notifierSettings.Sms.ApiKey);
            var result = client.Sms(new SmsParams()
            {
                Debug = notifierSettings.Sms.Debug,
                From = notifierSettings.Sms.From,
                Text = smsNotificationRequestModel.Text,
                To = smsNotificationRequestModel.To,
            }).Result;

            return true;
        }
        catch (Exception e)
        {
            Logger.Error(e);
            return false;
        }
    }
}