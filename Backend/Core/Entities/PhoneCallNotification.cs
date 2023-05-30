namespace Core.Entities;

public class PhoneCallNotification : BaseEntity
{
    public string? PhoneNumber { get; set; }
    public Guid? NotificationSettingId { get; set; }
    public NotificationSetting? NotificationSetting { get; set; }
    
    public Guid? AutomationSettingId { get; set; }
    public AutomationSetting? AutomationSetting { get; set; }
}