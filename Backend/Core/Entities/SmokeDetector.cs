namespace Core.Entities;

public class SmokeDetector : BaseEntity
{
    public bool IsViaMqtt { get; set; }
    public string? MqttTopic { get; set; }
    public string? MqttMessage { get; set; }
    public Guid SmokeDetectorModelId { get; set; }
    public SmokeDetectorModel? SmokeDetectorModel { get; set; }
    public string? RawTransmissionData { get; set; }
    public SmokeDetectorState State { get; set; }
    public DateTime LastBatteryReplacement { get; set; }
    public double BatteryLevel { get; set; }
    public bool BatteryLow { get; set; }
    public DateTime LastMaintenance { get; set; }
    public List<SmokeDetectorAlarm>? Events { get; set; }
    public List<SmokeDetectorMaintenance>? Maintenances { get; set; }
    public Guid? RoomId { get; set; }
    public Room? Room { get; set; }
}

public enum SmokeDetectorState 
{
    Normal,
    Warning,
    Alert
}