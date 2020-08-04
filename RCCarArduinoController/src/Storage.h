
class Storage {
    public:
        Storage(int chipSelect);
        void cardInfo();

        bool setup();

        bool startGPSSession(unsigned int carID, uint32_t rawDate, uint32_t rawTime);
        bool storeGPSData(byte* data);
        void stopGPSSession();

    private:
        int chipSelect;

        std::string sessionFilename;
};