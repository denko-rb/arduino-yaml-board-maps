class BoardsParser
  #
  # This catches the following styles of edge cases (only seen in ESP8266 core so far):
  #
  # 1) Main board defines a variant (header) folder, sub-models define none, so they all use the main folder:
  #     sonoff.build.board=ESP8266_SONOFF_SV
  #     sonoff.build.variant=itead
  #     sonoff.menu.BoardModel.sonoffBasic.build.board=ESP8266_SONOFF_BASIC
  #     sonoff.menu.BoardModel.sonoffS20.build.board=ESP8266_SONOFF_S20
  #     sonoff.menu.BoardModel.sonoffSV.build.board=ESP8266_SONOFF_SV
  #     sonoff.menu.BoardModel.sonoffTH.build.board=ESP8266_SONOFF_TH
  #
  # 2) Main board is defined. Sub-models each define their own variant (header) folder:
  #     arduino-esp8266.build.board=ESP8266_ARDUINO
  #     arduino-esp8266.menu.BoardModel.primo.build.board=ESP8266_ARDUINO_PRIMO
  #     arduino-esp8266.menu.BoardModel.primo.build.variant=arduino_spi
  #     arduino-esp8266.menu.BoardModel.starottodeved.build.board=ESP8266_ARDUINO_STAR_OTTO
  #     arduino-esp8266.menu.BoardModel.starottodeved.build.variant=arduino_uart
  #     arduino-esp8266.menu.BoardModel.unowifideved.build.board=ESP8266_ARDUINO_UNOWIFI
  #     arduino-esp8266.menu.BoardModel.unowifideved.build.variant=arduino_uart
  #
  # If both of these are ever combined in the same variant, this parser WILL fail.
  #
  def self.parse(core_root_path)
    boards = {}
    board_identifier = nil
    header_folder = nil
    
    File.readlines("#{core_root_path}/boards.txt").each do |line|
      # Lines matching this define a board or board sub-model.
      match = line.match(/build.board=(.*)\s*\z/)
      if match
        board_identifier = "ARDUINO_#{match[1]}"

        # If there's a board and header set, add it to the hash.
        # Will catch when a sub-model with different name reuses the main board header.
        if board_identifier && header_folder
          boards[board_identifier] = header_folder
        end
        next
      end

      # Lines matching this give the folder name for the board's header file.
      match = line.match(/build.variant=(.*)\s*\z/)
      if match
        header_folder = "#{core_root_path}/variants/#{match[1]}"

        # If there's a board and header set, add it to the hash.
        # Will catch when sub-models use different headers.
        if board_identifier && header_folder
          boards[board_identifier] = header_folder
        end
        next
      end

      # Reset state if end of board section reached.
      match = line.match(/######/)
      if match
        board_identifier = nil
        header_folder = nil
      end
    end

    return boards
  end
end
