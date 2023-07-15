require_relative "lib/boards_parser"
require_relative "lib/header_parser"

CORES = ["avr", "esp32", "esp8266", "megaavr", "rp2040", "sam3x", "samd", "ra4m1"]

# This will end up containing a map for each board identified. Each key
# is a board's identifier and the value is its pin map as a hash.
board_maps = {}

CORES.each do |core|
  core_root = "#{Dir.pwd}/cores/#{core}"

  # Get a hash that maps each board to its variant folder.
  board_headers = BoardsParser.parse(core_root)

  # For each board, parse its header and add it to the hash of maps.
  board_headers.each do |board, header_folder|
    # No idea what this is, but doesn't seem to be a real board.
    next if board.match /muxto/i
    
    parser = HeaderParser.new(header_folder)
    board_maps[board] = parser.map
  end
end

# Manually set DAC pins for Arduino branded RA4M1 boards.
# Should handle with different matchers for each core, but this works for now.
board_maps["ARDUINO_MINIMA"][:DAC] = 14
board_maps["ARDUINO_UNOWIFIR4"][:DAC] = 14
board_maps["ARDUINO_PORTENTA_C33"][:DAC] = 21
board_maps["ARDUINO_PORTENTA_C33"][:DAC1] = 20

# Remove chars from board identifier that won't work in a filename.
def board_to_filename(board_identifier)
  board_identifier.gsub(":", "_").gsub(",", "_").gsub(/\AARDUINO_/, "")
end

# Define every board name in BoardMap.h
File.open("#{Dir.pwd}/BoardMap.h", "w") do |file|
  board_maps.each_key do |board_identifier|
    file.write "#ifdef #{board_identifier}\n"
    file.write "  #define BOARD_MAP \"#{board_to_filename(board_identifier)}\"\n"
    file.write "#endif\n"
    file.write "\n"
  end
end

# Generate a YAML file for each board.
require 'yaml'
board_maps.each do |board_identifier, map|
  filename = board_to_filename(board_identifier)
  File.open("#{Dir.pwd}/yaml/#{filename}.yml", "w") do |file|
    file.write(map.to_yaml)
  end
end

puts "Parsed #{board_maps.count} boards."
