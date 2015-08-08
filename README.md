#DEPRECATION NOTICE
This project is here mostly as a guide for the old way to do basic C ESP8266 projects.  If you want improved WS2812 driving and a more modern environment, please check out: https://github.com/cnlohr/esp8266ws2812i2s.


#ESP8266 WS2812 Driver (With ESP8266 Build Guide)
A basic WS2812 driver for the ESP8266.  You send a UDP packet to it on port 7777 and it plops it out GPIO0.
In something the WS2812B can understand.  WARNING: You should have a 100p cap across GPIO0 to GND.  I don't know why but it will flash if you don't.


#How to build a build environment.

#STEP 0: Environment
  I use Linux Mint and already had all the packages I needed installed.
  If you  run into commands that do not exist on your system, it should prompt
  you on how to get it.  If you fail in GCC, you may need:

* build-essential
* gperf 
* bison flex 
* texinfo
* libtool
* libncurses5-dev
* wget
* gawk
* libc6-dev-amd64
* python-serial
* libexpat-dev
* libisl-dev
* libcloog-isl-dev
* libmpc-dev
* gprof

  amongst others.

#STEP 0.1: Alternatives.

The current method I use is this: https://github.com/pfalcon/esp-open-sdk You can skip Step 1 if you use this.
It also contains a superior libc, so I highly recommend it.

The methods outlined in this document are an older method of installing everything.  You can check out
this site here: https://github.com/esp8266/esp8266-wiki/wiki/Toolchain to see if anything jives more
easily with your setup.


#STEP 1: Getting GCC and tools
  Get and build a copy of the xtensa build toolchain here:
  https://github.com/jcmvbkbc/xtensa-toolchain-build
   ... you're building the lx106 version.  You will also need the patched GCC here: https://github.com/jcmvbkbc/gcc-xtensa/commits/call0-4.8.2
  The commands you will need are as follows:
```
cd ~/esp8266
git clone https://github.com/jcmvbkbc/xtensa-toolchain-build.git
cd xtensa-toolchain-build
wget http://ftp.gnu.org/pub/gnu/binutils/binutils-2.24.tar.bz2
git clone --depth=1 https://github.com/jcmvbkbc/gcc-xtensa.git
mv gcc-xtensa gcc-4.9.1
wget http://ftp.gnu.org/gnu/gdb/gdb-7.6.tar.bz2
./prepare.sh lx106
./build-elf.sh lx106
```

#Step 2: ESPTool (for binaries)
You'll need a copy of esptool:
  download esp-0.0.2.zip from http://filez.zoobab.com/esp8266/esptool-0.0.2.zip
  I downloaded it to ~/esp8266/other/.
  You will need to build it, too.
```
cd ~/esp8266
mkdir other
cd other
wget http://filez.zoobab.com/esp8266/esptool-0.0.2.zip
unzip esptool-0.0.2.zip
cd esptool
### Edit Makefile to read on the first line: TARGET_ARCH	= LINUX
make
```
  Verify there are no errors.

Note the "License" file in this folder, you can move it into esp_iot_sdk_v0.9.3 if you wish.


#Step 5: Configure and build.
Once you got all those four, check out a copy of ws2812esp8266.
```
cd ~/esp8266
git clone https://github.com/cnlohr/ws2812esp8266.git
```


#Step 3: esptool.py
You'll need to get a copy of esptool.py.  You may want to change:
```
ESP_ROM_BAUD    = 230400
```
  So you don't have to wait all day.
  You can get it from: https://github.com/themadinventor/esptool/.  Simply git clone.
```
cd ~/esp8266
git clone https://github.com/themadinventor/esptool.git
```
#Step 4: Get the SDK
I expect you get the esp_iot_sdk_v0.9.3. 
  esp_iot_sdk_v0.9.3_14_11_21.zip -> http://bbs.espressif.com/download/file.php?id=72
  esp_iot_sdk_v0.9.3_14_11_21_patch1.zip -> http://bbs.espressif.com/download/file.php?id=73
```
cd ~/esp8266
wget http://bbs.espressif.com/download/file.php?id=72 -O esp_iot_sdk_v0.9.3_14_11_21.zip
wget http://bbs.espressif.com/download/file.php?id=73 -O esp_iot_sdk_v0.9.3_14_11_21_patch1.zip
unzip esp_iot_sdk_v0.9.3_14_11_21.zip 
unzip -f esp_iot_sdk_v0.9.3_14_11_21_patch1.zip 
```

Note the "License" file in this folder, you can move it into esp_iot_.

    Building esptool Ffor building the esptool setting TARGET_ARCH to LINUX is fine. I needed to fix some return types in elf/esptool_elf_object.c (line 252 and 258) and binimage/esptool_binimage.c (line 159). The compiler tells the line-numbers.
sdk_v0.9.3 if you wish.


#Step 5: Configure and build.
Once you got all those four, check out a copy of ws2812esp8266.
```
cd ~/esp8266
git clone https://github.com/cnlohr/ws2812esp8266.git
```

Configure it in your makefile with the following:
```
GCC_FOLDER:=~/esp8266/xtensa-toolchain-build/build-lx106
ESPTOOL_PY:=~/esp8266/esptool/esptool.py
FW_TOOL:=~/esp8266/other/esptool/esptool
SDK:=~/esp8266/esp_iot_sdk_v0.9.3
```
#Step 6: Hardware

For my examples, I use the standard WI-06 format, it's the one with the 2x4 (8) pin .1" header at the bottom. 

```
 TXD        GND----+
                   |
 CH_PD      GPIO2  SWITCH  MAIN BODY + ANTENNA THIS WAY
  |                |               (TOP VIEW)
 RST---1k---GPIO0--+
  |
 VCC        RXD
```

#Appendix A: Building on OSX.
Ingo Randolf found that this also works on OSX with the following commands:


instead of wget one can use curl for downloading files:
curl -O http://file-to-download.zip

##1. building gcc

In order for gcc to build I had to specify where to find mpc, mpfr, gmp. all of those libraries are installed via macports, so they are at /opt/local/include and /opt/local/lib.

In build-gcc.sh I appended this to the line which call the configure command for gcc: 
```--with-mpc=/opt/local --with-mpfr=/opt/local --with-gmp=/opt/local```

The full line looks like this:
```../../$GCC/configure --target=$TARGET --prefix=$PREFIX \
    -enable__cxa_atexit --disable-shared --disable-libssp --enable-languages=c "$@"  --with-mpc=/opt/local --with-mpfr=/opt/local --with-gmp=/opt/local```


##2. ccache-install.sh

In ccache-install.sh i needed to change the last line to:

```find ./ -type f | xargs -I{} ln -sf ../../../ccache.sh ../ccache/{}```

"find" needs a path as the seconds argument, xargs option -i is deprecated, -I must be used.


##3. Building esptool

Ffor building the esptool setting TARGET_ARCH to LINUX is fine.  I needed to fix some return types in elf/esptool_elf_object.c (line 252 and 258) and binimage/esptool_binimage.c (line 159).  The compiler tells the line-numbers.


