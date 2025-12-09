# Wall Rendering Truth Table

**Created**: 2025-12-08  
**Branch**: viewport-rendering  
**Source**: VIEWPORT_RENDERING_FLOW.md, asterion_high_rom.asm lines 8085-8620

This document provides a comprehensive reference for every wall rendering decision in REDRAW_VIEWPORT.

---

## Bit Encoding Reference

**Wall State Byte** (3-bit encoding):
- **Bit 0**: Hidden door flag (1 = hidden door present)
- **Bit 1**: Wall exists flag (1 = wall/door present, 0 = empty space)
- **Bit 2**: Door state (1 = open, 0 = closed)

**Testing Order**: RRCA (Rotate Right Circular Accumulator) tests bits 0→1→2 sequentially

---

## Front Walls (F-Series)

### F0 - Front Wall at Distance 0 (Immediate)

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_F0_STATE` | $33e8 | 8131-8132 | 1 | X | X | Hidden door path | → 8134 | Start HD logic |
| `WALL_F0_STATE` | $33e8 | 8137-8138 | 1 | 0 | X | HD, no wall | → 8427 (F0_HD_NO_WALL) | Skip F1/F2 |
| `WALL_F0_STATE` | $33e8 | 8139-8140 | 1 | 1 | 0 | HD, closed door | → 8427 (F0_HD_NO_WALL) | Skip F1/F2 |
| `WALL_F0_STATE` | $33e8 | 8139-8141 | 1 | 1 | 1 | HD, open door | → 8422 (CHK_ITEM_F1) | DRAW_WALL_F0_AND_OPEN_DOOR |
| `WALL_F0_STATE` | $33e8 | 8154-8155 | 0 | 0 | X | No HD, no wall | → 8165 (F0_NO_HD_NO_WALL) | Check F1 |
| `WALL_F0_STATE` | $33e8 | 8156-8157 | 0 | 1 | 1 | No HD, open door | → 8141 (F0_NO_HD_WALL_OPEN) | DRAW_WALL_F0_AND_OPEN_DOOR |
| `WALL_F0_STATE` | $33e8 | 8156-8158 | 0 | 1 | 0 | No HD, closed door | → 8427 (F0_HD_NO_WALL) | DRAW_F0_WALL_AND_CLOSED_DOOR |

**Key Occlusion Jump**: Line 8159 - F0 closed door skips ~280 lines, jumping straight to L0/R0 side walls at line 8427

**Rendering Functions**:
- `DRAW_F0_WALL` (line 455): 16×15 BLU on BLU rectangle
- `DRAW_F0_WALL_AND_CLOSED_DOOR` (line 480): F0 wall + closed door overlay
- `DRAW_WALL_F0_AND_OPEN_DOOR` (line 523): F0 wall + open door overlay

---

### F1 - Front Wall at Distance 1 (Middle)

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_F1_STATE` | $33e9 | 8168-8169 | 1 | X | X | Hidden door path | → 8170 | Start HD logic |
| `WALL_F1_STATE` | $33e9 | 8173-8174 | 1 | 0 | X | HD, no wall | → 8306 (F1_HD_NO_WALL) | Skip F2 |
| `WALL_F1_STATE` | $33e9 | 8175-8176 | 1 | 1 | 0 | HD, closed door | → 8306 (F1_HD_NO_WALL) | Skip F2 |
| `WALL_F1_STATE` | $33e9 | 8175-8177 | 1 | 1 | 1 | HD, open door | → 8303 (CHK_ITEM_F2) | DRAW_WALL_F1_AND_OPEN_DOOR |
| `WALL_F1_STATE` | $33e9 | 8184-8185 | 0 | 0 | X | No HD, no wall | → 8199 (F1_NO_HD_NO_WALL) | Check F2 |
| `WALL_F1_STATE` | $33e9 | 8186-8187 | 0 | 1 | 1 | No HD, open door | → 8177 (F1_NO_HD_WALL_OPEN) | DRAW_WALL_F1_AND_OPEN_DOOR |
| `WALL_F1_STATE` | $33e9 | 8186-8188 | 0 | 1 | 0 | No HD, closed door | → 8306 (F1_HD_NO_WALL) | DRAW_WALL_F1_AND_CLOSED_DOOR |

**Key Occlusion Jump**: Line 8179 - F1 open door skips L2/R2/FL2/FR2, jumping to F2 item check at line 8303

**Rendering Functions**:
- `DRAW_WALL_F1` (line 558): 8×8 wall
- `DRAW_WALL_F1_AND_CLOSED_DOOR` (line 572): F1 wall + closed door
- `DRAW_WALL_F1_AND_OPEN_DOOR` (line 597): F1 wall + open door

---

