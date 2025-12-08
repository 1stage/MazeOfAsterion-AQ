# Modification Safety Zones for Viewport Rendering

**Created**: 2025-12-08  
**Branch**: viewport-rendering  
**Purpose**: Guide safe modification of rendering system for enhancement work

This document categorizes all aspects of the viewport rendering system by modification risk level, providing clear guidance on what can be safely changed versus what requires careful system-level redesign.

---

## Risk Level Definitions

**✓ SAFE**: Can be modified with minimal risk. Changes are localized and won't break rendering logic or occlusion system.

**⚠️ MEDIUM**: Requires careful consideration. Changes may affect visual appearance or overlap zones but won't break core logic if done correctly.

**🔶 COMPLEX**: Requires deep understanding of rendering flow. Changes may affect multiple systems and require updates to jump targets or call sites.

**❌ DANGEROUS**: High risk of breaking the rendering system. Requires complete system redesign or extensive testing across all 22 wall positions.

---

## SAFE Modifications (✓)

### 1. Wall and Door Colors

**What**: Changing COLRAM byte values within existing drawing functions

**Where**: Any `COLOR(fg, bg)` constant in drawing functions

**Examples**:
```asm
; Current F2 wall color
LD A, COLOR(BLK, DKGRY)    ; Line 640 in DRAW_WALL_F2

; Safe to change to:
LD A, COLOR(WHT, BLU)      ; Different color scheme
LD A, COLOR(RED, BLK)      ; Red on black walls
LD A, COLOR(CYN, DKGRY)    ; Cyan on dark gray
```

**Risk**: None - colors don't affect geometry or occlusion logic

**Testing**: Visual inspection only, no functional testing needed

**Files Affected**: `asterion_func_low.asm` (all `DRAW_*` functions)

---

### 2. Wall and Door Characters

**What**: Changing CHRRAM byte values for wall/door appearance

**Where**: Character constants in drawing functions

**Examples**:
```asm
; Current F2 base line character
LD A, $90                  ; Line 646 in DRAW_WALL_F2

; Safe to change to:
LD A, $91                  ; Different line character
LD A, $A0                  ; Block character
LD A, $80                  ; Pattern character
```

**Risk**: None - character codes don't affect layout

**Constraints**: 
- Must use valid Aquarius character codes ($00-$FF)
- Character RAM has graphics definitions at $3000 base

**Testing**: Visual verification of character appearance

**Files Affected**: `asterion_func_low.asm` (character drawing routines)

---

### 3. Item Graphics Selection

**What**: Changing which graphics are used for items/monsters at different distances

**Where**: `CHK_ITEM` BC parameter values (lines 8304, 8422-8424, 8467-8497, 8567-8597, 8622-8623)

**Current Distance-Based Graphics**:
| Distance | BC Params | Variant | Size | Call Lines |
|----------|-----------|---------|------|------------|
| F2 | $48a | _T (tiny) | Small distant | 8304 |
| FL1 | $4d0 | _S (small) | Small | 8467-8497 (×5) |
| F1 | $28a | _S (small) | Small | 8422-8424 |
| FR1 | $4e4 | _S (small) | Small | 8567-8597 (×5) |
| F0 | $8a | Regular | 4×4 full | 8622-8623 |

**Safe Changes**:
```asm
; Change F1 item size from small to regular
LD BC, $28a        ; Current (small)
LD BC, $08a        ; Change to regular 4×4

; Change F2 from tiny to small
LD BC, $48a        ; Current (tiny)
LD BC, $28a        ; Change to small
```

**Risk**: Low - may cause visual overlap if larger graphics used at distance

**Constraints**:
- B register = color offset ($00-$70 range)
- C register = screen position offset

**Testing**: Visual verification at all distances

**Files Affected**: `asterion_high_rom.asm` (REDRAW_VIEWPORT lines 8085-8620)

---

### 4. Background Colors (Ceiling/Floor)

**What**: Changing DRAW_BKGD ceiling and floor colors

**Where**: `asterion_func_low.asm` DRAW_BKGD function (lines 3013-3050)

**Current Layout**:
- Upper ceiling: 8 rows DKGRY on BLK
- Lower ceiling: 6 rows BLK on BLK
- Upper floor: 5 rows DKGRN on DKGRY
- Lower floor: 5 rows BLK on DKGRY

