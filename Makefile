all : image.elf
FW_FILE_1:=0x00000.bin
FW_FILE_2:=0x40000.bin

TARGET_OUT:=image.elf
OBJS:=driver/uart.o \
	user/mystuff.o \
	user/ws2812.o \
	user/user_main.o

SRCS:=driver/uart.c \
	user/mystuff.c \
	user/ws2812.c \
	user/user_main.c 

ESPTOOL_PY:=../../esp8266/firmware_staging/esptool/esptool.py
FW_TOOL:=../../esp8266/esptool/esptool/esptool
SDK:=../../esp8266/esp8266_sdk_v0.9.1
XTLIB:=$(SDK)/lib_from_xt/lx106/xtensa-elf/lib
FOLDERPREFIX=~/esp8266/xtensa-toolchain-build/build-lx106/root/bin
PREFIX:=$(FOLDERPREFIX)/xtensa-lx106-elf-
CC:=$(PREFIX)gcc

CFLAGS:=-mlongcalls -I$(SDK)/include -Imyclib -Iinclude -Iuser -Os -I$(SDK)/lib_from_xt/lx106/xtensa-elf/include/
LDFLAGS_CORE:=\
	$(SDK)/lib/libmain.a \
	$(SDK)/lib/liblwip.a \
	$(SDK)/lib/libphy.a \
	$(SDK)/lib/libssl.a \
	$(SDK)/lib/libupgrade.a \
	$(SDK)/lib/libupgrade_ssl.a \
	$(SDK)/lib/libnet80211.a \
	$(SDK)/lib/libwpa.a \
	$(SDK)/lib/libnet80211.a \
	-L$(SDK)/lib_from_xt/lx106/xtensa-elf/arch/lib \
	-L$(XTLIB) \
	-T deps/eagle.app.v6.ld

LDFLAGS:= \
	$(LDFLAGS_CORE) \
	$(XTLIB)/xcc/libgcc.a


LINKFLAGS:= \
	$(LDFLAGS_CORE) \
	-B$(XTLIB) \
	-B$(XTLIB)/../arch/lib

#image.elf : $(OBJS)
#	$(PREFIX)ld $^ $(LDFLAGS) -o $@

$(TARGET_OUT) : $(SRCS)
	$(PREFIX)gcc $^ $(CFLAGS) -flto $(LINKFLAGS) -o $@



$(FW_FILE_1): $(TARGET_OUT)
	@echo "FW $@"
	$(FW_TOOL) -eo $(TARGET_OUT) -bo $@ -bs .text -bs .data -bs .rodata -bc -ec

$(FW_FILE_2): $(TARGET_OUT)
	@echo "FW $@"
	$(FW_TOOL) -eo $(TARGET_OUT) -es .irom0.text $@ -ec

burn : $(FW_FILE_1) $(FW_FILE_2)
	($(ESPTOOL_PY) --port /dev/ttyUSB0 write_flash 0x00000 0x00000.bin)||(true)
	echo "Replug."
	sleep 2
	($(ESPTOOL_PY) --port /dev/ttyUSB0 write_flash 0x40000 0x40000.bin)||(true)


clean :
	rm -rf user/*.o driver/*.o $(TARGET_OUT) $(FW_FILE_1) $(FW_FILE_2)