### F2 - Front Wall at Distance 2 (Farthest)

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_F2_STATE` | $33ea | 8200-8201 | 1 | X | X | Hidden door path | → 8202 | Start HD logic |
| `WALL_F2_STATE` | $33ea | 8205-8206 | 1 | 0 | X | HD, no wall | → 8220 (CHK_WALL_L2_HD) | Check L2 |
| `WALL_F2_STATE` | $33ea | 8207-8208 | 1 | 1 | 0 | HD, closed door | → 8220 (CHK_WALL_L2_HD) | Check L2 |
| `WALL_F2_STATE` | $33ea | 8207-8209 | 1 | 1 | 1 | HD, open door | → 8220 (CHK_WALL_L2_HD) | DRAW_WALL_F2_AND_OPEN_DOOR |
| `WALL_F2_STATE` | $33ea | 8213-8214 | 0 | 0 | X | No HD, no wall | → 8220 (CHK_WALL_L2_HD) | Check L2 |
| `WALL_F2_STATE` | $33ea | 8215-8216 | 0 | 1 | 1 | No HD, open door | → 8209 (F2_NO_HD_WALL_OPEN) | DRAW_WALL_F2_AND_OPEN_DOOR |
| `WALL_F2_STATE` | $33ea | 8215-8217 | 0 | 1 | 0 | No HD, closed door | → 8220 (CHK_WALL_L2_HD) | DRAW_WALL_F2_AND_CLOSED_DOOR |

**No Occlusion Jump**: F2 is farthest wall, always falls through to L2/R2 distance-2 side walls

**Rendering Functions**:
- `DRAW_WALL_F2` (line 639): 4×4 wall + base line
- `DRAW_WALL_F2_AND_CLOSED_DOOR` (line 691): F2 wall + closed door
- `DRAW_WALL_F2_AND_OPEN_DOOR` (line 714): F2 wall + open door

---

## Distance-2 Side Walls (L2, FL2_A, R2, FR2_A)

### L2 - Left Wall at Distance 2

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_L2_STATE` | $33eb | 8221-8222 | 1 | X | X | Hidden door | → 8223 (DRAW_L2_WALL) | DRAW_WALL_L2 |
| `WALL_L2_STATE` | $33eb | 8225-8227 | 0 | 1 | X | No HD, wall exists | → 8223 (DRAW_L2_WALL) | DRAW_WALL_L2 |
| `WALL_L2_STATE` | $33eb | 8225-8228 | 0 | 0 | X | No HD, no wall | → 8228 (fall through) | DRAW_WALL_FL2_A_EMPTY |

**Note**: L2 only tests bit 0 and bit 1. Door state (bit 2) not checked - doors at distance 2 don't render differently.

**Jump Target**: Line 8224 - After drawing L2, jumps to CHK_WALL_R2_HD (line 8241)

**Rendering Functions**:
- `DRAW_WALL_L2` (line 1277): Complex diagonal wall using F1/F0 constants
- `DRAW_WALL_FL2_A_EMPTY` (line 1379): Clears FL2_A area

---

### FL2_A - Front-Left Wall Distance 2, Part A

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_FL2_A_STATE` | $33ec | 8230-8231 | 1 | X | X | Hidden door | → 8232 (DRAW_FL2_A_WALL) | DRAW_WALL_FL2_A |
| `WALL_FL2_A_STATE` | $33ec | 8235-8237 | 0 | 1 | X | No HD, wall exists | → 8232 (DRAW_FL2_A_WALL) | DRAW_WALL_FL2_A |
| `WALL_FL2_A_STATE` | $33ec | 8235-8238 | 0 | 0 | X | No HD, no wall | → 8238 (fall through) | DRAW_WALL_FL2_A_EMPTY |

**Jump Target**: After drawing FL2_A, jumps to CHK_WALL_R2_HD (line 8241)

**Rendering Functions**:
- `DRAW_WALL_FL2_A` (line 3792): 2×4 front-left corner wall

---

### R2 - Right Wall at Distance 2

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_R2_STATE` | $33ed | 8244-8245 | 1 | X | X | Hidden door | → 8246 (DRAW_R2_WALL) | DRAW_WALL_R2 |
| `WALL_R2_STATE` | $33ed | 8250-8251 | 0 | 1 | X | No HD, wall exists | → 8246 (DRAW_R2_WALL) | DRAW_WALL_R2 |
| `WALL_R2_STATE` | $33ed | 8250-8252 | 0 | 0 | X | No HD, no wall | → 8252 (fall through) | Check FR2_A |

**Jump Target**: Line 8248 - After drawing R2, jumps to CHK_ITEM_F2 (line 8303), skipping FR2_A

**Rendering Functions**:
- `DRAW_WALL_R2` (line 2118): Mirrors L2, uses F1/F0 constants

---

