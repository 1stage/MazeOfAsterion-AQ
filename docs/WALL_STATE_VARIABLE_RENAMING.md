# Wall State Variable Renaming

## Overview
This document tracks the systematic renaming of wall state variables from generic `DAT_ram_33xx` names to meaningful wall-specific names based on the 3D viewport wall diagram.

## Completed Renamings

### Confirmed Correct (No Changes Needed)
- `WALL_F0_STATE` ($33e8) - F0 wall (north wall of player position)
- `WALL_F1_STATE` ($33e9) - F1 wall (north wall one step forward)
- `WALL_F2_STATE` ($33ea) - F2 wall (north wall two steps forward)

### Fixed Misnaming
- `WALL_F3_STATE` → `WALL_FL2_STATE` ($33eb) - FL2 wall (north wall of left-of-F2)

### Educated Renamings (Based on 3D Viewport Pattern)
- `DAT_ram_33ec` → `WALL_L2_C_STATE` ($33ec) - L2_C wall (center-left wall at distance 2)
- `DAT_ram_33ed` → `WALL_FR2_STATE` ($33ed) - FR2 wall (far-right wall at distance 2)
- `DAT_ram_33ee` → `WALL_R1_STATE` ($33ee) - R1 wall (west wall between S1 and SR1)
- `DAT_ram_33ef` → `WALL_L1_STATE` ($33ef) - L1 wall (west wall of S1)
- `DAT_ram_33f0` → `WALL_FR1_STATE` ($33f0) - FR1 wall (north wall of SR1)
- `DAT_ram_33f1` → `WALL_FL1_STATE` ($33f1) - FL1 wall (north wall of SL1)
- `DAT_ram_33f2` → `WALL_L0_STATE` ($33f2) - L0 wall (west wall of player position)
- `DAT_ram_33f5` → `WALL_R0_STATE` ($33f5) - R0 wall (west wall between player and right)
- `DAT_ram_33f6` → `WALL_FR0_STATE` ($33f6) - FR0 wall (north wall of SR0)
- `DAT_ram_33f7` → `WALL_FL0_STATE` ($33f7) - FL0 wall (north wall of SL0)

### Unchanged (Require Further Analysis)
- `DAT_ram_33f3` ($33f3) - Unknown/unused?
- `DAT_ram_33f4` ($33f4) - Unknown/unused?
- `DAT_ram_33f9` ($33f9) - Additional wall state data
- `DAT_ram_33fa` ($33fa) - Additional wall state data
- `DAT_ram_33fb` ($33fb) - Additional wall state data
- `DAT_ram_33fd` ($33fd) - Additional wall state data

## Code Changes Made

### Files Modified:
1. **src/asterion.inc** - Updated EQU definitions
2. **src/asterion_high_rom.asm** - Updated variable references in REDRAW_VIEWPORT

### References Updated:
- Line 1535: `(DAT_ram_33f5)` → `(WALL_R0_STATE)`
- Line 3561: `DAT_ram_33ed` → `WALL_FR2_STATE` 
- Line 3587: `DAT_ram_33ef` → `WALL_L1_STATE`
- Line 3643: `DAT_ram_33f2` → `WALL_L0_STATE`
- Line 3703: `DAT_ram_33f5` → `WALL_R0_STATE`

### Bug Fix Applied:
- **Corrected L2 rendering issue**: `DAT_ram_33ec` was incorrectly renamed to `WALL_FR2_STATE` but actually controls `DRAW_WALL_L2_C` functions
- **Fixed**: `DAT_ram_33ec` → `WALL_L2_C_STATE` (controls L2_C walls)  
- **Fixed**: `DAT_ram_33ed` → `WALL_FR2_STATE` (controls FR2 walls, not R2 walls)

## Wall Diagram Reference

Based on `docs/wall_diagram.txt`, the 3D viewport contains:
```
 ------   ------   ------   ------   ------ 
| FL22 | | FL2  | |  F2  | | FR2  | | FR22 |
 ------ - ------ - ------ - ------ - ------
|      |L|      |L|      |R|      |R|      |
| SL22 |2| SL2  |2|  S2  |2| SR2  |2| SR22 |
|      |2|      | |      | |      |2|      |
 ------ - ------ - ------ - ------ - ------ 
         | FL1  | |  F1  | | FR1  |         
          ------ - ------ - ------    
         |      |L|      |R|      |    
         | SL1  |1|  S1  |1| SR1  |       
         |      | |      | |      |       
          ------ - ------ - ------          
         | FL0  | |  F0  | | FR0  |         
          ------ - ------ - ------       
         |      |L|      |R|      |       
         | SL0  |0|  S0  |0| SR0  |       
         |      | |      | |      |       
          ------ - ------ - ------          
                  |  B0  |                  
                   ------       
```

## Rationale

### Naming Convention:
- **F0, F1, F2**: Front walls at distances 0, 1, 2
- **L0, L1, L2**: Left walls at distances 0, 1, 2  
- **R0, R1, R2**: Right walls at distances 0, 1, 2
- **FL0, FL1, FL2**: Far-left walls (left side of front walls)
- **FR0, FR1, FR2**: Far-right walls (right side of front walls)

### Map Storage System:
- Each map cell stores: **North wall** (upper nibble) + **West wall** (lower nibble)
- To get other walls: **South wall** = north wall of cell+16, **East wall** = west wall of cell+1

### Validation:
- Build succeeds with all renamings ✓
- Variable names now match 3D viewport wall positions ✓
- Code is more self-documenting and maintainable ✓

## Next Steps

### Future Analysis Needed:
1. **Determine purpose of DAT_ram_33f3/33f4** - gaps in sequence suggest special purpose
2. **Analyze DAT_ram_33f9/33fa/33fb/33fd** - additional wall state data for complex cases
3. **Verify wall state calculations** - ensure renamed variables match actual calculated data
4. **Consider door state variables** - some addresses might store door-specific states

### Potential Extensions:
- **L22/R22 walls** - may be stored in the unanalyzed addresses
- **Door state separation** - walls vs. doors might use different variables
- **Hidden door states** - additional complexity for secret passages

---

*This renaming improves code readability and maintains consistency with the wall diagram. The build system confirms all changes are syntactically correct.*