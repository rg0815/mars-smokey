namespace Core.Entities;

public class MqttConnectionData : BaseEntity
{
    public string? ClientId { get; set; }
    public Guid Username { get; set; }
    public string PasswordHash { get; set; }
    public Guid BuildingUnitId { get; set; }
    public BuildingUnit BuildingUnit { get; set; }
}