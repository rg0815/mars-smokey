namespace Core.Entities;

public class Tenant : BaseEntity
{
    public ICollection<Building>? Buildings { get; set; }
}