# CHK_ITEM Call Sites and Rendering Conditions

**Created**: 2025-12-08  
**Branch**: viewport-rendering  
**Source**: asterion_high_rom.asm REDRAW_VIEWPORT function

This document maps every CHK_ITEM invocation in the viewport rendering system, documenting the exact conditions under which each item position is rendered.

---

## CHK_ITEM Function Overview

**Location**: `asterion_high_rom.asm` (called from REDRAW_VIEWPORT)

**Purpose**: Decodes item type/color and renders appropriate graphics using CHK_ITEM → GFX_DRAW chain

**Parameters**:
- `A` = Item code from ITEM_* memory location
- `BC` = Distance/size parameters (determines which graphics variant: regular, _S small, _T tiny)

**Call Pattern**:
```asm
LD      A,(ITEM_XX)        ; Load item code from memory
LD      BC,<params>        ; Set distance/size
CALL    CHK_ITEM           ; Render item
```

---

## Item Memory Locations

| Item Variable | Address | Description |
|---------------|---------|-------------|
| `ITEM_F2` | $37e8 | Item 2 spaces directly ahead |
| `ITEM_F1` | $37e9 | Item 1 space directly ahead |
| `ITEM_F0` | $37ea | Item in player's current space |
| `ITEM_FL1` | $37eb | Item 1 space diagonally ahead-left |
| `ITEM_FR1` | $37ec | Item 1 space diagonally ahead-right |
| `ITEM_R1` | $37ed | Item 1 space to the right |
| `ITEM_L1` | $37ee | Item 1 space to the left |
| `ITEM_B1` | $37ef | Item 1 space behind |

**Note**: Not all item positions are rendered by REDRAW_VIEWPORT (e.g., ITEM_R1, ITEM_L1, ITEM_B1 are not rendered in the 3D viewport).

---

## CHK_ITEM Call Sites in Rendering Order

### 1. F2 Item (Distance 2, Directly Ahead)

**Line**: 8304  
**Helper**: None (inline call)  
**Item Code**: `(ITEM_F2)` = $37e8  
**Parameters**: `BC = $48a`  
**Graphics**: Tiny variant (_T suffix)

**Rendering Conditions**:
- **Always rendered** after F2 wall processing completes
- Reached via multiple paths:
  - F1 open door (line 8179 → 8303)
  - L2/R2 wall processing completes (fall through from line 8302)

**Wall States That Lead Here**:
1. F0 empty AND F1 open door → Jump directly to CHK_ITEM_F2
2. F0 empty AND F1 empty → Process F2, L2, R2 walls → Fall through to CHK_ITEM_F2

**Count**: **1 call per frame**

---

### 2. SL1 Item (Distance 1, Diagonal Left-Forward)

**Lines**: 8467, 8475, 8482, 8492, 8497  
**Helper**: `CHK_ITEM_SL1` (lines 8498-8501)  
**Item Code**: `(ITEM_SL1)` = $37eb  
**Parameters**: `BC = $4d0`  
**Graphics**: Small variant (_S suffix)

**Rendering Conditions** (Up to 5 calls):

#### Call 1 (Line 8467):
- Path: L0 empty → FL0 empty → FL1_B hidden door
- Wall states: `WALL_L0_STATE` bit 1 = 0, `WALL_FL0_STATE` bit 1 = 0, `WALL_FL1_B_STATE` bit 0 = 1
- Action: After drawing DRAW_WALL_FL1_A

#### Call 2 (Line 8475):
- Path: Same as Call 1, but door is open
- Wall states: FL1_B hidden door (bit 0 = 1) AND wall exists (bit 1 = 1) AND door open (bit 2 = 1)
- Action: After drawing DRAW_DOOR_L1_HIDDEN

#### Call 3 (Line 8482):
- Path: L0 empty → FL0 empty → FL1_B no hidden door, wall exists, door open
- Wall states: `WALL_FL1_B_STATE` bit 0 = 0, bit 1 = 1, bit 2 = 1
- Action: After drawing DRAW_DOOR_L1_NORMAL

