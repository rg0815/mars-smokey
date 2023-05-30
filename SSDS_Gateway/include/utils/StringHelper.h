//
// Created by Roman on 26.04.2023.
//

#ifndef SSDS_GATEWAY_STRINGHELPER_H
#define SSDS_GATEWAY_STRINGHELPER_H


#include <Arduino.h>

class StringHelper {
public:
    static void generateGuid(char *str);
    static void generateGuidWithMacAddress(char *str);
    static void generateRandomString(char *str, int length);
};


#endif //SSDS_GATEWAY_STRINGHELPER_H
