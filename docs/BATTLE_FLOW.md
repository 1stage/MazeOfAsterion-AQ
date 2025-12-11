# Battle Flow Documentation

## Overview
A complete melee battle exchange in MazeOfAsterion consists of a monster encountering the player, both weapons flying across the screen in sequence, damage being calculated, and health being updated. This document describes the high-level flow of a full melee encounter.

---

## Phase 1: Battle Initiation

### Trigger
- Player moves forward into a monster space (encounter check)
- OR monster surprises player during movement (random encounter)

### Monster Setup (CALC_MONSTER_HP + associated handlers)
1. Monster type ($23-$27) is validated
2. Monster base stats (HP, damage) are retrieved based on type
3. Monster HP is randomized with variance (random 0-7 reduction applied separately to spiritual and physical HP)
4. Monster sprite frame is selected (base frame + level offset 0-3)
5. Monster attack damage value is calculated and stored

### Animation Initialization (INIT_MELEE_ANIM)
1. Animation state set to **3** (player attack phase - first frame)
2. Position counter initialized to **$0206** (H=2, L=6):
   - Represents 2 monster attack frames + 1 player attack frame = 1 cycle
   - 2 complete cycles (4 monster + 2 player frames) per full animation
3. Starting position set to **$31EA** (center-right of viewport, approximately row 12, col 10)
4. Monster health display updated
5. First weapon frame drawn
6. Returns to input wait

---

## Phase 2: Weapon Animation Loop

### Main Loop (MELEE_ANIM_LOOP)
Called repeatedly from input handler during battle. Each call:

1. **Sound effect**: Play attack blip sound
2. **Load state**: Read current animation state (1 or 3) and frame counter
3. **State check**: Determine animation direction
   - State = 3 (even count): Prepare for player attack phase (move down-right)
   - State ≠ 3 (odd count): Monster attack phase (move right)

### Monster Attack Frames (State 2-3)
- **Movement**: Weapon position += 1 (moves right, 1 byte per frame)
- **Frames**: 2 frames per cycle
- **Total**: 16 frames across full animation (8 cycles × 2)
- **Direction**: Right across screen (toward original right-hand item area)

### Player Attack Frames (State 1)
- **Movement**: Weapon position += 41 (moves down-right diagonal: 1 right + 40 down)
- **Frames**: 1 frame per cycle
- **Total**: 8 frames across full animation (8 cycles × 1)
- **Direction**: Down-right toward lower-right area

### Frame Counter Tracking
- **H byte** (high): Counts complete cycles (starts at 2)
  - When L reaches 0, H is decremented
  - When H reaches 0, animation complete
- **L byte** (low): Counts frames within cycle (toggles between 6 and 2)
  - Reset to 2 after each complete cycle
  - Decremented to trigger state/direction switch

### Drawing Each Frame (MELEE_DRAW_WEAPON_FRAME)
1. Save current 4×4 background area to buffer
2. Load weapon sprite ID based on animation state
3. Draw weapon sprite at current screen position
4. Store animation timer value

### Animation Paths

**Visual Representation — CURRENT STATE Monster Weapon Animation Path**

```
🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
⬛⬛⬛⬛⬛⬛⬛⬛🔴🔴0️⃣1️⃣2️⃣🔴🔴🔴⬛⬛⬛⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
⬛⬛⬛⬛⬛⬛⬛⬛🔴🔴🔴🔴🔴3️⃣🔴🔴⬛⬛⬛⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
⬛⬛⬛⬛⬛⬛⬛⬛🔴🔴🔴🔴🔴🔴🔴🔴6️⃣⬛⬛⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
🟫🟫🟫🟫🟫🟫🟫🟫🔴🔴🔴🔴🔴🔴🔴🔴🟫🟫🟫3️⃣🟫🟫🟫🟫🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
🟫🟫🟫🟫🟫🟫🟫🟫🔴🔴🔴🔴🔴🔴🔴🔴🟫🟫🟫🟫🟫🟫4️⃣🟫🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
🟫🟫🟫🟫🟫🟫🟫🟫🔴🔴🔴🔴🔴🔴🔴🔴🟫🟫🟫🟫🟫🟫🟫🟫🔲5️⃣🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
🟫🟫🟫🟫🟫🟫🟫🟫🔴🔴🔴🔴🔴🔴🔴🔴🟫🟫🟫🟫🟫🟫🟫🟫🔲🔲🔲🔲6️⃣🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
🟫🟫🟫🟫🟫🟫🟫🟫🔴🔴🔴🔴🔴🔴🔴🔴🟫🟫🟫🟫🟫🟫🟫🟫🔲🔲🔲🔲🔲🔲🔲7️⃣🔲🔲🔲🔲🔲🔲🔲🔲
⬛⬛⬛⬛⬛⬛🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫⬛⬛⬛⬛⬛⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲▶️▶️▶️▶️
⬛🖐️🖐️🖐️🖐️⬛🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫⬛🤚🤚🤚🤚⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲▶️▶️▶️▶️
⬛🖐️🖐️🖐️🖐️⬛🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫⬛🤚🤚🤚🤚⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲▶️▶️▶️▶️
⬛🖐️🖐️🖐️🖐️⬛🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫⬛🤚🤚🤚🤚⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲▶️▶️▶️▶️
⬛🖐️🖐️🖐️🖐️⬛🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫🟫⬛🤚🤚🤚🤚⬛🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲🔲
```

 Legend: 
 - ⬛🟫 Viewport Background (ceiling/floor)
 - 🖐️ Left Hand Item
 - 🤚 Right Hand Item
 - ▶️ Right Hand Item (CURRENT position in UI)
 - 🔴 S1 Monster
 - 🔲 UI Area
 - 0️⃣1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣ Weapon Animation Indexes, each render step

