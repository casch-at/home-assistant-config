#include "esphome.h"


class DeskHeightSensor: public Component, public UARTDevice, public Sensor {
public:
  DeskHeightSensor(UARTComponent *parent): UARTDevice(parent) {}

  void setup() override {}

  void loop() override {
    uint8_t sequence[this->FRAME_LENGTH] = {0};
    uint8_t idx = -1;
    uint8_t data;
    while (available()) {
      data = read();

      if (data > -1)
        sequence[++idx] = data;

      if (*(uint16_t*)(sequence) == 1 and idx == this->FRAME_LENGTH)
        publish_state(sequence[2]);
    }
  }
private:
  const uint8_t FRAME_LENGTH = 3;
}; // DeskHeightSensor
