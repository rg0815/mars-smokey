namespace Core.Entities;

public class FireAlarm : BaseEntity
{
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public required List<SmokeDetectorAlarm> AlarmedDetectors { get; set; } 
    public bool IsProbableFalseAlarm { get; set; } = false;
    public bool WasFalseAlarm { get; set; } = false;
    public Guid BuildingUnitId { get; set; }
    public BuildingUnit BuildingUnit { get; set; }
    public bool IsActive() => EndTime == DateTime.MinValue;

}