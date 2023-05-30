namespace backend_notification_service.Models;

public class NotificationRequestModel
{
    public int? RetryCount { get; set; }
    public PriorityType Priority { get; set; }
    public DateTime CreatedAt { get; set; }
    public EmailNotificationRequestModel? Email { get; set; }
    public HttpNotificationRequestModel? Http { get; set; }
    public SmsNotificationRequestModel? Sms { get; set; }
    public PhoneNotificationRequestModel? Phone { get; set; }
}

public enum PriorityType : int
{
    Critical = 10,
    Alert = 20,
    Maintenance = 100,
}