#include "CommandCenter.h"

void CommandCenter::update(long command) {
    this->command = command;
    long newStatus = 0;
    if (shouldStartGPSSession()) {
        newStatus = status | STATUS_SHOULD_START_GPS_SESSION;
    } else {
        newStatus = status & ~STATUS_SHOULD_START_GPS_SESSION;
    }
    updateStatus(newStatus);

    // Let's force to send update at least once when this command arrives.
    if (command & COMMAND_UPDATE_STATUS) {
        statusUpdated = true;
    }
}

long CommandCenter::getCommand() {
    return command;
}

bool CommandCenter::shouldUpdateStatus() {
    return statusUpdated && (command & COMMAND_UPDATE_STATUS);
}

long CommandCenter::getStatus() {
    return status;
}

void CommandCenter::didUpdateStatus() {
    statusUpdated = false;
}

bool CommandCenter::shouldUpdateHDOP() {
    return command & COMMAND_UPDATE_HDOP;
}

bool CommandCenter::shouldUpdateCommands() {
    return command & COMMAND_SEND_COMMANDS;
}

void CommandCenter::didUpdateCommands() {
    command &= ~COMMAND_SEND_COMMANDS;
}

void CommandCenter::accelerometerSetupError() {
    long newStatus = status | STATUS_ACCELEROMETER_SETUP_ERROR;
    updateStatus(newStatus);
}

void CommandCenter::accelerometerReadError() {
    long newStatus = status | STATUS_ACCELEROMETER_READ_ERROR;
    updateStatus(newStatus);
}

void CommandCenter::accelerometerReadFine() {
    long newStatus = status & ~STATUS_ACCELEROMETER_READ_ERROR;
    updateStatus(newStatus);
}

bool CommandCenter::shouldUpdateAccelerometerData() {
    return (command & COMMAND_ENABLE_ACCELEROMETER);
}

void CommandCenter::storageSetupError() {
    long newStatus = status | STATUS_STORAGE_SETUP_ERROR;
    updateStatus(newStatus);
}

bool CommandCenter::shouldSendCurrentPosition() {
    return command & COMMAND_SEND_POSITION;
}

bool CommandCenter::shouldStartGPSSession() {
    return true;
    return (command & COMMAND_START_GPS_SESSION);
}

void CommandCenter::gpsSessionInProgress() {
    long newStatus = status | STATUS_GPS_SESSION_IN_PROGRESS;
    updateStatus(newStatus);
}

void CommandCenter::gpsSessionStopped() {
    long newStatus = status & ~STATUS_GPS_SESSION_IN_PROGRESS;
    updateStatus(newStatus);
}

void CommandCenter::storeGPSDataError() {
    long newStatus = status | STATUS_STORE_GPS_DATA_ERROR;
    updateStatus(newStatus);
}

void CommandCenter::storeGPSDataFine() {
    long newStatus = status & ~STATUS_STORE_GPS_DATA_ERROR;
    updateStatus(newStatus);
}

void CommandCenter::gpsHasValidData(bool hasValidData) {
    long newStatus = 0;
    if (hasValidData) {
        newStatus = status | STATUS_GPS_HAS_VALID_DATA;
    } else {
        newStatus = status & ~STATUS_GPS_HAS_VALID_DATA;
    }
    updateStatus(newStatus);
}

void CommandCenter::updateStatus(long status) {
    if (!statusUpdated) {
        statusUpdated = this->status != status;
    }
    this->status = status;
}