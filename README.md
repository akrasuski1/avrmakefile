# AVR Template Creator

This project aims to create a generic makefile useful for developing for AVR devices. While it is not perfect, 
it does its job. I believe it's good for most AVR microprocessors. If you don't want to retype everything 
every time, you can create a file with just the answers to the questions, such as `in` - then project creation
will be as simple as `./avr_template < in`!

Sample run:
```
[adam@adam-Y510P /tmp]λ ~/avr/generic/avr_template 
Hello! This script will interactively create an AVR project.

Please type project name: justTest

Creating project justTest...

Listing possible processor choices:

avr-gcc: note: devices natively supported: ata5272 ata5505 ata5702m322 ata5782 [... snipped ...] at90usb646 at90usb647 at90usb82 at94k m3000
Please choose processor (one of above): atmega328p
You chose atmega328p.

Listing possible processor choices (for avrdude):

Valid parts are:
  uc3a0512 = AT32UC3A0512
  c128     = AT90CAN128
  c32      = AT90CAN32
  c64      = AT90CAN64
  pwm2     = AT90PWM2
  pwm216   = AT90PWM216
[... snipped ...]
  x64a3    = ATxmega64A3
  x64a3u   = ATxmega64A3U
  x64a4    = ATxmega64A4
  x64a4u   = ATxmega64A4U
  x64b1    = ATxmega64B1
  x64b3    = ATxmega64B3
  x64c3    = ATxmega64C3
  x64d3    = ATxmega64D3
  x64d4    = ATxmega64D4
  x8e5     = ATxmega8E5
  ucr2     = deprecated, use 'uc3a0512'

Please choose processor (one of above): m328p
You chose m328p.
Creating simple blink file - hopefully it compiles.
Patching makefile...
What is the clock frequency (F_CPU) in Hz (remember about UL suffix!): 8000000UL
[adam@adam-Y510P /tmp]λ cd justTest/
[adam@adam-Y510P /tmp/justTest]λ make
Compiling src/main.c
avr-gcc -c src/main.c -I"inc" -mmcu=atmega328p -Os -g3 -Wall -Wextra -ffunction-sections -fdata-sections -fpack-struct -fshort-enums -funsigned-char -funsigned-bitfields -MMD -MP -DF_CPU=8000000UL -std=c11 -o obj/main.o

Linking final ELF...
avr-gcc -mmcu=atmega328p -Wl,--gc-sections  -fno-exceptions -fno-rtti -o obj/justTest.elf obj/main.o   

Creating hex file...
avr-objcopy -R .eeprom -R .fuse -R .lock -R .signature -O ihex obj/justTest.elf obj/justTest.hex

Creating eeprom file...
avr-objcopy -j .eeprom --no-change-warnings --change-section-lma .eeprom=0 -O ihex obj/justTest.elf obj/justTest.eep

Creating lst file...
avr-objdump -h -S obj/justTest.elf > obj/justTest.lst

Printing size...
avr-size --format=avr --mcu=atmega328p obj/justTest.elf
AVR Memory Usage
----------------
Device: atmega328p

Program:     162 bytes (0.5% Full)
(.text + .data + .bootloader)

Data:          0 bytes (0.0% Full)
(.data + .bss + .noinit)
```
