# Maze of Asterion - Aquarius ROM Development

## Overview

This project creates a new ROM cartridge for the Mattel Aquarius computer, inspired by the legacy Advanced Dungeons & Dragons: Treasure of Tarmin cartridge. "Maze of Asterion" is a character-based first-person dungeon crawler designed specifically for the Aquarius and Aquarius+ systems.

## Project Structure

```
MazeOfAsterion-AQ/
├── src/                    # Z80 assembly source files
│   └── main.asm           # Main ROM source code
├── include/               # Header files and definitions
│   └── aquarius.inc       # Aquarius hardware definitions
├── graphics/              # Graphics data and character sets
├── build/                 # Build output directory
│   ├── maze_of_asterion.rom   # Final ROM binary
│   └── maze_of_asterion.sym   # Symbol table
├── docs/                  # Documentation
├── Makefile              # Build system
└── README.md             # This file
```

## Building the ROM

### Prerequisites

Install the Z80 assembler tools:
```bash
sudo apt install pasmo z80asm
```

Or use the convenience target:
```bash
make install-tools
```

### Building

To build the ROM cartridge:
```bash
make all
```

To test syntax without building:
```bash
make test
```

To see ROM information:
```bash
make info
```

To clean build artifacts:
```bash
make clean
```

## ROM Specifications

- **Target Platform**: Mattel Aquarius / Aquarius+
- **ROM Size**: Up to 16KB (0x0000 - 0x3FFF)
- **Current Size**: 376 bytes (plenty of room for expansion)
- **Assembly Format**: Z80 assembly using Pasmo assembler
- **Character Format**: Custom character set for dungeon graphics

## Memory Layout

| Address Range | Purpose |
|---------------|---------|
| 0x0000-0x3FFF | Cartridge ROM (up to 16KB) |
| 0x3000-0x37FF | Character RAM (2KB) |
| 0x3400-0x37FF | Video RAM (1KB) |
| 0x3800-0x3BFF | Color RAM (1KB) |
| 0x4000-0x7FFF | System RAM (16KB) |

## Features Implemented

### ✅ Complete
- ROM cartridge header with proper Aquarius identification
- Basic system initialization
- Screen clearing and display routines
- Title screen display
- Keyboard input handling
- Basic game loop structure
- Character and color definitions for dungeon graphics

### 🚧 Planned
- First-person dungeon rendering engine
- Map data structure and loading
- Player movement and collision detection
- Monster AI and combat system
- Inventory and item management
- Sound effects and music
- Save/load game state
- Multiple dungeon levels

## Graphics System

The game uses a custom character set designed for creating dungeon environments:

- Wall segments (horizontal, vertical, corners)
- Doors (open/closed)
- Stairs (up/down)
- Treasure chests
- Monster representations
- Player character

## Input Controls

| Key | Action |
|-----|--------|
| W | Move Forward |
| S | Move Backward |
| A | Turn Left |
| D | Turn Right |
| Space | Use/Interact |
| ESC | Menu/Pause |

## Development Notes

### Assembler Compatibility
The project uses Pasmo assembler, which is compatible with standard Z80 assembly syntax. All source files use `.asm` extension and include files use `.inc` extension.

### Ghidra Integration
The project is designed to accept disassembled code from Ghidra. To integrate Ghidra output:

1. Export the disassembly from Ghidra as Z80 assembly
2. Place relevant routines in separate `.asm` files in the `src/` directory
3. Add appropriate `INCLUDE` statements to `main.asm`
4. Update the Makefile to include additional source files

### Graphics Data
Character graphics should be placed in the `graphics/` directory as binary data files or assembly include files.

## Technical Specifications

### Aquarius Hardware
- **CPU**: Z80A at 3.58 MHz
- **RAM**: 4KB (expandable to 20KB)
- **ROM**: 8KB system + cartridge slots
- **Video**: 40x25 character display, 16 colors
- **Sound**: AY-3-8910 sound chip
- **Storage**: Cassette tape interface

### ROM Cartridge Format
- Must start with identification bytes AA 55
- Entry point address at offset 2-3
- Maximum size 16KB for standard cartridges
- Can include custom character sets

## License

This project is licensed under the GNU General Public License v3.0. See LICENSE file for details.

## Contributing

This is a development framework for creating Aquarius ROM cartridges. To add features:

1. Create new assembly files in `src/`
2. Add hardware definitions to `include/`
3. Place graphics data in `graphics/`
4. Update the Makefile as needed
5. Test with `make test` before committing

The structure is designed to be modular and extensible for creating various types of Aquarius software.