namespace Core.Entities;

public class BuildingUnit : BaseEntity
{
    public required List<FireAlarm> FireAlarms { get; set; }
    public required List<Room> Rooms { get; set; }
    public bool SendPreAlarm { get; set; } = false;
    public bool SendMqttInfo { get; set; } = false;
    public string? MqttText { get; set; }
    public List<ApiKey> ApiKeys { get; set; }
    public List<MqttConnectionData> MqttConnectionData { get; set; }
    public PreAlarmAutomationSetting PreAlarmNotification { get; set; }
    public AutomationSetting AutomationSetting { get; set; }
    public Guid BuildingId { get; set; }
    public required Building Building { get; set; }
}