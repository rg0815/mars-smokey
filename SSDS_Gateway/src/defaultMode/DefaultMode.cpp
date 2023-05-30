#include "defaultMode/DefaultMode.h"
#include "utils/CustomLED.h"
#include <Arduino.h>

#include <utility>
#include "Config.h"
#include "WiFi.h"
#include "utils/Timer.h"
#include "utils/PersistentDataManager.h"
#include "StringArray.h"
#include "utils/LogHelper.h"
#include "utils/DisplayHelper.h"
#include "defaultMode/PluginHandler.h"
#include <ArduinoQueue.h>


DefaultMode *DefaultMode::self = nullptr;

ArduinoQueue<MqttMessage> DefaultMode::mqttMessageQueue(30); // Add this line

bool DefaultMode::isInitialized = false;
bool DefaultMode::isConfigured = false;
bool DefaultMode::hasSetupReceivers = false;
bool DefaultMode::showUsername = false;
bool DefaultMode::isPairing = false;
unsigned long DefaultMode::lastDisplayChange = 0;
bool DefaultMode::toggleUsernameQr = false;

void DefaultMode::enqueueMqttMessage(const MqttMessage &message) {
    mqttMessageQueue.enqueue(message);
}

bool DefaultMode::sendMQTTMessage(const char *topic, const MqttMessage &msg) {
    LogHelper::log("MQTT", "Sending mqtt message", logging::LoggerLevel::LOGGER_LEVEL_INFO);

    char topic_full[strlen(Config::MQTT_TOPIC_PREFIX) + strlen(topic) + 1];
    strcpy(topic_full, Config::MQTT_TOPIC_PREFIX);
    strcat(topic_full, topic);

    const char *msgString = msg.toMqttString();

    bool res = mqtt.publish(topic_full, msgString, false, 1);
    if (!res) {
        LogHelper::log("MQTT", "Error sending message", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
        DisplayHelper::showMqttError(mqtt.lastError());
        DisplayHelper::showTextOnDisplay("Error sending message");
    }
    return res;
}

void DefaultMode::mqttCallback(String &topic, String &payloadMsg) {
    MqttMessage *msg = MqttMessage::fromMqttString(payloadMsg.c_str());
    if (msg == nullptr) {
        LogHelper::log("MQTT", "Could not parse message", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
        DisplayHelper::showTextOnDisplay("Could not parse message");
        return;
    }
    DynamicJsonDocument payload = msg->getPayload();

    switch (msg->getType()) {

        case S_Connected:
            break;
        case R_UsernameInfo:
            LogHelper::log("MQTT", "UsernameInfo received", logging::LoggerLevel::LOGGER_LEVEL_INFO);
            DisplayHelper::showTextOnDisplay("UsernameInfo received");

            const char *username;
            username = payload["username"];
            if (strlen(username) > 0) {
                LogHelper::log("MQTT", "Username: " + String(username), logging::LoggerLevel::LOGGER_LEVEL_INFO);
                DisplayHelper::showTextOnDisplay("Username: " + String(username));

                if (PersistentDataManager::writeFile(Config::FS_USERNAME_PATH, username)) {
                    LogHelper::log("MQTT", "Username saved to Filesystem", logging::LoggerLevel::LOGGER_LEVEL_INFO);
                    DisplayHelper::showTextOnDisplay("Username saved to Filesystem");
                } else {
                    LogHelper::log("MQTT", "Could not save Username to Filesystem",
                                   logging::LoggerLevel::LOGGER_LEVEL_ERROR);
                    DisplayHelper::showTextOnDisplay("Could not save Username to Filesystem");
                }
                DisplayHelper::showTextOnDisplay("System initialized. Restarting...", 1000);
                LogHelper::log("MQTT", "System initialized. Restarting...", logging::LoggerLevel::LOGGER_LEVEL_INFO);
                delay(1000);
                ESP.restart();
                break;

            } else {
                LogHelper::log("MQTT", "Username is empty", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
                DisplayHelper::showTextOnDisplay("Username is empty");
            }
            break;

        case S_Info:
            break;
        case S_Alert:
            break;
        case S_Alarm:
            break;
        case R_StartPairing:
            LogHelper::log("MQTT", "Start pairing", logging::LoggerLevel::LOGGER_LEVEL_INFO);
            showUsername = true;
            break;
        case R_StopPairing:
            LogHelper::log("MQTT", "Stop pairing", logging::LoggerLevel::LOGGER_LEVEL_INFO);
            showUsername = false;
            break;
        case R_StartPairingSmokeDetector:
            LogHelper::log("MQTT", "Start pairing smoke detector", logging::LoggerLevel::LOGGER_LEVEL_INFO);
            isPairing = true;
            break;
        case R_StopPairingSmokeDetector:
            LogHelper::log("MQTT", "Stop pairing smoke detector", logging::LoggerLevel::LOGGER_LEVEL_INFO);
            isPairing = false;
            break;
        case R_GatewayInitialized:
            LogHelper::log("MQTT", "Gateway initialized", logging::LoggerLevel::LOGGER_LEVEL_INFO);
            DisplayHelper::showTextOnDisplay("Gateway initialized");
            isInitialized = true;
            break;
        case R_PairingSmokeDetectorInfo:
            break;
        case R_PerformAlarm:
            LogHelper::log("MQTT", "addAlarm received", logging::LoggerLevel::LOGGER_LEVEL_INFO);
            DisplayHelper::showTextOnDisplay("addAlarm received");

            const char *pluginName;
            pluginName = payload["pluginName"];
            const char *rawCode;
            rawCode = payload["rawCode"];

            PluginBase *plugin;
            plugin = PluginHandler::getPluginByName(pluginName);
            PluginHandler::addAlarm(plugin, rawCode);
            break;
        case R_StopAlarm:
            LogHelper::log("MQTT", "stopAlarm received", logging::LoggerLevel::LOGGER_LEVEL_INFO);
            DisplayHelper::showTextOnDisplay("stopAlarm received");

            const char *pluginNameStop;
            pluginNameStop = payload["pluginName"];
            const char *rawCodeStop;
            rawCodeStop = payload["rawCode"];

            PluginBase *pluginStop;
            pluginStop = PluginHandler::getPluginByName(pluginNameStop);
            PluginHandler::stopAlarm(pluginStop, rawCodeStop);
            break;
    }
}

DefaultMode::DefaultMode(CustomLED *led, String wifi_ssid, String wifi_password)
        : Mode(led),
          net(),
          mqtt(256),
          wifi_ssid(std::move(wifi_ssid)),
          wifi_password(std::move(wifi_password)) {
    LogHelper::log("DefaultMode", "Starting in default mode", logging::LoggerLevel::LOGGER_LEVEL_INFO);
    self = this;
}

void DefaultMode::setWiFiHostname(const char *hostname) {
    WiFiClass::setHostname(hostname);
}

bool DefaultMode::subscribeMQTT(const char *topic, bool usePrefix = true) {
    DisplayHelper::showTextOnDisplay("Subscribing to topic: " + String(topic), 500);
    LogHelper::log("MQTT", "Subscribing to topic: " + String(topic), logging::LoggerLevel::LOGGER_LEVEL_INFO);

    if (usePrefix) {
        char topic_full[strlen(Config::MQTT_TOPIC_PREFIX) + strlen(topic) + 1];
        strcpy(topic_full, Config::MQTT_TOPIC_PREFIX);
        strcat(topic_full, topic);
        bool result = mqtt.subscribe(topic_full, 1);
        if (!result) {
            LogHelper::log("MQTT", "Error subscribing to topic: " + String(topic_full) + " - " + mqtt.lastError(),
                           logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            DisplayHelper::showMqttError(mqtt.lastError());
            DisplayHelper::showTextOnDisplay("Error subscribing to topic: " + String(topic_full));
        }
        return result;
    } else {
        bool result = mqtt.subscribe(topic, 1);
        if (!result) {
            LogHelper::log("MQTT", "Error subscribing to topic: " + String(topic) + " - " + mqtt.lastError(),
                           logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            DisplayHelper::showMqttError(mqtt.lastError());
            DisplayHelper::showTextOnDisplay("Error subscribing to topic: " + String(topic));
        }
        return result;
    }
}

void DefaultMode::connectMQTT(bool isRegistration = false) {
    DisplayHelper::showTextOnDisplay("Connecting to MQTT Broker", 500);
    LogHelper::log("MQTT", "Connecting to MQTT Broker", logging::LoggerLevel::LOGGER_LEVEL_INFO);

    String usedUsername = "";
    if (isRegistration) {
        usedUsername = "NEW-GATEWAY";
    } else {
        usedUsername = Config::MQTT_USERNAME;
    }

    Timer timer(1);
    while (!mqtt.connect(Config::MQTT_CLIENTID.c_str(), usedUsername.c_str(), Config::MQTT_PASSWORD.c_str())) {
        timer.start();
        while (!timer.isExpired()) {
            led->loop();
            delay(50);
        }
        Serial.print(".");
        delay(50);
    }
    LogHelper::log("MQTT", "Connected to MQTT Broker", logging::LoggerLevel::LOGGER_LEVEL_INFO);
    DisplayHelper::showTextOnDisplay("Connected to MQTT Broker", 500);

    String prefix = "";
    String topic = "";

    if (isRegistration) {
        prefix = "register/";
        topic = prefix + Config::MQTT_CLIENTID;
    } else {
        prefix = "down/";
        topic = prefix + Config::MQTT_CLIENTID;
    }

    bool result = this->subscribeMQTT(topic.c_str());
    if (result) {
        DisplayHelper::showTextOnDisplay("Subscribed!", 500);
        LogHelper::log("MQTT", "Subscribed!", logging::LoggerLevel::LOGGER_LEVEL_INFO);

        if (!isRegistration) {
            String upPrefix = "up/";
            String upTopic = upPrefix + Config::MQTT_CLIENTID;

            this->sendMQTTMessage(upTopic.c_str(),
                                  MqttMessage(Config::MQTT_CLIENTID.c_str(), S_Connected, "Connected!"));
        }
    } else {
        DisplayHelper::showTextOnDisplay("Could not subscribe to topic");
        LogHelper::log("MQTT", "Could not subscribe to topic - ", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
        DisplayHelper::showMqttError(mqtt.lastError());
    }
}

void DefaultMode::connectWifi(const char *ssid, const char *password) {
    DisplayHelper::showTextOnDisplay("Connecting to WiFi with SSID: " + String(ssid), 500);
    LogHelper::log("WiFi", "Connecting to WiFi with SSID: " + String(ssid), logging::LoggerLevel::LOGGER_LEVEL_INFO);

    WiFiClass::mode(WIFI_STA);
    WiFi.begin(ssid, password);
    Timer timer(1);
    while (WiFiClass::status() != WL_CONNECTED) {
        timer.start();
        while (!timer.isExpired()) {
            led->loop();
            delay(50); // nötig, damit WLAN Verbindung aufgebaut wird
        }
        Serial.print(".");
    }

    LogHelper::log("WiFi", "WiFi connected", logging::LoggerLevel::LOGGER_LEVEL_INFO);
    LogHelper::log("WiFi", "IP address: " + WiFi.localIP().toString(), logging::LoggerLevel::LOGGER_LEVEL_INFO);

    DisplayHelper::showTextOnDisplay("Connected. IP: " + WiFi.localIP().toString(), 300);
}

void DefaultMode::checkConfigured() {
    if (!PersistentDataManager::readFile(Config::FS_USERNAME_PATH, &Config::MQTT_USERNAME)) {
        LogHelper::log("DefaultMode", "System not initialized.", logging::LoggerLevel::LOGGER_LEVEL_INFO);
        isConfigured = false;
    } else {
        LogHelper::log("DefaultMode", "System initialized.", logging::LoggerLevel::LOGGER_LEVEL_INFO);
        isConfigured = true;
    }
}

void DefaultMode::setup() {
    DisplayHelper::showTextOnDisplay("Starting in DefaultMode", 500);

    checkConfigured();

    this->setWiFiHostname(Config::MQTT_CLIENTID.c_str());
    this->connectWifi(wifi_ssid.c_str(), wifi_password.c_str());

    LogHelper::log("MQTT", "Connecting to MQTT Broker: " + Config::MQTT_HOST + ":" + String(Config::MQTT_PORT),
                   logging::LoggerLevel::LOGGER_LEVEL_INFO);
    DisplayHelper::showTextOnDisplay(
            "Connecting to MQTT Broker: " + Config::MQTT_HOST + ":" + String(Config::MQTT_PORT), 500);
    mqtt.begin(Config::MQTT_HOST.c_str(), Config::MQTT_PORT, net);
    mqtt.onMessage(mqttCallback);

    if (isConfigured) {
        this->connectMQTT();
    } else {
        this->connectMQTT(true);
    }
    delay(50);
}

void DefaultMode::loop() {
    mqtt.loop();

    if (WiFiClass::status() != WL_CONNECTED) {
        LogHelper::log("WiFi", "WiFi disconnected. Reconnecting...", logging::LoggerLevel::LOGGER_LEVEL_INFO);
        DisplayHelper::showTextOnDisplay("WiFi disconnected. Reconnecting...", 500);
        WiFi.reconnect();
    }

    if (!mqtt.connected()) {
        LogHelper::log("MQTT", "Reconnecting to MQTT Broker", logging::LoggerLevel::LOGGER_LEVEL_INFO);
        DisplayHelper::showTextOnDisplay("Reconnecting to MQTT Broker", 500);
        this->connectMQTT(!isConfigured);
        delay(50);
    }

    if (showUsername) {
        // cycle every 5 seconds between username and qr code of username
        if (millis() - lastDisplayChange > 5000) {
            if (toggleUsernameQr) {
                DisplayHelper::showTextOnDisplay(Config::MQTT_CLIENTID, 0);
                toggleUsernameQr = false;
            } else {
                DisplayHelper::showQRCodeOnDisplay(Config::MQTT_CLIENTID);
                toggleUsernameQr = true;
            }
            lastDisplayChange = millis();
        }
    }

    if (isConfigured && isInitialized) {
        if (!hasSetupReceivers) {
            PluginHandler::setup();
            hasSetupReceivers = true;
        }


        if (isPairing) {
            DisplayHelper::showTextOnDisplay("Pairing Smoke Detector...", 0);
        }

        PluginHandler::pluginLoop();
    }

    while (!mqttMessageQueue.isEmpty()) {
        MqttMessage message = mqttMessageQueue.dequeue();
        String prefix = "up/";
        String topic = prefix + Config::MQTT_CLIENTID;
        sendMQTTMessage(topic.c_str(), message);
    }
}
