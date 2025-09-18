# Ghidra Integration Guide

This document explains how to integrate disassembled code from Ghidra into the Maze of Asterion project.

## Ghidra Export Process

1. **Open the ROM in Ghidra**
   - Load the original Treasure of Tarmin ROM
   - Set processor to Z80
   - Set memory map for Aquarius (ROM at 0x0000-0x3FFF)

2. **Analyze the Code**
   - Run Auto Analysis
   - Identify functions and data structures
   - Add labels and comments

3. **Export Assembly Code**
   - Select code regions to export
   - Use File → Export Program → Assembly
   - Choose Z80 assembly format

## Integration Steps

### 1. Organize Ghidra Output

Create separate files for different game systems:

```
src/
├── main.asm              # Main ROM entry and initialization
├── graphics.asm          # Display and rendering routines  
├── input.asm            # Keyboard and input handling
├── game_logic.asm       # Core game mechanics
├── monsters.asm         # Monster AI and behavior
├── items.asm            # Inventory and item system
└── sound.asm            # Audio and sound effects
```

### 2. Extract Useful Routines

From Ghidra output, identify and extract:

- **Display routines**: First-person view rendering
- **Movement code**: Player movement and collision
- **Map data**: Dungeon layout and structure
- **Game logic**: Combat, inventory, progression
- **Character graphics**: Wall patterns, monsters, items

### 3. Adapt Code Syntax

Ghidra export may need syntax adjustments:

**Ghidra Output:**
```assembly
LAB_0x0100:
        LD        A,0x20
        LD        (0x3400),A
        JP        LAB_0x0200
```

**Adapted for Project:**
```assembly
clear_screen_char:
        LD A, CHAR_SPACE
        LD (VIDEO_RAM_START), A
        JP next_routine
```

### 4. Update Include Files

Add constants from the original ROM to `include/aquarius.inc`:

```assembly
; Original game constants
DUNGEON_WIDTH           EQU 16
DUNGEON_HEIGHT          EQU 16
MAX_MONSTERS            EQU 8
PLAYER_START_HEALTH     EQU 200

; Memory locations from original
PLAYER_STATS            EQU $4000
CURRENT_MAP             EQU $4100
MONSTER_DATA            EQU $4200
```

### 5. Update Build System

Modify `Makefile` to include new source files:

```makefile
SOURCES = $(wildcard $(SRC_DIR)/*.asm)

$(ROM_FILE): $(SOURCES) $(INCLUDES) | $(BUILD_DIR)
	@echo "Assembling multiple sources..."
	cd $(SRC_DIR) && $(ASM) $(ASM_FLAGS) -I ../$(INC_DIR) main.asm ../$(ROM_FILE) ../$(SYMBOL_FILE)
```

## Useful Ghidra Files

When working with Ghidra, these files are most useful:

### Essential Files:
- **main.gpr** - Ghidra project file
- **[ROM_NAME].gzf** - Program database with analysis
- **[ROM_NAME].rep** - Analysis report

### Export Formats:
- **Assembly (.asm)** - Z80 assembly code
- **C (.c)** - Decompiled C code (for reference)
- **XML (.xml)** - Complete program data

### Not Needed:
- **Database files (.db)** - Internal Ghidra storage
- **Temp files (.tmp)** - Temporary analysis data

## Example Integration

Here's an example of integrating a movement routine from Ghidra:

**1. Ghidra identifies this routine:**
```assembly
; Function: handle_player_movement
; Address: 0x0850
LAB_0x0850:
        IN A, (0xFF)     ; Read keyboard
        CP 0x11          ; Check 'W' key
        JP Z, LAB_0x0870 ; Move forward
        CP 0x1F          ; Check 'S' key  
        JP Z, LAB_0x0890 ; Move backward
        RET

LAB_0x0870:
        ; Move forward logic
        LD A, (player_y)
        DEC A
        LD (player_y), A
        RET

LAB_0x0890:
        ; Move backward logic
        LD A, (player_y)
        INC A
        LD (player_y), A
        RET
```

**2. Adapted for our project:**
```assembly
; ==============================================================================
; PLAYER MOVEMENT - Adapted from original Treasure of Tarmin
; ==============================================================================

handle_player_movement:
        CALL get_key
        CP KEY_W                        ; Forward key
        JP Z, move_player_forward
        CP KEY_S                        ; Backward key
        JP Z, move_player_backward
        RET

move_player_forward:
        LD A, (player_y)
        DEC A                          ; Move north (decrease Y)
        ; TODO: Add collision detection
        LD (player_y), A
        RET

move_player_backward:
        LD A, (player_y) 
        INC A                          ; Move south (increase Y)
        ; TODO: Add collision detection
        LD (player_y), A
        RET
```

**3. Added to main.asm:**
```assembly
        INCLUDE "input.asm"            ; Include movement routines

; In main game loop:
        CALL handle_player_movement    ; Process movement input
```

## Best Practices

1. **Keep Original Comments**: Preserve Ghidra's analysis comments
2. **Use Meaningful Labels**: Replace auto-generated labels with descriptive names
3. **Modularize Code**: Split large routines into smaller, focused functions
4. **Document Sources**: Note which code came from Ghidra analysis
5. **Test Incrementally**: Add one routine at a time and test

## Memory Map Considerations

When integrating code, be aware of memory differences:

**Original Tarmin:**
- May have used different memory layout
- Character data at different addresses
- Different variable locations

**Our Project:**
- Follows standard Aquarius memory map
- Variables in `include/aquarius.inc`
- Character data in `graphics/charset.inc`

Always verify memory addresses match our target system!