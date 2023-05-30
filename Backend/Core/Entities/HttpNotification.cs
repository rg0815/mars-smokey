namespace Core.Entities;

public class HttpNotification : BaseEntity
{
    public Guid? NotificationSettingId { get; set; }
    public NotificationSetting? NotificationSetting { get; set; }
    
    public Guid? AutomationSettingId { get; set; }
    public AutomationSetting? AutomationSetting { get; set; }
    public string? Url { get; set; }
    public string? Method { get; set; }
    public string? Body { get; set; }
    public List<Header>? Headers { get; set; } = new();
}