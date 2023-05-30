namespace backend_system_service.Helper;

public class UserModel
{
    public Guid UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public Guid TenantId { get; set; }
    public bool IsSuperAdmin { get; set; }
    public bool IsTenantAdmin { get; set; }
    public List<Guid> WriteBuildingUnitIds { get; set; } = new();
    public List<Guid> ReadBuildingUnitIds { get; set; } = new();
}