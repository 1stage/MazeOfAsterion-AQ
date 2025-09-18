# Makefile for Maze of Asterion Aquarius ROM
# ==============================================================================

# Project settings
PROJECT_NAME = maze_of_asterion
ROM_NAME = $(PROJECT_NAME).rom
SRC_DIR = src
INC_DIR = include
BUILD_DIR = build
GRAPHICS_DIR = graphics

# Assembler settings
ASM = pasmo
ASM_FLAGS = --alocal

# Source files
MAIN_SRC = $(SRC_DIR)/main.asm
SOURCES = $(wildcard $(SRC_DIR)/*.asm)
INCLUDES = $(wildcard $(INC_DIR)/*.inc)

# Output files
ROM_FILE = $(BUILD_DIR)/$(ROM_NAME)
LISTING_FILE = $(BUILD_DIR)/$(PROJECT_NAME).lst
SYMBOL_FILE = $(BUILD_DIR)/$(PROJECT_NAME).sym

# Default target
all: $(ROM_FILE)

# Build ROM from main source
$(ROM_FILE): $(MAIN_SRC) $(INCLUDES) | $(BUILD_DIR)
	@echo "Assembling $(MAIN_SRC)..."
	cd $(SRC_DIR) && $(ASM) $(ASM_FLAGS) -I ../$(INC_DIR) main.asm ../$(ROM_FILE) ../$(SYMBOL_FILE)
	@echo "ROM built successfully: $(ROM_FILE)"
	@ls -la $(ROM_FILE)

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)
	@echo "Build artifacts cleaned"

# Test build (check syntax without creating ROM)
test:
	@echo "Testing assembly syntax..."
	cd $(SRC_DIR) && $(ASM) $(ASM_FLAGS) -I ../$(INC_DIR) main.asm /tmp/test.bin
	@echo "Syntax check passed"
	rm -f /tmp/test.bin

# Show ROM information
info: $(ROM_FILE)
	@echo "ROM Information:"
	@echo "  File: $(ROM_FILE)"
	@echo "  Size: $$(stat -c%s $(ROM_FILE)) bytes"
	@echo "  Max Cartridge Size: 16384 bytes (16KB)"
	@echo ""
	@echo "Memory Layout:"
	@echo "  ROM Start: 0x0000"
	@echo "  ROM End:   0x3FFF (16KB max)"
	@echo ""
	@if [ -f $(SYMBOL_FILE) ]; then \
		echo "Symbols:"; \
		head -20 $(SYMBOL_FILE); \
	fi

# Install development tools (run with sudo)
install-tools:
	apt update && apt install -y pasmo z80asm

# Show help
help:
	@echo "Maze of Asterion Build System"
	@echo "============================"
	@echo ""
	@echo "Targets:"
	@echo "  all          Build the ROM file (default)"
	@echo "  clean        Remove build artifacts"
	@echo "  test         Test assembly syntax"
	@echo "  info         Show ROM information"
	@echo "  install-tools Install development tools"
	@echo "  help         Show this help"
	@echo ""
	@echo "Files:"
	@echo "  Source:      $(MAIN_SRC)"
	@echo "  Includes:    $(INC_DIR)/"
	@echo "  Output ROM:  $(ROM_FILE)"
	@echo "  Graphics:    $(GRAPHICS_DIR)/"

.PHONY: all clean test info install-tools help