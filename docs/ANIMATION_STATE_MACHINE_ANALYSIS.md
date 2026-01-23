# Animation State Machine Analysis

**Date:** December 12, 2025  
**Tracing:** HL register progression through complete battle sequence  
**Scope:** Monster weapon animation, player weapon animation, and interaction patterns

---

## Executive Summary

**Verified from trace data (RD, WP, Str, HL):**

The battle animation system renders **two weapon sprites** that advance through the screen using different stride patterns:

1. **Stride Selection:** Movement alternates between single-cell steps (+1 or -1) and larger diagonal jumps (+41 or -41)
2. **Stride Rhythm:** Larger jumps occur at predictable intervals (every 3 RD rows based on verified stride data)
3. **Position Accumulation:** Both sprites use a shared screen-offset model, with player moving backward and monster moving forward
4. **Sprite Sequence:** 28 distinct rendering positions across the full animation

**Architectural Pattern (requires code verification):**

The stride rhythm suggests an internal **frame counter with prescaler logic** that gates between two movement rates. However, to confirm the mechanism (state machine, counter variables, etc.), actual assembly code examination is required. The verified trace data alone establishes the timing and stride patterns.

---

## Part 1: Core Animation Variables

### Three-Variable System

```
MONSTER_ATT_POS_COUNT ($0206)
├─ H byte: Cycle counter (starts $02 = 2 cycles)
└─ L byte: Frame counter within cycle (toggles $06 ↔ $02)

WEAPON_SPRITE_POS_OFFSET ($31EA initially)
└─ Screen-relative position offset into CHRRAM
   Direction: increases when moving down-right, decreases when moving up-left

MELEE_ANIM_STATE (initially $03)
└─ State ID: 1 (monster large step) or 3 (player small step)
   Determines which ADD/SUB operation executes
```

### HL Register Movement in Trace

Looking at the BATTLE_FLOW trace table, the HL column shows:

| RD | HL Value | Change | State |
|----|----------|--------|-------|
| 0  | $327B    | init   | - |
| 0  | $3122    | init   | - |
| 1  | $327A    | -1     | 3 |
| 1  | $3122    | +0     | 3 |
| 2  | $3279    | -1     | 2 |
| 2  | $3124    | +1     | 2 |
| 3  | $3250    | -41    | 1 |
| 3  | $314D    | +41    | 1 |

**Key observation:** The player weapon moves backward (`-1`, `-41`) while monster moves forward (`+1`, `+41`), using the **same accumulator variable** (WEAPON_SPRITE_POS_OFFSET).

---

## Part 2: State Machine Logic

### MONSTER_WEAPON_ANIM_STEP Breakdown

