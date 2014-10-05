A basic WS2812 driver for the ESP8266.  You send a UDP packet to it on port 7777 and it plops it out GPIO0.
In something the WS2812B can understand.  WARNING: You should have a 100p cap across GPIO0 to GND.  I don't know why
but it will flash if you don't.

There is a major flaw.  If you send packets big enough, something strange happens with the interrupts
that causes the chip to reboot. No idea why, though.

