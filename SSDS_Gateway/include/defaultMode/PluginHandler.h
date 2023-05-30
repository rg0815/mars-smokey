//
// Created by Roman on 26.04.2023.
//

#ifndef SSDS_GATEWAY_PLUGINHANDLER_H
#define SSDS_GATEWAY_PLUGINHANDLER_H


#include "defaultMode/plugins/PluginBase.h"

class PluginHandler {
private:

public:
    static bool isSending433;

    static void registerPlugin(PluginBase *plugin);

    static void pluginLoop();

    static void interruptHandler(bool state, unsigned long value);

    static void rx433Callback();

    static void setup433();

    static void setup();

    static void addAlarm(PluginBase *plugin, const char *rawSignal);

    static void sendAlarmToBackend(PluginBase *plugin, const char *code);

    static PluginBase *getPluginByName(const char *name);

    static void stopAlarm(PluginBase *plugin, const char *rawCode);
};


#endif //SSDS_GATEWAY_PLUGINHANDLER_H