**Examples**:
```asm
; Line 3040 - Upper ceiling color
LD A, COLOR(DKGRY, BLK)    ; Current

; Safe to change:
LD A, COLOR(BLU, BLK)      ; Blue ceiling
LD A, COLOR(DKGRY, DKBLU)  ; Dark blue background
```

**Risk**: None - purely cosmetic

**Testing**: Visual verification only

**Files Affected**: `asterion_func_low.asm` (DRAW_BKGD function)

---

## MEDIUM Risk Modifications (⚠️)

### 1. Rectangle Dimensions (Wall Sizes)

**What**: Changing `RECT(width, height)` parameters in drawing functions

**Where**: All `DRAW_*` functions using `FILL_CHRCOL_RECT`

**Current Dimensions** (from COLRAM_CHRRAM_VERIFICATION.md):
| Wall | Dimensions | Function | Line |
|------|------------|----------|------|
| F0 | 16×15 | DRAW_F0_WALL | 456 |
| F1 | 8×8 | DRAW_WALL_F1 | 558 |
| F2 | 4×4 + 4×1 base | DRAW_WALL_F2 | 639-646 |
| L0 | 4×15 diagonal | DRAW_WALL_L0 | 1021+ |
| R0 | 4×15 diagonal | DRAW_WALL_R0 | 1189+ |

**Risks**:
- **Overlap**: Larger rectangles may overwrite adjacent walls or items
- **Gaps**: Smaller rectangles may create visual holes
- **Perspective**: Size changes must maintain depth perception

**Safe Changes**:
```asm
; F2 wall currently 4×4
LD BC, RECT(4, 4)          ; Current

; Can increase slightly without overlap:
LD BC, RECT(4, 5)          ; +1 row (safe if tested)
LD BC, RECT(5, 4)          ; +1 column (may overlap FL2/FR2)
```

**Dangerous Changes**:
```asm
; F0 wall currently 16×15
LD BC, RECT(16, 15)        ; Current

; DON'T make F0 smaller without filling gap:
LD BC, RECT(12, 12)        ; Creates 4-pixel border gap
LD BC, RECT(16, 20)        ; Overflows screen (max 24 rows)
```

**Screen Constraints**:
- Viewport: 24×24 area (columns 8-31, rows 0-23)
- Total screen: 40×24 characters
- Any rectangle must fit within viewport bounds

**Testing Required**:
- Visual verification at all wall combinations
- Check for overlap with adjacent walls
- Verify perspective looks correct at distance
- Test with doors open/closed
- Test with items present

**Validation Tool**: Compare against `COLRAM_*_IDX` constants to ensure no overlap

**Files Affected**: `asterion_func_low.asm` (all wall drawing functions)

---

### 2. Adding New Drawing Calls

**What**: Inserting additional `CALL DRAW_*` or `CALL FILL_CHRCOL_RECT` within existing code flow

**Where**: Between existing drawing operations in REDRAW_VIEWPORT

**Example Use Case**: Adding decorative elements or overlay graphics

**Safe Insertion Points**:
```asm
; After F0 wall drawn, before jump (line 8143)
CALL DRAW_WALL_F0_AND_OPEN_DOOR
CALL DRAW_MY_CUSTOM_OVERLAY    ; NEW - Safe here
JP   CHK_ITEM_F1

; After background, before F0 check (line 8129)
CALL DRAW_BKGD
CALL DRAW_CUSTOM_CEILING       ; NEW - Safe here
LD   BC, ITEM_F2
```

**Risks**:
- **Draw Order**: Later draws overwrite earlier ones
- **Register Corruption**: Must preserve A, BC, DE, HL if needed after call
- **Performance**: Each additional call adds CPU cycles

**Register Preservation**:
```asm
; If you need to preserve registers:
PUSH AF
PUSH BC
CALL MY_CUSTOM_DRAW
POP  BC
POP  AF
```

**Testing Required**:
- Verify correct z-ordering (occlusion)
- Check register values before/after
- Performance testing (frame rate)

**Files Affected**: `asterion_high_rom.asm` (REDRAW_VIEWPORT), custom drawing functions

---

### 3. Modifying Item Rendering Parameters

**What**: Changing the 5 FL1/FR1 item rendering parameters to add/remove calls

**Where**: Lines 8467-8497 (FL1), 8567-8597 (FR1)

