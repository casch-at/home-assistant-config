#include "esphome.h"


class DeskHeightSensor: public Component, public UARTDevice, public Sensor {
public:
  DeskHeightSensor(UARTComponent *parent): UARTDevice(parent) {}

  void setup() override {}

  void loop() override {
    // Desk controller frames are 3 bytes long
    uint8_t sequence[3] = {0};
    uint8_t idx = 0;
    uint8_t data;
    while (available()) {
      data = read();
      if (data > -1) {
        sequence[idx] = data;
        ++idx;
      }
      if (idx == 3)
        break;
    }
    if (sequence[0] == 1 and sequence[1] == 0 and idx == 3) {
      publish_state(sequence[2]);
    }
  }

private:

}; // DeskHeightSensor
