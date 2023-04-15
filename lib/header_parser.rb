class HeaderParser
  attr_reader :map

  def initialize(folder)
    # Empty hash to fill and return with the pin map.
    @map = {}
    @folder = folder

    # Gotta try all .h files since there's no naming consistency...
    # No idea if this puts them in the right order, but it shouldn't matter.
    header_files = Dir["#{@folder}/*.h"]
    header_files.each do |path|
      parse_file(path)
    end

    clean_map
  end

  def parse_file(path)
    begin
      file = File.open(path)
    rescue => exception
      # Fail silently if file not found. Some of these headers include standard libs...
      return
    end

    file.each_line do |line|
      # Reject comments.
      next if line.match /\A\/\//

      # Reject lines that end with pin-style identifiers, instead of numbers.
      next if line.match /(PIN_)*(A|D|DAC|T)(\d+)\s*;*\s*\z/
      next if line.match /(PIN_SPI_|PIN_WIRE_)*(SDA|SCL|SS|MOSI|MISO|SCK)\s*;*\s*\z/

      # Recursively parse included headers...smh
      included = line.match /\A\s*#include\s*("|<)(.*)("|>)/
      if included
        path = File.expand_path(included[2], @folder)
        parse_file(path)
      end

      # Match RP2040 analog overrides and store them with prefixed keys like :_A0
      # Will substitute them later in #clean_map
      rp2040_analog = line.match /__PIN(_A\d+)\s*\(?(\d+)\w*\)?/
      if rp2040_analog
        @map[rp2040_analog[1].to_sym] = rp2040_analog[2].to_i
        next
      end

      #
      # Match analog input and DAC pins declared like:
      #     #define PIN_A0 (14ul)
      #     #define PIN_DAC0 (14)
      #     #define PIN_A0 14
      #     #define A0 14
      #
      pin = line.match /(PIN_)*((A|DAC)\d+)\s*\(?(\d+)\w*\)?/
      if pin
        @map[pin[2].to_sym] = pin[4].to_i
        next
      end

      #
      # Match I2C/SPI pins declared like:
      #     #define PIN_WIRE_SDA (20ul)
      #     #define PIN_SPI0_MOSI (51)
      #     #define PIN_WIRE2_SDA 20
      #     #define WIRE1_SDA 21
      #
      pin = line.match /(PIN_)*((WIRE|SPI)\d*_\w+)\s*\(?(\d+)\w*\)?/
      if pin
        @map[pin[2].to_sym] = pin[4].to_i
        next
      end

      #
      # Match custom labeled D* pins (eg. ESP8266) declared like: 
      #     static const uint D4 = (2)
      #
      # Match analog pins declared like:
      #     static const uint8_t A0 = 14
      #
      # Match DAC pins declared like:
      #     static const uint8_t DAC1 = 25
      #
      # Match capacitive touch pins declared like:
      #     static const uint8_t T0 = 4
      #
      pin = line.match /((A|D|DAC|T)\d+)\s*=\s*\(?(\d+)\w*\)?/
      if pin
        @map[pin[1].to_sym] = pin[3].to_i
        next
      end

      #
      # Match I2C/SPI pins declared like:
      #     static const uint8_t SDA = 21
      #
      pin = line.match /(SDA|SCL|SS|MOSI|MISO|SCK)\s*=\s*\(?(\d+)\w*\)?/
      if pin
        @map[pin[1].to_sym] = pin[2].to_i
        next
      end

      #
      # Match LED_BUILTIN declared like:
      #     #define LED_BUILTIN 13
      #     #define PIN_LED      2
      #     #define PIN_LED13   13
      #
      led = line.match /(PIN_LED|LED_BUILTIN)(_13)*\s+\(?(\d+)\w*\)?/
      if led
        @map[:LED_BUILTIN] = led[3].to_i unless line.match /2812/
        next
      end

      #
      # Match LED_BUILTIN declared like:
      #     static const uint8_t LED_BUILTIN   = 2
      #     static const uint8_t LED_BUILTIN13 = 13
      #     static const uint8_t PIN_LED       = 4
      #
      led = line.match /(PIN_LED|LED_BUILTIN)(_13)*\s*=\s*\(?(\d+)\w*\)?/
      if led
        @map[:LED_BUILTIN] = led[3].to_i unless line.match /2812/
        next
      end
    end
  end

  def clean_map
    # Updated references to merge with the map after.
    map_updates = {}

    @map.each do |key, value|
      # One board double defines SPI_SS and SPI_CS.
      @map.delete(key) if key.to_s.match /CS/

      # Filter out some stuff we shouldn't be catching.
      if key.to_s.match /(HOWMANY|PIN_DEFINED|INTERFACES_COUNT|CHANNELS_NUM|PAD)/
        @map.delete(key)
        next
      end

      # Fix RP2040 analog pin overrides.
      if key.to_s.match /_A\d+/
        new_key = key.to_s.gsub("_", "")
        map_updates[new_key.to_sym] = value
        @map.delete(key)
      end

      # Standardize SPI / WIRE styling.
      spi_match = key.to_s.match /(SPI|WIRE)(\d*)_(\w+)/
      if spi_match
        new_key = "#{spi_match[3]}#{spi_match[2]}"
        map_updates[new_key.to_sym] = value 
        @map.delete(key)
        next
      end
    end

    @map = @map.merge(map_updates)
  end
end
