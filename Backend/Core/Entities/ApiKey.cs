namespace Core.Entities;

public class ApiKey : BaseEntity
{
    public Guid Key { get; set; }
    public bool IsActive { get; set; }
    public DateTime? LastUsed { get; set; }
    public Guid BuildingUnitId { get; set; }
    public BuildingUnit BuildingUnit { get; set; }
}