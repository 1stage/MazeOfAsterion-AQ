# WALL RENDERING ANALYSIS

This document analyzes the rendering process for each of the 19 different walls shown in the viewport. We focus on the 9 walls that DON'T consider/render doors, identifying the discrete steps/functions/routines used to draw them from positioning to completion.

## Wall Categories

**Simple Rectangle Walls (Distance 2):**
- FL22, FL2, F2, FR2, FR22

**Complex Diagonal/Corner Walls (Distance 2):**  
- L22, L2, R2, R22

---

## F2 WALL - Front Wall at Distance 2

**Location:** Center front wall, 2 spaces ahead of player
**Map Cell:** Wall on the far side of S2 (player + 2 forward)
**Visual:** Small 4x4 rectangle in center of screen

### F2 WALL - Viewport Position:
```
VIEWPORT (24x24 chars, each char shown as 2-wide)
┌────────────────────────────────────────────────┐
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                    ████████                    │
│                    ████████                    │
│                    ████████                    │
│____________________████████____________________│
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
└────────────────────────────────────────────────┘

```

### Rendering Functions:

#### DRAW_WALL_F2

### Rendering Steps:
1. **Setup Rectangle Dimensions:** BC = RECT(4,4) = 4 wide × 4 high
2. **Position Setup:** HL = COLRAM_F1_DOOR_IDX (screen position)
3. **Color Setup:** A = COLOR(DKGRY,DKGRY) (dark gray on dark gray)
4. **Draw Rectangle:** FILL_CHRCOL_RECT fills the 4×4 area

### Functions Called:
- **FILL_CHRCOL_RECT** - Primary drawing function that fills rectangular area
  - Input: HL=position, BC=dimensions, A=color
  - Uses DRAW_ROW internally for horizontal line filling

### Rendering Characteristics:
- **Simple rectangle fill** - single function call
- **Fixed dimensions** - always 4×4 pixels
- **Solid color** - dark gray background and foreground
- **No door consideration** - wall-only rendering
- **Distance 2 positioning** - uses F1_DOOR_IDX for screen coordinates

---

## FL22 WALL - Far Left Wall at Distance 2

**Location:** Far left wall, 2 spaces ahead and 2 spaces left of player
**Map Cell:** Wall to the left of FL2 (colinear)
**Visual:** Small 4x4 rectangle on left side of screen

### FL22 WALL - Viewport Position:
```
VIEWPORT (24x24 chars, each char shown as 2-wide)
┌────────────────────────────────────────────────┐
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│████████                                        │
│████████                                        │
│████████                                        │
│████████________________________________________│
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
└────────────────────────────────────────────────┘

```

### Rendering Functions:

#### DRAW_WALL_FL22
#### DRAW_WALL_FL22_EMPTY (Two-Step Process)

### FL22 EMPTY - Two-Step Clearing Process:
```
Step 1: Clear FL22 color area (4x4)
┌────────────────────────────────────────────────┐
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│BBBBBBBB                                        │ ← FL22 filled with BLK
│BBBBBBBB                                        │
│BBBBBBBB                                        │
│BBBBBBBB________________________________________│
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
└────────────────────────────────────────────────┘

Step 2: Clear CHRRAM area (4x1 with SPACE chars)
Additional cleanup at DAT_ram_3230 (CHRRAM row 14, col 0)
┌────────────────────────────────────────────────┐
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│BBBBBBBB                                        │ ← FL22 filled with BLK
│BBBBBBBB                                        │
│BBBBBBBB                                        │
│BBBBBBBB________________________________________│
│S S S S                                         │ ← Row 14: 4 SPACE chars at col 0-3
│                                                │   (DAT_ram_3230 cleanup)
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
└────────────────────────────────────────────────┘
```

### Rendering Steps:
1. **Setup Rectangle Dimensions:** BC = RECT(4,4) = 4 wide × 4 high
2. **Position Setup:** HL = COLRAM_FL22_WALL_IDX (screen position $35b8)
3. **Color Setup:** A = COLOR(DKGRY,DKGRY) for wall or COLOR(BLK,BLK) for empty
4. **Draw Rectangle:** FILL_CHRCOL_RECT fills the 4×4 area
5. **Additional Cleanup (Empty only):** Fill 4x1 CHRRAM area with SPACE characters

### Functions Called:
- **FILL_CHRCOL_RECT** - Primary drawing function that fills rectangular area
  - Input: HL=position, BC=dimensions, A=color
  - Uses DRAW_ROW internally for horizontal line filling

### Rendering Characteristics:
- **Simple rectangle fill** - single function call
- **Fixed dimensions** - always 4×4 characters
- **Two variants** - normal wall (DKGRY) and empty (BLK for occlusion)
- **No door consideration** - wall-only rendering
- **Distance 2 positioning** - leftmost wall at distance 2
- **Perfect spacing** - positioned exactly 10 characters left of F2

---

## FR22 WALL - Far Right Wall at Distance 2

**Location:** Far right wall, 2 spaces ahead and 2 spaces right of player
**Map Cell:** Wall to the right of FR2 (colinear)
**Visual:** Small 4x4 rectangle on right side of screen

### FR22 WALL - Viewport Position:
```
VIEWPORT (24x24 chars, each char shown as 2-wide)
┌────────────────────────────────────────────────┐
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                        ████████│
│                                        ████████│
│                                        ████████│
│________________________________________████████│
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
│                                                │
└────────────────────────────────────────────────┘

```

### Rendering Functions:

#### DRAW_WALL_FR222_EMPTY

### Rendering Steps:
1. **Setup Rectangle Dimensions:** BC = RECT(4,4) = 4 wide × 4 high
2. **Position Setup:** HL = COLRAM_FR22_WALL_IDX (screen position $35cc)
3. **Color Setup:** A = COLOR(BLK,BLK) (black for empty/occluded)
4. **Draw Rectangle:** FILL_CHRCOL_RECT fills the 4×4 area

### Functions Called:
- **FILL_CHRCOL_RECT** - Primary drawing function that fills rectangular area
  - Input: HL=position, BC=dimensions, A=color
  - Uses DRAW_ROW internally for horizontal line filling

### Rendering Characteristics:
- **Simple rectangle fill** - single function call
- **Fixed dimensions** - always 4×4 characters
- **Empty-only variant** - only clearing function found (suggests frequent occlusion)
- **No door consideration** - wall-only rendering
- **Distance 2 positioning** - rightmost wall at distance 2
- **Perfect spacing** - positioned exactly 10 characters right of F2

---