#### Call 4 (Line 8492):
- Path: L0 empty → FL0 empty → FL1_B no wall → L22 wall exists
- Wall states: `WALL_FL1_B_STATE` bit 1 = 0, `WALL_L22_STATE` bit 1 = 1 (tested via RRCA)
- Action: After drawing DRAW_WALL_L1_SIMPLE

#### Call 5 (Line 8497):
- Path: L0 empty → FL0 empty → FL1_B no wall → L22 empty
- Wall states: `WALL_FL1_B_STATE` bit 1 = 0, `WALL_L22_STATE` bit 1 = 0
- Action: After drawing DRAW_WALL_FL22_EMPTY

**Count**: **1-5 calls per frame** depending on wall configuration

**Purpose of Multiple Calls**: Items need to be rendered on top of different wall layers as they're drawn. The layering ensures the item appears correctly regardless of which walls are visible.

---

### 3. F1 Item (Distance 1, Directly Ahead)

**Line**: 8424  
**Helper**: None (labeled as `CHK_ITEM_F1:`)  
**Item Code**: `(ITEM_F1)` = $37e9  
**Parameters**: `BC = $28a`  
**Graphics**: Small variant (_S suffix)

**Rendering Conditions**:
- **Always rendered** after L1/R1 wall processing completes
- Reached via multiple paths:
  - F0 open door (line 8143 → 8422)
  - R1 wall processing completes (fall through from line 8422)

**Wall States That Lead Here**:
1. F0 open door → Jump directly to CHK_ITEM_F1 (skips F2, L2, R2, L1, R1 walls)
2. Standard path → Process all walls through R1 → Fall through to CHK_ITEM_F1

**Count**: **1 call per frame**

---

### 4. SR1 Item (Distance 1, Diagonal Right-Forward)

**Lines**: 8567, 8575, 8582, 8592, 8597  
**Helper**: `CHK_ITEM_SR1` (lines 8598-8601)  
**Item Code**: `(ITEM_SR1)` = $37ec  
**Parameters**: `BC = $4e4`  
**Graphics**: Small variant (_S suffix)

**Rendering Conditions** (Up to 5 calls):

#### Call 1 (Line 8567):
- Path: R0 empty → FR0 empty → FR1_B hidden door
- Wall states: `WALL_R0_STATE` bit 1 = 0, `WALL_FR0_STATE` bit 1 = 0, `WALL_FR1_B_STATE` bit 0 = 1
- Action: After drawing DRAW_WALL_FR1_B

#### Call 2 (Line 8575):
- Path: Same as Call 1, but door is open
- Wall states: FR1_B hidden door (bit 0 = 1) AND wall exists (bit 1 = 1) AND door open (bit 2 = 1)
- Action: After drawing DRAW_DOOR_FR1_B_HIDDEN

#### Call 3 (Line 8582):
- Path: R0 empty → FR0 empty → FR1_B no hidden door, wall exists, door open
- Wall states: `WALL_FR1_B_STATE` bit 0 = 0, bit 1 = 1, bit 2 = 1
- Action: After drawing DRAW_DOOR_FR1_B_NORMAL

#### Call 4 (Line 8592):
- Path: R0 empty → FR0 empty → FR1_B no wall → R22 wall exists
- Wall states: `WALL_FR1_B_STATE` bit 1 = 0, `WALL_R22_STATE` bit 1 = 1 (tested via RRCA)
- Action: After drawing DRAW_WALL_R1_SIMPLE

#### Call 5 (Line 8597):
- Path: R0 empty → FR0 empty → FR1_B no wall → R22 empty
- Wall states: `WALL_FR1_B_STATE` bit 1 = 0, `WALL_R22_STATE` bit 1 = 0
- Action: After drawing DRAW_WALL_FR22_EMPTY

**Count**: **1-5 calls per frame** (mirrors FL1 behavior)

---

### 5. F0 Item (Distance 0, Current Space)

