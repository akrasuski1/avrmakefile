
PROJ:=REPLACE_ME_PROJ

SRC:=src
OBJ:=obj

TOOLCHAIN:=avr

PROCESSOR:=REPLACE_ME_PROCESSOR

OPT := -Os
DBG := -g3
WARN:= -Wall -Wextra

FLAGS:=-I"inc"
FLAGS+=-mmcu=$(PROCESSOR)
FLAGS+=$(OPT)
FLAGS+=$(DBG)
FLAGS+=$(WARN)
FLAGS+=-ffunction-sections -fdata-sections
FLAGS+=-fpack-struct -fshort-enums
FLAGS+=-funsigned-char -funsigned-bitfields
FLAGS+=-MMD -MP
FLAGS+=-DF_CPU=REPLACE_ME_F_CPU

C_FLAGS:=   $(FLAGS) -std=c11
CPP_FLAGS:= $(FLAGS) -std=c++14 -fno-exceptions -fno-rtti
S_FLAGS:=   $(FLAGS)

LD_FLAGS:=-mmcu=$(PROCESSOR)
LD_FLAGS+=-Wl,--gc-sections 
LD_FLAGS+=-fno-exceptions -fno-rtti

AVRDUDE=avrdude

AVRDUDE_DEVICE=REPLACE_ME_AVRDUDE_DEVICE
AVRDUDE_PROG=usbasp
AVRDUDE_FLAGS=-P/dev/tty/ACM0

#----------------------------------------------------------------

C_SOURCES:=$(shell find $(SRC) -name *.c)
C_OBJECTS:=$(subst .c,.o,$(subst $(SRC),$(OBJ),$(C_SOURCES)))

CPP_SOURCES:=$(shell find $(SRC) -name *.cpp)
CPP_OBJECTS:=$(subst .cpp,.o,$(subst $(SRC),$(OBJ),$(CPP_SOURCES)))

S_SOURCES:=$(shell find $(SRC) -name *.S)
S_OBJECTS:=$(subst .S,.o,$(subst $(SRC),$(OBJ),$(S_SOURCES)))

OBJECTS:=$(C_OBJECTS) $(CPP_OBJECTS) $(S_OBJECTS)

ELFFILE:=$(OBJ)/$(PROJ).elf
HEXFILE:=$(OBJ)/$(PROJ).hex
EEPFILE:=$(OBJ)/$(PROJ).eep
LSTFILE:=$(OBJ)/$(PROJ).lst

SRC_DIRS:=$(shell find $(SRC) -type d)
OBJ_DIRS:=$(subst $(SRC),$(OBJ),$(SRC_DIRS))

DEPS:=$(OBJECTS:.o=.d)

all: directories $(HEXFILE) $(EEPFILE) $(LSTFILE) printsize

flash: all
	@echo "Flashing..."
	$(AVRDUDE) -p $(AVRDUDE_DEVICE) -c $(AVRDUDE_PROG) $(AVRDUDE_FLAGS) -Uflash:w:$(HEXFILE):a -Ueeprom:w:$(EEPFILE):a
	@echo 

$(C_OBJECTS): $(OBJ)/%.o: $(SRC)/%.c
	@echo "Compiling $<"
	$(TOOLCHAIN)-gcc -c $< $(C_FLAGS) -o $@
	@echo
flags_c:
	@echo $(C_FLAGS) -DREPLACE_ME_AVRINC
$(CPP_OBJECTS): $(OBJ)/%.o: $(SRC)/%.cpp
	@echo "Compiling $<"
	$(TOOLCHAIN)-g++ -c $< $(CPP_FLAGS) -o $@
	@echo
flags_cpp:
	@echo $(CPP_FLAGS) -DREPLACE_ME_AVRINC
$(S_OBJECTS): $(OBJ)/%.o: $(SRC)/%.S
	@echo "Compiling $<"
	$(TOOLCHAIN)-gcc -c $< $(S_FLAGS) -o $@
	@echo
flags_S:
	@echo $(S_FLAGS) -DREPLACE_ME_AVRINC

directories:
	@mkdir -p $(OBJ_DIRS)

$(ELFFILE): $(OBJECTS)
	@echo "Linking final ELF..."
	$(TOOLCHAIN)-gcc $(LD_FLAGS) -o $(ELFFILE) $(OBJECTS) $(LIBS)
	@echo

$(HEXFILE): $(ELFFILE)
	@echo "Creating hex file..."
	$(TOOLCHAIN)-objcopy -R .eeprom -R .fuse -R .lock -R .signature -O ihex $(ELFFILE) $(HEXFILE)
	@echo

$(EEPFILE): $(ELFFILE)
	@echo "Creating eeprom file..."
	$(TOOLCHAIN)-objcopy -j .eeprom --no-change-warnings --change-section-lma .eeprom=0 -O ihex $(ELFFILE) $(EEPFILE)
	@echo

$(LSTFILE): $(ELFFILE)
	@echo "Creating lst file..."
	$(TOOLCHAIN)-objdump -h -S $(ELFFILE) > $(LSTFILE)
	@echo

printsize: $(ELFFILE)
	@echo "Printing size..."
	$(TOOLCHAIN)-size --format=avr --mcu=$(PROCESSOR) $(ELFFILE)
	@echo

clean:
	@echo "Cleaning objects..."
	-rm -rf $(OBJ)/*
	@echo

.PHONY: all clean printsize directories flags_c flags_cpp flags_S

-include $(DEPS)
