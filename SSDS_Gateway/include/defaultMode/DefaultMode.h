#ifndef DEFAULTMODE_H
#define DEFAULTMODE_H
#include <Arduino.h>
#include "Mode.h"
#include <WiFiClient.h>
#include <ArduinoQueue.h>
#include "MQTT.h"
#include "utils/MqttMessage.h"
#include <memory>

class CustomLED;

class DefaultMode : public Mode
{
private:
    WiFiClient net;
    MQTTClient mqtt;
    String wifi_ssid;
    String wifi_password;
    static bool isConfigured;
    static bool isInitialized;
    static bool hasSetupReceivers;
    static bool showUsername;
    static unsigned long lastDisplayChange;
    static bool toggleUsernameQr;
    static ArduinoQueue<MqttMessage> mqttMessageQueue;

    static DefaultMode *self;

    DefaultMode();

    static void setWiFiHostname(const char *hostname);
    void connectWifi(const char *ssid, const char *password);
    void connectMQTT(bool isRegistration);
    bool subscribeMQTT(const char *topic, bool usePrefix);
    static void mqttCallback(String &topic, String &payload);
    static void checkConfigured();


public:
    DefaultMode(CustomLED *led, String wifi_ssid, String wifi_password);

    void setup() override;

    void loop() override;

    static void enqueueMqttMessage(const MqttMessage &message);
    bool sendMQTTMessage(const char *topic, const MqttMessage& msg);


    static bool isPairing;
};

#endif // DEFAULTMODE_H