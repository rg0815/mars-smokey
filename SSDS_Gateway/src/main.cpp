#include <Arduino.h>
#include "Config.h"
#include "utils/MultiResetDetector.h"
#include "utils/PersistentDataManager.h"
#include "utils/CustomLED.h"
#include "configMode/ConfigMode.h"
#include "defaultMode/DefaultMode.h"
#include "Heltec.h"
#include "utils/LogHelper.h"
#include "utils/DisplayHelper.h"
#include "utils/StringHelper.h"

CustomLED led(Config::LED_PIN);
Mode *mode = nullptr;
MultiResetDetector *mrd;

void setup() {
    btStop();

    bool needsConfig = false;

    Heltec.begin(true, false, true);
    LogHelper::log("Main", "Booting...", logging::LoggerLevel::LOGGER_LEVEL_INFO);
    DisplayHelper::showTextOnDisplay("Booting...", 300);
    delay(300);

    // Initialize Gateway
    LogHelper::log("Main", "Initialize Gateway", logging::LoggerLevel::LOGGER_LEVEL_INFO);
    DisplayHelper::showTextOnDisplay("Initialize Gateway", 300);

    // Read ClientID from Filesystem
    if (!PersistentDataManager::readFile(Config::FS_MQTT_CLIENTID_PATH, &Config::MQTT_CLIENTID)) {
        LogHelper::log("Main", "No ClientID found", logging::LoggerLevel::LOGGER_LEVEL_INFO);
        DisplayHelper::showTextOnDisplay("No ClientID found", 500);

        char guidStr[37];
        StringHelper::generateGuidWithMacAddress(guidStr);
        Config::MQTT_CLIENTID = String(guidStr);
        LogHelper::log("Main", "Generated ClientID: " + Config::MQTT_CLIENTID, logging::LoggerLevel::LOGGER_LEVEL_INFO);

        if (!PersistentDataManager::writeFile(Config::FS_MQTT_CLIENTID_PATH, guidStr)) {

            LogHelper::log("Main", "Could not write ClientID to Filesystem", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            DisplayHelper::showTextOnDisplay("Could not write ClientID to Filesystem", 1000);
        }
    } else {
        if (Config::MQTT_CLIENTID.length() == 0) {
            LogHelper::log("Main", "ClientID is empty", logging::LoggerLevel::LOGGER_LEVEL_INFO);
            DisplayHelper::showTextOnDisplay("ClientID is empty", 500);
            char guidStr[37];
            StringHelper::generateGuidWithMacAddress(guidStr);
            Config::MQTT_CLIENTID = String(guidStr);
            LogHelper::log("Main", "Generated ClientID: " + Config::MQTT_CLIENTID,
                           logging::LoggerLevel::LOGGER_LEVEL_INFO);
            DisplayHelper::showTextOnDisplay("Generated ClientID: " + Config::MQTT_CLIENTID, 500);

            // Write ClientID to Filesystem
            if (!PersistentDataManager::writeFile(Config::FS_MQTT_CLIENTID_PATH, guidStr)) {
                LogHelper::log("Main", "Could not write ClientID to Filesystem",
                               logging::LoggerLevel::LOGGER_LEVEL_ERROR);
                DisplayHelper::showTextOnDisplay("Could not write ClientID to Filesystem", 1000);
            }
        }

        LogHelper::log("Main", "ClientID: " + Config::MQTT_CLIENTID, logging::LoggerLevel::LOGGER_LEVEL_INFO);
        DisplayHelper::showTextOnDisplay("ClientID: " + Config::MQTT_CLIENTID, 500);
    }

    if (!PersistentDataManager::readFile(Config::FS_MQTT_PASSWORD_PATH, &Config::MQTT_PASSWORD)) {
        LogHelper::log("Main", "No Password found", logging::LoggerLevel::LOGGER_LEVEL_INFO);
        DisplayHelper::showTextOnDisplay("No Password found", 500);

        char guidStr[37];
        StringHelper::generateGuid(guidStr);
        Config::MQTT_PASSWORD = String(guidStr);

        if (!PersistentDataManager::writeFile(Config::FS_MQTT_PASSWORD_PATH, guidStr)) {
            LogHelper::log("Main", "Could not write Password to Filesystem", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            DisplayHelper::showTextOnDisplay("Could not write Password to Filesystem", 1000);
        }
    } else {
        if (Config::MQTT_PASSWORD.length() == 0) {
            LogHelper::log("Main", "Password is empty", logging::LoggerLevel::LOGGER_LEVEL_INFO);
            DisplayHelper::showTextOnDisplay("Password is empty", 500);
            char guidStr[37];
            StringHelper::generateGuid(guidStr);
            Config::MQTT_PASSWORD = String(guidStr);

            // Write ClientID to Filesystem
            if (!PersistentDataManager::writeFile(Config::FS_WIFI_PASSWORD_PATH, guidStr)) {
                LogHelper::log("Main", "Could not write Password to Filesystem",
                               logging::LoggerLevel::LOGGER_LEVEL_ERROR);
                DisplayHelper::showTextOnDisplay("Could not write Password to Filesystem", 1000);
            }
        }
    }

    String receiverConfig;
    if (!PersistentDataManager::readFile(Config::FS_RECEIVER_PATH, &receiverConfig)) {
        needsConfig = true;
        LogHelper::log("Main", "No ReceiverConfig found", logging::LoggerLevel::LOGGER_LEVEL_INFO);
        DisplayHelper::showTextOnDisplay("No ReceiverConfig found", 1000);
    } else {
        //receiver config example: 0,0,0
        LogHelper::log("Main", "ReceiverConfig: " + receiverConfig, logging::LoggerLevel::LOGGER_LEVEL_INFO);
        Config::RECEIVER_433_ENABLED = receiverConfig.substring(0, 1).toInt();
        Config::RECEIVER_868_ENABLED = receiverConfig.substring(2, 3).toInt();
        Config::RECEIVER_GIRA_ENABLED = receiverConfig.substring(4, 5).toInt();
    }

    // Read MQTT-Host from Filesystem
    if (!PersistentDataManager::readFile(Config::FS_MQTT_HOST_PATH, &Config::MQTT_HOST)) {
        needsConfig = true;
        LogHelper::log("Main", "No MQTT-Host found", logging::LoggerLevel::LOGGER_LEVEL_INFO);
        DisplayHelper::showTextOnDisplay("No MQTT-Host found", 1000);
    } else {
        LogHelper::log("Main", "MQTT-Host: " + Config::MQTT_HOST, logging::LoggerLevel::LOGGER_LEVEL_INFO);
        DisplayHelper::showTextOnDisplay("MQTT-Host: " + Config::MQTT_HOST, 500);
    }

    // Read MQTT-Port from Filesystem
    String mqtt_port;
    if (!PersistentDataManager::readFile(Config::FS_MQTT_PORT_PATH, &mqtt_port)) {
        needsConfig = true;
        LogHelper::log("Main", "No MQTT-Port found", logging::LoggerLevel::LOGGER_LEVEL_INFO);
        DisplayHelper::showTextOnDisplay("No MQTT-Port found", 1000);
    } else {
        Config::MQTT_PORT = mqtt_port.toInt();
        LogHelper::log("Main", "MQTT-Port: " + String(Config::MQTT_PORT), logging::LoggerLevel::LOGGER_LEVEL_INFO);
        DisplayHelper::showTextOnDisplay("MQTT-Port: " + String(Config::MQTT_PORT), 500);
    }

    mrd = new MultiResetDetector(MRD_TIMEOUT, MRD_ADDRESS);
    bool isMultiReset = mrd->detectMultiReset();
    if (!isMultiReset && !needsConfig) {
        LogHelper::log("Main", "No Multi Reset Detected => DefaultMode", logging::LoggerLevel::LOGGER_LEVEL_INFO);

        led.turnOn();
        // Wifi-Config laden
        String wifi_ssid;
        String wifi_password;

        bool successSSID = PersistentDataManager::readFile(Config::FS_WIFI_SSID_PATH, &wifi_ssid);
        bool successPassword = PersistentDataManager::readFile(Config::FS_WIFI_PASSWORD_PATH, &wifi_password);
        if (successSSID && successPassword && wifi_ssid.length() != 0) {
            // Config vorhanden ==> in default Mode wechseln
            mode = new DefaultMode(&led, wifi_ssid, wifi_password);
            mode->setup();
            return;
        }
    } else {
        LogHelper::log("Main", "Multi Reset Detected => ConfigMode", logging::LoggerLevel::LOGGER_LEVEL_INFO);
        delay(300);
        led.blink(500);
        mode = new ConfigMode(&led);
        mode->setup();
    }
}

void loop() {
    led.loop();
    mode->loop();
    mrd->loop();
}