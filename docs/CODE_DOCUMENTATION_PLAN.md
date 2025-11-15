# Code Documentation Plan - Maze of Asterion

## Overview
This document outlines the plan for adding comprehensive comments and documentation to improve code maintainability and debugging effectiveness. The focus is on areas that are currently sparsely commented but critical for understanding game flow and troubleshooting issues.

## Documentation Standards
Following the existing pattern of header comments that document:
- **Purpose**: What the function does
- **Input Parameters**: Register states/values on entry
- **Working Registers**: Registers modified during execution  
- **Output/Return**: Register states/values on exit
- **Side Effects**: Memory locations modified, flags affected

## Priority 1: CRITICAL - Graphics Rendering System

### 1.1 Wall State Bit Manipulation Patterns
**Location**: Throughout `src/asterion_high_rom.asm` REDRAW_VIEWPORT function (lines ~3560-3900)

**Issue**: The 3-bit wall state checking using `RRCA` sequences appears dozens of times but is never explained.

**Documentation Needed**:
```asm
; === WALL STATE ENCODING PATTERN ===
; Based on wall_diagram.txt: Low bits=West wall, High bits=North wall  
; West: $x0=no wall, $x1=solid wall, $x2=visible closed door, $x4=hidden closed door
; North: $0x=no wall, $2x=solid wall, $4x=visible closed door, $6x=hidden closed door
; Standard RRCA pattern used throughout REDRAW_VIEWPORT:
LD          A,(DE)          ; Load wall state nibble from map position
RRCA                        ; Rotate bits for wall state testing
JP          NC,wall_check   ; Branch based on rotated bit state
; Wall exists, check if it has a door
RRCA                        ; Rotate bit 1 into Carry: test door present  
JP          NC,solid_wall   ; If bit 1 clear, solid wall (no door)
; Door exists, check open/closed state
RRCA                        ; Rotate bit 2 into Carry: test door state
JP          C,door_open     ; If bit 2 set, door is open
; Door is closed - render closed door with appropriate graphics
```

**Functions to Document**:
- All wall rendering sections in REDRAW_VIEWPORT
- Pattern explanation at first occurrence
- Reference comments for subsequent uses

### 1.2 Viewport Rendering Pipeline
**Location**: `REDRAW_VIEWPORT` function in `src/asterion_high_rom.asm`

**Issue**: Complex painter's algorithm implementation with no flow documentation.

**Header Comment Needed**:
```asm
;==============================================================================
; REDRAW_VIEWPORT - Renders 3D maze view using painter's algorithm
;==============================================================================
; PURPOSE: Redraws entire 3D viewport by rendering walls from far to near
; INPUT:   Wall state memory block at $33e8-$33fd (22 bytes, 3-bit encoding)
; PROCESS: 1. Clear viewport area
;          2. Render walls in painter's order (far to near):
;             - Far walls (F2, F1, F0) 
;             - Mid-distance walls (FL2, FR2, FL1, FR1, FL0, FR0)
;             - Near walls (L1, R1, L0, R0)
;          3. Each wall checks 3-bit state for wall/door presence and state
; OUTPUT:  Updated CHRRAM/COLRAM viewport area
; USES:    A, BC, DE, HL, AF' (all registers modified)
; MEMORY:  Modifies CHRRAM $3000+ and COLRAM $3400+ viewport regions
;==============================================================================
```

### 1.3 Generic Wall/Door Functions
**Location**: `src/asterion_func_low.asm` SUB_ram_* functions

**Issue**: Functions like `SUB_ram_cc6d`, `SUB_ram_cb4f` have generic labels but specific purposes.

**Documentation Priority**:
- Add header comments to all SUB_ram_* functions identified in previous analysis
- Document their specific wall/door rendering purpose
- Explain color schemes and geometric patterns used

## Priority 2: MEDIUM - Graphics Utility Functions

### 2.1 Core Drawing Functions ✅ **COMPLETED**
**Location**: `src/asterion_func_low.asm` drawing utilities

