#include <Arduino_LSM9DS1.h>
#include "Accelerometer.h"

bool Accelerometer::setup() {
    if (IMU.begin()) {
        return true;
    } else {
        return false;
    }
}

bool Accelerometer::read() {
    float z = 0;
    lastX = 0;
    lastY = 0;

    if (IMU.accelerationAvailable()) {
        IMU.readAcceleration(lastX, lastY, z);
        return true;
    } else {
        return false;
    }
}