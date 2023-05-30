namespace Core.Entities;

public class NotificationSetting : BaseEntity
{
    public required Guid UserId { get; set; }
    public bool EmailNotification { get; set; }
    public bool SmsNotification { get; set; }
    public bool PhoneCallNotification { get; set; }
    public bool PushNotification { get; set; }
    public bool HttpNotification { get; set; }
    public required UserEmailNotification Email { get; set; }
    public required PhoneCallNotification PhoneNumber { get; set; }
    public required SmsNotification SmsNumber { get; set; }
    public List<PushNotificationToken> PushNotificationTokens { get; set; } = new();
    public List<HttpNotification> HttpNotifications { get; set; } = new();
}