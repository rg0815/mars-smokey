using System.ComponentModel.DataAnnotations.Schema;

namespace Core.Entities;

public class AutomationSetting : BaseEntity
{
    public List<HttpNotification> HttpNotifications { get; set; } = new();
    public List<AutomationEmailNotification> EmailNotifications { get; set; } = new();
    public List<AutomationSmsNotification> SmsNotifications { get; set; } = new();
    public List<PhoneCallNotification> PhoneCallNotifications { get; set; } = new();
    public Guid BuildingUnitId { get; set; }
    public BuildingUnit BuildingUnit { get; set; }
}

public class PreAlarmAutomationSetting : BaseEntity
{
    public List<HttpNotification> HttpNotifications { get; set; } = new();
    public List<AutomationEmailNotification> EmailNotifications { get; set; } = new();
    public List<AutomationSmsNotification> SmsNotifications { get; set; } = new();
    public List<PhoneCallNotification> PhoneCallNotifications { get; set; } = new();
    public Guid BuildingUnitId { get; set; }
    public BuildingUnit BuildingUnit { get; set; }
}