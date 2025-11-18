# MazeOfAsterion-AQ

**Character-based first-person dungeon crawler for the Aquarius and Aquarius+ computer**

This project creates a new ROM cartridge for the Mattel Aquarius computer, inspired by the legacy Advanced Dungeons & Dragons: Treasure of Tarmin cartridge. "Maze of Asterion" is designed to be a spiritual successor with modern development practices while maintaining the classic 8-bit charm.

## Quick Start

1. **Install tools**: `make install-tools` (or `sudo apt install pasmo z80asm`)
2. **Build ROM**: `make all`
3. **Check ROM**: `make info`

The resulting ROM file will be in `build/maze_of_asterion.rom` and can be loaded into an Aquarius emulator or burned to an EPROM for real hardware.

## Project Status

✅ **Foundation Complete**
- ROM cartridge structure with proper Aquarius headers
- Z80 assembly development environment
- Build system with automated ROM generation
- Basic system initialization and display routines
- Character set definitions for dungeon graphics
- Keyboard input handling framework

🚧 **Ready for Development**
- Framework ready for Ghidra disassembly integration
- Modular structure for adding game mechanics
- Graphics system prepared for custom character sets
- Documentation and development guidelines

## Key Features

- **Authentic Hardware**: Designed specifically for Mattel Aquarius specifications
- **Modular Architecture**: Easy integration of Ghidra disassembly work
- **Custom Graphics**: Character-based dungeon rendering system
- **Professional Toolchain**: Modern build system with Z80 assembly
- **Open Source**: GPL v3 licensed for community development

## Technical Specifications

- **Target**: Mattel Aquarius / Aquarius+ (Z80 @ 3.58 MHz)
- **ROM Size**: Up to 16KB cartridge (currently 376 bytes)
- **Display**: 40x25 character mode with 16 colors
- **Input**: Full keyboard support with game controls
- **Sound**: AY-3-8910 sound chip ready

## Development

This project provides a complete development framework for creating Aquarius ROM cartridges. The structure is designed to easily accept:

- **Ghidra Disassembly**: Import existing game logic from legacy ROMs
- **Custom Graphics**: Add new character sets and sprites
- **Game Mechanics**: Modular assembly files for different game systems
- **Audio**: Sound effects and music integration

See `docs/README.md` for detailed development documentation.

## Building

```bash
# Test syntax
make test

# Build ROM
make all

# Show ROM information  
make info

# Clean build
make clean
```

## License

GNU General Public License v3.0 - see LICENSE file for details.
