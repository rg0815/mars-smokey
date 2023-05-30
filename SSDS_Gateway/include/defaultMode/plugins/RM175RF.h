//
// Created by Roman on 26.04.2023.
//

#ifndef SSDS_GATEWAY_RM175RF_H
#define SSDS_GATEWAY_RM175RF_H


#include "defaultMode/plugins/PluginBase.h"

class RM175RF : public PluginBase {
private:
    // short pulse
    const long shortPulseOn = 436;  //464;
    const long shortPulseOff = 1299;

// long pulse
    const long longPulseOn = 1202;
    const long longPulseOff = 526;

// stop pulse
    const long stopPulseOn = 434;
    const long stopPulseOff = 434;

// wide gap
    const long wideGap = 11764;

public:
    long delayTime;
    unsigned long lastRun = 0;

    std::deque<const char *> activeAlarms;

    unsigned int getMinStartPulse() const override { return 11000; };

    unsigned int getMaxStartPulse() const override { return 12000; };

    unsigned int getMinBitPulse() const override { return 450; };

    unsigned int getMinHiTime() const override { return 450; };

    unsigned int getPulseVariance() const override { return 700; };

    unsigned int getMinPulseCount() const override { return 20; };

    unsigned int getMaxPulseCount() const override { return 100; };

    unsigned int getPbSize() const override { return 216; };

    void loop() override;

    void decode(bool state, unsigned long value) override;

    void showBuffer() override;

    void create() override;

    void performAlarm(const char *rawCode) override;

    void sendStartPulse() const;

    void sendShortPulse() const;

    void sendLongPulse() const;

    void sendStopPulse() const;
};


#endif //SSDS_GATEWAY_RM175RF_H
