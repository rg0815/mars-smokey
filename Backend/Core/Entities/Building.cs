using Newtonsoft.Json;

namespace Core.Entities;

public class Building : BaseEntity
{
    public required Address Address { get; set; }
    public required List<BuildingUnit> BuildingUnits { get; set; }
    public Guid TenantId { get; set; }
    public required Tenant Tenant { get; set; }
}