cores = [
  { name: "avr",      repo: "https://github.com/arduino/ArduinoCore-avr.git",     commit: "c8c514c9a19602542bc32c7033f48fecbbda4401" },
  { name: "esp32",    repo: "https://github.com/espressif/arduino-esp32.git",     commit: "13cd0d3c3fb6d6f719c55cdb671d6807874427b5" },
  { name: "esp8266",  repo: "https://github.com/esp8266/Arduino.git",             commit: "587435110f03a3ad53a0cc7144387a353f478521" },
  { name: "megaavr",  repo: "https://github.com/arduino/ArduinoCore-megaavr.git", commit: "5e639ee40afa693354d3d056ba7fb795a8948c11" },
  { name: "ra4m1",    repo: "https://github.com/arduino/ArduinoCore-renesas.git", commit: "f032b827fec8ae4d33e55aa0f92b906e76a51aa5" },
  { name: "rp2040",   repo: "https://github.com/earlephilhower/arduino-pico.git", commit: "dd1c9095e8e3f37eb38fc4d11f9aec9214d1cfba" },
  { name: "sam3x",    repo: "https://github.com/arduino/ArduinoCore-sam",         commit: "790ff2c852bf159787a9966bddee4d9f55352d15" },
  { name: "samd",     repo: "https://github.com/arduino/ArduinoCore-samd.git",    commit: "993398cb7a23a4e0f821a73501ae98053773165b" },
]

cores.each do |core|
  dir = "#{Dir.pwd}/cores/#{core[:name]}"
  git_dir = "#{dir}/.git"
  `git clone #{core[:repo]} "#{dir}"`
  `git --git-dir="#{git_dir}" --work-tree="#{dir}" checkout #{core[:commit]}`
end