**Functions With Enhanced Headers**:
- ✅ `FILL_CHRCOL_RECT` - Rectangle fill operation (comprehensive header with REGISTERS MODIFIED)
- ✅ `DRAW_ROW` - Helper function for row filling (concise documentation)
- **In Progress**: Adding detailed line-by-line contextual comments

**Remaining Functions Needing Headers**:
- `DRAW_CHRCOLS` - Column drawing with color  
- `DRAW_VERTICAL_LINE_*` - Line drawing primitives
- `DRAW_HORIZONTAL_LINE_*` - Line drawing primitives

**Standard Header Template**:
```asm
;==============================================================================
; FUNCTION_NAME - Brief description
;==============================================================================
; PURPOSE: Detailed explanation of what function does
; INPUT:   HL = starting screen position (CHRRAM or COLRAM address)
;          BC = dimensions (B=height, C=width) 
;          A  = character/color value to draw
; PROCESS: Step-by-step explanation of algorithm
; OUTPUT:  Screen memory updated, registers preserved/modified
; USES:    List of registers modified during execution
; NOTES:   Coordinate system: (0,0) at top-left, +X right, +Y down
;==============================================================================
```

### 2.2 Enhanced Line-by-Line Commenting ✅ **IN PROGRESS**
**Location**: Core graphics functions in `src/asterion_func_low.asm` and `src/asterion_high_rom.asm`

**Completed Functions**:
- ✅ `GFX_DRAW` - Full contextual commenting explaining AQUASCII processing, cursor movement, and stack operations
- **In Progress**: `FILL_CHRCOL_RECT` and associated drawing functions

**Commenting Style**:
```asm
PUSH        HL                                  ; Save current row start position  
PUSH        BC                                  ; Save rectangle dimensions (B=width, C=height)
CALL        DRAW_ROW                            ; Fill current row with character/color in A
POP         BC                                  ; Restore rectangle dimensions
POP         HL                                  ; Restore row start position
DEC         C                                   ; Decrement remaining height
RET         Z                                   ; Return if all rows completed
ADD         HL,DE                               ; Move to start of next row (+40 characters)
JP          DRAW_CHRCOLS                        ; Continue with next row
```

**Functions Requiring Line Comments**:
- `FILL_CHRCOL_RECT` - Rectangle fill with row-by-row processing
- `DRAW_ROW` - Single row fill operation  
- `DRAW_F0_WALL` - Far wall rendering with blue color
- `DRAW_F0_WALL_AND_CLOSED_DOOR` - Wall plus door rendering
- Related wall/door drawing functions

### 2.3 Memory Address Calculation Patterns  
**Location**: Graphics functions throughout codebase

**Documentation Needed**:
- ✅ Explain CHRRAM ($3000-$33E7) vs COLRAM ($3400-$37E7) usage (40x25 = 1000 bytes each)
- Document coordinate system: **40x25** character screen (corrected from 40x24)  
- Explain common offset calculations (DE=$28 for next row)
- Rectangle encoding in BC register (B=width, C=height)
- ✅ **AQUASCII Control Characters**: Documented in GFX_DRAW function:
  - `00`=move right, `01`=CR+LF, `02`=backspace  
  - `03`=LF, `04`=cursor up, `A0`=reverse colors, `FF`=end

## Priority 3: MEDIUM - Item and Monster Systems

### 3.1 Item Graphics System
**Location**: `CHK_ITEM` function around line 1685 in `src/asterion_high_rom.asm`

**Issues**: Complex item type and color decoding logic uncommented.

**Header Comment Needed**:
```asm
;==============================================================================
; CHK_ITEM - Decode and render item/monster graphics
;==============================================================================
; PURPOSE: Decodes item type and color, renders appropriate graphics
; INPUT:   A  = item code (encoded type and color)
;          BC = position/color parameters
; PROCESS: 1. Check for "no item" marker ($FE)
;          2. Extract item type through bit shifting
;          3. Determine color palette (RED/MAG=$10, YEL/WHT=$30)  
;          4. Calculate graphics pointer offset
;          5. Call GFX_DRAW to render
; OUTPUT:  Item graphics rendered to screen
; USES:    A, BC, DE, HL (all modified)
; MEMORY:  Reads from graphics table at $FF00+, updates screen
;==============================================================================
```