**Current FL1 Rendering** (5 calls):
```asm
8467: LD BC, $4d0      ; Call 1
8475: LD BC, $4d8      ; Call 2
8482: LD BC, $508      ; Call 3
8492: LD BC, $510      ; Call 4
8497: LD BC, $4e0      ; Call 5
```

**Possible Modifications**:
- Reduce to 3 calls for performance
- Add more calls for layered effect
- Change BC parameters for different positions

**Risks**:
- **Visual Gaps**: Removing calls may leave items partially rendered
- **Overlap**: Adding calls may overwrite walls
- **Asymmetry**: FL1 and FR1 should match for visual consistency

**Testing Required**:
- Test with items at FL1/FR1 positions
- Verify all wall configurations (L1 closed, open, no wall)
- Check visual appearance is balanced

**Files Affected**: `asterion_high_rom.asm` (REDRAW_VIEWPORT)

---

## COMPLEX Modifications (🔶)

### 1. Changing Rendering Order

**What**: Reordering when walls are drawn within REDRAW_VIEWPORT

**Current Order** (from VIEWPORT_RENDERING_FLOW.md):
1. Background (DRAW_BKGD)
2. F0 → F1 → F2 (front walls, closest to farthest)
3. L2, FL2_A, R2, FR2_A (distance-2 sides)
4. L1, FL1_A/B, FL2_B (distance-1 left)
5. R1, FR1_A/B, FR2_B (distance-1 right)
6. L0, FL0, FL1_B, FL22 (distance-0 left + items)
7. R0, FR0, FR1_B, FR22 (distance-0 right + items)
8. F1 item, F0 item (final overlays)

**Why Order Matters**:
- **Occlusion**: Closer walls must overwrite distant walls
- **Jump Targets**: Occlusion jumps skip rendering based on F0/F1 walls
- **Items**: Must render after walls to appear "on top"

**Major Occlusion Jumps** (from WALL_RENDERING_TRUTH_TABLE.md):
| Source | Condition | Target | Walls Skipped |
|--------|-----------|--------|---------------|
| F0 | Closed door | Line 8427 | F1, F2, L2, FL2_A, R2, FR2_A, L1, FL1, FL2_B, R1, FR1, FR2_B |
| F1 | Closed door | Line 8306 | F2, L2, FL2_A, R2, FR2_A |
| F1 | Open door | Line 8303 | L2, FL2_A, R2, FR2_A |

**Safe Order Changes**:
- Swap L2 ↔ R2 (symmetric)
- Swap FL2_A ↔ FR2_A (symmetric)
- Move item renders within same distance group

**Dangerous Order Changes**:
```asm
; DON'T draw F2 before F0:
CALL DRAW_WALL_F2          ; WRONG - F0 will overwrite
CALL DRAW_F0_WALL          ; Should be first

; DON'T draw items before walls:
CALL CHK_ITEM              ; WRONG - wall will overwrite item
CALL DRAW_WALL_F1          ; Should be before item
```

**Required Updates When Changing Order**:
1. Update all `JP` targets to match new line numbers
2. Verify occlusion jumps still skip correct walls
3. Update VIEWPORT_RENDERING_FLOW.md documentation
4. Update WALL_RENDERING_TRUTH_TABLE.md jump targets

**Testing Required**:
- Test all 8 wall state combinations per position (2³ bits)
- Verify correct occlusion in all scenarios
- Check item rendering at all distances
- Test door open/close transitions

**Files Affected**: `asterion_high_rom.asm` (REDRAW_VIEWPORT), documentation

---

### 2. Modifying Jump Targets (Occlusion System)

**What**: Changing `JP` targets to skip different walls based on occlusion

**Current Occlusion Logic**:
- F0 closed wall → Skip to line 8427 (skip F1, F2, distance-2, distance-1)
- F0 open door → Skip to line 8422 (render F1 item, skip walls)
- F1 closed wall → Skip to line 8306 (skip F2, distance-2)
- F1 open door → Skip to line 8303 (skip distance-2, render F2 item)

**Example Modification**: Make F0 open door skip more aggressively
```asm
; Current (line 8143):
JP CHK_ITEM_F1             ; → Line 8422 (renders F1 item + distance-1)

; More aggressive skip:
JP CHK_ITEM_F0             ; → Line 8622 (skip everything, render F0 item only)
```

**Risks**:
- **Over-Culling**: Skipping too much creates visual holes
- **Under-Culling**: Not skipping enough wastes CPU cycles
- **Logic Errors**: Wrong target breaks rendering completely