**Line**: 8623  
**Helper**: None (labeled as `CHK_ITEM_F0:`)  
**Item Code**: `(ITEM_F0)` = $37ea  
**Parameters**: `BC = $8a`  
**Graphics**: Regular variant (4×4 size)

**Rendering Conditions**:
- **ALWAYS rendered** as the absolute final step
- This is the last operation before REDRAW_VIEWPORT returns

**Wall States That Lead Here**:
- All paths eventually lead to CHK_ITEM_F0
- Even F0 closed wall path (line 8159) eventually reaches here after processing L0/R0 walls

**Count**: **1 call per frame**

---

## Item Rendering Summary Table

| Item | Calls | Parameters | Graphics | First Call Line | Helper Function |
|------|-------|------------|----------|----------------|-----------------|
| F2   | 1     | $48a       | _T (tiny)| 8304           | None            |
| SL1  | 1-5   | $4d0       | _S (small)| 8467          | CHK_ITEM_SL1    |
| F1   | 1     | $28a       | _S (small)| 8424          | None            |
| SR1  | 1-5   | $4e4       | _S (small)| 8567          | CHK_ITEM_SR1    |
| F0   | 1     | $8a        | Regular  | 8623           | None            |

**Total CHK_ITEM calls per frame**: 5 to 13 (depending on wall configuration)

---

## Visual Rendering Order

```
Best Case (All Walls Empty):
  1. Background
  2-5. F0, F1, F2 walls (empty variants)
  6-9. L2, FL2, R2, FR2 walls (empty)
 10. → CHK_ITEM(F2) ← Item renders on empty background
11-14. L1, FL1, R1, FR1 walls (empty)
 15. → CHK_ITEM(F1) ← Item renders on empty background
16-19. L0, FL0, R0, FR0 walls (empty)
20-24. SL1 checks (may call CHK_ITEM_SL1 up to 5 times)
25-29. SR1 checks (may call CHK_ITEM_SR1 up to 5 times)
 30. → CHK_ITEM(F0) ← Final item render

Worst Case (F0 Solid Wall):
  1. Background
  2. F0 wall
  3-6. Skip to L0/R0 side walls
  7-11. L0 side processing (SL1 items may render)
 12-16. R0 side processing (SR1 items may render)
  17. → CHK_ITEM(F0) ← Only F0 item visible
```

---

## Critical Insights

### 1. Multiple Rendering is Intentional
SL1 and SR1 items can render up to 5 times because they need to appear on top of different wall layers. Each rendering ensures the item is visible regardless of which walls are drawn.

### 2. Distance-Based Graphics Selection
The BC parameter determines which graphics variant is used:
- `$8a` (F0) → Regular 4×4 graphics
- `$28a` (F1) → _S small variant (usually 2×2)
- `$4d0`, `$4e4` (SL1, SR1) → _S small variant
- `$48a` (F2) → _T tiny variant (usually 1×1)

### 3. Occlusion Affects Item Visibility
When F0 has a closed wall, F2 and F1 items are NEVER rendered because those code paths are skipped entirely. Only F0, SL1, and SR1 items can appear.

### 4. Item Rendering Always Happens Last
Items are rendered AFTER their associated wall layers, ensuring they appear on top of walls, never behind them.

---

## Usage for Modifications

### To Change Item Rendering Order:
1. Identify which CHK_ITEM call(s) to move
2. Check wall state dependencies - ensure walls are drawn first
3. Update jump targets to route to new positions
4. Test with various wall configurations

### To Add New Item Positions:
1. Define new ITEM_* memory location
2. Add LD A,(ITEM_XX) + LD BC,<params> + CALL CHK_ITEM
3. Position call after appropriate wall rendering
4. Consider if multiple renders are needed for layering

### To Remove Item Rendering:
1. Comment out or remove the CHK_ITEM call sequence
2. Item code will still exist in memory but won't be drawn
3. No other changes needed (safe to remove)

---

*Document Status: COMPLETE - All CHK_ITEM call sites mapped with conditions*