### FR2_A - Front-Right Wall Distance 2, Part A

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_FR2_A_STATE` | $33ee | 8254-8255 | 1 | X | X | Hidden door | → 8256 (DRAW_FR2_A_WALL) | DRAW_WALL_FR2_A |
| `WALL_FR2_A_STATE` | $33ee | 8260-8261 | 0 | 1 | X | No HD, wall exists | → 8256 (DRAW_FR2_A_WALL) | DRAW_WALL_FR2_A |
| `WALL_FR2_A_STATE` | $33ee | 8260-8262 | 0 | 0 | X | No HD, no wall | → 8262 (fall through) | DRAW_WALL_FR2_A_EMPTY |

**Jump Target**: Line 8258 - After drawing FR2_A, jumps to CHK_ITEM_F2 (line 8303)

**Fall Through**: Line 8303 - CHK_ITEM_F2 renders F2 item, then falls to F1_HD_NO_WALL

**Rendering Functions**:
- `DRAW_WALL_FR2_A` (line 2047): Front-right corner wall
- `DRAW_WALL_FR2_A_EMPTY` (line 2063): Clears FR2_A area

---

## Distance-1 Left Side Walls (L1, FL1_A, FL2_B)

### L1 - Left Wall at Distance 1

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_L1_STATE` | $33ef | 8309-8310 | 1 | X | X | Hidden door path | → 8311 | Start HD logic |
| `WALL_L1_STATE` | $33ef | 8314-8315 | 1 | 0 | X | HD, no wall | → 8376 (CHK_WALL_R1_HD) | Skip rest of L1 |
| `WALL_L1_STATE` | $33ef | 8316-8317 | 1 | 1 | 0 | HD, closed door | → 8376 (CHK_WALL_R1_HD) | Skip rest of L1 |
| `WALL_L1_STATE` | $33ef | 8316-8318 | 1 | 1 | 1 | HD, open door | → 8376 (CHK_WALL_R1_HD) | DRAW_FL1_DOOR |
| `WALL_L1_STATE` | $33ef | 8322-8323 | 0 | 0 | X | No HD, no wall | → 8329 (CHK_WALL_FL1_B) | Check FL1_B |
| `WALL_L1_STATE` | $33ef | 8324-8325 | 0 | 1 | 1 | No HD, open door | → 8318 (DRAW_L1_DOOR_OPEN) | DRAW_FL1_DOOR |
| `WALL_L1_STATE` | $33ef | 8324-8326 | 0 | 1 | 0 | No HD, closed door | → 8376 (CHK_WALL_R1_HD) | DRAW_L1 |

**Rendering Functions**:
- `DRAW_WALL_L1` (line 1435): Diagonal L1 wall
- `DRAW_L1` (line 1590): L1 wall with door
- `DRAW_FL1_DOOR` (line 1513): FL1 door overlay

---

### FL1_A - Front-Left Wall Distance 1, Part A

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_FL1_A_STATE` | $33f0 | 8332-8333 | 1 | X | X | Hidden door path | → 8334 | Start HD logic |
| `WALL_FL1_A_STATE` | $33f0 | 8337-8338 | 1 | 0 | X | HD, no wall | → 8376 (CHK_WALL_R1_HD) | Skip to R1 |
| `WALL_FL1_A_STATE` | $33f0 | 8339-8340 | 1 | 1 | 0 | HD, closed door | → 8376 (CHK_WALL_R1_HD) | Skip to R1 |
| `WALL_FL1_A_STATE` | $33f0 | 8339-8341 | 1 | 1 | 1 | HD, open door | → 8376 (CHK_WALL_R1_HD) | DRAW_DOOR_FL1_B_HIDDEN |
| `WALL_FL1_A_STATE` | $33f0 | 8347-8348 | 0 | 0 | X | No HD, no wall | → 8357 (CHK_WALL_FL2) | Check FL2_B |
| `WALL_FL1_A_STATE` | $33f0 | 8349-8350 | 0 | 1 | 1 | No HD, open door | → 8341 (DRAW_FL1_B_DOOR_OPEN) | DRAW_DOOR_FL1_B_HIDDEN |
| `WALL_FL1_A_STATE` | $33f0 | 8349-8351 | 0 | 1 | 0 | No HD, closed door | → 8376 (CHK_WALL_R1_HD) | DRAW_DOOR_FL1_B_NORMAL |

**Note**: This is labeled FL1_B in code but uses FL1_A state variable. This checks the back wall visible through L1 gap.

**Rendering Functions**:
- `DRAW_WALL_FL1_B` (line 1589): FL1 back wall section
- `DRAW_DOOR_FL1_B_NORMAL` (line 1645): Normal door on FL1 back
- `DRAW_DOOR_FL1_B_HIDDEN` (line 1659): Hidden door on FL1 back

---

### FL2_B - Front-Left Wall Distance 2, Part B

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_FL2_B_STATE` | $33f1 | 8358-8359 | 1 | X | X | Hidden door | → 8360 (DRAW_FL2_WALL) | DRAW_WALL_FL2 |
| `WALL_FL2_B_STATE` | $33f1 | 8363-8365 | 0 | 1 | X | No HD, wall exists | → 8360 (DRAW_FL2_WALL) | DRAW_WALL_FL2 |
| `WALL_FL2_B_STATE` | $33f1 | 8363-8366 | 0 | 0 | X | No HD, no wall | → 8366 (fall through) | DRAW_WALL_FL2_EMPTY |

