using System.Text.Json.Serialization;

namespace backend_system_service.Models.MQTT;

public class MqttAuthResponse
{
    [JsonPropertyName("result")] public string Result { get; set; }
    [JsonPropertyName("is_superuser")] public bool is_superuser { get; set; }
}