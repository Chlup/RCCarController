#include <ArduinoBLE.h>

typedef void (*CommandHandler)(long command);

class Bluetooth {       // The class
  public:             // Access specifier
    Bluetooth();
    bool setup();
    bool isConnected();

    void registerCommandHandler(CommandHandler handler);
    
    void updateAccelerometerData(float x, float y);

    void readCommand(BLEDevice central, BLECharacteristic characteristic);

  private:
    BLEService btService;
    BLELongCharacteristic commandCharacteristic;
    BLEShortCharacteristic accelerometerBTChar;
    BLECharCharacteristic trackingSessionChar;

    BLEDevice central();

    CommandHandler commandHandler;
};