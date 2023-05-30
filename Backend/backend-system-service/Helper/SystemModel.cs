using Core.Entities;

namespace backend_system_service.Helper;

public class SystemModel
{
    public bool IsAuthenticated { get; set; }
    public Guid BuildingUnitId { get; set; }
}