**Required Updates**:
1. Trace execution path to verify all cases covered
2. Update VIEWPORT_RENDERING_FLOW.md with new paths
3. Update WALL_RENDERING_TRUTH_TABLE.md jump targets
4. Test all 2²² wall state combinations (4,194,304 states!)

**Practical Testing Strategy**:
- Test each wall position with all 8 states (2³ bits × 22 walls = 176 cases)
- Test common configurations (straight corridors, T-junctions, rooms)
- Test with items at all positions
- Performance benchmark before/after

**Files Affected**: `asterion_high_rom.asm` (REDRAW_VIEWPORT), documentation

---

### 3. Adding New Wall Positions

**What**: Rendering additional walls beyond the current 21 viewport positions

**Current Coverage**: 21 walls + 1 back wall (B0, not rendered)

**Possible Additions**:
- FL22+, FR22+ synthetic walls (mentioned in wall_diagram.txt)
- Distance-3 walls (F3, L3, R3)
- Diagonal corner walls

**Requirements**:
1. **Wall State Variables**: Add to $33e8-$33fd range (only 2 bytes free!)
2. **State Calculation**: Update REDRAW_START (FACING_NORTH/SOUTH/EAST/WEST)
3. **COLRAM/CHRRAM Constants**: Define screen positions in asterion.inc
4. **Drawing Functions**: Create DRAW_* routines in asterion_func_low.asm
5. **Rendering Calls**: Insert into REDRAW_VIEWPORT flow
6. **Occlusion Logic**: Update jump targets to account for new walls

**Memory Constraint**: Only 2 bytes remain in wall state range ($33fe-$33ff)

**Screen Space Constraint**: 
- Viewport is 24×24 (columns 8-31, rows 0-23)
- F2 already uses center 4×4 (smallest visible wall)
- F3 would be ~2×2 pixels (may not be visible)

**Risk**: HIGH - requires system-level changes across 5+ files

**Alternative**: Use existing FL22/FR22 positions for synthetic walls instead of adding new ones

**Files Affected**: `asterion.inc`, `asterion_func_low.asm`, `asterion_high_rom.asm` (REDRAW_START, REDRAW_VIEWPORT)

---

## DANGEROUS Modifications (❌)

### 1. Wall State Calculation (REDRAW_START)

**What**: Modifying how wall state bytes are calculated from map data

**Where**: `asterion_high_rom.asm` FACING_NORTH/SOUTH/EAST/WEST functions (lines 7500-7900)

**Current Logic**:
- Reads map data from current position + facing direction
- Calculates 22 wall state bytes ($33e8-$33fd)
- Uses bit masks to extract wall/door states
- Uses `CALC_HALF_WALLS` for FL/FR positions

**Why Dangerous**:
- **Bit Encoding**: Changing bit meanings breaks all wall rendering logic
- **Calculation Errors**: Wrong wall states cause visual glitches across entire viewport
- **Half-Wall Logic**: FL/FR positions use complex A/B split calculations
- **Direction Dependence**: Must update all 4 facing direction functions

**Example of Dangerous Change**:
```asm
; DON'T change bit encoding:
AND 0x7        ; Current: extracts bits 0-2 for wall state

; Changing to:
AND 0xF        ; Uses bits 0-3, breaks RRCA rotation logic in REDRAW_VIEWPORT
```

**Required for Safe Changes**:
1. Deep understanding of map data format
2. Update all 4 facing direction functions identically
3. Update all wall state testing in REDRAW_VIEWPORT (22 positions × 3 bits = 66 tests)
4. Update WALL_RENDERING_TRUTH_TABLE.md documentation
5. Extensive testing of all map configurations

**Testing Required**:
- Test at every map position (512 positions in 16×32 map)
- Test facing all 4 directions at each position
- Test all door/wall combinations
- Verify hidden doors work correctly

**Recommendation**: ❌ **DO NOT MODIFY** unless redesigning entire rendering system

**Files Affected**: `asterion_high_rom.asm` (REDRAW_START), `asterion.inc` (bit encoding documentation)

---

### 2. Bit Encoding Scheme (Wall State Bits)

**What**: Changing which bits represent hidden door, wall exists, door state

