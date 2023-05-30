using Newtonsoft.Json;

namespace Core.Entities;

public class Room : BaseEntity
{
    public List<Gateway> Gateways { get; set; }
    public List<SmokeDetector> SmokeDetectors { get; set; }
    public Guid BuildingUnitId { get; set; }
    public BuildingUnit BuildingUnit { get; set; }
}