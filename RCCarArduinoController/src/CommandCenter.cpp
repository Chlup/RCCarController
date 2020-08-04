#include "CommandCenter.h"

void CommandCenter::update(long command) {
    this->command = command;
}

bool CommandCenter::shouldUpdateAccelerometerData() {
    return (command & COMMAND_ENABLE_ACCELEROMETER);
}

bool CommandCenter::shouldUpdateStatus() {
    return (command & COMMAND_UPDATE_STATUS);
}

void CommandCenter::statusUpdated() {
    command &= ~COMMAND_UPDATE_STATUS;
}

bool CommandCenter::shouldStartTrackingSession() {
    return true;
}