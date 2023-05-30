//
// Created by Roman on 25.04.2023.
//

#include "utils/DisplayHelper.h"
#include "heltec.h"
#include "qrcode.h"
#include "utils/LogHelper.h"

void DisplayHelper::showMqttError(lwmqtt_err_t err) {
    switch (err) {
        case LWMQTT_SUCCESS:
            LogHelper::log("MQTT", "Error: LWMQTT_SUCCESS", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            break;
        case LWMQTT_BUFFER_TOO_SHORT:
            LogHelper::log("MQTT", "Error: LWMQTT_BUFFER_TOO_SHORT", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            break;
        case LWMQTT_VARNUM_OVERFLOW:
            LogHelper::log("MQTT", "Error: LWMQTT_VARNUM_OVERFLOW", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            break;
        case LWMQTT_NETWORK_FAILED_CONNECT:
            LogHelper::log("MQTT", "Error: LWMQTT_NETWORK_FAILED_CONNECT", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            break;
        case LWMQTT_NETWORK_TIMEOUT:
            LogHelper::log("MQTT", "Error: LWMQTT_NETWORK_TIMEOUT", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            break;
        case LWMQTT_NETWORK_FAILED_READ:
            LogHelper::log("MQTT", "Error: LWMQTT_NETWORK_FAILED_READ", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            break;
        case LWMQTT_NETWORK_FAILED_WRITE:
            LogHelper::log("MQTT", "Error: LWMQTT_NETWORK_FAILED_WRITE", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            break;
        case LWMQTT_REMAINING_LENGTH_OVERFLOW:
            LogHelper::log("MQTT", "Error: LWMQTT_REMAINING_LENGTH_OVERFLOW", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            break;
        case LWMQTT_REMAINING_LENGTH_MISMATCH:
            LogHelper::log("MQTT", "Error: LWMQTT_REMAINING_LENGTH_MISMATCH", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            break;
        case LWMQTT_MISSING_OR_WRONG_PACKET:
            LogHelper::log("MQTT", "Error: LWMQTT_MISSING_OR_WRONG_PACKET", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            break;
        case LWMQTT_CONNECTION_DENIED:
            LogHelper::log("MQTT", "Error: LWMQTT_CONNECTION_DENIED", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            break;
        case LWMQTT_FAILED_SUBSCRIPTION:
            LogHelper::log("MQTT", "Error: LWMQTT_FAILED_SUBSCRIPTION", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            break;
        case LWMQTT_SUBACK_ARRAY_OVERFLOW:
            LogHelper::log("MQTT", "Error: LWMQTT_SUBACK_ARRAY_OVERFLOW", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            break;
        case LWMQTT_PONG_TIMEOUT:
            LogHelper::log("MQTT", "Error: LWMQTT_PONG_TIMEOUT", logging::LoggerLevel::LOGGER_LEVEL_ERROR);
            break;
    }
}

void DisplayHelper::showQRCodeOnDisplay(String text) {
    QRCode qrcode;
    uint8_t qrcodeData[qrcode_getBufferSize(3)];
    qrcode_initText(&qrcode, qrcodeData, 3, 0, text.c_str());

    Heltec.display->clear();
    int startX = (SCREEN_WIDTH - (qrcode.size * pixelSize) - (pixelSize * 2)) / 2;
    int startY = (SCREEN_HEIGHT - (qrcode.size * pixelSize) - (pixelSize * 2)) / 2;

    int qrCodeSize = qrcode.size;

    for (uint8_t y = 0; y < qrCodeSize; y++) {
        for (uint8_t x = 0; x < qrCodeSize; x++) {
            if (qrcode_getModule(&qrcode, x, y)) {
                Heltec.display->fillRect(x * pixelSize + startX + pixelSize,
                                         y * pixelSize + startY + pixelSize, pixelSize,
                                         pixelSize);
            }
        }
    }
    Heltec.display->display();
}

void DisplayHelper::showTextOnDisplay(String text, int delayTime) {
    Heltec.display->clear();
    Heltec.display->setTextAlignment(TEXT_ALIGN_CENTER);
    Heltec.display->drawStringMaxWidth(64, 0, Heltec.display->getWidth(), text);
    Heltec.display->display();
    delay(delayTime);
}