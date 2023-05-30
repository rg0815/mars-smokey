namespace backend_system_service.Models.MQTT;

public class MqttAuthorizationRequest
{
    public string Action { get; set; }
    public string ClientId { get; set; }
    public string MountPoint { get; set; }
    public string PeerHost { get; set; }
    public string Topic { get; set; }
    public string Username { get; set; }
}