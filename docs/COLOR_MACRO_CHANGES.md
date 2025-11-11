# COLOR() Macro Conversion Documentation

## Overview
Converting hex color values in `LD A,$XX` statements to use the COLOR(fg,bg) macro for better readability in COLRAM operations.

**Date:** November 11, 2025  
**Branch:** relabeling  
**Macro Definition:** `#define COLOR(fg,bg) (fg * 16) + bg` (in src/aquarius.inc line 43)

## Color Constants Reference (from aquarius.inc)
```asm
BLK     EQU 0      ; Black
RED     EQU 1      ; Red  
GRN     EQU 2      ; Green
YEL     EQU 3      ; Yellow
BLU     EQU 4      ; Blue
MAG     EQU 5      ; Magenta
CYN     EQU 6      ; Cyan
WHT     EQU 7      ; White
GRY     EQU 8      ; Light Gray
DKCYN   EQU 9      ; Dark Cyan
DKMAG   EQU 10     ; Dark Magenta
DKBLU   EQU 11     ; Dark Blue
LTYEL   EQU 12     ; Light Yellow
DKGRN   EQU 13     ; Dark Green
DKRED   EQU 14     ; Dark Red
DKGRY   EQU 15     ; Dark Grey
```

## Hex to COLOR() Conversion Chart
- `$b0` = 176 = (11*16) + 0 = `COLOR(DKBLU,BLK)`
- `$f0` = 240 = (15*16) + 0 = `COLOR(DKGRY,BLK)`  
- `$44` = 68 = (4*16) + 4 = `COLOR(BLU,BLU)`
- `$22` = 34 = (2*16) + 2 = `COLOR(GRN,GRN)`
- `$2d` = 45 = (2*16) + 13 = `COLOR(GRN,DKGRN)`
- `$ff` = 255 = (15*16) + 15 = `COLOR(DKGRY,DKGRY)`
- `$4b` = 75 = (4*16) + 11 = `COLOR(BLU,DKBLU)`
- `$11` = 17 = (1*16) + 1 = `COLOR(RED,RED)`
- `$0f` = 15 = (0*16) + 15 = `COLOR(BLK,DKGRY)`
- `$00` = 0 = (0*16) + 0 = `COLOR(BLK,BLK)`

## Changes to be Made

### File: src/asterion_high_rom.asm

#### Change 1: Line 233
**Before:** `LD A,$b0                                   ; DKBLU on BLK`
**After:** `LD A,COLOR(DKBLU,BLK)                                   ; DKBLU on BLK`
**Context:** Fill map viewport colors, COLRAM_VIEWPORT_IDX ($3428)

#### Change 2: Line 399
**Before:** `LD A,$f0                                   ; DKGRY on BLK`
**After:** `LD A,COLOR(DKGRY,BLK)                                   ; DKGRY on BLK`
**Context:** Item drawing, COLRAM_RH_ITEM_IDX

#### Change 3: Line 2137
**Before:** `XOR A                                       ; BLK on BLK`
**After:** `LD A,COLOR(BLK,BLK)                                       ; BLK on BLK`
**Context:** Player dies screen, COLRAM_VIEWPORT_IDX ($3428)

### File: src/asterion_func_low.asm

#### Change 4: Line 114
**Before:** `LD A,$44                                   ; BLU on BLU`
**After:** `LD A,COLOR(BLU,BLU)                                   ; BLU on BLU`
**Context:** DRAW_F0_WALL, COLRAM_F0_WALL_MAP_IDX ($34cc)

#### Change 5: Line 118
**Before:** `LD A,$22                                   ; GRN on GRN`
**After:** `LD A,COLOR(GRN,GRN)                                   ; GRN on GRN`
**Context:** Used by DRAW_DOOR_F0, COLRAM_F0_DOOR_IDX

