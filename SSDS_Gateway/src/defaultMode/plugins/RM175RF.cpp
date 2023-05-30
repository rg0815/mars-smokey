//
// Created by Roman on 26.04.2023.
//

#include "defaultMode/plugins/RM175RF.h"
#include "defaultMode/PluginHandler.h"
#include "config.h"

void RM175RF::decode(bool state, unsigned long value) {
    if (state) {
        if (value > getMinBitPulse()) { // store pulse in ring buffer only if duration is longer than MINBITPULSE
            // To be able to store startpulses of more than Maxint duration, we dont't store the actual time,
            // but we store  MINSTARTPULSE+LowVal/10, be sure to calculate back showing the startpulse length!
            if (value > getMinStartPulse() && value < getMaxStartPulse())
                value = getMinStartPulse() + value / 10; // we will store this as unsigned int, so do range checking

            pulsbuf[pbwrite] = value; // store the LOW pulse length
            pbwrite++;                        // advance write pointer in ringbuffer
            if (pbwrite >= getPbSize())
                pbwrite = 0; // ring buffer is at its end
        }
    } else {
        hibuf[pbwrite] = value; // store the HIGH pulse length
    }
}

void RM175RF::loop() {
    unsigned long lowtime, hitime;
    if (pbread != pbwrite) // check for data in ring buffer
    {
        lowtime = pulsbuf[pbread]; // read data from ring buffer
        hitime = hibuf[pbread];
        cli(); // Interrupts off while changing the read pointer for the ringbuffer
        pbread++;
        if (pbread >= getPbSize())
            pbread = 0;
        sei();                       // Interrupts on again
        if (lowtime > getMinStartPulse()) // we found a valid startbit!
        {
            if (counting)
                showBuffer(); // new buffer starts while old is still counting, show it first
            startBitDurationL = lowtime;
            startBitDurationH = hitime;
            counting = true; // then start collecting bits
            counter = 0;     // no data bits yet
        } else if (counting && (counter == 0)) // we now see the first data bit
        {                                    // this may be a 0-bit or a 1-bit, so make some assumption about max/min lengths of data bits that will follow
            shortBitDuration = lowtime / 2;
            if (shortBitDuration < getMinBitPulse() + getPulseVariance())
                shortBitDuration = getMinBitPulse();
            else
                shortBitDuration -= getPulseVariance();
            longBitDuration = lowtime * 2 + getPulseVariance();
            validpulsbuf[counter] = lowtime;
            validhibuf[counter] = hitime;
            counter++;
        } else if (counting && (lowtime > shortBitDuration) && (lowtime < longBitDuration)) {
            validpulsbuf[counter] = lowtime;
            validhibuf[counter] = hitime;
            counter++;
            if ((counter == getMaxPulseCount()) || (hitime < getMinHiTime())) {
                showBuffer();
            }
        } else // Low Pulse is too short
        {
            if (counting)
                showBuffer();
            counting = false;
            counter = 0;
        }
    }
}

void RM175RF::create() {
    name = "RM175RF";
    delayTime = 500;
    lastRun = millis();
    pulsbuf = new unsigned long[getPbSize()];
    hibuf = new unsigned long[getPbSize()];
    validpulsbuf = new unsigned long[getMaxPulseCount()];
    validhibuf = new unsigned long[getMaxPulseCount()];
}

void RM175RF::showBuffer() {
    unsigned long sum, avg;
    sum = 0;
    if (counter >= getMinPulseCount()) { // only show buffer contents if it has enough bits in it
        //     Serial.print("Start Bit L: ");
        // Serial.print((startBitDurationL - MINSTARTPULSE) * 10L);
        // Serial.print("   H: ");
        // Serial.println(startBitDurationH);
        // Serial.print("Data Bits: ");
        // Serial.println(counter);
        // Serial.print("L: ");
        for (i = 0; i < counter; i++) {
            // Serial.print(validpulsbuf[i]);
            // Serial.print(" ");
            sum += validpulsbuf[i];
        }
        // Serial.println();

        // Serial.print("H: ");
        // for (i = 0; i < counter; i++)
        // {
        //     Serial.print(validhibuf[i]);
        //     Serial.print(" ");
        // }
        // Serial.println();

        avg = sum / counter; // calculate the average pulse length
        // then assume that 0-bits are shorter than avg, 1-bits are longer than avg

        String code = "";

        for (i = 0; i < counter; i++) {
            if (validpulsbuf[i] < avg)
                code += "0";
            else
                code += "1";
        }

        if (code.length() > 24) {
            code = code.substring(0, 24);
        }

        if (code.length() == 24) {
            lastReceivedCodes.push_back(code); // Add the current code to the queue

            // Remove the oldest code if the queue size exceeds the desired size
            if (lastReceivedCodes.size() > codeCheckCount) {
                lastReceivedCodes.pop_front();
            }

            bool allCodesSame = true;
            for (size_t i = 1; i < lastReceivedCodes.size(); ++i) {
                if (lastReceivedCodes[i] != lastReceivedCodes[0]) {
                    allCodesSame = false;
                    break;
                }
            }

            if (allCodesSame && lastReceivedCodes.size() == codeCheckCount) {
                PluginHandler::sendAlarmToBackend(this, code.c_str());
                lastReceivedCodes.clear();
            }
        }


    }
    counting = false;
    counter = 0;
}

void RM175RF::performAlarm(const char *rawCode) {

    if (millis() - lastRun < delayTime) {
        return;
    }
    Serial.println("Set sending true");

    Serial.println("RM175RF: Sending alarm");
    PluginHandler::isSending433 = true;

    for (int i = 0; i < 8; i++) {
        sendStartPulse();

        for (int j = 0; j < strlen(rawCode); j++) {
            char c = rawCode[j];

            switch (c) {
                case '0':
                    sendLongPulse();
                    break;
                case '1':
                    sendShortPulse();
                    break;
                default:
                    break;
            }
        }
        sendStopPulse();
    }

    PluginHandler::isSending433 = false;
    lastRun = millis();
    Serial.println("Set sending false");

}

void RM175RF::sendStartPulse() const {
    digitalWrite(Config::TRANSMITTER_433_PIN, HIGH);
    delayMicroseconds(shortPulseOn);
    digitalWrite(Config::TRANSMITTER_433_PIN, LOW);
    delayMicroseconds(wideGap);
}

void RM175RF::sendShortPulse() const {
    digitalWrite(Config::TRANSMITTER_433_PIN, HIGH);
    delayMicroseconds(shortPulseOn);
    digitalWrite(Config::TRANSMITTER_433_PIN, LOW);
    delayMicroseconds(shortPulseOff);
}

void RM175RF::sendLongPulse() const {
    digitalWrite(Config::TRANSMITTER_433_PIN, HIGH);
    delayMicroseconds(longPulseOn);
    digitalWrite(Config::TRANSMITTER_433_PIN, LOW);
    delayMicroseconds(longPulseOff);
}

void RM175RF::sendStopPulse() const {
    digitalWrite(Config::TRANSMITTER_433_PIN, HIGH);
    delayMicroseconds(stopPulseOn);
    digitalWrite(Config::TRANSMITTER_433_PIN, LOW);
    delayMicroseconds(stopPulseOff);
    digitalWrite(Config::TRANSMITTER_433_PIN, HIGH);
    delayMicroseconds(stopPulseOn);
    digitalWrite(Config::TRANSMITTER_433_PIN, LOW);
    delayMicroseconds(stopPulseOff);
}