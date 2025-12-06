# Refactoring History - Maze of Asterion

## Overview
This document summarizes major refactoring efforts completed during the relabeling branch work (November 2024 - December 2025). Individual change details are preserved in git history.

---

## Macro Conversions (November 2025)

### COLOR() Macro Implementation
**Branch:** relabeling  
**Files:** asterion_high_rom.asm, asterion_func_low.asm

Converted raw hex color values to COLOR(fg,bg) macro for COLRAM operations:
- **Macro Definition:** `#define COLOR(fg,bg) (fg * 16) + bg`
- **Examples:** 
  - `$b0` → `COLOR(DKBLU,BLK)`
  - `$f0` → `COLOR(DKGRY,BLK)`
  - `$4b` → `COLOR(BLU,DKBLU)`

**Impact:** ~50+ color value conversions across both files, improving readability of COLRAM operations.

### RECT() Macro Implementation
**Branch:** relabeling  
**Files:** asterion_high_rom.asm, asterion_func_low.asm

Converted hex rectangle dimensions to RECT(width,height) macro:
- **Macro Definition:** `#define RECT(width,height) (width * 256) + height`
- **Examples:**
  - `$1818` → `RECT(24,24)` (viewport fills)
  - `$1010` → `RECT(16,16)` (wall fills)
  - `$404` → `RECT(4,4)` (item blocks)

**Impact:** ~15+ rectangle dimension conversions, making FILL_CHRCOL_RECT calls self-documenting.

---

## Label and Variable Renaming (November 2025)

### Wall State Variables
**Branch:** relabeling  
**File:** asterion.inc, asterion_high_rom.asm

Renamed wall state variables from generic `DAT_ram_33xx` to descriptive names based on 3D viewport diagram:
- `DAT_ram_33ec` → `WALL_L2_STATE`
- `DAT_ram_33ee` → `WALL_R1_STATE`
- `DAT_ram_33f0` → `WALL_FR1_STATE`
- `DAT_ram_33f1` → `WALL_FL1_STATE`
- Plus ~10 additional wall state variables

**Impact:** Clarified wall rendering logic in REDRAW_VIEWPORT function.

### GFX_DRAW Internal Labels
**Branch:** relabeling  
**File:** asterion_high_rom.asm

Proposed descriptive labels for 10 subroutines within GFX_DRAW function:
- `LAB_ram_f338` → `GFX_DRAW_MAIN_LOOP`
- `LAB_ram_f33f` → `GFX_MOVE_RIGHT`
- `LAB_ram_f345` → `GFX_CRLF`
- Plus 7 additional control code handlers

**Status:** Documented in GFX_DRAW_SUBROUTINE_RELABELING.md; implementation may be pending.

---

## Terminology Corrections (November 2025)

### Character-Based vs Pixel-Based Language
**Branch:** relabeling  
**Files:** asterion_func_low.asm, documentation

Corrected terminology to align with Mattel Aquarius character-based graphics system:
- **Function Rename:** `DRAW_SINGLE_PIXEL_DOWN` → `DRAW_SINGLE_CHAR_DOWN`
- **Documentation:** "16x16 pixels" → "16x16 characters"
- **Rationale:** Aquarius uses 40x24 character screen with CHRRAM/COLRAM, not pixel manipulation

**Impact:** 6 function calls updated; documentation now accurately reflects hardware architecture.

---

## Header Cleanup (December 2025)

### Input:/Output:/Flow: Section Removal
**Branch:** relabeling-pt2  
**File:** asterion_high_rom.asm

Removed redundant documentation sections from routine headers:
- **Removed:** Input:, Output:, Flow: sections (~1,900 lines total)
- **Retained:** Registers: (Start/In Process/End), Memory Modified:, Calls: sections
- **Added:** Proper `====` separator formatting to 20 headers missing them

**Impact:** Cleaner, more consistent header documentation following standardized template.

### asterion.inc Reorganization
**Branch:** relabeling-pt2  
**File:** asterion.inc

Reorganized 261 EQU labels by memory address for easier reference:
- Low RAM ($1xxx-$2xxx)
- CHRRAM ($3000-$33FF)
- Wall States ($33E8-$33FD)
- COLRAM ($3400-$37FF)
- High RAM ($3800-$3FFF)

**Impact:** Labels now grouped logically by memory region, making lookups faster.

---

## Reference
For detailed change-by-change analysis, see git history for branches:
- `relabeling` (November 2025)
- `relabeling-pt2` (December 2025)
- `relabeling-pt3` (December 2025 - ongoing)
