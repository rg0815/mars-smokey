//
// Created by Roman on 26.04.2023.
//

#include "defaultMode/PluginHandler.h"
#include "Config.h"
#include <vector>
#include "defaultMode/plugins/FA22RF.h"
#include "defaultMode/plugins/RM175RF.h"
#include "defaultMode/DefaultMode.h"
#include "utils/MqttMessage.h"
#include "utils/LogHelper.h"

bool PluginHandler::isSending433 = false;


std::vector<PluginBase *> plugins;

PluginBase *PluginHandler::getPluginByName(const char *name) {
    for (PluginBase *plugin: plugins) {
        if (strcmp(plugin->name, name) == 0) {
            return plugin;
        }
    }
    return nullptr;
}

void PluginHandler::registerPlugin(PluginBase *plugin) {
    if (plugin == nullptr) {
        LogHelper::log("PluginHandler", "Cannot register null plugin",
                       logging::LoggerLevel::LOGGER_LEVEL_WARN);
        return;
    }

    plugin->create();

    LogHelper::log("PluginHandler", "Registering plugin: " + String(plugin->name),
                   logging::LoggerLevel::LOGGER_LEVEL_INFO);

    plugins.push_back(plugin);
}

void PluginHandler::pluginLoop() {
    for (PluginBase *plugin: plugins) {
        plugin->loop();

        if (!plugin->activeAlarms.empty()) {
            for (const char *alarm: plugin->activeAlarms) {
                plugin->performAlarm(alarm);
            }
        }
    }
}

void PluginHandler::interruptHandler(bool state, unsigned long value) {
    for (PluginBase *plugin: plugins) {
        plugin->decode(state, value);
    }
}

void PluginHandler::setup() {
    isSending433 = false;
    setup433();
}

ICACHE_RAM_ATTR void PluginHandler::rx433Callback() {
    if (isSending433) {
        return;
    }

    static unsigned long rx433LineUp, rx433LineDown;
    unsigned long LowVal, HighVal;
    int rx433State = digitalRead(Config::RECEIVER_433_PIN); // current pin state
    if (rx433State)                                         // pin is now HIGH
    {
        rx433LineUp = micros();               // line went HIGH after being LOW at this time
        LowVal = rx433LineUp - rx433LineDown; // calculate the LOW pulse time
        interruptHandler(rx433State, LowVal);
    } else {
        rx433LineDown = micros();              // line went LOW after being HIGH
        HighVal = rx433LineDown - rx433LineUp; // calculate the HIGH pulse time

        if (HighVal > 31999)
            HighVal = 31999; // we will store this as unsigned int
        interruptHandler(rx433State, HighVal);
    }
}

void PluginHandler::setup433() {

    if (!Config::RECEIVER_433_ENABLED) {
        LogHelper::log("433MHz", "433 MHz disabled", logging::LoggerLevel::LOGGER_LEVEL_INFO);
        return;
    }

    LogHelper::log("433MHz", "433 MHz enabled - registering plugins!", logging::LoggerLevel::LOGGER_LEVEL_INFO);

    pinMode(Config::TRANSMITTER_433_PIN, OUTPUT);
    pinMode(Config::RECEIVER_433_PIN, INPUT);
    attachInterrupt(digitalPinToInterrupt(Config::RECEIVER_433_PIN), rx433Callback, CHANGE);


    PluginBase *fa22rf = new FA22RF();
    PluginBase *rm175Rf = new RM175RF();

    registerPlugin(fa22rf);
    registerPlugin(rm175Rf);
}

void PluginHandler::addAlarm(PluginBase *plugin, const char *rawSignal) {
    plugin->activeAlarms.emplace_back(rawSignal);
}

void PluginHandler::sendAlarmToBackend(PluginBase *plugin, const char *code) {

    DynamicJsonDocument payloadDoc(256);
    payloadDoc["model"] = plugin->name;
    payloadDoc["rawCode"] = code;

    String payload;
    serializeJson(payloadDoc, payload);

    MqttMessage message;

    if(DefaultMode::isPairing){
        message = MqttMessage(Config::MQTT_CLIENTID.c_str(), R_PairingSmokeDetectorInfo, payload.c_str());
    }else{
        message = MqttMessage(Config::MQTT_CLIENTID.c_str(), S_Alarm, payload.c_str());

    }
    
    DefaultMode::enqueueMqttMessage(message);
}

void PluginHandler::stopAlarm(PluginBase *plugin, const char *rawCode) {
    plugin->activeAlarms.erase(
            std::remove_if(
                    plugin->activeAlarms.begin(),
                    plugin->activeAlarms.end(),
                    [rawCode](const char* alarm) { return strcmp(alarm, rawCode) == 0; }),
            plugin->activeAlarms.end());
}


