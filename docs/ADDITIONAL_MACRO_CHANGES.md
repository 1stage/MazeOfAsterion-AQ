# Additional COLOR() and RECT() Macro Changes Documentation

## Overview
Additional macro conversions found after the initial COLOR() and RECT() implementation.

**Date:** November 11, 2025  
**Branch:** relabeling  
**File:** src/asterion_func_low.asm only

## Additional Changes Made

### COLOR() Conversions (DE Register Operations)

#### Change 1: Line 2
**Before:** `LD DE,$29                                                         ; GRN on DKCYN`
**After:** `LD DE,COLOR(GRN,DKCYN)                                    ; GRN on DKCYN`
**Context:** DRAW_DOOR_BOTTOM_SETUP function
**Note:** This is a DE register load, not A register - used for color operations

#### Change 2: Line 18
**Before:** `LD DE,$29                                                         ; GRN on DKCYN`
**After:** `LD DE,COLOR(GRN,DKCYN)                                    ; GRN on DKCYN`
**Context:** Second instance in drawing functions
**Note:** Duplicate of the same color value as above

### Standard COLOR() Conversions (A Register Operations)

#### Change 3: Line 125
**Before:** `LD A,$f0                                                          ; DKGRY on BLK`
**After:** `LD A,COLOR(DKGRY,BLK)                                                             ; DKGRY on BLK`
**Context:** DRAW_WALL_F0_AND_OPEN_DOOR function

#### Change 4: Line 138
**Before:** `LD A,$4b                                                          ; BLU on DKBLU`
**After:** `LD A,COLOR(BLU,DKBLU)                                                             ; BLU on DKBLU`
**Context:** DRAW_WALL_F1 function, COLRAM_F0_DOOR_IDX

#### Change 5: Line 149
**Before:** `LD A,0x0                                                          ; BLK on BLK`
**After:** `LD A,COLOR(BLK,BLK)                                                               ; BLK on BLK`
**Context:** DRAW_WALL_F1_AND_OPEN_DOOR function

#### Change 6: Line 160
**Before:** `LD A,0x0                                                          ; BLK on BLK`
**After:** `LD A,COLOR(BLK,BLK)                                                               ; BLK on BLK`
**Context:** DRAW_DOOR_F2_OPEN function, COLRAM_F1_DOOR_IDX

#### Change 7: Line 166
**Before:** `LD A,$40                                                          ; BLU on BLK`
**After:** `LD A,COLOR(BLU,BLK)                                       ; BLU on BLK`
**Context:** DRAW_WALL_FL0 function, COLRAM_FL00_WALL_IDX

#### Change 8: Line 172
**Before:** `LD A,0x4                                                          ; BLK on BLU`
**After:** `LD A,COLOR(BLK,BLU)                               ; BLK on BLU`
**Context:** DRAW_WALL_FL0 function

#### Change 9: Line 180
**Before:** `LD A,$f4                                                          ; DKGRY on BLU`
**After:** `LD A,COLOR(DKGRY,BLU)                                     ; DKGRY on BLU`
**Context:** DRAW_WALL_FL0 function

#### Change 10: Line 196
**Before:** `LD A,$f0                                                          ; DKGRY on BLK`
**After:** `LD A,COLOR(DKGRY,BLK)                                     ; DKGRY on BLK`
**Context:** DRAW_DOOR_FLO function

#### Change 11: Line 200
**Before:** `LD A,0x4                                                          ; BLK on BLU`
**After:** `LD A,COLOR(BLK,BLU)                                       ; BLK on BLU`
**Context:** DRAW_DOOR_FLO function

#### Change 12: Line 206
**Before:** `LD A,$f2                                                          ; DKGRY on GRN`
**After:** `LD A,COLOR(DKGRY,GRN)                                     ; DKGRY on GRN`
**Context:** SUB_ram_c996 function

#### Change 13: Line 210
**Before:** `LD A,$24                                                          ; GRN on BLU`
**After:** `LD A,COLOR(GRN,BLU)                                       ; GRN on BLU`
**Context:** SUB_ram_c996 function, used in DRAW_FL0_DOOR_FRAME

#### Change 14: Line 234
**Before:** `LD A,0x4                                                          ; BLK on BLU`
**After:** `LD A,COLOR(BLK,BLU)                                                       ; BLK on BLU`
**Context:** SUB_ram_c9c5 function

#### Change 15: Line 246
**Before:** `LD A,$4b                                                          ; BLU on DKBLU`
**After:** `LD A,COLOR(BLU,DKBLU)                                     ; BLU on DKBLU`
**Context:** SUB_ram_c9d0 function, COLRAM_L1_WALL_IDX

#### Change 16: Line 250
**Before:** `LD A,$dd                                                          ; DKGRN on DKGRN`
**After:** `LD A,COLOR(DKGRN,DKGRN)                           ; DKGRN on DKGRN`
**Context:** SUB_ram_c9e5 function

### RECT() Conversions

#### Change 17: Line 162
**Before:** `LD BC,$404                                                                ; 4 x 4 rectangle`
**After:** `LD BC,RECT(4,4)                                                           ; 4 x 4 rectangle`
**Context:** UPDATE_F0_ITEM function

#### Change 18: Line 253
**Before:** `LD BC,$206                                                                ; 2 x 6 rectangle`
**After:** `LD BC,RECT(2,6)                                           ; 2 x 6 rectangle`
**Context:** DRAW_L1_DOOR_PATTERN function, used with DRAW_CHRCOLS

## Color Value Conversions Reference
- `$29` = 41 = (2*16) + 9 = `COLOR(GRN,DKCYN)`
- `$f0` = 240 = (15*16) + 0 = `COLOR(DKGRY,BLK)`
- `$4b` = 75 = (4*16) + 11 = `COLOR(BLU,DKBLU)`
- `$40` = 64 = (4*16) + 0 = `COLOR(BLU,BLK)`
- `$04` = 4 = (0*16) + 4 = `COLOR(BLK,BLU)`
- `$f4` = 244 = (15*16) + 4 = `COLOR(DKGRY,BLU)`
- `$f2` = 242 = (15*16) + 2 = `COLOR(DKGRY,GRN)`
- `$24` = 36 = (2*16) + 4 = `COLOR(GRN,BLU)`
- `$dd` = 221 = (13*16) + 13 = `COLOR(DKGRN,DKGRN)`
- `$00` = 0 = (0*16) + 0 = `COLOR(BLK,BLK)`

## Summary
**Total Additional Changes: 18**
- **16 COLOR() conversions:** 14 for A register operations, 2 for DE register operations
- **2 RECT() conversions:** Missed hex values converted to RECT macro

## Notes
- Found interesting use of COLOR() macro with DE register (lines 2, 18) - not just A register
- All changes maintain exact same functionality with improved readability
- Two additional RECT() conversions that were missed in previous systematic search
- These changes complete the macro conversion coverage for this file

## Lines Still Using Hex (if any)
Additional sweep may be needed to ensure complete conversion coverage.