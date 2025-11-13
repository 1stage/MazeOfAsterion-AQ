# Maze of Asterion - Viewport Redraw Process Flow Analysis

## Overview
This document describes the complete flow of the viewport rendering system in Maze of Asterion for the Mattel Aquarius. Understanding this flow is essential for modifying wall graphics and maze rendering.

## High-Level Flow

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

## Detailed Process Flow

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
- `WALL_FL2_STATE` ($33eb) - FL2 wall (left of F2)
- `DAT_ram_33ec` through `DAT_ram_33fd` - All side wall states (L0/R0, L1/R1, L2/R2, FL0/FR0, FL1/FR1, FL22/FR22, etc.)

The function writes approximately 22 bytes of wall state data covering every wall segment that could be visible in the 3D viewport. This includes symmetric calculations for both left and right side walls at all distances.

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

#### 3.2 Draw Walls by Distance (Far to Near)

The rendering follows a **painter's algorithm** - draw from back to front with specific order and wall determination logic:

#### Wall State Bit Pattern Logic

**Note**: The misleading variable name `WALL_F3_STATE` has been corrected to `WALL_FL2_STATE` to accurately reflect that it controls the FL2 wall segment (left side of F2), not a non-existent "F3" wall. See `docs/wall_diagram.txt` for the correct wall layout.

**Corrected Wall State Mapping**:
- `WALL_F0_STATE` ($33e8) → Controls **F0** wall (correct)
- `WALL_F1_STATE` ($33e9) → Controls **F1** wall (correct)  
- `WALL_F2_STATE` ($33ea) → Controls **F2** wall (correct)
- `WALL_FL2_STATE` ($33eb) → Controls **FL2** wall (now correctly named)
- `DAT_ram_33ed` → Controls **FR2** and **L2** walls
- `DAT_ram_33ef+` → Controls **FL1**, **L1** walls  
- `DAT_ram_33f2+` → Controls **FR1**, **R1** walls
- `DAT_ram_33f5+` → Controls **FL0**, **L0** walls
- `DAT_ram_33f9+` → Controls **FR0**, **R0** walls

Each wall state byte uses a 3-bit pattern checked via `RRCA` (rotate right carry):
- **Bit 0** (LSB): Hidden door present flag  
- **Bit 1**: Wall/obstruction present flag
- **Bit 2**: Door open/closed state flag

The checking logic uses successive `RRCA` instructions:
1. First `RRCA`: Check bit 0 (hidden door)
2. Second `RRCA`: Check bit 1 (wall present)  
3. Third `RRCA`: Check bit 2 (door state)

#### Exact Rendering Order:

**1. F0 Walls (Immediate foreground - 16x16 characters)**
- Address: `WALL_F0_STATE` ($33e8)
- Logic flow:
  ```asm
  LD A,(WALL_F0_STATE)
  RRCA                    ; Check hidden door bit
  JP NC,F0_NO_HD          ; Jump if no hidden door
  CALL DRAW_F0_WALL       ; Draw hidden door background
  RRCA                    ; Check wall bit  
  JP NC,F0_HD_NO_WALL     ; Jump if no wall
  RRCA                    ; Check door open bit
  JP NC,F0_HD_NO_WALL     ; Jump if door closed
  CALL DRAW_WALL_F0_AND_OPEN_DOOR
  ```
- Functions: `DRAW_F0_WALL`, `DRAW_F0_WALL_AND_CLOSED_DOOR`, `DRAW_WALL_F0_AND_OPEN_DOOR`

**2. F1 Walls (Middle distance - 8x8 characters)**
- Address: `WALL_F1_STATE` ($33e9) 
- Similar 3-bit logic as F0
- Functions: `DRAW_WALL_F1`, `DRAW_WALL_F1_AND_CLOSED_DOOR`, `DRAW_WALL_F1_AND_OPEN_DOOR`

