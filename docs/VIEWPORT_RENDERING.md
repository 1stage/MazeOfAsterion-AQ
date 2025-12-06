# Maze of Asterion - Viewport Rendering System

## Overview
This document describes the complete viewport rendering system in Maze of Asterion for the Mattel Aquarius, combining the rendering flow with detailed wall-by-wall analysis. Understanding this system is essential for modifying wall graphics and maze rendering.

---

## Part I: Rendering Flow & Architecture

### High-Level Flow

```
Game Event (movement, turn, door open, etc.)
    ↓
UPDATE_VIEWPORT (asterion_high_rom.asm:1391)
    ↓
REDRAW_START (asterion_high_rom.asm:3011)
    ↓
REDRAW_VIEWPORT (asterion_high_rom.asm:3479)
    ↓
Individual Wall/Door Drawing Functions
    ↓
FILL_CHRCOL_RECT (asterion_func_low.asm:98)
    ↓
Updated Screen Display
```

### 1. Entry Point: UPDATE_VIEWPORT
**Location**: `asterion_high_rom.asm:1391`

**Function**: Central entry point for all viewport updates
```asm
UPDATE_VIEWPORT:
    CALL        REDRAW_START
    CALL        REDRAW_VIEWPORT
```

**Triggers**: Called from various game events:
- Player movement (`DO_MOVE_FW_CHK_WALLS`)
- Player rotation (`ROTATE_FACING_LEFT`, `ROTATE_FACING_RIGHT`)
- Door operations
- Item interactions
- Combat state changes

### 2. Stage 1: REDRAW_START - Calculate Wall States
**Location**: `asterion_high_rom.asm:3011`

**Purpose**: Calculate which walls are visible from current player position and facing direction

**Key Operations**:
- Reads player position from `PLAYER_MAP_POS`
- Reads facing direction from `DIR_FACING_SHORT`
- Calculates wall states for ALL wall positions visible in the 3D viewport
- Uses complex geometric calculations based on player facing direction
- Stores results in a sequential block of wall state variables from $33e8 to $33fd

**Wall State Variables Calculated**:
- `WALL_F0_STATE` ($33e8) - Wall directly ahead
- `WALL_F1_STATE` ($33e9) - Wall one step ahead
- `WALL_F2_STATE` ($33ea) - Wall two steps ahead  
- `WALL_L2_STATE` ($33eb) - FL2 wall (left of F2)
- Plus ~18 additional state bytes for all visible wall segments

**Direction Handling**:
- `FACING_NORTH`: Player facing north (DIR_FACING_SHORT = 1)
- `FACING_EAST`: Player facing east (DIR_FACING_SHORT = 2)  
- `FACING_SOUTH`: Player facing south (DIR_FACING_SHORT = 3)
- `FACING_WEST`: Player facing west (DIR_FACING_SHORT = 4)

### 3. Stage 2: REDRAW_VIEWPORT - Render the Scene
**Location**: `asterion_high_rom.asm:3479`

**Purpose**: Clear the viewport and draw all visible walls/doors based on calculated states

#### 3.1 Initialize Background
```asm
REDRAW_VIEWPORT:
    CALL        DRAW_BKGD
```

`DRAW_BKGD` (asterion_func_low.asm:1137):
- Clears viewport with SPACE characters (`$20`)
- Sets up three-layer background:
  - **Ceiling**: 8 rows of DKGRY on BLK (`$f0`)
  - **Horizon**: 6 rows of BLK on BLK (`$00`) 
  - **Floor**: 10 rows of DKGRN on DKGRY (`$df`)

#### 3.2 Wall State Bit Pattern Logic

Each wall state byte uses encoding defined in wall_diagram.txt:

**West Wall (Low Bits)**:
- `$x0`: No wall
- `$x1`: Wall, no door (solid)
- `$x2`: Wall, visible door, closed 
- `$x4`: Wall, hidden door, closed
- `$x6`: Wall, visible door, opened *(player interaction only)*
- `$x7`: Wall, hidden door, opened *(player interaction only)*

**North Wall (High Bits)**:
- `$0x`: No wall  
- `$2x`: Wall, no door (solid)
- `$4x`: Wall, visible door, closed
- `$6x`: Wall, hidden door, closed
- `$Cx`: Wall, visible door, opened *(player interaction only)*
- `$Ex`: Wall, hidden door, opened *(player interaction only)*

**Example**: `$42` = North wall visible closed door + West wall visible closed door

