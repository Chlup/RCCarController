#include <TinyGPS++.h>

class GPS {
    public:
        GPS();
        void readSerialData(unsigned long timeout);
        double speed();
        short hdop();
        uint32_t rawDate();
        uint32_t rawTime();
        bool hasValidData();
        bool hasNewData();
        byte* getData();
        void printPosition();

    private:
        TinyGPSPlus gps;
        size_t dataSize();
        byte* lastRecord;
};