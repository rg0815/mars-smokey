using Core.Entities;

namespace backend_system_service.Models;

public class AlarmHandlerModel
{
    public List<string> SmokeDetectors { get; set; } = new();
    public required string Location { get; set; }
    public bool IsExpanding { get; set; }
    public bool IsProbableFalseAlarm { get; set; }
    public bool HandlePreAlarm { get; set; }
    public bool EvacuateBuilding { get; set; }
    public Room Room { get; set; }
    public BuildingUnit BuildingUnit { get; set; }
    public Guid BuildingId { get; set; }
}