**Jump Target**: Line 8362 - After drawing FL2, jumps to CHK_WALL_R1_HD (line 8376)

**Rendering Functions**:
- `DRAW_WALL_FL2` (line 3719): 2×4 FL2 wall section
- `DRAW_WALL_FL2_EMPTY` (line 3753): Clears FL2 area

---

## Distance-1 Right Side Walls (R1, FR1_A, FR2_B)

### R1 - Right Wall at Distance 1

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_R1_STATE` | $33f2 | 8377-8378 | 1 | X | X | Hidden door path | → 8379 | Start HD logic |
| `WALL_R1_STATE` | $33f2 | 8382-8383 | 1 | 0 | X | HD, no wall | → 8427 (F0_HD_NO_WALL) | Skip to L0/R0 |
| `WALL_R1_STATE` | $33f2 | 8384-8385 | 1 | 1 | 0 | HD, closed door | → 8427 (F0_HD_NO_WALL) | Skip to L0/R0 |
| `WALL_R1_STATE` | $33f2 | 8384-8386 | 1 | 1 | 1 | HD, open door | → 8427 (F0_HD_NO_WALL) | DRAW_DOOR_R1 |
| `WALL_R1_STATE` | $33f2 | 8390-8391 | 0 | 0 | X | No HD, no wall | → 8397 (CHK_WALL_FR1_A) | Check FR1_A |
| `WALL_R1_STATE` | $33f2 | 8392-8393 | 0 | 1 | 1 | No HD, open door | → 8386 (DRAW_R1_DOOR_OPEN) | DRAW_DOOR_R1 |
| `WALL_R1_STATE` | $33f2 | 8392-8394 | 0 | 1 | 0 | No HD, closed door | → 8427 (F0_HD_NO_WALL) | DRAW_WALL_R1 |

**Rendering Functions**:
- `DRAW_WALL_R1` (line 1686): Diagonal R1 wall
- `DRAW_DOOR_R1` (line 1723): R1 door (normal and hidden variants)

---

### FR1_A - Front-Right Wall Distance 1, Part A

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_FR1_A_STATE` | $33f3 | 8398-8399 | 1 | X | X | Hidden door path | → 8400 | Start HD logic |
| `WALL_FR1_A_STATE` | $33f3 | 8403-8404 | 1 | 0 | X | HD, no wall | → 8427 (F0_HD_NO_WALL) | Skip to L0/R0 |
| `WALL_FR1_A_STATE` | $33f3 | 8405-8406 | 1 | 1 | 0 | HD, closed door | → 8427 (F0_HD_NO_WALL) | Skip to L0/R0 |
| `WALL_FR1_A_STATE` | $33f3 | 8405-8407 | 1 | 1 | 1 | HD, open door | → 8427 (F0_HD_NO_WALL) | DRAW_DOOR_FR1_B_HIDDEN |
| `WALL_FR1_A_STATE` | $33f3 | 8411-8412 | 0 | 0 | X | No HD, no wall | → 8418 (CHK_WALL_FR2_B) | Check FR2_B |
| `WALL_FR1_A_STATE` | $33f3 | 8413-8414 | 0 | 1 | 1 | No HD, open door | → 8407 (DRAW_FR1_A_DOOR_OPEN) | DRAW_DOOR_FR1_B_HIDDEN |
| `WALL_FR1_A_STATE` | $33f3 | 8413-8415 | 0 | 1 | 0 | No HD, closed door | → 8427 (F0_HD_NO_WALL) | DRAW_DOOR_FR1_B_NORMAL |

**Note**: Similar to FL1_A, this uses FR1_B drawing functions but checks FR1_A state.

**Rendering Functions**:
- `DRAW_WALL_FR1_B` (line 1886): FR1 back wall section
- `DRAW_DOOR_FR1_B_NORMAL` (line 1916): Normal door on FR1 back
- `DRAW_DOOR_FR1_B_HIDDEN` (line 1967): Hidden door on FR1 back

---

