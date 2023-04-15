# Arduino Board Maps in YAML Format

The aim of this script is to map common identifiers used in the [Arduino](https://github.com/arduino) IDE to their integer pin numbers. For example, on many Arduino boards, the analog input pin labeled `A0` maps to an integer pin number of `14`, but this isn't always the case. With the large variety of boards the Arduino IDE supports, it's difficult to keep track of mappings manually.

### How to identify the board?

Along with the maps inside the `yaml` folder, there is `BoardMap.h`. Include that in a sketch, and it will `#define BOARD_MAP`, based on your board selection in Arduino. The value of `BOARD_MAP` is the filename for that board's map, minus the `.yml` extension.

### Why map the pins?

If the sketch tells a remote machine its `BOARD_MAP`, the map can be loaded from its file. From there, the remote machine uses it to translate between pin identifiers and integers, before sending instructions to the board, or receiving messages from it.

This is the exact use case this was deisgned for, in support of the [dino](https://github.com/austinbv/dino) Ruby gem. It allows more intuitive pin referencing in Ruby, while simplifying the Arduino sketch so it only handles pins as integers.

## Supported Arduino Cores

- [avr](https://github.com/arduino/ArduinoCore-avr)
- [megaavr](https://github.com/arduino/ArduinoCore-megaavr)
- [sam](https://github.com/arduino/ArduinoCore-sam)
- [samd](https://github.com/arduino/ArduinoCore-samd)
- [esp8266](https://github.com/esp8266/Arduino)
- [esp32](https://github.com/espressif/arduino-esp32)
- [rp2040](https://github.com/earlephilhower/arduino-pico)

## Mappings

- `A0` analog input pins (sequential on AVR, disordered on others)
- `DAC0` digital-to-analog-pins
- `D0` pins (some on RP2040. Many on ESP8266 where DX doesn't map to GPIOX)
- `T0` pins (capacitive touch pins on ESP32)
- `SCL`, `SDA`, `SCLX`, `SDAX`, default and numbered hardware I2C pins
- `MOSI`, `MISO`, `SCK`, `SS`, `MOSIX`, `MISOX`, `SCKX`, `SSX`, default and numbered hardware SPI pins
- `LED_BUILTIN` which is usually defined for the on-board LED

TODO: Add UART and CAN?

## Usage

Clone or download this repo and use `BoardMap.ccpp` and all the files inside `yaml` as descibed above.

Each map is a flat dictionary where each key (an identifier) maps to one integer.

**Note:** All keys are prefixed with `:`, so they automatically translate to Ruby symbols when loaded.

## Development

Be warned: This is mostly a hack that runs `boards.txt` and header files form the Arduino core repos through regexes. :man_shrugging:

- Clone this repo.
- Clone the submodules inside `core`. No need for recursion. Still close to 4GB.
- `ruby run.rb` to udpate `BoardMap.cpp` and all the files inside `yaml`.
