
#ifndef COMMANDS
#endif

class CommandCenter {
    public:
        void update(long command);
        long getCommand();

        bool shouldUpdateStatus();
        long getStatus();
        void didUpdateStatus();

        bool shouldUpdateHDOP();

        bool shouldUpdateCommands();
        void didUpdateCommands();

        void accelerometerSetupError();
        void accelerometerReadError();
        void accelerometerReadFine();
        bool shouldUpdateAccelerometerData();

        void storageSetupError();

        bool shouldSendCurrentPosition();

        bool shouldStartGPSSession();
        void gpsSessionInProgress();
        void gpsSessionStopped();
        void storeGPSDataError();
        void storeGPSDataFine();

        void gpsHasValidData(bool hasValidData);
        
    private:
        long command = 0;
        const long COMMAND_ENABLE_ACCELEROMETER = 1 << 0;
        const long COMMAND_START_GPS_SESSION = 1 << 1;
        const long COMMAND_UPDATE_STATUS = 1 << 2;
        const long COMMAND_UPDATE_HDOP = 1 << 3;
        const long COMMAND_SEND_POSITION = 1 << 4;
        const long COMMAND_SEND_COMMANDS = 1 << 5;
        
        bool statusUpdated = false;
        long status = 0;
        const long STATUS_ACCELEROMETER_SETUP_ERROR = 1 << 0;
        const long STATUS_ACCELEROMETER_READ_ERROR = 1 << 1;
        const long STATUS_STORAGE_SETUP_ERROR = 1 << 2;
        const long STATUS_GPS_HAS_VALID_DATA = 1 << 3;
        const long STATUS_SHOULD_START_GPS_SESSION = 1 << 4;
        const long STATUS_GPS_SESSION_IN_PROGRESS = 1 << 5;
        const long STATUS_STORE_GPS_DATA_ERROR = 1 << 6;

        void updateStatus(long status);
};