using backend_notification_service.Models;
using NLog;

namespace backend_notification_service.Notifier;

public static class NotificationManager
{
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();
    private static List<NotificationRequestModel> _notificationQueue = new();
    private static readonly ManualResetEvent RunningSignal = new(false);
    private static readonly ManualResetEvent StopSignal = new(false);
    private static List<NotificationRequestModel> _phoneNotificationQueue = new();
    private static readonly ManualResetEvent RunningPhoneSignal = new(false);
    private static readonly ManualResetEvent StopPhoneSignal = new(false);


    public static bool AddNotification(NotificationRequestModel notification)
    {
        try
        {
            Logger.Debug("Adding notification to queue");
            notification.CreatedAt = DateTime.Now;
            lock (_notificationQueue)
            {
                _notificationQueue.Add(notification);
                _notificationQueue = _notificationQueue
                    .OrderBy(x => x.Priority)
                    .ThenBy(x => x.CreatedAt).ToList();
                RunningSignal.Set();
            }

            return true;
        }
        catch (Exception e)
        {
            Logger.Error(e);
            return false;
        }
    }

    private static NotificationRequestModel? GetNextNotification()
    {
        lock (_notificationQueue)
        {
            if (_notificationQueue.Any())
            {
                var notification = _notificationQueue.First();
                _notificationQueue.RemoveRange(0, 1);
                return notification;
            }

            RunningSignal.Reset();
            return null;
        }
    }

    public static void Initialize()
    {
        StopSignal.Reset();
        var notificationThread = new Thread(NotificationHandler);
        notificationThread.Start();

        StopPhoneSignal.Reset();
        var phoneNotificationThread = new Thread(PhoneNotificationHandler);
        phoneNotificationThread.Start();
    }

    private static void NotificationHandler()
    {
        var settings = Program.NotifierSettings;
        if (settings == null)
        {
            Logger.Error("Notifier settings are not configured or invalid");
            return;
        }

        Logger.Info("Notification handler started");
        StopSignal.Reset();

        var waitHandles = new WaitHandle[] { RunningSignal, StopSignal };
        while (WaitHandle.WaitAny(waitHandles) == 0)
        {
            var notification = GetNextNotification();
            if (notification == null)
            {
                Thread.Sleep(1000);
                continue;
            }

            if (notification.Email != null && settings.Mail.Enabled)
            {
                var mailThread = new Thread(() => SendMail(notification));
                mailThread.Start();
            }

            if (notification.Http != null && settings.Http.Enabled)
            {
                var httpThread = new Thread(() => SendHttp(notification));
                httpThread.Start();
            }

            if (notification.Sms != null && settings.Sms.Enabled)
            {
                var smsThread = new Thread(() => SendSms(notification));
                smsThread.Start();
            }

            if (notification.Phone != null && settings.PhoneCall.Enabled)
            {
                QueuePhone(notification);
            }

            if (StopSignal.WaitOne(TimeSpan.FromSeconds(2))) // sleep between sending results 2 sec
            {
                break;
            }
        }
    }

    private static void PhoneNotificationHandler()
    {
        var settings = Program.NotifierSettings;
        if (settings == null)
        {
            Logger.Error("Notifier settings are not configured or invalid");
            return;
        }

        Logger.Info("Phone Notification handler started");

        var waitHandles = new WaitHandle[] { RunningPhoneSignal, StopPhoneSignal };
        while (WaitHandle.WaitAny(waitHandles) == 0)
        {
            var notification = GetNextPhoneNotification();
            if (notification == null)
            {
                Thread.Sleep(1000);
                continue;
            }

            if (notification.Phone == null) return;
            var success = PhoneCallNotifier.PerformPhoneCall(notification.Phone);

            if (success) return;

            Logger.Error("Failed to send phone call to {Phone}",
                notification.Phone.To);

            if (notification.RetryCount is not <= 3) return;
            notification.RetryCount = notification.RetryCount == null ? 1 : notification.RetryCount + 1;

            if (!QueuePhone(notification))
            {
                Logger.Error("Failed to add notification to queue");
            }

            if (StopPhoneSignal.WaitOne(TimeSpan.FromSeconds(2))) // sleep between sending results 2 sec
            {
                break;
            }
        }
    }

    private static bool QueuePhone(NotificationRequestModel notification)
    {
        Logger.Info("Adding phone notification to queue");

        try
        {
            lock (_phoneNotificationQueue)
            {
                if (_phoneNotificationQueue.Any(x => x.Phone?.To == notification.Phone?.To)) return true;

                _phoneNotificationQueue.Add(notification);
                _phoneNotificationQueue = _phoneNotificationQueue
                    .OrderBy(x => x.Priority)
                    .ThenBy(x => x.CreatedAt).ToList();
                RunningPhoneSignal.Set();
            }

            return true;
        }
        catch (Exception e)
        {
            Logger.Error(e);
            return false;
        }
    }

    private static NotificationRequestModel? GetNextPhoneNotification()
    {
        lock (_phoneNotificationQueue)
        {
            if (_phoneNotificationQueue.Any())
            {
                var notification = _phoneNotificationQueue.First();
                _phoneNotificationQueue.RemoveRange(0, 1);
                return notification;
            }

            RunningPhoneSignal.Reset();
            return null;
        }
    }

    private static void SendHttp(NotificationRequestModel notification)
    {
        throw new NotImplementedException();
    }

    private static void SendSms(NotificationRequestModel notification)
    {
        if (notification.Sms == null) return;
        SmsNotifier.SendSms(notification.Sms);
    }

    private static void SendMail(NotificationRequestModel notification)
    {
        if (notification.Email == null) return;

        var mailRes = MailNotifier.SendMail(notification.Email);
        if (mailRes) return;

        Logger.Error("Failed to send mail to {Email} with subject {Subject}",
            notification.Email.Recipient.Email, notification.Email.Subject);

        if (notification.RetryCount is not <= 3) return;

        var noti = new NotificationRequestModel
        {
            RetryCount = notification.RetryCount == null ? 1 : notification.RetryCount + 1,
            Email = notification.Email,
            Priority = notification.Priority
        };
        if (!AddNotification(noti))
        {
            Logger.Error("Failed to add notification to queue");
        }
    }
}