### FR2_B - Front-Right Wall Distance 2, Part B

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_FR2_B_STATE` | $33f4 | 8419-8420 | 1 | X | X | Hidden door | → 8421 (DRAW_FR2_WALL) | DRAW_WALL_FR2 |
| `WALL_FR2_B_STATE` | $33f4 | 8424-8426 | 0 | 1 | X | No HD, wall exists | → 8421 (DRAW_FR2_WALL) | DRAW_WALL_FR2 |
| `WALL_FR2_B_STATE` | $33f4 | 8424-8427 | 0 | 0 | X | No HD, no wall | → 8427 (F0_HD_NO_WALL) | DRAW_WALL_FR2_EMPTY |

**Jump Target**: Line 8423 - After drawing FR2, jumps to F0_HD_NO_WALL (line 8427)

**Fall Through**: Line 8427 starts distance-0 left side wall processing

**Rendering Functions**:
- `DRAW_WALL_FR2` (line 2009): FR2 wall section
- `DRAW_WALL_FR2_EMPTY` (line 2093): Clears FR2 area

---

## Distance-0 Left Side Walls (L0, FL0, FL1_B, FL22)

### L0 - Left Wall at Distance 0

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_L0_STATE` | $33f5 | 8428-8429 | 1 | X | X | Hidden door path | → 8430 | Start HD logic |
| `WALL_L0_STATE` | $33f5 | 8433-8434 | 1 | 0 | X | HD, no wall | → 8527 (CHK_WALL_R0_HD) | Skip to R0 |
| `WALL_L0_STATE` | $33f5 | 8435-8436 | 1 | 1 | 0 | HD, closed door | → 8527 (CHK_WALL_R0_HD) | Skip to R0 |
| `WALL_L0_STATE` | $33f5 | 8435-8437 | 1 | 1 | 1 | HD, open door | → 8527 (CHK_WALL_R0_HD) | DRAW_DOOR_L0_HIDDEN |
| `WALL_L0_STATE` | $33f5 | 8441-8442 | 0 | 0 | X | No HD, no wall | → 8448 (CHK_WALL_FL0) | Check FL0 |
| `WALL_L0_STATE` | $33f5 | 8443-8444 | 0 | 1 | 1 | No HD, open door | → 8437 (DRAW_L0_DOOR_OPEN) | DRAW_DOOR_L0_NORMAL |
| `WALL_L0_STATE` | $33f5 | 8443-8445 | 0 | 1 | 0 | No HD, closed door | → 8527 (CHK_WALL_R0_HD) | DRAW_WALL_L0 |

**Rendering Functions**:
- `DRAW_WALL_L0` (line 1021): Diagonal L0 wall, large
- `DRAW_DOOR_L0_NORMAL` (line 1060): Normal L0 door
- `DRAW_DOOR_L0_HIDDEN` (line 1093): Hidden L0 door

---

### FL0 - Front-Left Wall at Distance 0

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_FL0_STATE` | $33f6 | 8449-8450 | 1 | X | X | Hidden door path | → 8451 | Start HD logic |
| `WALL_FL0_STATE` | $33f6 | 8454-8455 | 1 | 0 | X | HD, no wall | → 8527 (CHK_WALL_R0_HD) | Skip to R0 |
| `WALL_FL0_STATE` | $33f6 | 8456-8457 | 1 | 1 | 0 | HD, closed door | → 8527 (CHK_WALL_R0_HD) | Skip to R0 |
| `WALL_FL0_STATE` | $33f6 | 8456-8458 | 1 | 1 | 1 | HD, open door | → 8527 (CHK_WALL_R0_HD) | DRAW_DOOR_FL0_HIDDEN |
| `WALL_FL0_STATE` | $33f6 | 8462-8463 | 0 | 0 | X | No HD, no wall | → 8469 (CHK_WALL_FL1_B) | Check FL1_B |
| `WALL_FL0_STATE` | $33f6 | 8464-8465 | 0 | 1 | 1 | No HD, open door | → 8458 (DRAW_FL0_DOOR_OPEN) | DRAW_DOOR_FL0_NORMAL |
| `WALL_FL0_STATE` | $33f6 | 8464-8466 | 0 | 1 | 0 | No HD, closed door | → 8527 (CHK_WALL_R0_HD) | DRAW_WALL_FL0 |

**Rendering Functions**:
- `DRAW_WALL_FL0` (line 952): FL0 diagonal wall section
- `DRAW_DOOR_FL0_NORMAL` (line 989): Normal FL0 door
- `DRAW_DOOR_FL0_HIDDEN` (line 1003): Hidden FL0 door

---

### FL1_B - Front-Left Wall Distance 1, Part B (from L0 view)

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_FL1_B_STATE` | $33f7 | 8470-8471 | 1 | X | X | Hidden door path | → 8472 | Start HD logic |
| `WALL_FL1_B_STATE` | $33f7 | 8475-8476 | 1 | 0 | X | HD, no wall | → 8527 (CHK_WALL_R0_HD) | Skip to R0 |
| `WALL_FL1_B_STATE` | $33f7 | 8477-8478 | 1 | 1 | 0 | HD, closed door | → 8527 (CHK_WALL_R0_HD) | Skip to R0 |
| `WALL_FL1_B_STATE` | $33f7 | 8477-8479 | 1 | 1 | 1 | HD, open door | → 8480 (CHK_ITEM_SL1) | DRAW_DOOR_FL1_A_HIDDEN + items |
| `WALL_FL1_B_STATE` | $33f7 | 8483-8484 | 0 | 0 | X | No HD, no wall | → 8490 (CHK_WALL_FL22) | Check FL22 |
| `WALL_FL1_B_STATE` | $33f7 | 8485-8486 | 0 | 1 | 1 | No HD, open door | → 8479 (DRAW_FL1_B_DOOR_OPEN) | DRAW_DOOR_FL1_A_NORMAL + items |
| `WALL_FL1_B_STATE` | $33f7 | 8485-8487 | 0 | 1 | 0 | No HD, closed door | → 8480 (CHK_ITEM_SL1) | DRAW_WALL_FL1_A + items |

