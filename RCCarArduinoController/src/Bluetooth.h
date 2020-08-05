#include <ArduinoBLE.h>

typedef void (*CommandHandler)(long command);

class Bluetooth {       // The class
  public:             // Access specifier
    Bluetooth();
    bool setup();
    bool isConnected();

    void registerCommandHandler(CommandHandler handler);
    
    void updateAccelerometerData(float x, float y);
    void updateStatus(long status);
    void updateHDOP(short hdop);
    void updatePosition(double lon, double lat);
    void updateCommands(long command);

    void readCommand(BLEDevice central, BLECharacteristic characteristic);

  private:
    BLEService btService;
    BLELongCharacteristic commandCharacteristic;
    BLELongCharacteristic statusCharacteristic;
    BLEShortCharacteristic accelerometerCharacteristic;
    BLEShortCharacteristic hdopCharacteristic;
    BLEDoubleCharacteristic currentPositionCharacteristic;

    BLEDevice central();

    CommandHandler commandHandler;
};