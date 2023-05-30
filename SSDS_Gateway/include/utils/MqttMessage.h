#ifndef MQTT_MESSAGE_H
#define MQTT_MESSAGE_H

#include "ArduinoJson.h"

enum MessageType
{
    S_Connected,
    R_UsernameInfo,
    S_Info,
    S_Alert,
    S_Alarm,
    R_StartPairing,
    R_StopPairing,
    R_StartPairingSmokeDetector,
    R_StopPairingSmokeDetector,
    R_PairingSmokeDetectorInfo,
    R_GatewayInitialized,
    R_PerformAlarm,
    R_StopAlarm,
};
class MqttMessage {
public:
    MqttMessage();
    MqttMessage(const char* clientId, MessageType type, const char* payload);
    MqttMessage(const MqttMessage& other);
    MqttMessage& operator=(const MqttMessage& other);
    ~MqttMessage();

    const char* getClientId() const;
    MessageType getType() const;
    DynamicJsonDocument getPayload() const;
    const char* toMqttString() const;
    static MqttMessage* fromMqttString(const char* mqttString);

private:
    void copy(const MqttMessage& other);
    char* _clientId;
    MessageType _type;
    char* _payload;
};

#endif