using System.Diagnostics;
using backend_notification_service.Models;
using NLog;

namespace backend_notification_service.Notifier;

public static class PhoneCallNotifier
{
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();

    public static bool PerformPhoneCall(PhoneNotificationRequestModel model)
    {
        try
        {
            Logger.Info("Performing phone call to {PhoneNumber}", model.To);

            var notifierSettings = Program.NotifierSettings;
            if (notifierSettings == null)
            {
                Logger.Error("Notifier settings are not configured or invalid");
                return false;
            }
            
            if(!notifierSettings.PhoneCall.Enabled) return true;

            if (!File.Exists(notifierSettings.PhoneCall.PathToPhoneCallTool))
            {
                Logger.Error("Phone call tool is not installed");
                return false;
            }

            var process = new Process
            {
                StartInfo =
                {
                    FileName = notifierSettings.PhoneCall.PathToPhoneCallTool,
                    Arguments = $"{model.To}",
                    UseShellExecute = false
                }
            };
            process.Start();
            process.WaitForExit();

            var exitCode = process.ExitCode;

            if (!Enum.TryParse(exitCode.ToString(), out ErrorCode errorCode))
            {
                Logger.Error("Unknown error code {ExitCode}", exitCode);
                errorCode = ErrorCode.UnknownError;
            }

            switch (errorCode)
            {
                case ErrorCode.UnknownError or ErrorCode.InvalidPhoneNumber or ErrorCode.AudioFileNotFound
                    or ErrorCode.SipCallFailed:
                    Logger.Error("Phone call failed with error code {ErrorCode}", errorCode);
                    return false;
                case ErrorCode.TaskCancelled:
                    Logger.Warn("Phone call was cancelled - this may be in most cases be caused by hanging up of the user");
                    return true;
                default:
                    Logger.Info("Phone call was successful");
                    return true;
            }
        }
        catch (Exception e)
        {
            Logger.Error(e);
            return false;
        }
    }

    private enum ErrorCode
    {
        NoError = 0,
        InvalidPhoneNumber = 1,
        AudioFileNotFound = 2,
        SipCallFailed = 3,
        TaskCancelled = 4,
        UnknownError = 5
    }
}