**Special Behavior**: FL1_B rendering triggers multiple SL1 item checks (up to 5 calls to CHK_ITEM)

**Item Rendering**: Lines 8480-8500 contain 5 CHK_ITEM calls for FL1 position with different parameters

**Rendering Functions**:
- `DRAW_WALL_FL1_A` (line 1555): FL1 front wall section
- `DRAW_DOOR_FL1_A_NORMAL` (line 1621): Normal FL1_A door
- `DRAW_DOOR_FL1_A_HIDDEN` (line 1635): Hidden FL1_A door

---

### FL22 - Far Left Corner Wall (Distance 2, Left Corner)

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_L22_STATE` | $33f8 | 8491-8492 | 1 | X | X | Hidden door | → 8493 (DRAW_FL22_WALL) | DRAW_WALL_FL22 |
| `WALL_L22_STATE` | $33f8 | 8496-8498 | 0 | 1 | X | No HD, wall exists | → 8493 (DRAW_FL22_WALL) | DRAW_WALL_FL22 |
| `WALL_L22_STATE` | $33f8 | 8496-8499 | 0 | 0 | X | No HD, no wall | → 8499 (fall through) | DRAW_WALL_FL22_EMPTY |

**Jump Target**: Line 8495 - After drawing FL22, jumps to CHK_ITEM_F1 (line 8422)

**Rendering Functions**:
- `DRAW_WALL_FL22` (line 3823): 4×4 far left corner wall
- `DRAW_WALL_FL22_EMPTY` (line 3695): Clears FL22 area (tail-call with JP)

---

## Distance-0 Right Side Walls (R0, FR0, FR1_B, FR22)

### R0 - Right Wall at Distance 0

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_R0_STATE` | $33f9 | 8528-8529 | 1 | X | X | Hidden door path | → 8530 | Start HD logic |
| `WALL_R0_STATE` | $33f9 | 8533-8534 | 1 | 0 | X | HD, no wall | → 8622 (CHK_ITEM_F0) | Skip to F0 item |
| `WALL_R0_STATE` | $33f9 | 8535-8536 | 1 | 1 | 0 | HD, closed door | → 8622 (CHK_ITEM_F0) | Skip to F0 item |
| `WALL_R0_STATE` | $33f9 | 8535-8537 | 1 | 1 | 1 | HD, open door | → 8622 (CHK_ITEM_F0) | DRAW_R0_DOOR_HIDDEN |
| `WALL_R0_STATE` | $33f9 | 8541-8542 | 0 | 0 | X | No HD, no wall | → 8548 (CHK_WALL_FR0) | Check FR0 |
| `WALL_R0_STATE` | $33f9 | 8543-8544 | 0 | 1 | 1 | No HD, open door | → 8537 (DRAW_R0_DOOR_OPEN) | DRAW_R0_DOOR_NORMAL |
| `WALL_R0_STATE` | $33f9 | 8543-8545 | 0 | 1 | 0 | No HD, closed door | → 8622 (CHK_ITEM_F0) | DRAW_WALL_R0 |

**Rendering Functions**:
- `DRAW_WALL_R0` (line 1189): Diagonal R0 wall, large
- `DRAW_R0_DOOR_NORMAL` (line 1228): Normal R0 door
- `DRAW_R0_DOOR_HIDDEN` (line 1240): Hidden R0 door

---