### Frame Trace (code-derived)
- INIT_MELEE_ANIM draws the first frame at **$31EA** (row 12, col 10) before call #1 enters the loop.

| Call | State In | Branch | Counter After (H,L) | Position Before | Draw Position |
| ---: | :------- | :----- | :------------------ | :-------------- | :------------ |
| 0 | - | - | - | - | $31EA |
| 1 | 3 | +1 (small) | 0206 | $31EA | $31EB |
| 2 | 2 | +1 (small) | 0206 | $31EB | $31EC |
| 3 | 1 | +$29 (large) | 0205 | $31EC | $3215 |
| 4 | 3 | +1 (small) | 0205 | $3215 | $3216 |
| 5 | 2 | +1 (small) | 0205 | $3216 | $3217 |
| 6 | 1 | +$29 (large) | 0204 | $3217 | $3240 |
| 7 | 3 | +1 (small) | 0204 | $3240 | $3241 |
| 8 | 2 | +1 (small) | 0204 | $3241 | $3242 |
| 9 | 1 | +$29 (large) | 0203 | $3242 | $326B |
| 10 | 3 | +1 (small) | 0203 | $326B | $326C |
| 11 | 2 | +1 (small) | 0203 | $326C | $326D |
| 12 | 1 | +$29 (large) | 0202 | $326D | $3296 |
| 13 | 3 | +1 (small) | 0202 | $3296 | $3297 |
| 14 | 2 | +1 (small) | 0202 | $3297 | $3298 |
| 15 | 1 | +$29 (large) | 0201 | $3298 | $32C1 |
| 16 | 3 | +1 (small) | 0201 | $32C1 | $32C2 |
| 17 | 2 | +1 (small) | 0201 | $32C2 | $32C3 |
| 18 | 1 | +$29 (large) | 0102 | $32C3 | $32EC |
| 19 | 3 | +1 (small) | 0102 | $32EC | $32ED |
| 20 | 2 | +1 (small) | 0102 | $32ED | $32EE |
| 21 | 1 | +$29 (large) | 0101 | $32EE | $3317 |
| 22 | 3 | +1 (small) | 0101 | $3317 | $3318 |
| 23 | 2 | +1 (small) | 0101 | $3318 | $3319 |
| 24 | 1 | Stop (H,L→0000) | 0000 | $3319 | — (FINISH_AND_APPLY_DAMAGE, no draw) |

Notes:
- Last on-screen draw from the loop is at **$3319** (row 19, col 33).

---

## Phase 3: Damage Calculation & Application

### Animation Completion
When frame counter reaches 0 (both H and L bytes = 0):
- Call **FINISH_AND_APPLY_DAMAGE**
- Restore final background from buffer (erase weapon sprite)

### Damage Calculation (ACCUM_DAMAGE_LOOP)
1. Load base weapon damage from **WEAPON_VALUE_HOLDER**
2. Load iteration count from **MULTIPURPOSE_BYTE** (determines multiplier)
3. Multiply damage using BCD arithmetic:
   - Repeat addition of base damage × iteration count
   - Apply DAA (decimal adjust) after each addition
   - Result in A register

### Target Determination (FINISH_AND_APPLY_DAMAGE)
Check **MELEE_WEAPON_SPRITE** to determine who takes damage:
- **$24-$27**: Monster attacking player
  - Player is damage target
  - Apply shield defense calculation
  - Apply damage to player physical/spiritual health
