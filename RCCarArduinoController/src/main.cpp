#include <Arduino.h>
#include <ArduinoBLE.h>
#include <SD.h> 

#include "constants.h"
#include "Bluetooth.h"
#include "Accelerometer.h"
#include "GPS.h"
#include "Storage.h"
#include "CommandCenter.h"

CommandCenter commandCenter;
Bluetooth ble;
Accelerometer accelerometer;
GPS gps;
Storage storage(10);

File myFile;

bool trackingSessionInProgress = false;
bool onePositionSent = false;

const unsigned long mainLoopMaxLength = 300;
const unsigned long gpsLoopMaxLength = 50;

const unsigned int carID = 1;

void receivedTrackingRawCommand(std::string rawCommand) {
  Serial.print("Command "); Serial.println(rawCommand.c_str());
}

void receivedCommand(long command) {
  Serial.print("Received command "); Serial.println(command);
  commandCenter.update(command);
}

void setup() {
  Serial.begin(9600);
  Serial1.begin(9600);

  delay(3000);  
  Serial.println("Setup");
  
  bool initialized = true;

  if (!accelerometer.setup()) {
    Serial.print("Fialed to initialize accelerometer.");
    initialized = false;
    commandCenter.accelerometerSetupError();
  }

  if (ble.setup()) {
    ble.registerCommandHandler(receivedCommand);
  } else{
    Serial.println("Failed to initialize bluetooth.");
    initialized = false;
  }

  if (!storage.setup()) {
    Serial.println("Failed to initialize SD card.");
    initialized = false;
    commandCenter.storageSetupError();
  }

  if (!initialized) {
    Serial.println("Initialization failed. Something went horribly wrong.");
  }
}

void loop() {
  unsigned long start = millis();

  gps.readSerialData(gpsLoopMaxLength);

  bool btIsConnected = ble.isConnected();

  bool gpsHasValidData = gps.hasValidData();
  commandCenter.gpsHasValidData(gpsHasValidData && !gps.errorReadingGPSData());

  if (gpsHasValidData && commandCenter.shouldStartGPSSession()) {
    if (trackingSessionInProgress) {
      if (gps.hasNewData()) {
        if (storage.storeGPSData(gps.getData())) {
          commandCenter.storeGPSDataFine();
        } else {
          commandCenter.storeGPSDataError();
        }
      }
    } else {
      trackingSessionInProgress = storage.startGPSSession(carID, gps.rawDate(), gps.rawTime());
      if (trackingSessionInProgress) {
        commandCenter.gpsSessionInProgress();
      } else {
        commandCenter.gpsSessionStopped();
      }
      Serial.print("Session in progress "); Serial.println(trackingSessionInProgress);
    }
  } else if (trackingSessionInProgress) {
    storage.stopGPSSession();
    trackingSessionInProgress = false;
    commandCenter.gpsSessionStopped();
  }

  if (btIsConnected) {
    if (commandCenter.shouldUpdateCommands()) {
      ble.updateCommands(commandCenter.getCommand());
      commandCenter.didUpdateCommands();
    }

    if (commandCenter.shouldUpdateAccelerometerData()) {
      if (accelerometer.read()) {
        commandCenter.accelerometerReadFine();
      } else {
        commandCenter.accelerometerReadError();
      }
      ble.updateAccelerometerData(accelerometer.lastX, accelerometer.lastY);
    } 

    if (commandCenter.shouldSendCurrentPosition()) {
      if (!onePositionSent || gps.hasNewData()) {
        Serial.println("Sending GPS position.");
        ble.updatePosition(gps.lastLon, gps.lastLat);
        onePositionSent = true;
      }
    } else {
        onePositionSent = false;
    }

    if (commandCenter.shouldUpdateStatus()) {
      Serial.println("Updating status over BLE");
      ble.updateStatus(commandCenter.getStatus());
      commandCenter.didUpdateStatus();
    }

    if (commandCenter.shouldUpdateHDOP() && gps.isHDOPUpdated()) {
      Serial.println("Updating HDOP");
      ble.updateHDOP(gps.hdop());
    }
  }

  unsigned long loopLength = millis() - start;
  Serial.print("Loop length: "); Serial.println(loopLength);
  unsigned long waitFor = mainLoopMaxLength - loopLength;
  if (waitFor > 0 && waitFor <= mainLoopMaxLength) {
    delay(waitFor);
  }
}