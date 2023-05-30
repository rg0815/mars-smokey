using backend_notification_service.Models;
using NLog;

namespace backend_notification_service.Notifier;

public static class HttpNotifier
{
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();

    public static void SendHttpRequest(HttpNotificationRequestModel notification)
    {
        Logger.Info("Sending HTTP request");
        
        var client = new HttpClient();
        var request = new HttpRequestMessage
        {
            Method = new HttpMethod(notification.Method),
            RequestUri = new Uri(notification.Url),
            Content = new StringContent(notification.Body)
        };
        foreach (var header in notification.Headers)
        {
            request.Headers.Add(header.Item1, header.Item2);
        }
        
        client.SendAsync(request);
        
        Logger.Info("HTTP request sent");
        client.Dispose();
        request.Dispose();
    }
}