The checking logic uses successive `RRCA` instructions:
```asm
LD A,(WALL_STATE)
RRCA                    ; Rotate bit 0 → Carry (hidden door check)
JP NC,NO_HIDDEN_DOOR
RRCA                    ; Rotate bit 1 → Carry (wall presence)
JP NC,NO_WALL
RRCA                    ; Rotate bit 2 → Carry (door state)
JP C,DOOR_OPEN
```

#### 3.3 Draw Walls by Distance (Painter's Algorithm)

Rendering follows **back-to-front** order:

**1. F0 Walls (Immediate foreground - 16x16 characters)**
- Functions: `DRAW_F0_WALL`, `DRAW_F0_WALL_AND_CLOSED_DOOR`, `DRAW_WALL_F0_AND_OPEN_DOOR`

**2. F1 Walls (Middle distance - 8x8 characters)**
- Functions: `DRAW_WALL_F1`, `DRAW_WALL_F1_AND_CLOSED_DOOR`, `DRAW_WALL_F1_AND_OPEN_DOOR`

**3. F2 Walls (Far distance - 4x4 characters)**
- Functions: `DRAW_WALL_F2`, `DRAW_DOOR_F2_OPEN`

**4-13. Side Walls (FL/FR/L/R series)**
Complex geometric wall segments that create the 3D perspective effect:
- **FL0/FR0**: Closest side walls
- **FL1/FR1**: Medium distance side walls  
- **FL2/FR2**: Far side walls
- **FL22/FR22**: Far corner walls
- **L1/L2, R1/R2**: Near left/right walls

### 4. Core Rendering Function: FILL_CHRCOL_RECT
**Location**: `asterion_func_low.asm:98`

**Purpose**: Low-level function that actually draws rectangles to screen memory

**Parameters**:
- `HL`: Starting screen memory address (COLRAM or CHRRAM)
- `BC`: Rectangle dimensions (B=width, C=height) via RECT() macro
- `A`: Color value via COLOR() macro or character value

**Operation**:
```asm
FILL_CHRCOL_RECT:
    LD          DE,$28        ; DE = 40 (screen width for next row)
DRAW_CHRCOLS:
    PUSH        HL
    PUSH        BC
    CALL        DRAW_ROW      ; Draw one row of width B
    POP         BC
    POP         HL
    DEC         C             ; Decrement height counter
    RET         Z             ; Return if done
    ADD         HL,DE         ; Move to next screen row
    JP          DRAW_CHRCOLS  ; Repeat for next row
```

## Screen Memory Layout

### COLRAM (Color RAM) Areas
The viewport uses specific COLRAM addresses for different wall segments:

- `COLRAM_VIEWPORT_IDX` ($3428): Main viewport area
- `COLRAM_F0_WALL_MAP_IDX` ($34cc): F0 wall area (16x16)
- `COLRAM_F0_DOOR_IDX`: F0 door area (8x12)  
- `COLRAM_F1_DOOR_IDX` ($35c2): F1 wall/door area (8x8, 4x6)
- `COLRAM_FL00_WALL_IDX` ($34a3): Far left wall areas
- `COLRAM_FL22_WALL_IDX` ($35b8): Far left corner walls

### CHRRAM (Character RAM) Areas
Character graphics are stored separately:

- `IDX_VIEWPORT_CHRRAM`: Main viewport character area
- `CHRRAM_F1_WALL_IDX`: F1 wall character area

---

## Part II: Detailed Wall Rendering Analysis

This section analyzes the rendering process for individual walls, focusing on the simple rectangular walls that don't consider doors.

### Wall Categories

**Simple Rectangle Walls (Distance 2):**
- FL22, FL2, F2, FR2, FR22

**Complex Diagonal/Corner Walls:**  
- L0/R0, L1/R1, L2/R2, FL0/FR0, FL1/FR1

---

## F2 WALL - Front Wall at Distance 2

**Location:** Center front wall, 2 spaces ahead of player  
**Visual:** Small 4x4 rectangle in center of screen

### Viewport Position:
```
VIEWPORT (24x24 chars)
┌────────────────────────────────────────────────┐
│                                                │
│                                                │
...
│                    ████████                    │ ← F2 wall
│                    ████████                    │
│                    ████████                    │
│____________________████████____________________│
...
└────────────────────────────────────────────────┘
```

### Rendering: DRAW_WALL_F2

**Steps**:
1. Setup Rectangle Dimensions: BC = RECT(4,4)
2. Position Setup: HL = COLRAM_F1_DOOR_IDX
3. Color Setup: A = COLOR(DKGRY,DKGRY)
4. Draw Rectangle: FILL_CHRCOL_RECT

**Characteristics**:
- Simple rectangle fill - single function call
- Fixed dimensions - always 4×4 characters
- Solid color - dark gray
- No door consideration

