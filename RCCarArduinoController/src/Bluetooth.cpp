#include <Arduino.h>
#include <ArduinoBLE.h>
#include "Bluetooth.h"

Bluetooth* sharedInstance;

void _readCommand(BLEDevice central, BLECharacteristic characteristic) {
    sharedInstance->readCommand(central, characteristic);
}

Bluetooth::Bluetooth() : 
    btService("07838daa-b3df-4ca2-892c-0844b6969519"),
    commandCharacteristic("f6791979-f52a-4d4a-98d8-af5c3ea3cf68", BLEWrite | BLERead | BLENotify),
    statusCharacteristic("1faa2a5c-0825-48d0-bfa8-e15b84145116", BLERead | BLENotify),
    accelerometerCharacteristic("3178812e-f8ca-48cb-93f6-a3387bf41a63", BLERead | BLENotify),
    hdopCharacteristic("5ea3439d-c263-41ac-a74d-68015b7a7d91", BLERead | BLENotify),
    currentPositionCharacteristic("67657b6a-6291-4166-b2bb-5caa09d91f95", BLERead | BLENotify) {
    sharedInstance = this;
}

BLEDevice Bluetooth::central() {
    return BLE.central();
}

bool Bluetooth::setup() {
    if (BLE.begin()) {
        BLE.setLocalName("ChlupsArduino");
        BLE.setDeviceName("ChlupsArduino");
        BLE.setAdvertisedService(btService);
        btService.addCharacteristic(commandCharacteristic);
        btService.addCharacteristic(accelerometerCharacteristic);
        btService.addCharacteristic(statusCharacteristic);
        btService.addCharacteristic(hdopCharacteristic);
        btService.addCharacteristic(currentPositionCharacteristic);
        BLE.addService(btService);
        BLE.advertise();
        commandCharacteristic.setEventHandler(BLEWritten, _readCommand);
        return true;

    } else {
        Serial.println("starting BLE failed!");
        return false;
    }
}

bool Bluetooth::isConnected() {
    return central().connected();
}

void Bluetooth::updateAccelerometerData(float x, float y) {
    short sendX = (short)((x * 100) + 100);
    short sendY = (short)((y * 100) + 100);

    short encodedAccelerometerData = 0;
    encodedAccelerometerData |= sendX;
    encodedAccelerometerData |= (sendY << 8 );
 
    accelerometerCharacteristic.writeValue(encodedAccelerometerData);
}

void Bluetooth::updateStatus(long status) {
    statusCharacteristic.writeValue(status);
}

void Bluetooth::updateHDOP(short hdop) {
    hdopCharacteristic.writeValue(hdop);
}

void Bluetooth::updatePosition(double lon, double lat) {
    currentPositionCharacteristic.writeValue(lon);
    currentPositionCharacteristic.writeValue(lat);
}

void Bluetooth::updateCommands(long command) {
    commandCharacteristic.writeValue(command);
}

void Bluetooth::registerCommandHandler(CommandHandler handler) {
    commandHandler = handler;
}

void Bluetooth::readCommand(BLEDevice central, BLECharacteristic characteristic) {
    commandHandler(commandCharacteristic.value());    
}
