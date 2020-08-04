
#ifndef COMMANDS
#endif

class CommandCenter {
    public:
        void update(long command);

        bool shouldUpdateAccelerometerData();
        bool shouldUpdateStatus();
        
        void statusUpdated();

        bool shouldStartTrackingSession();

        
    private:
        const long COMMAND_ENABLE_ACCELEROMETER = 1 << 0;
        const long COMMAND_UPDATE_STATUS = 1 << 1;

        long command = 0;
};