---

## FL22 WALL - Far Left Corner Wall

**Location:** Far left corner, 2 spaces ahead and 2 spaces left  
**Visual:** Small 4x4 rectangle on left side

### Viewport Position:
```
VIEWPORT (24x24 chars)
┌────────────────────────────────────────────────┐
│                                                │
...
│████████                                        │ ← FL22 wall
│████████                                        │
│████████                                        │
│████████________________________________________│
...
└────────────────────────────────────────────────┘
```

### Rendering: DRAW_WALL_FL22_EMPTY

**Two-Step Clearing Process**:
1. Clear FL22 color area (4x4) with BLK
2. Clear CHRRAM area (4x1 with SPACE chars) at DAT_ram_3230

**Steps**:
1. Setup Rectangle Dimensions: BC = RECT(4,4)
2. Position Setup: HL = COLRAM_FL22_WALL_IDX ($35b8)
3. Color Setup: A = COLOR(BLK,BLK) for empty
4. Draw Rectangle: FILL_CHRCOL_RECT
5. Additional Cleanup: Fill 4x1 CHRRAM with SPACE

**Characteristics**:
- Two variants: normal wall (DKGRY) and empty (BLK for occlusion)
- Perfect spacing - positioned 10 characters left of F2
- Additional CHRRAM cleanup for complete clearing

---

## FR22 WALL - Far Right Corner Wall

**Location:** Far right corner, 2 spaces ahead and 2 spaces right  
**Visual:** Small 4x4 rectangle on right side

### Viewport Position:
```
VIEWPORT (24x24 chars)
┌────────────────────────────────────────────────┐
│                                                │
...
│                                        ████████│ ← FR22 wall
│                                        ████████│
│                                        ████████│
│________________________________________████████│
...
└────────────────────────────────────────────────┘
```

### Rendering: DRAW_WALL_FR222_EMPTY

**Steps**:
1. Setup Rectangle Dimensions: BC = RECT(4,4)
2. Position Setup: HL = COLRAM_FR22_WALL_IDX ($35cc)
3. Color Setup: A = COLOR(BLK,BLK)
4. Draw Rectangle: FILL_CHRCOL_RECT

**Characteristics**:
- Empty-only variant found (suggests frequent occlusion)
- Perfect spacing - positioned 10 characters right of F2
- Mirrors FL22 positioning

---

## Perspective System

The 3D perspective is achieved through:

1. **Size scaling**: F0 (16x16) → F1 (8x8) → F2 (4x4)
2. **Position mapping**: Each distance has specific COLRAM coordinates
3. **Layered rendering**: Back-to-front drawing order
4. **Color gradation**: Darker colors for distant walls

---

## Key Constants and Macros

### Color Macro:
```asm
COLOR(fg,bg) = (fg * 16) + bg
```

### Rectangle Macro:
```asm  
RECT(width,height) = (width * 256) + height
```

### Color Constants:
- BLK=0, RED=1, GRN=2, YEL=3, BLU=4, MAG=5, CYN=6, WHT=7
- GRY=8, DKCYN=9, DKMAG=10, DKBLU=11, LTYEL=12, DKGRN=13, DKRED=14, DKGRY=15

---

## Modification Guidelines

### To Add New Wall Types:
1. **Create new drawing functions** in `asterion_func_low.asm`:
   ```asm
   DRAW_NEW_WALL_F0:
       LD          HL,COLRAM_F0_WALL_MAP_IDX
       LD          BC,RECT(16,16)
       LD          A,COLOR(NEW_FG,NEW_BG)
       JP          FILL_CHRCOL_RECT
   ```

2. **Modify decision logic** in `REDRAW_VIEWPORT` to call your new functions

3. **Update wall state calculation** in `REDRAW_START` if needed

### To Modify Existing Graphics:
- **Change colors**: Modify COLOR() macro values
- **Change patterns**: Modify character values in CHRRAM operations
- **Change sizes**: Modify RECT() macro values (maintain perspective ratios)

---

## Memory Usage

### Screen Layout (40x24 characters):
- Viewport occupies central 24x24 area
- UI elements surround viewport (stats, items, etc.)
- Each character cell = 1 byte CHRRAM + 1 byte COLRAM

### Performance Considerations:
- FILL_CHRCOL_RECT is the bottleneck - called ~20-50 times per redraw
- Viewport redraws happen on every player action
- Total redraw affects ~576 character cells (24x24)

---

*This document provides comprehensive understanding of the Maze of Asterion rendering system, from high-level flow to individual wall rendering details. The modular structure makes it straightforward to modify graphics while maintaining the 3D perspective system.*
