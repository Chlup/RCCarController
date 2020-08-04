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

const unsigned long mainLoopMaxLength = 300;
const unsigned long gpsLoopMaxLength = 100;

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

  digitalWrite(LED_BUILTIN, HIGH);

  delay(3000);  
  Serial.println("Setup");
  
  bool initialized = true;

  if (!accelerometer.setup()) {
    Serial.print("Fialed to initialize accelerometer.");
    initialized = false;
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
  }

  if (initialized) {
    digitalWrite(LED_BUILTIN, LOW);
  } else {
    Serial.println("Initialization failed. Something went horribly wrong.");
    while (true);
  }

  // if (!SD.begin(10)) {
  //   Serial.println("initialization failed!");
  //   return;
  // }
  // Serial.println("initialization done.");

  // if (!SD.exists("somedir")) {
  //   if (!SD.mkdir("somedir")) {
  //     Serial.println("Can't create directory");
  //   } else {
  //     Serial.println("Directory created");
  //   }
  // } else {
  //   Serial.println("Directory exists");
  // }

  // // open the file. note that only one file can be open at a time,
  // // so you have to close this one before opening another.
  // myFile = SD.open("somedir/test.txt", FILE_WRITE);
  
  // // if the file opened okay, write to it:
  // if (myFile) {
  //   Serial.print("Writing to test.txt...");
  //   myFile.println("testing 1, 2, 3.");
  // // close the file:
  //   myFile.close();
  //   Serial.println("done.");
  // } else {
  //   // if the file didn't open, print an error:
  //   Serial.println("error opening test.txt");
  // }
  
  // // re-open the file for reading:
  // myFile = SD.open("test.txt");
  // if (myFile) {
  //   Serial.println("test.txt:");
    
  //   // read from the file until there's nothing else in it:
  //   while (myFile.available()) {
  //     Serial.write(myFile.read());
  //   }
  //   // close the file:
  //   myFile.close();
  // } else {
  //   // if the file didn't open, print an error:
  //   Serial.println("error opening test.txt");
  // }
}


void loop() {
  unsigned long start = millis();

  gps.readSerialData(100);

  // BLEDevice btDevice = ble.central();
  bool btIsConnected = ble.isConnected();

  if (commandCenter.shouldUpdateAccelerometerData() && btIsConnected) {
      accelerometer.read();
      ble.updateAccelerometerData(accelerometer.lastX, accelerometer.lastY);
  } 

  // const char* dir = "somedir2";
  // if (SD.exists(dir)) {
  //   Serial.println("Dir exists");
  //   const char* filename = "somedir2/file.txt";
  //   File file = SD.open(filename, FILE_WRITE);
  //   if (file) {
  //     if (file.write("H", sizeof(byte)) > 0) {
  //       Serial.println("Wrote data to file.");
  //     } else {
  //       Serial.print("Failed to write to file: "); Serial.println(filename);
  //     }
  //     file.close();
  //   } else {
  //     Serial.println("File is not available.");
  //   }
  // } else {
  //   Serial.println("Dire doesn't exist");
  //   if (SD.mkdir(dir)) {
  //     Serial.println("Dir created");
  //   } else {
  //     Serial.println("Fail to created directory");
  //   }
  // }

  // if (gps.hasValidData() && commandCenter.shouldStartTrackingSession()) {
  //   if (trackingSessionInProgress) {
  //     if (gps.hasNewData()) {
  //       storage.storeGPSData(gps.getData());
  //     }
  //   } else {
  //     trackingSessionInProgress = storage.startGPSSession(carID, gps.rawDate(), gps.rawTime());
  //     Serial.print("Session in progress "); Serial.println(trackingSessionInProgress);
  //   }
  // } else if (trackingSessionInProgress) {
  //   storage.stopGPSSession();
  //   trackingSessionInProgress = false;
  // }

  // std::string gpsLine;
  // if (ble.shouldLogGPSData()) {
  // gps.readSerialData(100);
  // TinyGPSPlus data = gps.data;
  // gpsLine += std::to_string(data.time.hour());
  // gpsLine += ",";
  // gpsLine += std::to_string(data.time.minute());
  // gpsLine += ",";
  // gpsLine += std::to_string(data.time.second());
  // gpsLine += ",";
  // gpsLine += std::to_string(data.location.lng());
  // gpsLine += ",";
  // gpsLine += std::to_string(data.location.lat());
  // gpsLine += ",";
  // gpsLine += std::to_string(data.speed.kmph());
  // gpsLine += ",";
  // gpsLine += std::to_string(data.altitude.meters());

  // Serial.println(gpsLine.c_str());
  // Serial.println(sizeof(short));

  //   // gps.printPosition();
  // }  

  unsigned long waitFor = mainLoopMaxLength - (millis() - start);
  if (waitFor > 0) {
    Serial.print("Wait for "); Serial.println(waitFor);
    delay(waitFor);
  }
}