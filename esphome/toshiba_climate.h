#pragma once

#include "esphome/components/climate_ir/climate_ir.h"

namespace esphome {
namespace toshiba {

const float TOSHIBA_TEMP_MIN = 17.0;
const float TOSHIBA_TEMP_MAX = 30.0;

class MyToshibaClimate : public climate_ir::ClimateIR {
 public:
  ToshibaClimate() : climate_ir::ClimateIR(
    TOSHIBA_TEMP_MIN,
    TOSHIBA_TEMP_MAX,
    1.0f,
    true,
    true,
    std:vector<climate::ClimateFanMode>{
      climate::ClimateFanMode::CLIMATE_FAN_AUTO,
      climate::ClimateFanMode::CLIMATE_FAN_LOW,
      climate::ClimateFanMode::CLIMATE_FAN_MEDIUM,
      climate::ClimateFanMode::CLIMATE_FAN_HIGH,
      climate::ClimateFanMode::CLIMATE_FAN_MIDDLE,
      climate::ClimateFanMode::CLIMATE_FAN_FOCUS
    }
    std:vector<climate::ClimateSwingMode>{
      climate::ClimateSwingMode::CLIMATE_SWING_OFF,
      climate::ClimateSwingMode::CLIMATE_SWING_BOTH,
      climate::ClimateSwingMode::CLIMATE_SWING_VERTICAL,
      climate::ClimateSwingMode::CLIMATE_SWING_HORIZONTAL
    }
  ) {}

 protected:
  void transmit_state() override;
  bool on_receive(remote_base::RemoteReceiveData data) override;
};

} /* namespace toshiba */
} /* namespace esphome */
