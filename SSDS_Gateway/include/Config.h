#ifndef CONFIG_H
#define CONFIG_H
#include <Arduino.h>

class Config
{
public:
    static String MQTT_HOST;
    static int MQTT_PORT;
    static String MQTT_CLIENTID; // auto generated
    static String MQTT_PASSWORD; // auto generated
    static String MQTT_USERNAME; // auto generated

    static bool RECEIVER_433_ENABLED;
    static bool RECEIVER_868_ENABLED;
    static bool RECEIVER_GIRA_ENABLED;

    // Constants
    static const char *AP_SSID;

    static const char *MQTT_TOPIC_PREFIX;

    static const char *OTA_PASSWORD;

    static const char *FS_WIFI_SSID_PATH;
    static const char *FS_WIFI_PASSWORD_PATH;

    static const char *FS_MQTT_HOST_PATH;
    static const char *FS_MQTT_PORT_PATH;
    static const char *FS_MQTT_CLIENTID_PATH;
    static const char *FS_MQTT_PASSWORD_PATH;
    static const char *FS_USERNAME_PATH;
    static const char *FS_RECEIVER_PATH;

    static const uint8_t LED_PIN = LED_BUILTIN;

    static const uint8_t CONFIG_MODE_DELAY_s = 4;


#ifdef HELTEC_WIFI_KIT_32_V3
    static const uint8_t RECEIVER_433_PIN = 3;
    static const uint8_t TRANSMITTER_433_PIN = 4;
#else
    static const uint8_t RECEIVER_433_PIN = 12;
    static const uint8_t TRANSMITTER_433_PIN = 14;
#endif

};

#endif // CONFIG_H