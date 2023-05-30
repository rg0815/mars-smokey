//
// Created by Roman on 25.04.2023.
//

#ifndef SSDS_GATEWAY_DISPLAYHELPER_H
#define SSDS_GATEWAY_DISPLAYHELPER_H

#include <Arduino.h>
#include "lwmqtt/lwmqtt.h"


class DisplayHelper {
private:
    static const int pixelSize = 2;
    static const int SCREEN_WIDTH = 128;
    static const int SCREEN_HEIGHT = 64;

public:
    static void showQRCodeOnDisplay(String text);
    static void showTextOnDisplay(String text, int delayTime = 0);
    static void showMqttError(lwmqtt_err_t err);

};


#endif //SSDS_GATEWAY_DISPLAYHELPER_H
