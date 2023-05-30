//
// Created by Roman on 26.04.2023.
//

#include "utils/StringHelper.h"
#include "WiFi.h"

void StringHelper::generateRandomString(char *str, int length) {
    str[length] = '\0'; // Set the null terminator character

    for (int i = 0; i < length; i++) {
        int randomNum = random(10); // Generate a random number between 0 and 9
        str[i] = '0' + randomNum;   // Convert the number to a character and add it to the string
    }
}

void StringHelper::generateGuid(char *str) {
    uint8_t data[16];
    randomSeed(analogRead(0));

    // Generate random bytes
    for (unsigned char &i: data) {
        i = random(256);
    }

    // Set version and variant bits
    data[6] = (data[6] & 0x0f) | 0x40; // Set version to 4 (random GUID)
    data[8] = (data[8] & 0x3f) | 0x80; // Set variant to 10 (RFC 4122)

    // Convert bytes to hex characters
    char hexChars[] = "0123456789abcdef";
    int index = 0;

    for (int i = 0; i < 16; i++) {
        str[index++] = hexChars[data[i] >> 4];
        str[index++] = hexChars[data[i] & 0x0f];

        if (i == 3 || i == 5 || i == 7 || i == 9) {
            str[index++] = '-';
        }
    }

    str[36] = '\0'; // Set the null terminator character
}


void StringHelper::generateGuidWithMacAddress(char *str) {
    uint8_t data[16];

    // Get local MAC address
    uint8_t mac[6];
    WiFi.macAddress(mac);

    // Set first 6 bytes of data to local MAC address
    memcpy(data, mac, 6);

    // Generate random bytes for the remaining 10 bytes
    randomSeed(analogRead(0));
    for (int i = 6; i < 16; i++) {
        data[i] = random(256);
    }

    // Set version and variant bits
    data[6] = (data[6] & 0x0f) | 0x40; // Set version to 4 (random GUID)
    data[8] = (data[8] & 0x3f) | 0x80; // Set variant to 10 (RFC 4122)

    // Convert bytes to hex characters
    char hexChars[] = "0123456789abcdef";
    int index = 0;

    for (int i = 0; i < 16; i++) {
        str[index++] = hexChars[data[i] >> 4];
        str[index++] = hexChars[data[i] & 0x0f];

        if (i == 3 || i == 5 || i == 7 || i == 9) {
            str[index++] = '-';
        }
    }

    str[36] = '\0'; // Set the null terminator character
}