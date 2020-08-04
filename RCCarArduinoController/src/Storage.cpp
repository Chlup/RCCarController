#include <SD.h> 

#include "Storage.h"
#include "constants.h"

Storage::Storage(int chipSelect) {
    this->chipSelect = chipSelect;
}

bool Storage::setup() {
  return SD.begin(chipSelect);
}

bool Storage::startGPSSession(unsigned int carID, uint32_t rawDate, uint32_t rawTime) {
  std::string directory = std::to_string(rawDate);
  const char* cDirectory = directory.c_str();
  if (!SD.exists(cDirectory)) {
    if (SD.mkdir(cDirectory)) {
      Serial.print("Created directory: "); Serial.println(cDirectory);
    } else {
      Serial.print("Can't create directory: "); Serial.println(cDirectory);
      return false;
    }
  }

  sessionFilename = directory + "/" + std::to_string(rawTime) + ".log";

  File file = SD.open(sessionFilename.c_str(), FILE_WRITE);
  if (file.write((const uint8_t*)&carID, sizeof(unsigned int)) == 0) {
    Serial.print("Failed to write cardID to file: "); Serial.println(sessionFilename.c_str());
    file.close();
    sessionFilename = "";
    return false;
  }

  file.close();
  return true;
}

bool Storage::storeGPSData(byte* data) {
  if (sessionFilename.length() == 0) {
    return false;
  }

  File file = SD.open(sessionFilename.c_str(), FILE_WRITE);
  if (file.write(data, sizeof(byte) * GPS_DATA_LENGTH) == 0) {
    Serial.print("Failed to write cardID to file: "); Serial.println(sessionFilename.c_str());
    file.close();
    return false;
  }

  file.close();

  Serial.println("Wrote to file");

  byte hour = data[0];
  byte minute = data[1];
  byte second = data[2];

  DoubleBytes lonBytes;
  DoubleBytes latBytes;
  ShortBytes altBytes;

  for (int i = 3; i < 11; i++) {
    lonBytes.bytes[i-3] = data[i];
  }

  for (int i = 11; i < 19; i++) {
    latBytes.bytes[i-11] = data[i];
  }

  altBytes.bytes[0] = data[19];
  altBytes.bytes[1] = data[20];

  ShortBytes hdopBytes;
  hdopBytes.bytes[0] = data[20];
  hdopBytes.bytes[1] = data[21];

  // storage.storeSessionRecord(data);
  Serial.print("Hour "); Serial.println(hour); 
  Serial.print("Minute "); Serial.println(minute);
  Serial.print("Second "); Serial.println(second);
  Serial.print("lon "); Serial.println(lonBytes.value, 6);
  Serial.print("lat "); Serial.println(latBytes.value, 6);
  Serial.print("altitude "); Serial.println(altBytes.value);
  Serial.print("HDOP (raw) "); Serial.println(hdopBytes.value);
  return true;
}

void Storage::stopGPSSession() {
  sessionFilename = "";
}

void Storage::cardInfo() {
    Sd2Card card;
    SdVolume volume;
    SdFile root;

    Serial.print("\nInitializing SD card...");

  // we'll use the initialization code from the utility libraries
  // since we're just testing if the card is working!
  if (!card.init(SPI_FULL_SPEED, chipSelect)) {
    Serial.println("initialization failed. Things to check:");
    Serial.println("* is a card inserted?");
    Serial.println("* is your wiring correct?");
    Serial.println("* did you change the chipSelect pin to match your shield or module?");
    while (1);
  } else {
    Serial.println("Wiring is correct and a card is present.");
  }

  // print the type of card
  Serial.println();
  Serial.print("Card type:         ");
  switch (card.type()) {
    case SD_CARD_TYPE_SD1:
      Serial.println("SD1");
      break;
    case SD_CARD_TYPE_SD2:
      Serial.println("SD2");
      break;
    case SD_CARD_TYPE_SDHC:
      Serial.println("SDHC");
      break;
    default:
      Serial.println("Unknown");
  }

  // Now we will try to open the 'volume'/'partition' - it should be FAT16 or FAT32
  if (!volume.init(card)) {
    Serial.println("Could not find FAT16/FAT32 partition.\nMake sure you've formatted the card");
    while (1);
  }

  Serial.print("Clusters:          ");
  Serial.println(volume.clusterCount());
  Serial.print("Blocks x Cluster:  ");
  Serial.println(volume.blocksPerCluster());

  Serial.print("Total Blocks:      ");
  Serial.println(volume.blocksPerCluster() * volume.clusterCount());
  Serial.println();

  // print the type and size of the first FAT-type volume
  uint32_t volumesize;
  Serial.print("Volume type is:    FAT");
  Serial.println(volume.fatType(), DEC);

  volumesize = volume.blocksPerCluster();    // clusters are collections of blocks
  volumesize *= volume.clusterCount();       // we'll have a lot of clusters
  volumesize /= 2;                           // SD card blocks are always 512 bytes (2 blocks are 1KB)
  Serial.print("Volume size (Kb):  ");
  Serial.println(volumesize);
  Serial.print("Volume size (Mb):  ");
  volumesize /= 1024;
  Serial.println(volumesize);
  Serial.print("Volume size (Gb):  ");
  Serial.println((float)volumesize / 1024.0);

  Serial.println("\nFiles found on the card (name, date and size in bytes): ");
  root.openRoot(volume);

  // list all files in the card with date and size
  root.ls(LS_R | LS_DATE | LS_SIZE);
  root.close();
  Serial.println("\nListing files finished.");
}