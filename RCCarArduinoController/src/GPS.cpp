
#include <TinyGPS++.h>
#include <Arduino.h>
#include <math.h>

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

    checkForReceivingError();
}

void GPS::checkForReceivingError() {
    uint32_t charsProcessed = gps.charsProcessed();
    unsigned long now = millis();
    if (charsProcessed - charsProcessedBeforeLastRead > 0) {
        lastCharsRead = now;
        charsProcessedBeforeLastRead = charsProcessed;
        gpsError = false;
    } else if (now - lastCharsRead > 5000) {
        gpsError = true;
        Serial.println("NO data from GPS!");
    }
}

double GPS::speed() {
    return gps.speed.kmph();
}

short GPS::hdop() {
    return lastHDOP;
}

bool GPS::isHDOPUpdated() {
    int32_t newHDOP = gps.hdop.value();
    if (newHDOP > 65535) { newHDOP = 65535; }
    short newHDOPFinal = (short)newHDOP;

    bool isUpdated = newHDOPFinal != lastHDOP;
    lastHDOP = newHDOPFinal;
    return isUpdated;
}

bool GPS::errorReadingGPSData() {
    return gpsError;
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
    bool updated = false;
    if (gps.location.isUpdated()) {
        double lon = gps.location.lng();
        double lat = gps.location.lat();

        const double earthRadius = 6371e3;
        const double piRads = M_PI / 180;
        double lastLatRads = lastLat * piRads;
        double latRads = lat * piRads;
        double latDeltaRads = (lat - lastLat) * piRads;
        double lonDeltaRads = (lon - lastLon) * piRads; 

        double latDeltaRadsSin = sinl(latDeltaRads / 2);
        double lonDeltaRadsSin = sin(lonDeltaRads / 2);
        double haversine = latDeltaRadsSin * latDeltaRadsSin + cosl(lastLatRads) * cos(latRads) * lonDeltaRadsSin * lonDeltaRadsSin;
        
        double c = 2 * atan2l(sqrtl(haversine), sqrtl(1 - haversine));
        double diffInMeters = earthRadius * c;

        // diff must be higher then 30 cm
        updated = diffInMeters > 0.5;
        lastLon = lon;
        lastLat = lat;

        if (updated) {
            Serial.print("Location diff: "); Serial.println(diffInMeters);
        }
    }

    if (!updated && gps.altitude.isUpdated()) {
        double altitude = gps.altitude.meters();
        int altDiff = abs(lastAlt - altitude);
        updated = altDiff >= 1;
        lastAlt = altitude;

        if (updated) {
            Serial.print("Alt diff: "); Serial.println(altDiff);
        }
    }

    Serial.print("GPS data updated: "); Serial.println(updated);

    #warning "JUST for DEBUG";
    updated = true;

    return updated;
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
    lonBytes.value = lastLon;
    for (int i = 3; i < 11; i++) {
        lastRecord[i] = lonBytes.bytes[i-3];
    }

    DoubleBytes latBytes;
    latBytes.value = lastLat;
    for (int i = 11; i < 19; i++) {
        lastRecord[i] = latBytes.bytes[i-11];
    }
    
    ShortBytes altBytes;
    altBytes.value = (short)floor(lastAlt);
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