namespace backend_system_service.Models;

public class AddBuildingRequest
{
    public string BuildingName { get; set; }
    public string BuildingDescription { get; set; } 
    public string Street { get; set; }
    public string City { get; set; }
    public string ZipCode { get; set; }
    public string Country { get; set; }
}