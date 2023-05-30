namespace backend_notification_service.Models;

public class HttpNotificationRequestModel
{
    public string Url { get; set; }
    public string Method { get; set; }
    public string Body { get; set; }
    public List<Tuple<string, string>> Headers { get; set; }
}