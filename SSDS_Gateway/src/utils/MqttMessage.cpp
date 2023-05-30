#include "utils/MqttMessage.h"
#include "ArduinoJson.h"
#include "utils/LogHelper.h"
#include "Config.h"
#include <ArduinoJson.h>

MqttMessage::MqttMessage() : _clientId(nullptr), _type(S_Connected), _payload(nullptr) {}

MqttMessage::MqttMessage(const char *clientId, MessageType type, const char *payload)
        : _clientId(nullptr), _type(type), _payload(nullptr) {
    _clientId = new char[strlen(clientId) + 1];
    strcpy(_clientId, clientId);

    _payload = new char[strlen(payload) + 1];
    strcpy(_payload, payload);
}

MqttMessage::MqttMessage(const MqttMessage &other) {
    copy(other);
}

MqttMessage &MqttMessage::operator=(const MqttMessage &other) {
    if (this != &other) {
        delete[] _clientId;
        delete[] _payload;
        copy(other);
    }
    return *this;
}

MqttMessage::~MqttMessage() {
    delete[] _clientId;
    delete[] _payload;
}

const char *MqttMessage::getClientId() const {
    return _clientId;
}

MessageType MqttMessage::getType() const {
    return _type;
}

DynamicJsonDocument MqttMessage::getPayload() const {
    Serial.println("getPayload");
    Serial.println(_payload);

    DynamicJsonDocument jsonDoc(512);

    DeserializationError error = deserializeJson(jsonDoc, _payload);

    // Test if parsing succeeds.
    if (error) {
        Serial.print(F("deserializeJson() failed: "));
        Serial.println(error.f_str());
        return jsonDoc;
    }

    return jsonDoc;
}

void MqttMessage::copy(const MqttMessage &other) {
    _type = other._type;

    _clientId = new char[strlen(other._clientId) + 1];
    strcpy(_clientId, other._clientId);

    _payload = new char[strlen(other._payload) + 1];
    strcpy(_payload, other._payload);
}

MqttMessage *MqttMessage::fromMqttString(const char *mqttString) {
    StaticJsonDocument<512> jsonDoc;
    DeserializationError error = deserializeJson(jsonDoc, mqttString);
    if (error) {
        LogHelper::log("MqttMessage", "Failed to deserialize JSON string", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
        return nullptr;
    }

    const char *clientId = jsonDoc["ClientId"];
    const char *payload = jsonDoc["Payload"];
    MessageType type = static_cast<MessageType>(jsonDoc["Action"].as<int>());
    auto *message = new MqttMessage(clientId, type, payload);
    return message;
}

const char *MqttMessage::toMqttString() const {
    StaticJsonDocument<200> jsonDoc;
    jsonDoc["clientId"] = _clientId;
    jsonDoc["action"] = _type;
    jsonDoc["payload"] = _payload;
    String jsonStr;
    serializeJson(jsonDoc, jsonStr);

    Serial.println(jsonStr);

    return jsonStr.c_str();
}