**Current Encoding**:
- Bit 0: Hidden door flag (1 = hidden door present)
- Bit 1: Wall exists flag (1 = wall/door present, 0 = empty)
- Bit 2: Door state (1 = open, 0 = closed)

**Used By**: All 22 wall state checks in REDRAW_VIEWPORT (66 bit tests total)

**Testing Pattern**:
```asm
RRCA           ; Rotate bit 0 → Carry
JP NC, ...     ; Jump if bit 0 = 0
RRCA           ; Rotate bit 1 → Carry
JP NC, ...     ; Jump if bit 1 = 0
RRCA           ; Rotate bit 2 → Carry
JP C, ...      ; Jump if bit 2 = 1
```

**Why Dangerous**:
- **Ubiquity**: Used 66 times across REDRAW_VIEWPORT
- **RRCA Dependency**: Rotation order (0→1→2) is hardcoded
- **Map Format**: Bit meanings tied to map data structure
- **Documentation**: All truth tables reference current encoding

**If Changed, Must Update**:
1. All 66 RRCA/JP sequences in REDRAW_VIEWPORT
2. Map data format and all map files
3. REDRAW_START wall calculation logic
4. WALL_RENDERING_TRUTH_TABLE.md (all bit columns)
5. wall_diagram.txt documentation
6. VIEWPORT_RENDERING.md documentation

**Estimated Impact**: 200+ line changes across 3 files

**Recommendation**: ❌ **DO NOT MODIFY** - fundamental system design

**Files Affected**: `asterion_high_rom.asm` (REDRAW_START, REDRAW_VIEWPORT), map data files, all documentation

---

### 3. Screen Memory Layout (COLRAM/CHRRAM Addresses)

**What**: Changing base addresses or index constants for screen positions

**Current Layout** (from asterion.inc):
- CHRRAM: $3000-$33E7 (character data, 999 bytes)
- COLRAM: $3400-$37E7 (color data, 999 bytes)
- Viewport starts: $3028 (CHRRAM_VIEWPORT_IDX = CHRRAM_L0_WALL_IDX)

**Aliasing** (from COLRAM_CHRRAM_VERIFICATION.md):
- $3028: CHRRAM_VIEWPORT_IDX = CHRRAM_L0_WALL_IDX
- $3168: CHRRAM_L1_WALL_IDX = CHRRAM_WALL_FL1_A_IDX
- $34a3: COLRAM_L0_WALL_IDX = COLRAM_FL0_WALL_IDX
- $35c2: COLRAM_F2_WALL_IDX = COLRAM_F1_DOOR_IDX = COLRAM_L2_RIGHT

**Why Dangerous**:
- **Aliasing**: Multiple constants point to same address for memory reuse
- **Hardware**: Aquarius screen hardware requires exact memory layout
- **Overlap**: Changing addresses breaks intentional screen space reuse
- **Perspective**: Current layout creates correct depth perception

**Example of Breaking Change**:
```asm
; Current F2 and F1 door share address $35c2
COLRAM_F2_WALL_IDX     EQU $35c2
COLRAM_F1_DOOR_IDX     EQU $35c2    ; ALIAS - intentional

; DON'T separate these:
COLRAM_F2_WALL_IDX     EQU $35c2
COLRAM_F1_DOOR_IDX     EQU $35c6    ; BREAKS depth perception
```

**If Changed, Must Update**:
1. All 50+ COLRAM/CHRRAM constants in asterion.inc
2. All drawing functions using those constants
3. Viewport layout calculations
4. Verify no overlap or gaps in screen coverage
5. COLRAM_CHRRAM_VERIFICATION.md (all addresses)
6. Test visual appearance at all distances

**Hardware Constraints**:
- Aquarius screen: 40 columns × 24 rows = 960 bytes
- CHRRAM/COLRAM must stay in $3000-$37FF range
- Cannot extend beyond hardware screen boundaries

**Recommendation**: ❌ **DO NOT MODIFY** - tied to hardware layout

**Files Affected**: `asterion.inc`, all drawing functions, documentation

---

### 4. FILL_CHRCOL_RECT Algorithm

**What**: Modifying the core rectangle drawing algorithm

**Where**: `asterion_func_low.asm` FILL_CHRCOL_RECT (lines ~400-430)

