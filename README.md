A basic WS2812 driver for the ESP8266.  You send a UDP packet to it on port 7777 and it plops it out GPIO0.
In something the WS2812B can understand.  WARNING: You should have a 100p cap across GPIO0 to GND.  I don't know why
but it will flash if you don't.

There is a major flaw.  If you send packets big enough, something strange happens with the interrupts
that causes the chip to reboot. No idea why, though.

General notes:

You'll need a copy of esptool:
  download esp-0.0.2.zip from http://filez.zoobab.com/esp8266/esptool-0.0.2.zip

You'll need to get a copy of esptool.py.  You may want to change:
     ESP_ROM_BAUD    = 230400
  So you don't have to wait all day.
  You can get it from: https://github.com/themadinventor/esptool/

I expect you get the esp_iot_sdk_v0.9.3. 
  esp_iot_sdk_v0.9.3_14_11_21.zip -> http://bbs.espressif.com/download/file.php?id=72
  esp_iot_sdk_v0.9.3_14_11_21_patch1.zip -> http://bbs.espressif.com/download/file.php?id=73

You'll need to build a copy of the xtensa build toolchain here:
  https://github.com/jcmvbkbc/xtensa-toolchain-build
   ... you're building the lx106 version.
    ./build-elf.sh lx106

Once you got all those four, configure, in your makeifle the following:
  GCC_FOLDER:=~/esp8266/xtensa-toolchain-build/build-lx106
  ESPTOOL_PY:=../../esp8266/firmware_staging/esptool/esptool.py
  FW_TOOL:=../../esp8266/esptool/esptool/esptool
  SDK:=../../esp8266/esp_iot_sdk_v0.9.3