### FR0 - Front-Right Wall at Distance 0

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_FR0_STATE` | $33fa | 8549-8550 | 1 | X | X | Hidden door path | → 8551 | Start HD logic |
| `WALL_FR0_STATE` | $33fa | 8554-8555 | 1 | 0 | X | HD, no wall | → 8622 (CHK_ITEM_F0) | Skip to F0 item |
| `WALL_FR0_STATE` | $33fa | 8556-8557 | 1 | 1 | 0 | HD, closed door | → 8622 (CHK_ITEM_F0) | Skip to F0 item |
| `WALL_FR0_STATE` | $33fa | 8556-8558 | 1 | 1 | 1 | HD, open door | → 8622 (CHK_ITEM_F0) | DRAW_DOOR_FR0_HIDDEN |
| `WALL_FR0_STATE` | $33fa | 8562-8563 | 0 | 0 | X | No HD, no wall | → 8569 (CHK_WALL_FR1_B) | Check FR1_B |
| `WALL_FR0_STATE` | $33fa | 8564-8565 | 0 | 1 | 1 | No HD, open door | → 8558 (DRAW_FR0_DOOR_OPEN) | DRAW_DOOR_FR0_NORMAL |
| `WALL_FR0_STATE` | $33fa | 8564-8566 | 0 | 1 | 0 | No HD, closed door | → 8622 (CHK_ITEM_F0) | DRAW_WALL_FR0 |

**Rendering Functions**:
- `DRAW_WALL_FR0` (line 1137): FR0 diagonal wall section
- `DRAW_DOOR_FR0_NORMAL` (line 1174): Normal FR0 door
- `DRAW_DOOR_FR0_HIDDEN` (line 1188): Hidden FR0 door

---

### FR1_B - Front-Right Wall Distance 1, Part B (from R0 view)

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_FR1_B_STATE` | $33fb | 8570-8571 | 1 | X | X | Hidden door path | → 8572 | Start HD logic |
| `WALL_FR1_B_STATE` | $33fb | 8575-8576 | 1 | 0 | X | HD, no wall | → 8622 (CHK_ITEM_F0) | Skip to F0 item |
| `WALL_FR1_B_STATE` | $33fb | 8577-8578 | 1 | 1 | 0 | HD, closed door | → 8622 (CHK_ITEM_F0) | Skip to F0 item |
| `WALL_FR1_B_STATE` | $33fb | 8577-8579 | 1 | 1 | 1 | HD, open door | → 8580 (CHK_ITEM_SR1) | DRAW_DOOR_FR1_A_HIDDEN + items |
| `WALL_FR1_B_STATE` | $33fb | 8583-8584 | 0 | 0 | X | No HD, no wall | → 8590 (CHK_WALL_FR22) | Check FR22 |
| `WALL_FR1_B_STATE` | $33fb | 8585-8586 | 0 | 1 | 1 | No HD, open door | → 8579 (DRAW_FR1_B_DOOR_OPEN) | DRAW_DOOR_FR1_A_NORMAL + items |
| `WALL_FR1_B_STATE` | $33fb | 8585-8587 | 0 | 1 | 0 | No HD, closed door | → 8580 (CHK_ITEM_SR1) | DRAW_WALL_FR1_A + items |

**Special Behavior**: FR1_B rendering triggers multiple SR1 item checks (up to 5 calls to CHK_ITEM)

**Item Rendering**: Lines 8580-8600 contain 5 CHK_ITEM calls for SR1 position with different parameters

**Rendering Functions**:
- `DRAW_WALL_FR1_A` (line 1853): FR1 front wall section
- `DRAW_DOOR_FR1_A_NORMAL` (line 1983): Normal FR1_A door
- `DRAW_DOOR_FR1_A_HIDDEN` (line 1997): Hidden FR1_A door

---

### FR22 - Far Right Corner Wall (Distance 2, Right Corner)

| State Var | Address | Check Line | Bit 0 | Bit 1 | Bit 2 | Action | Jump Target | Draw Function |
|-----------|---------|------------|-------|-------|-------|--------|-------------|---------------|
| `WALL_R22_STATE` | $33fc | 8591-8592 | 1 | X | X | Hidden door | → 8593 (DRAW_FR22_WALL) | DRAW_WALL_FR22 |
| `WALL_R22_STATE` | $33fc | 8596-8598 | 0 | 1 | X | No HD, wall exists | → 8593 (DRAW_FR22_WALL) | DRAW_WALL_FR22 |
| `WALL_R22_STATE` | $33fc | 8596-8599 | 0 | 0 | X | No HD, no wall | → 8599 (fall through) | DRAW_WALL_FR22_EMPTY |

**Jump Target**: Line 8595 - After drawing FR22, jumps to CHK_ITEM_F1 (line 8422)

**Fall Through**: Line 8622 - CHK_ITEM_F0 (final item render)

**Rendering Functions**:
- `DRAW_WALL_FR22` (line 2126): 4×4 far right corner wall
- `DRAW_WALL_FR22_EMPTY` (line 1743): Clears FR22 area

---

## Item Rendering (Final Steps)

### F1 Item Rendering

| Entry Point | Line | Item Variable | BC Params | Description |
|-------------|------|---------------|-----------|-------------|
| CHK_ITEM_F1 | 8422 | ITEM_F1 ($37ea) | $028a | F1 item render (small, _S variant) |

**Source**: Called from F0 open door path (line 8143), FL22/FR22 rendering (lines 8495, 8595)

---

### F0 Item Rendering (Final Step)

| Entry Point | Line | Item Variable | BC Params | Description |
|-------------|------|---------------|-----------|-------------|
| CHK_ITEM_F0 | 8622 | ITEM_F0 ($37ec) | $008a | F0 item render (regular 4×4) |

**Source**: Final step of REDRAW_VIEWPORT, called from all R0/FR0/FR1_B paths

**End**: Line 8623 - RET (return from REDRAW_VIEWPORT)

---

## Summary Tables

### Occlusion Jump Targets

