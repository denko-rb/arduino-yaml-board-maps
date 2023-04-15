require_relative "lib/boards_parser"
require_relative "lib/header_parser"

CORES = ["avr", "esp32", "esp8266", "megaavr", "rp2040", "sam3x", "samd"]

# This will end up containing a map for each board identified. Each key
# is a board's identifier and the value is its pin map as a hash.
board_maps = {}

CORES.each do |core|
  core_root = "#{Dir.pwd}/cores/#{core}"

  # Get a hash that maps each board to its variant folder.
  board_headers = BoardsParser.parse(core_root)

  # For each board, parse its header and add it to the hash of maps.
  board_headers.each do |board, header_folder|
    parser = HeaderParser.new(header_folder)
    board_maps[board] = parser.map
  end
end

# Remove chars from board identifier that won't work in a filename.
def board_to_filename(board_identifier)
  board_identifier.gsub(":", "_").gsub(/\AARDUINO_/, "")
end

# Define every board name in BoardMap.cpp
File.open("#{Dir.pwd}/BoardMap.cpp", "w") do |file|
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
