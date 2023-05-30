namespace Core.Entities;

public abstract class EmailNotification : BaseEntity
{
    public required string Email { get; set; }
}

public class UserEmailNotification : EmailNotification
{
    public Guid? NotificationSettingId { get; set; }
    public NotificationSetting? NotificationSetting { get; set; }
}

public class AutomationEmailNotification : EmailNotification
{
    public Guid? AutomationSettingId { get; set; }
    public AutomationSetting? AutomationSetting { get; set; }
    public string? Subject { get; set; }
    public string? Text { get; set; }
}