- **Other values**: Player attacking monster
  - Monster is damage target
  - Apply damage to monster physical/spiritual health

### Shield Defense (if player is target)
1. Load player's spiritual shield value
2. Calculate shield effectiveness roll:
   - Divide incoming damage by 2
   - Add randomized variance (BCD nybble randomization)
   - Subtract shield value
3. If result is negative (blocked): Reduce damage, sound effect
4. If result is positive: Apply as-is

### Health Application
1. **Monster damage path**: Subtract from monster HP (spiritual or physical based on weapon type)
2. **Player damage path**: Subtract from player HP (spiritual or physical)
3. Update health displays (both player and monster status)
4. Check for death:
   - If monster health ≤ 0: Victory → Item reward, return to normal play
   - If player health ≤ 0: Defeat → Game over sequence

---

## Phase 4: Return to Input

After damage applied and displays updated:
- Return to **WAIT_FOR_INPUT**
- Player can continue dungeon exploration or engage in another battle

---

## Data Structures

### Key Memory Locations
- **MELEE_ANIM_STATE** ($020D): Current animation state (1 or 3)
- **MONSTER_ATT_POS_COUNT** ($0206): Frame counter (H=cycles, L=frames)
- **WEAPON_SPRITE_POS_OFFSET** ($31EA): Current screen position of weapon
- **WEAPON_VALUE_HOLDER**: Damage value for this attack
- **MELEE_WEAPON_SPRITE**: Sprite ID (determines which weapon and damage target)
- **MULTIPURPOSE_BYTE**: Iteration count (damage multiplier)
- **CURR_MONSTER_PHYS** / **CURR_MONSTER_SPRT**: Current monster HP
- **PLAYER_PHYS_HEALTH** / **PLAYER_SPRT_HEALTH**: Current player HP
- **SHIELD_SPRT**: Player's spiritual shield defense value

### Screen Position Math
- CHRRAM base: $3000
- Viewport width: 40 bytes per row ($28)
- Starting position: $31EA (relative offset from CHRRAM base)
- Monster stride: +1 (right, 1 cell)
- Player stride: +41 (down-right: 40 + 1)

---

## Animation Timing

### Frame Sequencing (High-Level)
```
Cycle 1-8:
  - 2 monster frames (stride +1 each) → move right
  - 1 player frame (stride +41) → move down-right
  - Repeat 8 times
Total: 16 monster frames + 8 player frames = 24 frames
```

### Screen Position Progression
- **Monster phase**: Position advances 1 byte per frame × 16 frames = 16 bytes right
- **Player phase**: Position advances 41 bytes per frame × 8 frames = 328 bytes down-right
- **Total displacement**: Right ~16 bytes, down ~328 bytes (moves from center toward lower-right)

---

## Important Notes on Naming

**Label refactoring completed Dec 11, 2025:**

Variables and routines have been renamed for clarity:

- **`WEAPON_SPRITE_POS_OFFSET`** - Shared position variable for all weapon animation phases. Stores the current screen position where the weapon sprite is drawn, regardless of whether it's a monster or player attack phase.

- **`MELEE_ANIM_SMALL_STEP`** - Animation routine that advances weapon position by +1 (small stride, horizontal movement). Executes during animation states 3 and 2.

- **`MELEE_ANIM_LARGE_STEP`** - Animation routine that advances weapon position by +41 (large stride, diagonal down-right movement). Executes during animation state 1.

- **`MELEE_WEAPON_SPRITE`** - Stores the weapon sprite ID that determines both which sprite graphic is drawn during animation AND who is the damage target ($24-$27 = monster attacking player; other values = player attacking monster).

**Historical context**: Original names reflected an incomplete understanding from early development/reverse engineering. The animation system uses a single shared position variable that advances continuously throughout both attack phases, with different sprites drawn based on `MELEE_WEAPON_SPRITE`. Both phases use ADD operations to move the position forward.

---

## Future Enhancements / Notes

- Monster attack animation direction can be adjusted by changing stride value in `MELEE_ANIM_SMALL_STEP`
- Player attack animation direction can be adjusted by changing stride value in `MELEE_ANIM_LARGE_STEP`
- Player attack can be skipped in one-sided battles (surprise attacks) by modifying animation state initialization
- Damage multiplier (MULTIPURPOSE_BYTE) can vary based on weapon type, player level, or other factors
- Animation frame count ($0206) can be adjusted to speed up or slow down battles