| Source Wall | Condition | Jump Target | Lines Skipped | Walls Skipped |
|-------------|-----------|-------------|---------------|---------------|
| F0 | Closed door | Line 8427 (F0_HD_NO_WALL) | ~268 | F1, F2, L2, FL2_A, R2, FR2_A, L1, FL1_A, FL2_B, R1, FR1_A, FR2_B |
| F0 | Open door | Line 8422 (CHK_ITEM_F1) | ~273 | F1, F2, L2-R2 (distance-2), L1-R1 (distance-1) |
| F1 | Closed door | Line 8306 (F1_HD_NO_WALL) | ~117 | F2, L2, FL2_A, R2, FR2_A |
| F1 | Open door | Line 8303 (CHK_ITEM_F2) | ~114 | L2, FL2_A, R2, FR2_A |
| L2 | Wall drawn | Line 8241 (CHK_WALL_R2_HD) | ~12 | FL2_A |
| R2 | Wall drawn | Line 8303 (CHK_ITEM_F2) | ~50 | FR2_A |
| FL2_A | Wall drawn | Line 8241 (CHK_WALL_R2_HD) | ~2 | (jump back to R2 check) |

**Key Insight**: F0 closed wall creates the largest jump, skipping 268 lines and 12+ wall checks. This is the primary occlusion optimization.

---

### Wall State Variables (Memory Map)

| Variable | Address | Distance | Direction | Render Order |
|----------|---------|----------|-----------|--------------|
| WALL_F0_STATE | $33e8 | 0 | Front | 1st |
| WALL_F1_STATE | $33e9 | 1 | Front | 2nd |
| WALL_F2_STATE | $33ea | 2 | Front | 3rd |
| WALL_L2_STATE | $33eb | 2 | Left | 4th |
| WALL_FL2_A_STATE | $33ec | 2 | Front-Left A | 5th |
| WALL_R2_STATE | $33ed | 2 | Right | 6th |
| WALL_FR2_A_STATE | $33ee | 2 | Front-Right A | 7th |
| WALL_L1_STATE | $33ef | 1 | Left | 8th |
| WALL_FL1_A_STATE | $33f0 | 1 | Front-Left A | 9th |
| WALL_FL2_B_STATE | $33f1 | 2 | Front-Left B | 10th |
| WALL_R1_STATE | $33f2 | 1 | Right | 11th |
| WALL_FR1_A_STATE | $33f3 | 1 | Front-Right A | 12th |
| WALL_FR2_B_STATE | $33f4 | 2 | Front-Right B | 13th |
| WALL_L0_STATE | $33f5 | 0 | Left | 14th |
| WALL_FL0_STATE | $33f6 | 0 | Front-Left | 15th |
| WALL_FL1_B_STATE | $33f7 | 1 | Front-Left B | 16th |
| WALL_L22_STATE | $33f8 | 2 | Far Left Corner | 17th |
| WALL_R0_STATE | $33f9 | 0 | Right | 18th |
| WALL_FR0_STATE | $33fa | 0 | Front-Right | 19th |
| WALL_FR1_B_STATE | $33fb | 1 | Front-Right B | 20th |
| WALL_R22_STATE | $33fc | 2 | Far Right Corner | 21st |
| WALL_B0_STATE | $33fd | 0 | Back | (not rendered in viewport) |

**Total**: 22 wall state variables, 21 rendered in viewport

---

## Modification Safety Analysis

### SAFE - Wall State Testing (Bit Logic)

✓ **Bit encoding is consistent across all walls**:
- Bit 0: Always hidden door flag
- Bit 1: Always wall exists flag
- Bit 2: Always door state (open/closed)

✓ **RRCA rotation pattern is invariant** - changing would break all wall logic

❌ **DO NOT** modify bit meanings or rotation order

---

### SAFE - Drawing Function Colors/Characters

✓ **Each DRAW_* function uses COLRAM/CHRRAM constants** - can modify colors/characters within functions

✓ **Rectangle sizes are well-defined** - documented in COLRAM_CHRRAM_VERIFICATION.md

⚠️ **MEDIUM RISK**: Changing rectangle sizes (may overlap or create gaps)

---

### COMPLEX - Rendering Order

⚠️ **Rendering order affects occlusion**:
- Front-to-back with strategic jumps
- Changing order requires updating all jump targets
- Must maintain depth-sorting for correct visual layering

❌ **DANGEROUS**: Reordering F0→F1→F2 sequence (breaks occlusion jumps)

---

### DANGEROUS - Wall State Calculation

❌ **Wall states calculated in REDRAW_START** (separate function, not analyzed here)

❌ **DO NOT** modify state variables directly in REDRAW_VIEWPORT

❌ **State variables must be pre-calculated before REDRAW_VIEWPORT executes**

---

## Conclusion

This truth table documents every conditional branch in REDRAW_VIEWPORT's 535-line rendering algorithm. All 22 wall positions have been mapped with exact line numbers, bit conditions, jump targets, and drawing functions.

**Key Finding**: The algorithm uses **conditional front-to-back rendering** with 7 major occlusion jumps, NOT painter's algorithm. The F0 closed wall creates the largest optimization, skipping 268 lines and 12+ wall checks.

**Documentation Status**: COMPLETE - Ready for TODO #5 (modification safety zones)

---

*Document Status: COMPLETE - All wall rendering decisions mapped*
