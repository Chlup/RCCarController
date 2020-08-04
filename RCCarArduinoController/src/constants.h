#ifndef CONSTANTS
#define CONSTANTS

#define GPS_DATA_LENGTH 22
#define STORAGE_VERSION 1

union DoubleBytes {
    byte bytes[8];
    double value;
};

union ShortBytes {
    byte bytes[2];
    short value;
};

#endif