From [asterion_high_rom.asm](src/asterion_high_rom.asm#L1116):

```asm
MONSTER_WEAPON_ANIM_STEP:
    CALL        SOUND_05                            ; Play attack sound
    LD          A,(MELEE_ANIM_STATE)                ; Load state (1 or 3)
    LD          HL,(MONSTER_ATT_POS_COUNT)          ; Load frame counter
    DEC         A                                   ; Decrement state: 1→0 or 3→2
    JP          NZ,MELEE_ANIM_SMALL_STEP            ; If A≠0 (state was 3), use +1 stride
                                                    ; If A=0 (state was 1), fall through
    DEC         L                                   ; Decrement L byte (frame counter)
    JP          NZ,MELEE_ANIM_LARGE_STEP            ; If L≠0, use +41 stride
    DEC         H                                   ; L reached 0: decrement H (cycle counter)
    JP          Z,FINISH_AND_APPLY_DAMAGE           ; If both=0, animation done
    LD          A,$32                               ; Set monster CHRRAM high byte
    LD          (MN_WPN_CHRRAM_ADDR_HI),A
    LD          L,0x2                               ; Reset L to 2
    
MELEE_ANIM_LARGE_STEP:
    LD          A,0x3                               ; Set state to 3 (player phase)
    LD          (MELEE_ANIM_STATE),A
    LD          (MONSTER_ATT_POS_COUNT),HL          ; Save frame counter
    LD          HL,(WEAPON_SPRITE_POS_OFFSET)       ; Load position
    LD          BC,$29                              ; BC = 41 ($29)
    ADD         HL,BC                               ; Position += 41
    LD          (WEAPON_SPRITE_POS_OFFSET),HL       ; Save new position
    JP          DRAW_MONSTER_WEAPON_FRAME           ; Draw weapon
    
MELEE_ANIM_SMALL_STEP:
    LD          (MELEE_ANIM_STATE),A                ; Store state (decremented)
    LD          HL,(WEAPON_SPRITE_POS_OFFSET)       ; Load position
    INC         HL                                  ; Position += 1
    LD          (WEAPON_SPRITE_POS_OFFSET),HL       ; Save new position
    ; (Falls through to DRAW_MONSTER_WEAPON_FRAME)
```

### State Transitions

**Initial State:** `MELEE_ANIM_STATE = $03`, `MONSTER_ATT_POS_COUNT = $0206`

**Cycle Pattern (per call to MONSTER_WEAPON_ANIM_STEP):**

| Call | A after DEC | L→0? | Path | CHRRAM Stride | MELEE_ANIM_STATE after | L value after |
|------|-------------|------|------|---------------|----------------------|-----------------|
| 1 | $02 | NZ | SMALL_STEP | +1 | $02 | $06 |
| 2 | $02 | NZ | SMALL_STEP | +1 | $02 | $05 |
| 3 | $02 | NZ | SMALL_STEP | +1 | $02 | $04 |
| 4 | $02 | NZ | SMALL_STEP | +1 | $02 | $03 |
| 5 | $02 | NZ | SMALL_STEP | +1 | $02 | $02 |
| 6 | $02 | NZ | SMALL_STEP | +1 | $02 | $01 |
| 7 | $02 | Z | LARGE_STEP | +41 | $03 | $02 |

So the **state machine cycles between**:

- **States 3→2** (via `DEC A` when `MELEE_ANIM_STATE=$03`): Uses `MELEE_ANIM_SMALL_STEP` (+1)
- **States 1→0** (via `DEC A` when `MELEE_ANIM_STATE=$01`): Uses `MELEE_ANIM_LARGE_STEP` (+41)

The **L byte acts as a prescaler**: it counts down 6→5→...→1→0, and when it hits 0, the next call resets it to 2 and increments the state. Every 7th call, **`DEC L; JP NZ` will take the LARGE_STEP path**.

---

## Part 3: Player Animation Path (DRAW_PLAYER_WEAPON_FRAME)

From [asterion_high_rom.asm](src/asterion_high_rom.asm#L633):

```asm
DRAW_PLAYER_WEAPON_FRAME:
    CALL        SOUND_05                            ; Play animation sound
    LD          A,(ITEM_ANIM_STATE)                 ; Load item animation state
    LD          HL,(ITEM_ANIM_LOOP_COUNT)           ; Load loop counters
    DEC         A                                   ; Decrement state
    JP          NZ,ADVANCE_RH_ANIM_FRAME            ; If non-zero, advance frame
    DEC         L                                   ; Decrement inner loop (L byte)
    JP          NZ,RESET_RH_ANIM_STATE              ; If not zero, refresh state
    DEC         H                                   ; Decrement outer loop (H byte)
    JP          Z,ITEM_COMBAT_DISPATCH              ; If zero, animation complete
    LD          A,$31                               ; Player weapon CHRRAM row base
    LD          (PL_WPN_CHRRAM_ADDR_HI),A
    LD          L,0x4                               ; Reset inner counter to 4
    
RESET_RH_ANIM_STATE:
    LD          A,0x4                               ; Reset state to 4
    LD          (ITEM_ANIM_STATE),A
    LD          (ITEM_ANIM_LOOP_COUNT),HL
    LD          HL,(ITEM_ANIM_CHRRAM_PTR)           ; Load CHRRAM pointer
    LD          BC,$29                              ; BC = 41 bytes
    XOR         A
    SBC         HL,BC                               ; Pointer -= 41 (move backward)
    LD          (ITEM_ANIM_CHRRAM_PTR),HL
    JP          COPY_RH_ITEM_FRAME_GFX
    
ADVANCE_RH_ANIM_FRAME:
    LD          (ITEM_ANIM_STATE),A
    LD          HL,(ITEM_ANIM_CHRRAM_PTR)
    DEC         HL                                  ; Move pointer left by 1 byte
    LD          (ITEM_ANIM_CHRRAM_PTR),HL
```

**Key differences from monster path:**
- Uses **ITEM_ANIM_STATE** (separate from MELEE_ANIM_STATE)
- Initial state is likely $04, resets L to $04 (not $02)
- **Position moves backward** via `SBC HL, $29` (−41 bytes)
- **Single-byte movement** via `DEC HL` (−1 byte)
- Different CHRRAM base: $31 (player row) vs $32 (monster row)

---

## Part 4: Dual-Draw System (First Half)

### TIMER_UPDATED_CHECK_INPUT Loop

From [asterion_high_rom.asm](src/asterion_high_rom.asm#L2763):

```asm
TIMER_UPDATED_CHECK_INPUT:
    ; ... state checks ...
    
MONSTER_ANIM_TICK:
    LD          HL,MASTER_TICK_TIMER
    LD          A,(MONSTER_ANIM_TIMER_COPY)
    CP          (HL)                                ; Has timer advanced?
    JP          NZ,WAIT_FOR_INPUT                   ; No → skip this frame
    
    CALL        MELEE_RESTORE_BG_FROM_BUFFER        ; Erase previous weapon sprite
    CALL        COPY_ITEM_GFX_TO_CHRRAM             ; Update item blink state
    CALL        DRAW_PLAYER_WEAPON_FRAME            ; Draw player weapon (Draw 1)
    CALL        MONSTER_WEAPON_ANIM_STEP            ; Draw monster weapon (Draw 2)
    JP          WAIT_FOR_INPUT
```

**Each animation frame executes:**

1. **Erase:** `MELEE_RESTORE_BG_FROM_BUFFER` — restores saved background under melee sprite
2. **Item blink:** `COPY_ITEM_GFX_TO_CHRRAM` — handles RH item animation state
3. **Draw player weapon:** `DRAW_PLAYER_WEAPON_FRAME` → advances player position, draws at new location
4. **Draw monster weapon:** `MONSTER_WEAPON_ANIM_STEP` → advances monster position, draws at new location

**Order matters:** Monster draw is **second**, so it overlays the player weapon at overlap points.

---

## Part 5: Rhythm & Pattern

### Why +41 Jumps at Predictable Intervals

From your HL trace, +41 strides occur at RD: 3, 6, 9, 12, 15, 18, 21, 24 → **every 3 rows**.

This is because:

```
MONSTER_ATT_POS_COUNT.L starts at $06

Call 1: DEC L → $05 (NZ) → SMALL_STEP
Call 2: DEC L → $04 (NZ) → SMALL_STEP
Call 3: DEC L → $03 (NZ) → SMALL_STEP
Call 4: DEC L → $02 (NZ) → SMALL_STEP
Call 5: DEC L → $01 (NZ) → SMALL_STEP
Call 6: DEC L → $00 (Z)  → LARGE_STEP, then reset L to $02
Call 7: DEC L → $01 (NZ) → SMALL_STEP
Call 8: DEC L → $00 (Z)  → LARGE_STEP, then reset L to $02
```

So every 6 calls, one uses the LARGE_STEP. But the rhythm depends on **how many times `MONSTER_WEAPON_ANIM_STEP` is called per animation cycle**.

From the trace, **both player and monster paths call their respective advance routines each frame**. Looking at the pattern:

- RD 0-1: Calls 1-2
- RD 1-2: Calls 3-4  (wait, RD 1 has TWO weapons drawn...)
- RD 2-3: Calls 5-6 → First LARGE_STEP (RD 3)

So the rhythm is **every 3 RD rows = 6 total weapon draws** (3 player + 3 monster per 2 cycles).

---

## Part 6: Frame Counter & Cycle Logic

### Starting State

```
INIT_MELEE_ANIM:
    LD          HL,$206                    ; HL = $0206
    LD          (MONSTER_ATT_POS_COUNT),HL ; H=$02 (2 cycles), L=$06 (6 frames)
    LD          HL,$31ea
    LD          (WEAPON_SPRITE_POS_OFFSET),HL
```

### Ending Condition

When `H=0` AND `L=0` (both bytes decremented to 0), the animation completes:

```asm
    DEC         H
    JP          Z,FINISH_AND_APPLY_DAMAGE
```

### Total Frames Calculation

With initial `H=$02, L=$06`:

- **Cycle 1:** L counts down 6→5→4→3→2→1→0 = 7 decrements
  - Calls to MONSTER_WEAPON_ANIM_STEP: 7 (each decrements L)
  - Calls to DRAW_PLAYER_WEAPON_FRAME: 7 (implied, dual-draw)

- **Cycle 2:** H decrements from $02→$01, L resets to $02, counts 2→1→0 = 3 decrements
  - Calls: 3 each

- **Total calls:** 7 + 3 = 10 monster weapon steps, 10 player weapon steps

But wait—looking at your trace table, RD goes up to 27, which is far more than 10. This suggests:

**The initial value $206 might mean something else:**
- $02 = high byte (cycle/iteration counter for a loop)
- $06 = low byte (frames within cycle)

Or the animation runs **multiple times** with slightly different starting conditions.

---

## Part 7: Insights from Verified Trace Data

### Verified Observations from HL, RD, WP, and Str Columns

The following are derived from the verified data points (RD, WP, Str, HL):

1. **Stride Selection Pattern:**
   - Strides of +1 or -1 represent single-cell movement
   - Strides of +41 or -41 represent diagonal movement (40 down + 1 horizontal)
   - Pattern: Predominantly single-cell moves, with larger jumps interspersed at regular intervals

2. **Position Accumulation (HL):**
   - Player weapon HL values decrease overall (moving backward/upward)
   - Monster weapon HL values increase overall (moving forward/downward)
   - Both use the same screen-offset calculation model

3. **Stride Rhythm (from Verified Data):**
   - +41 strides occur at RD: 3, 6, 9, 12, 15, 18, 21, 24 (every 3 RD rows)
   - This rhythm is predictable and could be driven by an internal counter (like the L-byte prescaler)

**Note on Routine Flow Column:**
The Routine Flow column in the trace was generated during previous documentation and should be verified against the actual assembly code before making architectural conclusions based on it. The verified data (RD, WP, Str, HL) is sufficient to understand the animation mechanics without relying on Routine Flow accuracy.

### HL Movement Patterns

Player weapon HL:
```
$327B → $327A → $3279 → $3250 → $324F → $324E → $324D → $3224 → ...
        -1      -1      -41     -1      -1      -1      -41
```

Monster weapon HL:
```
$3122 → $3122 → $3124 → $314D → $314E → $314F → $3178 → $3179 → ...
        +0      +1      +41     +1      +1      +41     +1
```

**Observation:** 
- Player: Strides of -1, -41, -1, -1, -1, -41 (pattern repeats)
- Monster: Strides of +1, +41, +1, +1, +41, +1, +1 (pattern repeats)

The **+41 appears every 3-4 small moves**, which aligns with the L-byte decrement logic.

---

## Part 8: Recommendations for Code Clarity

Based on this analysis, the routines could be documented more explicitly:

### 1. Add Stride Selection Comments
In `MONSTER_WEAPON_ANIM_STEP`:

```asm
    DEC         L                           ; L was $06; now $05
    JP          NZ,MELEE_ANIM_SMALL_STEP    ; Stride +1 selected (6 calls to accumulate for LARGE_STEP)
    ; ... when L reaches 0, LARGE_STEP with +41 stride is used next
```

### 2. Document Frame Counter Interpretation
In `INIT_MELEE_ANIM`:

```asm
    LD          HL,$206
    ; H=$02 = Number of "full cycles" before animation completes
    ;         (Each cycle has both SMALL_STEP and LARGE_STEP phases)
    ; L=$06 = Frames within current cycle (6 small steps before 1 large step)
    LD          (MONSTER_ATT_POS_COUNT),HL
```

### 3. Add State Machine Truth Table
Near `MELEE_ANIM_STATE` usage, add a comment block:

```
; MELEE_ANIM_STATE Behavior:
;   State $01: SMALL_STEP (+1 stride), next→$02
;   State $03: SMALL_STEP (+1 stride), next→$02
;   After L→0: Reset L to $02, toggle state to $03 (for next cycle)
;   After H→0: Animation complete, jump to FINISH_AND_APPLY_DAMAGE
```

---

## Part 9: Summary Table

| Component | Purpose | Key Values | Update Rate |
|-----------|---------|-----------|-------------|
| `MONSTER_ATT_POS_COUNT.H` | Cycle counter | $02→$01→$00 | Decremented when L reaches 0 |
| `MONSTER_ATT_POS_COUNT.L` | Frame counter | $06→$05→...→$00→$02 (reset) | Decremented every call |
| `WEAPON_SPRITE_POS_OFFSET` | Screen position | $31EA + (stride × frame) | Updated each call |
| `MELEE_ANIM_STATE` | State selector | $01 (LARGE) or $03 (SMALL) | Toggled when L=0 |
| `ITEM_ANIM_STATE` | Player animation state | $04 (startup), varies | Separate from melee state |

---

## Conclusion

**From verified trace data (RD, WP, Str, HL):**

The animation system exhibits a clear, predictable rhythm in stride selection:
- Single-cell moves dominate the animation
- Larger 41-byte jumps occur every 3 RD rows
- Both sprites advance in alternating directions using the same offset calculation model
- This pattern repeats consistently across all 28 animation frames

**What requires code verification:**

The exact mechanism driving this rhythm (whether it's a prescaler counter like the L-byte hypothesis, or a different gating mechanism) must be confirmed by examining:
1. How `MONSTER_ATT_POS_COUNT` or similar variables are initialized and updated
2. Whether separate loop counters track the player and monster animation independently
3. How the stride selection (+1 vs +41) is actually decided on each frame

The trace pattern alone is insufficient to determine the code's internal logic, but it does provide a strong baseline for what behavior to expect once the assembly is verified.