**Current Algorithm**:
```asm
FILL_CHRCOL_RECT:
    LD   DE, $28              ; Row stride (40 chars)
DRAW_CHRCOLS:
    PUSH HL                   ; Save row start
    PUSH BC                   ; Save dimensions
    CALL DRAW_ROW             ; Fill current row
    POP  BC                   ; Restore dimensions
    POP  HL                   ; Restore row start
    DEC  C                    ; Decrement height
    RET  Z                    ; Done if height = 0
    ADD  HL, DE               ; Next row (+40)
    JP   DRAW_CHRCOLS         ; Continue
```

**Used By**: Every wall, door, background, and item drawing function (50+ calls)

**Why Dangerous**:
- **Ubiquity**: Called by all drawing functions
- **Register Contract**: Expects HL=position, BC=dimensions, A=value, DE=stride
- **Screen Stride**: DE=$28 (40 chars) is Aquarius screen width
- **Recursion**: Uses stack for row iteration

**If Broken**:
- All walls render incorrectly
- Viewport becomes garbled
- May crash if stack overflow
- Screen corruption

**Safe Optimizations**:
- Replace `JP` with fall-through for last row
- Unroll loop for specific rectangle sizes
- Add bounds checking (performance cost)

**Dangerous Changes**:
- Changing register usage (breaks all callers)
- Changing stride calculation (breaks screen layout)
- Removing stack operations (corrupts dimensions)

**Recommendation**: ❌ **DO NOT MODIFY** - core system primitive

**Files Affected**: `asterion_func_low.asm` (FILL_CHRCOL_RECT), all drawing functions

---

## Summary Table: Modification Risk Matrix

| Category | Risk Level | Files Affected | Testing Required | Documentation Updates |
|----------|------------|----------------|------------------|----------------------|
| Colors | ✓ SAFE | asterion_func_low.asm | Visual only | None |
| Characters | ✓ SAFE | asterion_func_low.asm | Visual only | None |
| Item Graphics | ✓ SAFE | asterion_high_rom.asm | Visual only | None |
| Background | ✓ SAFE | asterion_func_low.asm | Visual only | None |
| Rectangle Sizes | ⚠️ MEDIUM | asterion_func_low.asm | Visual + overlap | COLRAM_CHRRAM_VERIFICATION.md |
| New Drawing Calls | ⚠️ MEDIUM | asterion_high_rom.asm | Visual + registers | VIEWPORT_RENDERING_FLOW.md |
| Item Parameters | ⚠️ MEDIUM | asterion_high_rom.asm | Visual + walls | CHK_ITEM_CALL_SITES.md |
| Rendering Order | 🔶 COMPLEX | asterion_high_rom.asm | Full regression | VIEWPORT_RENDERING_FLOW.md, WALL_RENDERING_TRUTH_TABLE.md |
| Jump Targets | 🔶 COMPLEX | asterion_high_rom.asm | Full regression | VIEWPORT_RENDERING_FLOW.md, WALL_RENDERING_TRUTH_TABLE.md |
| New Wall Positions | 🔶 COMPLEX | Multiple (5+) | Full regression | All documentation |
| Wall State Calc | ❌ DANGEROUS | asterion_high_rom.asm | Comprehensive | WALL_RENDERING_TRUTH_TABLE.md |
| Bit Encoding | ❌ DANGEROUS | Multiple (3+) | Comprehensive | All documentation |
| Screen Layout | ❌ DANGEROUS | asterion.inc, multiple | Comprehensive | COLRAM_CHRRAM_VERIFICATION.md |
| FILL_CHRCOL_RECT | ❌ DANGEROUS | asterion_func_low.asm | Comprehensive | None |

---

## Recommended Modification Workflow

### For SAFE Changes (✓)
1. Make change in source file
2. Build and run
3. Visual verification
4. Commit

### For MEDIUM Changes (⚠️)
1. Review relevant documentation (COLRAM_CHRRAM_VERIFICATION.md, etc.)
2. Check for overlaps or conflicts
3. Make change in source file
4. Build and run
5. Test affected scenarios (doors, items, walls)
6. Update documentation if needed
7. Commit with detailed description

### For COMPLEX Changes (🔶)
1. **Plan**: Review all affected documentation
2. **Document**: Create modification plan with line numbers
3. **Branch**: Create feature branch for changes
4. **Implement**: Make changes systematically
5. **Update Jumps**: Fix all affected JP targets
6. **Test**: Full regression test suite
   - All wall states (8 per position)
   - All item positions (5 viewport items)
   - All door combinations (open/closed/hidden)