**3. F2 Walls (Far distance - 4x4 characters)**
- Address: `WALL_F2_STATE` ($33ea)
- Simplified 2-bit check (no hidden door support)
- Functions: `DRAW_WALL_F2`, `DRAW_DOOR_F2_OPEN`

**4. FL2 Left Far Walls**
- Address: `WALL_FL2_STATE` ($33eb) - **Correctly named FL2 wall control**
- Controls FL2 wall segment (left side of F2 wall)
- Functions: `DRAW_WALL_FL2_EMPTY` (when no wall), `DRAW_WALL_FL2_NEW` (when wall present)

**5. L2 Center-Left Walls** 
- Address: `DAT_ram_33ed` ($33ed) and `DAT_ram_33ee` ($33ee)
- Controls middle-left wall segments
- Functions: `DRAW_WALL_L2_C`, `DRAW_WALL_L2_C_EMPTY`

**6. FR2 Right Far Walls**
- Address: `DAT_ram_33ed` ($33ed)
- Controls far right wall segments  
- Functions: `DRAW_WALL_FR2`, `DRAW_WALL_FR2_EMPTY`

**7. FL1 Left Near Walls**
- Address: `DAT_ram_33ef` ($33ef) and `DAT_ram_33f0` ($33f0)
- Controls near-left wall segments
- Functions: `DRAW_L1_WALL`, `DRAW_L1`, `DRAW_FL1_DOOR`

**8. Additional Left Wall Segments (FL2)**
- Address: `DAT_ram_33f1` ($33f1) 
- More detailed left wall geometry
- Functions: `DRAW_WALL_FL2_NEW`, `DRAW_WALL_FL2_EMPTY`

**9. FR1 Right Near Walls**
- Address: `DAT_ram_33f2` ($33f2), `DAT_ram_33f3` ($33f3), `DAT_ram_33f4` ($33f4)
- Controls near-right wall segments in multiple passes
- Functions: `DRAW_WALL_FR1`, various SUB_ram_cc functions for door frames

**10. FL0 Left Immediate Walls**
- Address: `DAT_ram_33f5` ($33f5) through `DAT_ram_33f8` ($33f8)
- Controls closest left wall segments with complex geometry
- Functions: `DRAW_WALL_FL0`, `DRAW_DOOR_FLO`, `SUB_ram_c996`

**11. FL22 Left Corner Walls**
- Address: Multiple state bytes for corner geometry
- Functions: `DRAW_WALL_FL22_EMPTY` - handles far left corner cases

**12. FR0 Right Immediate Walls**  
- Address: `DAT_ram_33f9` ($33f9) through `DAT_ram_33fc` ($33fc)
- Controls closest right wall segments
- Functions: `DRAW_FR0_DOOR`, various SUB_ram_cb functions

**13. FR22 Right Corner Walls (Final)**
- Address: Final state bytes in sequence
- Functions: `DRAW_WALL_FR222_EMPTY` - handles far right corner cases

#### Half-Wall Rendering Details

The "half-walls" (FL1, FR1, FL2, FR2, FL22, FR22) create the 3D perspective effect using geometric patterns:

**FL0/FR0 (Immediate Side Walls)**:
- Use complex character-based drawing with multiple geometric primitives
- `DRAW_WALL_FL0`: Uses `DRAW_DOOR_BOTTOM_SETUP`, `DRAW_DL_3X3_CORNER`, `DRAW_HORIZONTAL_LINE_3_RIGHT`
- Creates perspective depth with layered color patterns (BLU on BLK base, BLK on BLU highlights, DKGRY on BLU shadows)

**FL1/FR1 (Near Side Walls)**:
- Medium complexity geometric shapes  
- `DRAW_WALL_FR1`: Uses 4x8 rectangle base with right-angle characters ($c0, $c1)
- Applies perspective shading with multiple color layers

**FL2/FR2 (Far Side Walls)**:
- Simpler rectangular segments
- `DRAW_WALL_FL2_NEW`: Uses thin baseline character ($90) with 2x4 color rectangles
- Minimalist representation for distance effect

