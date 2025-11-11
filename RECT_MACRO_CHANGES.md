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

## Changes Made (Initial 5) and Additional Changes Needed

### File: src/asterion_high_rom.asm

#### Change 1: Line 226 ✅ COMPLETED
**Before:** `LD BC,$1818` **After:** `LD BC,RECT(24,24)`
**Context:** FILL_CHRCOL_RECT call on line 229  
**Function:** Fill map CHARs with SPACES

#### Change 2: Line 231 ✅ COMPLETED
**Before:** `LD BC,$1818` **After:** `LD BC,RECT(24,24)`
**Context:** FILL_CHRCOL_RECT call on line 234  
**Function:** Fill map colors

#### Change 3: Line 2136 ✅ COMPLETED
**Before:** `LD BC,$1818` **After:** `LD BC,RECT(24,24)`
**Context:** FILL_CHRCOL_RECT call on line 2138  
**Function:** PLAYER_DIES function + fixed comment

#### Change 4: Line 399 🔄 NEEDS UPDATE
**Before:** `LD BC,$404` **After:** `LD BC,RECT(4,4)`
**Context:** CALL FILL_CHRCOL_RECT on line 401
**Function:** Item drawing

### File: src/asterion_func_low.asm

#### Change 5: Line 113 ✅ COMPLETED
**Before:** `LD BC,$1010` **After:** `LD BC,RECT(16,16)`
**Context:** JP FILL_CHRCOL_RECT on line 115  
**Function:** DRAW_F0_WALL

#### Change 6: Line 121 🔄 NEEDS UPDATE
**Before:** `LD BC,$80c` **After:** `LD BC,RECT(8,12)`
**Context:** JP FILL_CHRCOL_RECT on line 122
**Function:** DRAW_DOOR_F0

#### Change 7: Line 131 🔄 NEEDS UPDATE  
**Before:** `LD BC,$808` **After:** `LD BC,RECT(8,8)`
**Context:** CALL FILL_CHRCOL_RECT on line 135
**Function:** DRAW_WALL_F1

#### Change 8: Line 145 🔄 NEEDS UPDATE
**Before:** `LD BC,$406` **After:** `LD BC,RECT(4,6)`
**Context:** JP FILL_CHRCOL_RECT on line 146
**Function:** Drawing function

#### Change 9: Line 162 🔄 NEEDS UPDATE
**Before:** `LD BC,$404` **After:** `LD BC,RECT(4,4)`
**Context:** JP FILL_CHRCOL_RECT on line 163
**Function:** Drawing function

#### Change 10: Line 235 🔄 NEEDS UPDATE
**Before:** `LD BC,$410` **After:** `LD BC,RECT(4,16)`
**Context:** JP FILL_CHRCOL_RECT on line 236
**Function:** Drawing function

#### Change 11: Line 382 🔄 NEEDS UPDATE
**Before:** `LD BC,$408` **After:** `LD BC,RECT(4,8)`
**Context:** CALL FILL_CHRCOL_RECT on line 384
**Function:** Drawing function

#### Change 12: Line 404 🔄 NEEDS UPDATE
**Before:** `LD BC,$204` **After:** `LD BC,RECT(2,4)`
**Context:** CALL FILL_CHRCOL_RECT on line 406
**Function:** Drawing function

#### Change 13: Line 544 🔄 NEEDS UPDATE
**Before:** `LD BC,$410` **After:** `LD BC,RECT(4,16)`
**Context:** JP FILL_CHRCOL_RECT on line 545
**Function:** Drawing function

#### Change 14: Line 694 🔄 NEEDS UPDATE
**Before:** `LD BC,$408` **After:** `LD BC,RECT(4,8)`
**Context:** CALL FILL_CHRCOL_RECT on line 696
**Function:** Drawing function

#### Change 15: Line 716 🔄 NEEDS UPDATE
**Before:** `LD BC,$204` **After:** `LD BC,RECT(2,4)`
**Context:** CALL FILL_CHRCOL_RECT on line 718
**Function:** Drawing function

#### Change 16: Line 1140 ✅ COMPLETED
**Before:** `LD BC,$1818` **After:** `LD BC,RECT(24,24)`
**Context:** CALL FILL_CHRCOL_RECT on line 1141  
**Function:** DRAW_BKGD

#### Change 17: Line 1433 🔄 NEEDS UPDATE
**Before:** `LD BC,$404` **After:** `LD BC,RECT(4,4)`
**Context:** CALL FILL_CHRCOL_RECT on line 1435
**Function:** Drawing function

#### Change 18: Line 1442 🔄 NEEDS UPDATE
**Before:** `LD BC,$401` **After:** `LD BC,RECT(4,1)`
**Context:** CALL FILL_CHRCOL_RECT on line 1444
**Function:** Drawing function

#### Change 19: Line 1446 🔄 NEEDS UPDATE
**Before:** `LD BC,$204` **After:** `LD BC,RECT(2,4)`
**Context:** CALL FILL_CHRCOL_RECT on line 1448
**Function:** Drawing function

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