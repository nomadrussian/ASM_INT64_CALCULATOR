SRC_DIR = src
BUILD_DIR = bin
DEBUG_DIR = bin_debug
NASM = nasm -f elf64
NASM_DEBUG = nasm -g -f elf64
LD = ld --fatal-warnings
SRC = $(wildcard $(SRC_DIR)/*.asm)
OBJ = $(patsubst $(SRC_DIR)%.asm, $(BUILD_DIR)%.o, $(SRC))
OBJ_DEBUG = $(patsubst $(SRC_DIR)%.asm, $(DEBUG_DIR)%.o, $(SRC))
BIN = $(BUILD_DIR)/calc
BIN_DEBUG = $(DEBUG_DIR)/calc_debug
RUNFILE = run
DEBUGFILE = debug

.PHONY:
	bin
	dbg
	build_dir
	debug_dir
	clean
	clean_debug
	clean_all

all: bin dbg
bin: build_dir $(BIN) $(RUNFILE)
dbg: debug_dir $(BIN_DEBUG) $(DEBUGFILE)

# creating build directory
build_dir:
	@mkdir -p $(BUILD_DIR)

# creating debug directory
debug_dir:
	@mkdir -p $(DEBUG_DIR)

# main project binary file
$(BIN) : $(OBJ)
	@$(LD) $(OBJ) -o $(BIN)
	@rm $(OBJ)

# debug binary file
$(BIN_DEBUG) : $(OBJ_DEBUG)
	@$(LD) $(OBJ_DEBUG) -o $(BIN_DEBUG)
	@rm $(OBJ_DEBUG)

# object modules
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm
	@$(NASM) $< -o $@

# object modules with debug info
$(DEBUG_DIR)/%.o: $(SRC_DIR)/%.asm
	@$(NASM_DEBUG) $< -o $@

$(RUNFILE):
	@touch $(RUNFILE)
	@echo "#!/bin/sh" > $(RUNFILE)
	@echo "./$(BIN)" > $(RUNFILE)
	@chmod +x $(BIN)
	@chmod +x $(RUNFILE)

$(DEBUGFILE):
	@touch $(DEBUGFILE)
	@echo "#!/bin/sh" > $(DEBUGFILE)
	@echo "gdb $(BIN_DEBUG)" > $(DEBUGFILE)
	@chmod +x $(BIN_DEBUG)
	@chmod +x $(DEBUGFILE)

# cleaning the build

clean: clean_bin clean_debug

clean_bin:
	@rm -f $(BIN) $(RUNFILE)
	@rm -rf $(BUILD_DIR)

clean_debug:
	@rm -f $(BIN_DEBUG) $(DEBUGFILE)
	@rm -rf $(DEBUG_DIR)