**FL22/FR22 (Corner Walls)**:
- Handle edge cases and corner geometry  
- `DRAW_WALL_FL22_EMPTY`: 4x4 black rectangle with space character fill
- Provides clean transitions at viewport edges

#### Wall Determination Priority
1. **Hidden doors take precedence** - if hidden door bit is set, background wall is drawn first
2. **Wall presence check** - only proceed if wall bit is set
3. **Door state determines final rendering** - open vs. closed door graphics
4. **Side walls render independently** - each uses separate state bytes for complex perspective geometry

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

## Wall Drawing Functions by Distance

### F0 (Immediate Foreground - 16x16)
- `DRAW_F0_WALL`: Solid blue wall (BLU on BLU)
- `DRAW_F0_WALL_AND_CLOSED_DOOR`: Blue wall + green door  
- `DRAW_WALL_F0_AND_OPEN_DOOR`: Blue wall + dark opening

### F1 (Middle Distance - 8x8)  
- `DRAW_WALL_F1`: Character-based wall with blue colors
- `DRAW_WALL_F1_AND_CLOSED_DOOR`: Wall + green door
- `DRAW_WALL_F1_AND_OPEN_DOOR`: Wall + black opening

### F2 (Far Distance - 4x4)
- `DRAW_WALL_F2`: Small dark gray wall
- `DRAW_DOOR_F2_OPEN`: Small black opening

### Side Walls (FL/FR/L/R series)
Complex geometric wall segments that create the 3D perspective effect:
- **FL0/FR0**: Closest side walls
- **FL1/FR1**: Medium distance side walls  
- **FL2/FR2**: Far side walls
- **FL22/FR22**: Far corner walls
- **L1/L2, R1/R2**: Near left/right walls

## Perspective System

The 3D perspective is achieved through:

1. **Size scaling**: F0 (16x16) → F1 (8x8) → F2 (4x4)
2. **Position mapping**: Each distance has specific COLRAM coordinates
3. **Layered rendering**: Back-to-front drawing order
4. **Color gradation**: Darker colors for distant walls

## Modification Points for New Graphics

### To Add New Wall Types:
1. **Create new drawing functions** in `asterion_func_low.asm` following the pattern:
   ```asm
   DRAW_NEW_WALL_F0:
       LD          HL,COLRAM_F0_WALL_MAP_IDX
       LD          BC,RECT(16,16)
       LD          A,COLOR(NEW_FG,NEW_BG)
       JP          FILL_CHRCOL_RECT
   ```

2. **Modify decision logic** in `REDRAW_VIEWPORT` to call your new functions based on wall type flags

3. **Update wall state calculation** in `REDRAW_START` if you need new wall type detection

### To Modify Existing Graphics:
- **Change colors**: Modify the COLOR() macro values in existing drawing functions
- **Change patterns**: Modify character values in CHRRAM-based drawing functions  
- **Change sizes**: Modify RECT() macro values (but maintain perspective ratios)

### Character-Based Graphics:
Some walls use character graphics stored in CHRRAM:
- F1 walls use character `$20` (SPACE) with color-only rendering
- Original code used `$86` (crosshatch) character
- You can use custom characters by modifying the character value in drawing functions

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

## Memory Usage

### Screen Layout (40x24 characters):
- Viewport occupies central 24x24 area
- UI elements surround viewport (stats, items, etc.)
- Each character cell = 1 byte CHRRAM + 1 byte COLRAM

### Performance Considerations:
- FILL_CHRCOL_RECT is the bottleneck function - called ~20-50 times per redraw
- Viewport redraws happen on every player action
- Total redraw affects ~576 character cells (24x24)

---

*This analysis provides the foundation for understanding and modifying the Maze of Asterion rendering system. The modular wall drawing functions make it relatively straightforward to add new wall graphics while maintaining the existing 3D perspective system.*