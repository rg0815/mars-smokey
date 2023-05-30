using Newtonsoft.Json;

namespace Core.Entities;

public class SmokeDetectorAlarm : BaseEntity
{
    public DateTime StartTime { get; set; }
    public Guid SmokeDetectorId { get; set; }
    public SmokeDetector SmokeDetector { get; set; }
    public FireAlarm FireAlarm { get; set; }
    public Guid FireAlarmId { get; set; }
}