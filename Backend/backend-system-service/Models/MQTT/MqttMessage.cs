using System.Text.Json.Serialization;

namespace backend_system_service.Models.MQTT;

public class MqttMessage
{
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public MqttMessageAction Action { get; set; }
    public string ClientId { get; set; }
    public string Payload { get; set; }
}

public enum MqttMessageAction
{
    R_Connected,
    S_UsernameInfo,
    R_Info,
    R_Alert,
    R_Alarm,
    S_StartPairingGateway,
    S_StopPairingGateway,
    S_StartPairingSmokeDetector,
    S_StopPairingSmokeDetector,
    R_PairingSmokeDetectorInfo,
    S_GatewayInitialized,
    S_PerformAlarm,
    S_StopAlarm,
    SF_PairingSmokeDetectorInfo,
}