7. **Document**: Update all affected .md files
8. **Review**: Code review before merge
9. **Commit**: Detailed commit message with rationale

### For DANGEROUS Changes (❌)
1. **DON'T** - Unless redesigning entire system
2. **IF REQUIRED**:
   - Create comprehensive design document
   - Review with experienced assembly programmer
   - Create extensive test suite (automated if possible)
   - Budget 10-20 hours for implementation + testing
   - Update ALL documentation files
   - Consider backward compatibility with save files
   - Plan rollback strategy

---

## Testing Checklist

### Visual Tests (for SAFE/MEDIUM changes)
- [ ] F0 wall closed
- [ ] F0 wall open
- [ ] F0 wall with items
- [ ] F1 wall closed
- [ ] F1 wall open
- [ ] F1 wall with items
- [ ] F2 wall with items
- [ ] L0/R0 walls
- [ ] L1/R1 walls
- [ ] L2/R2 walls
- [ ] FL0/FR0 diagonal walls
- [ ] FL1/FR1 diagonal walls with items (5 renders each)
- [ ] FL22/FR22 corner walls
- [ ] Straight corridor (all distances visible)
- [ ] T-junction (left/right walls)
- [ ] Room (no front walls)
- [ ] Dead end (F0 closed)

### Functional Tests (for COMPLEX changes)
- [ ] All wall state combinations (2³ × 22 = 176 cases)
- [ ] Door open/close transitions
- [ ] Hidden door reveals
- [ ] Item pickup renders correctly
- [ ] Monster movement across distances
- [ ] Occlusion jumps work (F0/F1 skips)
- [ ] Player movement updates walls correctly
- [ ] Rotation (N/S/E/W) renders correctly
- [ ] Performance: 60 FPS or equivalent target

### Regression Tests (for DANGEROUS changes)
- [ ] All 512 map positions
- [ ] All 4 facing directions at each position
- [ ] Save/load game preserves state
- [ ] No memory corruption
- [ ] No stack overflow
- [ ] All game features still work (combat, inventory, etc.)

---

## Future Enhancement Ideas (Ranked by Safety)

### SAFE Enhancements
1. **Color Palette Swap**: Change all walls to different color scheme
2. **Alternate Character Sets**: Load different graphics for walls/doors
3. **Dynamic Backgrounds**: Change ceiling/floor colors based on level
4. **Item Color Variations**: Use different colors for item types

### MEDIUM Enhancements
1. **Larger Item Graphics**: Use regular instead of _S for FL1/FR1
2. **Wall Decorations**: Add small overlays (torches, banners) after walls
3. **Distance Fog**: Gradually darken far walls (F2, distance-2)
4. **Door Animations**: Multi-frame door open/close sequences

### COMPLEX Enhancements
1. **Optimized Occlusion**: More aggressive culling to improve performance
2. **Reordered Rendering**: Draw distance-2 before distance-1 for different effect
3. **Additional Item Positions**: Render items at L0/R0 positions
4. **Transparent Doors**: Render F1/F2 through open F0 door

### DANGEROUS Enhancements (System Redesign Required)
1. **Distance-3 Walls**: Add F3, L3, R3 positions (requires new state vars)
2. **Vertical Wall Sections**: Different top/bottom wall graphics (new bit encoding)
3. **Dynamic Screen Layout**: Resize viewport based on context (new COLRAM layout)
4. **Z-Buffer System**: Full 3D occlusion instead of front-to-back (complete rewrite)

---

## Conclusion

The viewport rendering system is a carefully balanced design with:
- **21 rendered wall positions** checked against **176 state combinations**
- **7 major occlusion jumps** optimizing performance
- **50+ drawing functions** sharing screen memory through intentional aliasing
- **66 bit tests** using hardcoded RRCA rotation sequences

**Safe modifications** (colors, characters, graphics) can be done confidently with minimal testing.

**Medium modifications** (sizes, new calls) require careful consideration of screen space and overlap zones.

**Complex modifications** (rendering order, jumps) require deep understanding and comprehensive testing.

**Dangerous modifications** (state calculation, bit encoding, screen layout) should only be attempted as part of a complete system redesign.

Use this document as a reference when planning any changes to the rendering system. When in doubt, start with SAFE changes and work up to more complex modifications as you gain confidence.

---

*Document Status: COMPLETE - All modification zones categorized and documented*
