namespace backend_system_service.Models;

public class BasicUpdateRequest
{
    public string Name { get; set; }
    public string Description { get; set; }
}

public class GatewayUpdateRequest : BasicUpdateRequest
{
    public string RoomId { get; set; }
}

public class SmokeDetectorInitRequest : BasicUpdateRequest
{
    public Guid RoomId { get; set; }
    public Guid SmokeDetectorModelId { get; set; }
}