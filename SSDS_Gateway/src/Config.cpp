#include "Config.h"
#include "Arduino.h"

String Config::MQTT_HOST = "";
int Config::MQTT_PORT = 1883;
String Config::MQTT_CLIENTID = "";
String Config::MQTT_PASSWORD = "";
String Config::MQTT_USERNAME = "";
bool Config::RECEIVER_433_ENABLED = false;
bool Config::RECEIVER_868_ENABLED = false;
bool Config::RECEIVER_GIRA_ENABLED = false;

// CONSTANTS
const char *Config::AP_SSID = "SDSS Gateway";

const char *Config::MQTT_TOPIC_PREFIX = "ssds/";

const char *Config::OTA_PASSWORD = "notusedrightnow";

const char *Config::FS_WIFI_SSID_PATH = "/wifi_ssid.txt";
const char *Config::FS_WIFI_PASSWORD_PATH = "/wifi_password.txt";

const char *Config::FS_MQTT_HOST_PATH = "/mqtt_host.txt";
const char *Config::FS_MQTT_PORT_PATH = "/mqtt_port.txt";
const char *Config::FS_MQTT_CLIENTID_PATH = "/mqtt_clientid.txt";
const char *Config::FS_MQTT_PASSWORD_PATH = "/mqtt_password.txt";
const char *Config::FS_USERNAME_PATH = "/init.txt";
const char *Config::FS_RECEIVER_PATH = "/receiver.txt";
