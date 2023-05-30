using Core.Entities;

namespace backend_system_service.Models;

public class AddOrUpdateNotificationRequest
{
    public bool EmailNotification { get; set; }
    public bool SmsNotification { get; set; }
    public bool PhoneCallNotification { get; set; }
    public bool PushNotification { get; set; }
    public bool HttpNotification { get; set; }
    public string? Email { get; set; }
    public string? PhoneNumber { get; set; }
    public string? SMSNumber { get; set; }
    public bool NumbersAreIdentical { get; set; }
    public List<string> PushNotificationTokens { get; set; } = new();
    public List<AddHttpNotificationRequest> HttpNotifications { get; set; } = new();
}

public class AddHttpNotificationRequest
{
    public string? Url { get; set; }
    public string? Method { get; set; }
    public string? Body { get; set; }
    public List<AddHeaderRequest>? Headers { get; set; } = new();
}

public class AddHeaderRequest
{
    public string? Key { get; set; }
    public string? Value { get; set; }
}