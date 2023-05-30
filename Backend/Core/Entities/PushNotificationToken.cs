namespace Core.Entities;

public class PushNotificationToken : BaseEntity
{
    public Guid NotificationSettingId { get; set; }
    public NotificationSetting NotificationSetting { get; set; }
    public string? Token { get; set; }
}