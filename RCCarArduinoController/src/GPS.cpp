
#include <TinyGPS++.h>
#include <Arduino.h>

#include "GPS.h"
#include "constants.h"

GPS::GPS() {
    lastRecord = (byte*)malloc(dataSize());
}

void GPS::readSerialData(unsigned long timeout) {
    unsigned long start = millis();
    do {
        while (Serial1.available()) {
            gps.encode(Serial1.read());
        }
    } while (millis() - start < timeout); 
}

double GPS::speed() {
    return gps.speed.kmph();
}

short GPS::hdop() {
    int32_t hdop = gps.hdop.value();
    if (hdop > 65535) { hdop = 65535; }
    return (short)hdop;
}

uint32_t GPS::rawDate() {
    return gps.date.value();
}

uint32_t GPS::rawTime() {
    return gps.time.value();
}

bool GPS::hasValidData() {
    return (gps.time.isValid() && gps.location.isValid() && gps.altitude.isValid() && gps.hdop.isValid());
}

bool GPS::hasNewData() {
    return true;
    // return (gps.time.isUpdated() || gps.location.isUpdated() || gps.altitude.isUpdated() || gps.hdop.isUpdated());
}

/*
Serialized data:

hours 	 	    1 byte
minute  	    1 byte
second		    1 byte
lon		        8 byte (double)
lat 	    	8 byte (double
altitude (m)	2 byte
HDOP            2 bytes
*/
byte* GPS::getData() {
    lastRecord[0] = gps.time.hour();
    lastRecord[1] = gps.time.minute();
    lastRecord[2] = gps.time.second();

    DoubleBytes lonBytes;
    lonBytes.value = gps.location.lng();
    for (int i = 3; i < 11; i++) {
        lastRecord[i] = lonBytes.bytes[i-3];
    }

    DoubleBytes latBytes;
    latBytes.value = gps.location.lat();
    for (int i = 11; i < 19; i++) {
        lastRecord[i] = latBytes.bytes[i-11];
    }
    
    ShortBytes altBytes;
    altBytes.value = (short)floor(gps.altitude.meters());
    lastRecord[19] = altBytes.bytes[0];
    lastRecord[20] = altBytes.bytes[1];

    ShortBytes hdopBytes;
    hdopBytes.value = hdop();
    lastRecord[20] = hdopBytes.bytes[0];
    lastRecord[21] = hdopBytes.bytes[1];

    return lastRecord;
};

size_t GPS::dataSize() {
    return sizeof(byte) * GPS_DATA_LENGTH;
}

void GPS::printPosition() {
    Serial.print("LAT=");  Serial.println(gps.location.lat(), 6);
    Serial.print("LONG="); Serial.println(gps.location.lng(), 6);
}