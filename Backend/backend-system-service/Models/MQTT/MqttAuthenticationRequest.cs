namespace backend_system_service.Models.MQTT;

public class MqttAuthenticationRequest
{
    public string Username { get; set; }
    public string Password { get; set; }
    public string ClientId { get; set; }
}