# RECT() Macro Conversion Documentation

## Overview
Converting hex values in `LD BC,$XXXX` statements to use the RECT(width,height) macro for better readability.

**Date:** November 11, 2025  
**Branch:** relabeling  
**Macro Definition:** `#define RECT(width,height) (width * 256) + height` (in src/aquarius.inc line 45)

## Parameter Order Confirmation
- **Width:** High byte (B register) - first parameter
- **Height:** Low byte (C register) - second parameter  
- **Hex Format:** `$WWHH` where WW=width, HH=height (both in hex)

## Changes to be Made

### File: src/asterion_high_rom.asm

#### Change 1: Line 226
**Before:**
```asm
    LD          BC,$1818								;  24 x 24
```
**After:**
```asm
    LD          BC,RECT(24,24)								;  24 x 24
```
**Context:** FILL_CHRCOL_RECT call on line 229  
**Function:** Fill map CHARs with SPACES

#### Change 2: Line 231  
**Before:**
```asm
    LD          BC,$1818								;  24 x 24
```
**After:**
```asm
    LD          BC,RECT(24,24)								;  24 x 24
```
**Context:** FILL_CHRCOL_RECT call on line 234  
**Function:** Fill map colors

#### Change 3: Line 2136
**Before:**
```asm
    LD          BC,$1818								;  18 x 18 rectangle
```
**After:**
```asm
    LD          BC,RECT(24,24)								;  24 x 24 rectangle
```
**Context:** FILL_CHRCOL_RECT call on line 2138  
**Function:** PLAYER_DIES function  
**Note:** Also fixing incorrect comment (was "18 x 18" should be "24 x 24")

### File: src/asterion_func_low.asm

#### Change 4: Line 113
**Before:**
```asm
    LD          BC,$1010							; 16 x 16 rectangle
```
**After:**
```asm
    LD          BC,RECT(16,16)							; 16 x 16 rectangle
```
**Context:** JP FILL_CHRCOL_RECT on line 115  
**Function:** DRAW_F0_WALL

#### Change 5: Line 1140
**Before:**
```asm
    LD          BC,$1818								;  24 x 24 cells
```
**After:**
```asm
    LD          BC,RECT(24,24)								;  24 x 24 cells
```
**Context:** CALL FILL_CHRCOL_RECT on line 1141  
**Function:** DRAW_BKGD

## Hex to Decimal Conversions
- `$1010` = 16,16 decimal → `RECT(16,16)`
- `$1818` = 24,24 decimal → `RECT(24,24)`

## Rollback Instructions
To rollback these changes, reverse each replacement:
1. `RECT(24,24)` → `$1818`
2. `RECT(16,16)` → `$1010`
3. Fix comment on line 2136 back to original if desired

## Files Not Changed
The following LD BC statements were identified but NOT changed because they are not followed by FILL_CHRCOL_RECT:
- asterion_high_rom.asm line 278: `LD BC,$1018` (used for different purpose)
- asterion_high_rom.asm line 1198: `LD BC,$8600` (sleep cycles)
- asterion_high_rom.asm line 1883: `LD BC,$1600` (not followed by FILL_CHRCOL_RECT)
- asterion_func_low.asm line 1308: `LD BC,$8000` (different purpose)
- asterion_func_low.asm line 1324: `LD BC,$d1d0` (value, not address)
- asterion_func_low.asm line 1342: `LD BC,$f00f` (value, not address)
- asterion_func_low.asm line 1466: `LD BC,$1300` (not followed by FILL_CHRCOL_RECT)

## Verification
After changes:
1. Build should succeed with no errors
2. All RECT() macro calls should resolve correctly
3. No functional changes to game behavior expected