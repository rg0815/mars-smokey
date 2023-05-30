//
// Created by Roman on 26.04.2023.
//

#ifndef SSDS_GATEWAY_FA22RF_H
#define SSDS_GATEWAY_FA22RF_H


#include "defaultMode/plugins/PluginBase.h"

class FA22RF : public PluginBase {
private:
    // short pulse
    const long shortPulseOn = 800;  //464;
    const long shortPulseOff = 1400;

// long pulse
    const long longPulseOn = 800;
    const long longPulseOff = 2700;

// wide gap
    const long wideGap = 18800;
    const long shortGapOn = 8100;
    const long shortGapOff = 800;

public:
    long delayTime;
    unsigned long lastRun = 0;

    std::deque<const char *> activeAlarms;

    unsigned int getMinStartPulse() const override { return 8000; };

    unsigned int getMaxStartPulse() const override { return 10000; };

    unsigned int getMinBitPulse() const override { return 1300; };

    unsigned int getMinHiTime() const override { return 750; };

    unsigned int getPulseVariance() const override { return 1000; };

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


#endif //SSDS_GATEWAY_FA22RF_H
