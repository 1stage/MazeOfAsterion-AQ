# Maze of Asterion - Terminology Corrections

## Overview
This document tracks corrections made to align terminology with the Mattel Aquarius's character-based graphics system rather than pixel-based terminology.

## Background
The Mattel Aquarius uses a character-based graphics system with:
- 40x24 character screen resolution
- Character RAM (CHRRAM) for character definitions
- Color RAM (COLRAM) for character colors
- No direct pixel manipulation capabilities

## Documentation Changes

### VIEWPORT_REDRAW_FLOW.md
**Date**: November 11, 2025

**Changes Made**:
- **"16x16 pixels"** → **"16x16 characters"** (F0 walls)
- **"8x8 pixels"** → **"8x8 characters"** (F1 walls) 
- **"4x4 pixels"** → **"4x4 characters"** (F2 walls)

**Rationale**: The viewport rendering system operates on character cells, not individual pixels. Wall segments are measured in character dimensions.

## Code Changes

### Function Renaming
**Date**: November 11, 2025

#### DRAW_SINGLE_PIXEL_DOWN → DRAW_SINGLE_CHAR_DOWN
**File**: `src/asterion_func_low.asm`
**Line**: 4

**Original Function**:
```asm
DRAW_SINGLE_PIXEL_DOWN:
    LD          (HL),A      ; Write to screen memory
    SCF                     ; Set carry flag  
    CCF                     ; Clear carry flag
    SBC         HL,DE       ; Move down one screen row
```

**Analysis**: This function writes a single character or color value to screen memory and moves to the next row down. It manipulates character cells, not pixels.

**Updated Function Name**: `DRAW_SINGLE_CHAR_DOWN`

**Usage**: Called 6 times throughout `asterion_func_low.asm` for:
- Drawing character symbols (`$c0`, `$c1` - right-angle characters)
- Setting color values (`COLOR(DKGRY,BLU)`, `$b0`)
- Drawing door frame elements  
- Creating wall geometry patterns

**Impact**: 
- Function definition updated
- 6 function calls updated
- Build artifacts (asterion.lis, asterion.map) will reflect changes after rebuild

## Technical Notes

### Character-Based Graphics System
The Aquarius graphics system works with:
- **Character cells**: 8x8 pixel character definitions stored in CHRRAM
- **Color attributes**: Foreground/background colors stored in COLRAM  
- **Screen layout**: 40 columns × 24 rows of character cells
- **Memory mapping**: Direct memory access to character and color data

### Rendering Process
1. Character data defines the shape/pattern within each 8x8 cell
2. Color data defines foreground and background colors for each cell
3. Wall rendering functions write both character codes and color codes
4. No direct pixel manipulation - all graphics through character cell system

## Benefits of Correction

1. **Accuracy**: Terminology now matches the actual hardware capabilities
2. **Clarity**: Developers understand they're working with character cells
3. **Documentation**: Technical documentation reflects true system behavior
4. **Maintenance**: Code is more self-documenting with correct function names

## References

- Mattel Aquarius Technical Reference Manual
- `docs/VIEWPORT_REDRAW_FLOW.md` - Complete rendering system analysis
- `src/asterion_func_low.asm` - Low-level graphics functions
- `src/asterion.inc` - Graphics system constants and macros