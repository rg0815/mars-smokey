//
// Created by Roman on 26.04.2023.
//

#ifndef SSDS_GATEWAY_PLUGINBASE_H
#define SSDS_GATEWAY_PLUGINBASE_H


#include <Arduino.h>
#include <deque>


class PluginBase {
public:
    long delayTime;
    unsigned long lastRun;

    const char *name;
    std::deque<const char *> activeAlarms;
    std::deque<String> lastReceivedCodes;
    const size_t codeCheckCount = 5;
    volatile unsigned long *pulsbuf;
    volatile unsigned long *hibuf;
    unsigned long *validpulsbuf;
    unsigned long *validhibuf;
    volatile byte pbread, pbwrite;
    boolean counting;
    byte i, counter;
    unsigned long startBitDurationL, startBitDurationH, shortBitDuration, longBitDuration;

    virtual unsigned int getMinStartPulse() const { return 0; };

    virtual unsigned int getMaxStartPulse() const { return 0; };

    virtual unsigned int getMinBitPulse() const { return 0; };

    virtual unsigned int getMinHiTime() const { return 0; };

    virtual unsigned int getPulseVariance() const { return 0; };

    virtual unsigned int getMinPulseCount() const { return 0; };

    virtual unsigned int getMaxPulseCount() const { return 0; };

    virtual unsigned int getPbSize() const { return 0; };

    virtual void loop() = 0;

    virtual void decode(bool state, unsigned long value) = 0;

    virtual void showBuffer() = 0;

    virtual void create() = 0;

    virtual void performAlarm(const char *rawCode) = 0;

};

#endif //SSDS_GATEWAY_PLUGINBASE_H
