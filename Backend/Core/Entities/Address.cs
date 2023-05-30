using Newtonsoft.Json;

namespace Core.Entities;

public class Address : BaseEntity
{
    public required string Street { get; set; }
    public required string City { get; set; }
    public required string ZipCode { get; set; }
    public required string Country { get; set; }
    public Guid BuildingId { get; set; }
    public Building Building { get; set; }
}