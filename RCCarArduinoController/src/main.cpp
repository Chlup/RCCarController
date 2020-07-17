#include <Arduino.h>
#include <ArduinoBLE.h>
#include <Servo.h>
#include <Arduino_LSM9DS1.h>

//https://github.com/NikodemBartnik/rc_robot/blob/master/rc_robot_with_arduino/rc_robot_with_arduino.ino
//https://learn.openenergymonitor.org/electricity-monitoring/pulse-counting/interrupt-based-pulse-counter


Servo stering; 

uint32_t config = 0;
int counter = 0;

uint32_t bleConfigEnableAccelerometer = 1 << 0;

BLEService btService("07838daa-b3df-4ca2-892c-0844b6969519");
BLEIntCharacteristic configBTChar("f6791979-f52a-4d4a-98d8-af5c3ea3cf68", BLERead | BLEWrite | BLENotify);
BLEShortCharacteristic accelerometerBTChar("3178812e-f8ca-48cb-93f6-a3387bf41a63", BLERead | BLENotify);

int inputSample[5] = {0, 0, 0, 0, 0};

void readConfig(BLEDevice central, BLECharacteristic characteristic) {
  Serial.println("Read config");
  configBTChar.readValue(config);

  Serial.println(config);
  if (config & bleConfigEnableAccelerometer) {
    Serial.println("enable accelerometer");
  } else {
    Serial.println("disable accelerometer");
  }
}

void setup() {
  Serial.begin(9600);
  // stering.attach(10, 900, 2100);

  if (!IMU.begin()) {
    Serial.println("Failed to initialize IMU!");
  }

  if (BLE.begin()) {
    BLE.setLocalName("ChlupsArduino");
    BLE.setDeviceName("ChlupsArduino");
    BLE.setAdvertisedService(btService);
    btService.addCharacteristic(accelerometerBTChar);
    btService.addCharacteristic(configBTChar);
    BLE.addService(btService);
    BLE.advertise();

    configBTChar.setEventHandler(BLEWritten, readConfig);
  } else {
    Serial.println("starting BLE failed!");
  }
}

void loop() {
  BLEDevice central = BLE.central();

  if (central.connected()) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());

    while (central.connected()) {

      if (config & bleConfigEnableAccelerometer) {
        Serial.println("Accelerometer sending");

        float x, y, z = 0;
        short encodedAccelerometerData = 0;

        if (IMU.accelerationAvailable()) {
          IMU.readAcceleration(x, y, z);

          short sendX = (short)((x * 100) + 100);
          short sendY = (short)((y * 100) + 100);

          encodedAccelerometerData |= sendX;
          encodedAccelerometerData |= (sendY << 8 );

          Serial.print(sendX);
          Serial.print(" ");
          Serial.print(sendY);
          Serial.println();
        } else {
          Serial.println("Acceleration not available");
        } 
        accelerometerBTChar.writeValue(encodedAccelerometerData);
      }

      counter += 1;
      Serial.println(counter);
      delay(100);
    } 
  } else {
    Serial.println("Not connected to cental");
  }
  
  delay(100);
}