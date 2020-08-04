#include <Arduino.h>
#include <ArduinoBLE.h>
#include "Bluetooth.h"

Bluetooth* sharedInstance;

void _readCommand(BLEDevice central, BLECharacteristic characteristic) {
    sharedInstance->readCommand(central, characteristic);
}

Bluetooth::Bluetooth() : 
    btService("07838daa-b3df-4ca2-892c-0844b6969519"),
    commandCharacteristic("f6791979-f52a-4d4a-98d8-af5c3ea3cf68", BLEWrite),
    accelerometerBTChar("3178812e-f8ca-48cb-93f6-a3387bf41a63", BLERead | BLENotify),
    trackingSessionChar("57710079-3d51-49bf-8009-5ddbc0a6ba94", BLERead | BLEWrite | BLENotify) {
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
        btService.addCharacteristic(accelerometerBTChar);
        btService.addCharacteristic(commandCharacteristic);
        // btService.addCharacteristic(trackingSessionChar);
        BLE.addService(btService);
        BLE.advertise();
        commandCharacteristic.setEventHandler(BLEWritten, _readCommand);
        // trackingSessionChar.setEventHandler(BLEWritten, _readTrackingSession);
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
 
    accelerometerBTChar.writeValue(encodedAccelerometerData);
}

void Bluetooth::registerCommandHandler(CommandHandler handler) {
    commandHandler = handler;
}

void Bluetooth::readCommand(BLEDevice central, BLECharacteristic characteristic) {
    commandHandler(commandCharacteristic.value());    
}
