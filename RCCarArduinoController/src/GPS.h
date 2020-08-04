#include <TinyGPS++.h>

class GPS {
    public:
        GPS();
        void readSerialData(unsigned long timeout);
        double speed();
        short hdop();
        bool isHDOPUpdated();
        bool errorReadingGPSData();
        uint32_t rawDate();
        uint32_t rawTime();
        bool hasValidData();
        bool hasNewData();
        byte* getData();
        void printPosition();

        double lastLon = 0;
        double lastLat = 0;

    private:
        TinyGPSPlus gps;
        size_t dataSize();
        byte* lastRecord;

        double lastAlt = 0;
        short lastHDOP = 0;

        uint32_t charsProcessedBeforeLastRead = 0;
        unsigned long lastCharsRead = 0;
        bool gpsError = false;
        void checkForReceivingError();
};