### 3.2 Graphics Pointer System
**Location**: Item/monster graphics lookup tables

**Documentation Needed**:
- Explain graphics pointer table organization
- Document color encoding system
- Explain offset calculations for different item types

## Priority 4: LOW-MEDIUM - Game State Management

### 4.1 Game Initialization
**Location**: `GAMEINIT` function start of `src/asterion_high_rom.asm`

**Header Comment Needed**:
```asm
;==============================================================================
; GAMEINIT - Initialize new game state
;==============================================================================
; PURPOSE: Sets up initial game state, player stats, and screen display
; INPUT:   None (cold start)
; PROCESS: 1. Clear CHRRAM and COLRAM memory
;          2. Initialize player health (PHYS=30, SPRT=15)
;          3. Set starting inventory (FOOD=14, ARROWS=14)
;          4. Initialize random number seed
;          5. Set up initial display state
; OUTPUT:  Game ready for play
; USES:    All registers modified
; MEMORY:  Initializes game variables, screen memory
;==============================================================================
```

### 4.2 State Transition Functions
**Location**: Various state management functions

**Documentation Needed**:
- Document `GAME_BOOLEANS` bit flag usage
- Explain state transition triggers
- Document difficulty level effects

## Priority 5: LOW - Data Structure Documentation

### 5.1 Memory Layout Documentation
**Location**: `src/asterion.inc` and related files

**Documentation Needed**:
- Add comments to memory address definitions
- Explain data structure layouts
- Document array organizations

### 5.2 Wall State Memory Block
**Location**: Wall state variables $33e8-$33fd

**Already Documented**: See `WALL_STATE_VARIABLE_RENAMING.md`  
**Additional Need**: Inline comments in code using these addresses
**Research Findings**: Map generation at $3800 (16x16 tiles, 256 bytes)
- 4-bit encoding per position: Upper nibble=North wall, Lower nibble=West wall
- Wraps around with special E/W boundary navigation rules
- Guarantees at least one route into every map position

## Implementation Strategy

### Phase 1: Critical Path (Week 1)
1. Add wall state bit pattern explanation to first occurrence in REDRAW_VIEWPORT
2. Add header comment to REDRAW_VIEWPORT function
3. Document 5-10 most commonly used graphics utility functions

### Phase 2: Core Systems (Week 2)  
1. Add headers to all major wall/door rendering functions
2. Document graphics utility parameter conventions
3. Add CHK_ITEM system documentation

### Phase 3: Comprehensive Coverage (Week 3)
1. Add headers to remaining functions
2. Document initialization and state management
3. Add inline comments for complex calculations

### Phase 4: Polish and Review (Week 4)
1. Review documentation consistency
2. Add cross-references between related functions
3. Create function index/overview document

## Tools and Resources Needed

1. ✅ **Wall Bit Pattern Research**: PowerPoint presentation analyzed - provides definitive wall encoding
2. **Existing Examples**: Reference well-commented functions already in codebase  
3. **Testing**: Verify documentation accuracy through code tracing
4. **Consistency Check**: Ensure uniform header format across all functions

## Research Validation Complete

Your PowerPoint research has provided the missing pieces for accurate documentation:

- **Wall State Encoding**: Confirmed patterns per wall_diagram.txt (West=low bits, North=high bits)
- **Map Layout**: 16x16 grid at $3800 with 4-bit nibbles (North/West walls per position)  
- **Graphics Control Codes**: AQUASCII control characters explain cursor movement in graphics
- **Item/Monster Levels**: Color encoding in bits 0-1 (RED/YELLOW/MAGENTA/WHITE)

This eliminates guesswork and ensures technical accuracy in all documentation.

## Success Criteria

- Every major function has a proper header comment
- Wall state bit manipulation patterns are clearly explained
- Graphics system coordinate systems are documented
- Code is significantly easier to debug and maintain
- New developers can understand system flow from comments alone

---

*This plan prioritizes areas most critical for debugging graphics issues while building comprehensive documentation coverage across the entire codebase.*