#### Change 6: Line 142
**Before:** `LD A,$2d                                   ; GRN on DKGRN`
**After:** `LD A,COLOR(GRN,DKGRN)                                   ; GRN on DKGRN`
**Context:** DRAW_DOOR_F1_OPEN, COLRAM_F1_DOOR_IDX

#### Change 7: Line 154
**Before:** `LD A,$ff                                   ; DKGRY on DKGRY`
**After:** `LD A,COLOR(DKGRY,DKGRY)                                   ; DKGRY on DKGRY`
**Context:** DRAW_WALL_F2, COLRAM_F1_DOOR_IDX

#### Change 8: Line 306
**Before:** `LD A,$ff                                   ; DKGRY on DKGRY`
**After:** `LD A,COLOR(DKGRY,DKGRY)                                   ; DKGRY on DKGRY`
**Context:** COLRAM_FL22_WALL_IDX

#### Change 9: Line 383
**Before:** `LD A,$4b                                   ; BLU on DKBLU`
**After:** `LD A,COLOR(BLU,DKBLU)                                   ; BLU on DKBLU`
**Context:** SUB_ram_cab0, DAT_ram_356c ($356c COLRAM)

#### Change 10: Line 405
**Before:** `LD A,$11                                   ; BLK on DKGRY`
**After:** `LD A,COLOR(RED,RED)                                   ; RED on RED`
**Context:** DRAW_WALL_FL2, COLRAM_FL2_WALL_IDX
**Note:** Fixed comment - $11 = COLOR(RED,RED), not "BLK on DKGRY"

#### Change 11: Line 416
**Before:** `LD A,0x0                                   ; BLK on BLK`
**After:** `LD A,COLOR(BLK,BLK)                                   ; BLK on BLK`
**Context:** COLRAM_FL2_WALL_IDX

#### Change 12: Line 695
**Before:** `LD A,$4b                                   ; BLU on DKBLU`
**After:** `LD A,COLOR(BLU,DKBLU)                                   ; BLU on DKBLU`
**Context:** SUB_ram_cc9a, DAT_ram_3578 ($3578 COLRAM)

#### Change 13: Line 717
**Before:** `LD A,0x0                                   ; BLK on BLK`
**After:** `LD A,COLOR(BLK,BLK)                                   ; BLK on BLK`
**Context:** SUB_ram_ccc3, DAT_ram_35ca ($35ca COLRAM)

#### Change 14: Line 1434
**Before:** `LD A,0x0                                   ; BLK on BLK`
**After:** `LD A,COLOR(BLK,BLK)                                   ; BLK on BLK`
**Context:** DRAW_WALL_FL22_EMPTY, COLRAM_FL22_WALL_IDX

#### Change 15: Line 1447
**Before:** `LD A,0xf                                   ; BLK on DKGRY`
**After:** `LD A,COLOR(BLK,DKGRY)                                   ; BLK on DKGRY`
**Context:** $35bc (COLRAM address)

## Verification Requirements
After changes:
1. Build should succeed with no errors
2. All COLOR() macro calls should resolve correctly  
3. No functional changes to game behavior expected
4. All 15 COLRAM operations now use readable COLOR(fg,bg) format

## Rollback Instructions
To rollback these changes, reverse each COLOR() conversion:
- `COLOR(DKBLU,BLK)` → `$b0`
- `COLOR(DKGRY,BLK)` → `$f0`
- `COLOR(BLU,BLU)` → `$44`
- `COLOR(GRN,GRN)` → `$22`
- `COLOR(GRN,DKGRN)` → `$2d`
- `COLOR(DKGRY,DKGRY)` → `$ff`
- `COLOR(BLU,DKBLU)` → `$4b`
- `COLOR(RED,RED)` → `$11`
- `COLOR(BLK,DKGRY)` → `$0f`
- `COLOR(BLK,BLK)` → `$00` (or `XOR A` for line 2137)

## Total Changes
**15 COLOR() conversions** across 2 files:
- asterion_high_rom.asm: 3 changes
- asterion_func_low.asm: 12 changes