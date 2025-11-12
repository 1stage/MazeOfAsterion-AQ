# GFX_DRAW Subroutine Relabeling Analysis

## Overview
This document provides a comprehensive analysis of the 10 subroutines within the GFX_DRAW function, proposing descriptive replacement labels and documenting all references across the codebase to ensure safe relabeling.

## Current Function Context
- **Function**: GFX_DRAW (lines 2705-2839 in asterion_high_rom.asm)
- **Purpose**: Core AQUASCII graphics rendering with cursor control
- **System**: Character-based graphics for Mattel Aquarius
- **Memory**: CHRRAM ($3000-$33FF), COLRAM ($3400-$37FF)

## Subroutine Analysis

### 1. LAB_ram_f338 - Main Processing Loop
**Current Label**: `LAB_ram_f338`
**Recommended Label**: `GFX_DRAW_MAIN_LOOP`
**Function**: Main character processing loop that fetches bytes and dispatches to appropriate handlers
**Location**: Line 2723
**References Found**: 8 references (all within GFX_DRAW function)
- Line 2735: `JP LAB_ram_f338` (from $00 handler - move right)
- Line 2745: `JP LAB_ram_f338` (from $01 handler - CR+LF)  
- Line 2750: `JP LAB_ram_f338` (from $02 handler - backspace)
- Line 2761: `JP LAB_ram_f338` (from $03 handler - LF)
- Line 2772: `JP LAB_ram_f338` (from $04 handler - cursor up)
- Line 2780: `JP LAB_ram_f338` (from $A0 handler - reverse colors)
- Line 2813: `JP LAB_ram_f338` (from character drawing completion)

**Archive Files**: Also referenced in asterion_high_rom_restore.txt and asterion_old.asm.txt (backup/archive copies)

### 2. LAB_ram_f33f - Control Code $00 Handler  
**Current Label**: `LAB_ram_f33f`
**Recommended Label**: `GFX_MOVE_RIGHT`
**Function**: Handles AQUASCII control code $00 (move cursor right)
**Location**: Line 2731
**References Found**: 2 references
- Line 2728: `JP NZ,LAB_ram_f33f` (conditional jump from main loop)
- Line 2731: Label definition

**Archive Files**: Also referenced in restore and old archive files

### 3. LAB_ram_f345 - Control Code $01 Handler
**Current Label**: `LAB_ram_f345`  
**Recommended Label**: `GFX_CRLF`
**Function**: Handles AQUASCII control code $01 (carriage return + line feed)
**Location**: Line 2736
**References Found**: 2 references
- Line 2733: `JP NZ,LAB_ram_f345` (conditional jump from main loop)
- Line 2736: Label definition

**Archive Files**: Also referenced in restore and old archive files

### 4. LAB_ram_f352 - Control Code $02 Handler
**Current Label**: `LAB_ram_f352`
**Recommended Label**: `GFX_BACKSPACE`
**Function**: Handles AQUASCII control code $02 (backspace cursor)
**Location**: Line 2746
**References Found**: 2 references  
- Line 2738: `JP NZ,LAB_ram_f352` (conditional jump from main loop)
- Line 2746: Label definition

**Archive Files**: Also referenced in restore and old archive files

### 5. LAB_ram_f359 - Control Code $03 Handler
**Current Label**: `LAB_ram_f359`
**Recommended Label**: `GFX_LINE_FEED`
**Function**: Handles AQUASCII control code $03 (line feed only)
**Location**: Line 2751  
**References Found**: 2 references
- Line 2748: `JP NZ,LAB_ram_f359` (conditional jump from main loop)
- Line 2751: Label definition

**Archive Files**: Also referenced in restore and old archive files

### 6. LAB_ram_f367 - Control Code $04 Handler
**Current Label**: `LAB_ram_f367`
**Recommended Label**: `GFX_CURSOR_UP`
**Function**: Handles AQUASCII control code $04 (move cursor up)
**Location**: Line 2762
**References Found**: 2 references
- Line 2753: `JP NZ,LAB_ram_f367` (conditional jump from main loop)  
- Line 2762: Label definition

**Archive Files**: Also referenced in restore and old archive files

### 7. LAB_ram_f377 - Control Code $A0 Handler
**Current Label**: `LAB_ram_f377`
**Recommended Label**: `GFX_REVERSE_COLOR`
**Function**: Handles AQUASCII control code $A0 (toggle reverse video colors)
**Location**: Line 2773
**References Found**: 2 references
- Line 2764: `JP NZ,LAB_ram_f377` (conditional jump from main loop)
- Line 2773: Label definition

**Archive Files**: Also referenced in restore and old archive files

### 8. LAB_ram_f385 - Character Drawing Handler
**Current Label**: `LAB_ram_f385`
**Recommended Label**: `GFX_DRAW_CHAR`
**Function**: Handles drawing normal characters (not control codes) to CHRRAM/COLRAM
**Location**: Line 2781
**References Found**: 2 references
- Line 2775: `JP NZ,LAB_ram_f385` (conditional jump for non-control characters)
- Line 2781: Label definition  

**Archive Files**: Also referenced in restore and old archive files

### 9. LAB_ram_f398 - Low Nybble Color Handler
**Current Label**: `LAB_ram_f398`
**Recommended Label**: `GFX_COLOR_LOW_NYBBLE`
**Function**: Stores color information in low nybble of COLRAM byte (for chars > $0F)
**Location**: Line 2801
**References Found**: 2 references
- Line 2793: `JP C,LAB_ram_f398` (conditional jump when B > $0F)
- Line 2801: Label definition

**Archive Files**: Also referenced in restore and old archive files

### 10. LAB_ram_f39a - Color Merge Handler
**Current Label**: `LAB_ram_f39a`
**Recommended Label**: `GFX_SWAP_FG_BG`
**Function**: Merges color nybbles and stores final color value to COLRAM
**Location**: Line 2804
**References Found**: 2 references
- Line 2800: `JP LAB_ram_f39a` (unconditional jump from high nibble path)
- Line 2804: Label definition

**Archive Files**: Also referenced in restore and old archive files

## Reference Summary
All 10 subroutine labels are **internally referenced only** within the GFX_DRAW function itself. No external functions call these labels directly, making them safe candidates for relabeling. The pattern is consistent:

1. **Archive files contain identical copies** - these are backup/restore versions
2. **All references are local** - no cross-function dependencies  
3. **Clean encapsulation** - all jumps originate and terminate within GFX_DRAW
4. **Consistent patterns** - each handler follows same dispatch→process→return pattern

## Implementation Strategy
Since all references are local to the GFX_DRAW function and contained within the same file (plus archive copies), relabeling can be done safely with a systematic find-and-replace approach for each label.

## Recommended Relabeling Order
1. Start with most frequently referenced (LAB_ram_f338 → GFX_DRAW_MAIN_LOOP)
2. Continue with control code handlers in logical order ($00-$04, $A0)
3. Finish with character drawing and color handlers
4. Update archive files if they are actively maintained

## Benefits of Relabeling
- **Immediate code comprehension** - function purpose clear from label name
- **Maintenance efficiency** - easier debugging and modification  
- **Documentation alignment** - labels match comprehensive function documentation
- **Professional appearance** - descriptive naming consistent with documented code
- **Educational value** - newcomers can understand AQUASCII control system instantly