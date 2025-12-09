# Items & Monsters Reference

Last updated: 2025-12-06

This document catalogs item and monster codes, their color/level encoding, behaviors, placement, and rendering as implemented in the assembly source.

## Encoding Basics

Item/monster bytes encode a baseline type with a 2-bit level/color modifier:
- Bits 0–1: Level/Color (00=RED, 01=YELLOW, 10=MAGENTA, 11=WHITE). Each item/monster type occupies a 4-wide block.
- Higher bits: Base type discriminator often compared after shifting right twice (e.g., `SRL` twice in `DO_USE_ATTACK`).
- Some objects (ladder, maps, monsters) have special ranges or singletons for fast logic checks.
- `$FE` is the sentinel for empty map space (NEW_RETURN_EMPTY_SPACE).
- `$FF` is the terminator byte for the sparse item table at `$3900` and is never a valid item/monster code.

## Code Groups (baseline + color in bits 0–1)

A new line is listed for every 4-value group. The Compare column shows the value after shifting right twice (>>2), which is what many branches compare against. Names align with entries and ordering in `src/asterion_gfx_pointers.asm` and comments in `src/asterion_gfx.asm`.

| Codes      | Compare | Name            | Colors                 | Notes |
|------------|---------|-----------------|------------------------|-------|
| `00–03`    | `00`    | Buckler         | RED, YEL, MAG, WHT     | Small left-hand shield. |
| `04–07`    | `01`    | Ring            | RED, YEL, MAG, WHT     | Auto-wear enchant; replaces weaker ring. |
| `10–13`    | `04`    | Pavise          | RED, YEL, MAG, WHT     | Large left-hand shield. |
| `18–1B`    | `06`    | Bow             | RED, YEL, MAG, WHT     | Starting right-hand `$18` (RED). |
| `1C–1F`    | `07`    | Scroll          | RED, YEL, MAG, WHT     | Magical attack item. |
| `20–23`    | `08`    | Axe             | RED, YEL, MAG, WHT     | Throwing melee weapon. |
| `24–27`    | `09`    | Fireball        | RED, YEL, MAG, WHT     | Thrown magical attack. |
| `28–2B`    | `0A`    | Mace            | RED, YEL, MAG, WHT     | Throwing melee weapon. |
| `2C–2F`    | `0B`    | Staff           | RED, YEL, MAG, WHT     | Advanced magical weapon. |
| `30–33`    | `0C`    | Crossbow        | RED, YEL, MAG, WHT     | Advanced physical ranged. |
| `42`       | `10`    | Ladder          | MAG (singleton)        | First entry in `$3900` as `[pos,$42]`. |
| `44–47`    | `11`    | Chest           | RED, YEL, MAG, WHT     | Opens into loot (treasure/potion/map/key). |
| `48–4B`    | `12`    | Food            | RED, YEL, MAG, WHT     | Increases FOOD_INV (BCD corrected). |
| `4C–4F`    | `13`    | Quiver          | RED, YEL, MAG, WHT     | Increases ARROW_INV (cap `$33`). |
| `50–53`    | `14`    | Locked Chest    | RED, YEL, MAG, WHT     | Requires key. |
| `54–57`    | `15`    | Amulet          | RED, YEL, MAG, WHT     | Trinket/treasure. |
| `58–5B`    | `16`    | Key             | RED, YEL, MAG, WHT     | Used by `DO_USE_KEY`. |
| `5C–5F`    | `17`    | Chalice         | RED, YEL, MAG, WHT     | Trinket/treasure. |
| `64–67`    | `19`    | Warrior Potion  | RED, YEL, MAG, WHT     | Physical stat effect. |
| `68–6B`    | `1A`    | Mage Potion     | RED, YEL, MAG, WHT     | Spirit stat effect. |
| `6C–6F`    | `1B`    | Map             | RED, YEL, MAG, WHT     | Sets HAVE MAP; colors show in UI. |
| `70–73`    | `1C`    | Chaos Potion    | RED, YEL, MAG, WHT     | Special effects cluster. |
| `DE–DF`    | `37`    | Map (hi-tier)   | PUR, WHT               | Also treated as maps in logic. |

Notes:
- Post-shift compares seen in logic map CHEST→`$11`, KEY→`$16`, PHYS POTION→`$19`, SPRT POTION→`$1A`, CHAOS POTION→`$1C` after removing color bits.
- Boundaries in pickup code (`CP $48`, `CP $50`, `CP $5C`, `CP $64`) align with group starts above.

## Monster Codes (4-wide groups; `>= $78` blocks movement)

Verified from pointer ordering (`asterion_gfx_pointers.asm`) and combat initialization code (`INIT_MONSTER_COMBAT` at lines 6000–6400, `asterion_high_rom.asm`). 

**Movement Blocking:** The code checks `ITEM_F1 + 2 >= $7A`, which means original codes `>= $78` block forward movement (line 377: `FW_WALLS_CLEAR_CHK_MONSTER`).

**Monster Type Codes (after right-shift 2):** Skeleton=$1E, Snake=$1F, Spider=$20, Mimic=$21, Malocchio=$22, Dragon=$23, Mummy=$24, Necromancer=$25, Gryphon=$26, Minotaur=$27.

**HP Format:** H=SPRT, L=PHYS in BCD (e.g., $304 = 3 SPRT, 4 PHYS).

**Damage Calculation:** Base damage × (level+1) where level extracted from bits 0-1 (RED=0, YEL=1, MAG=2, WHT=3). Formula in `CALC_WEAPON_VALUE` (line 6300): `((base × (level+1)) - random_0_to_7 + dungeon_bonus)` with BCD arithmetic.

**HP Randomization:** Each HP component (SPRT and PHYS) independently reduced by random 0-7 from `GET_RANDOM_0_TO_7` using screen saver timer masked with $07.

### Skeletons

| Code | Compare | Monster  | Color | Attack Dmg | SPRT HP | PHYS HP |
|------|---------|----------|-------|------------|---------|---------|
| `78` | `1E`    | Skeleton | RED   | 7          | 3       | 04      |
| `79` | `1E`    | Skeleton | YEL   | 14         | 3       | 04      |
| `7A` | `1E`    | Skeleton | MAG   | 21         | 3       | 04      |
| `7B` | `1E`    | Skeleton | WHT   | 28         | 3       | 04      |

### Snakes

| Code | Compare | Monster | Color | Attack Dmg | SPRT HP | PHYS HP |
|------|---------|---------|-------|------------|---------|---------|----------|
| `7C` | `1F`    | Snake   | RED   | 3          | 1       | 01      |
| `7D` | `1F`    | Snake   | YEL   | 6          | 1       | 01      |
| `7E` | `1F`    | Snake   | MAG   | 9          | 1       | 01      |
| `7F` | `1F`    | Snake   | WHT   | 12         | 1       | 01      |

### Spiders

| Code | Compare | Monster | Color | Attack Dmg | SPRT HP | PHYS HP |
|------|---------|---------|-------|------------|---------|---------|----------|
| `80` | `20`    | Spider  | RED   | 4          | 0       | 02      |
| `81` | `20`    | Spider  | YEL   | 8          | 0       | 02      |
| `82` | `20`    | Spider  | MAG   | 12         | 0       | 02      |
| `83` | `20`    | Spider  | WHT   | 16         | 0       | 02      |

### Mimics

| Code | Compare | Monster | Color | Attack Dmg | SPRT HP | PHYS HP |
|------|---------|---------|-------|------------|---------|---------|----------|
| `84` | `21`    | Mimic   | RED   | 5          | 2       | 03      |
| `85` | `21`    | Mimic   | YEL   | 10         | 2       | 03      |
| `86` | `21`    | Mimic   | MAG   | 15         | 2       | 03      |
| `87` | `21`    | Mimic   | WHT   | 20         | 2       | 03      |

### Malocchi

| Code | Compare | Monster   | Color | Attack Dmg | SPRT HP | PHYS HP |
|------|---------|-----------|-------|------------|---------|---------|----------|
| `88` | `22`    | Malocchio | RED   | 3          | 3       | 02      |
| `89` | `22`    | Malocchio | YEL   | 6          | 3       | 02      |
| `8A` | `22`    | Malocchio | MAG   | 9          | 3       | 02      |
| `8B` | `22`    | Malocchio | WHT   | 12         | 3       | 02      |

### Dragons

| Code | Compare | Monster | Color | Attack Dmg | SPRT HP | PHYS HP |
|------|---------|---------|-------|------------|---------|---------|----------|
| `8C` | `23`    | Dragon  | RED   | 8          | 4       | 05      |
| `8D` | `23`    | Dragon  | YEL   | 16         | 4       | 05      |
| `8E` | `23`    | Dragon  | MAG   | 24         | 4       | 05      |
| `8F` | `23`    | Dragon  | WHT   | 32         | 4       | 05      |

### Mummies

| Code | Compare | Monster | Color | Attack Dmg | SPRT HP | PHYS HP |
|------|---------|---------|-------|------------|---------|---------|----------|
| `90` | `24`    | Mummy   | RED   | 6          | 2       | 04      |
| `91` | `24`    | Mummy   | YEL   | 12         | 2       | 04      |
| `92` | `24`    | Mummy   | MAG   | 18         | 2       | 04      |
| `93` | `24`    | Mummy   | WHT   | 24         | 2       | 04      |

### Necromancers

| Code | Compare | Monster     | Color | Attack Dmg | SPRT HP | PHYS HP |
|------|---------|-------------|-------|------------|---------|---------|----------|
| `94` | `25`    | Necromancer | RED   | 19         | 5       | 05      |
| `95` | `25`    | Necromancer | YEL   | 38         | 5       | 05      |
| `96` | `25`    | Necromancer | MAG   | 57         | 5       | 05      |
| `97` | `25`    | Necromancer | WHT   | 76         | 5       | 05      |

### Gryphons

| Code | Compare | Monster | Color | Attack Dmg | SPRT HP | PHYS HP |
|------|---------|---------|-------|------------|---------|---------|----------|
| `98` | `26`    | Gryphon | RED   | 4          | 4       | 05      |
| `99` | `26`    | Gryphon | YEL   | 8          | 4       | 05      |
| `9A` | `26`    | Gryphon | MAG   | 12         | 4       | 05      |
| `9B` | `26`    | Gryphon | WHT   | 16         | 4       | 05      |

### Minotaur (Boss)

| Code | Compare | Monster  | Color | Attack Dmg | SPRT HP | PHYS HP |
|------|---------|----------|-------|------------|---------|---------|----------|
| `9F` | `27`    | Minotaur | WHT   | 17 (special) | 4     | 05      |

- ITEM_DRAW renders monsters via the same path; forward movement is blocked when `ITEM_F1 + 2 >= $7A`, which is equivalent to original code `>= $78` (Skeleton RED and all higher).
- Minotaur always spawns as WHITE (`$9F`) only; defeating it wins the game. 
- **Minotaur Special Calculation (CHK_FOR_MINOTAUR, line 6220):**
  - Base damage: $11 (17 BCD), base HP: $405 (4 SPRT, 5 PHYS)
  - Special player-stat-based HP boost calculation using alternate registers
  - Sprite selection based on player survivability: $24 (physical/red) if player would survive, $3C (spiritual/purple) if mercy needed
  - Attack damage shown (17) is base before level multiplication - actual damage calculated via CALC_WEAPON_VALUE
- HP values shown are **base values before randomization**. Actual HP at spawn = base - random(0-7) for each component independently.
- Attack damage values shown are **after level multiplication** (RED=×1, YEL=×2, MAG=×3, WHT=×4) but before randomization and dungeon bonus.

**Monster Color/Strength Mechanics:**

The color bits (0–1) directly affect monster capabilities. During combat initialization (`INIT_MONSTER_COMBAT`, lines 6000–6400, `asterion_high_rom.asm`):

1. Each monster type has base damage (D register) and HP values (HL pair: H=SPRT, L=PHYS, BCD format)
2. Color bits extracted to B register via bit shifts (0=RED, 1=YEL, 2=MAG, 3=WHT)
3. `CALC_WEAPON_VALUE` (line 6300) multiplies base damage by (B+1) using BCD math loop
4. Formula: `damage = base_damage × (level+1) - random_0_to_7 + dungeon_level_bonus` (all BCD)
5. HP randomization uses `GET_RANDOM_0_TO_7`: reads screen saver timer, masks with $07, subtracts from each HP component independently via `WRITE_HP_TRIPLET`

**Result:** Higher color tier = stronger monster. WHITE (bits=11) multiplies base damage ×4 compared to RED (bits=00) at ×1. YEL and MAG provide ×2 and ×3 respectively. Deeper dungeon levels further increase damage via `+C` bonus calculated from `DUNGEON_LEVEL` BCD digits.

### Difficulty & Boss Spawn Threshold

Difficulty selection on the title screen stores a raw value (0–3) in `INPUT_HOLDER` (not in `GAME_BOOLEANS`; that only gets bit 0 set as a general “game started” flag and bit 2 later for map possession). The mapping (inside the title input loop) is:

| Key Pressed | Stored Difficulty Value | Label in Code | Minotaur Spawn Level Threshold (C) |
|-------------|-------------------------|---------------|------------------------------------|
| Other / default | 0 | `SET_DIFFICULTY_4` | 2 |
| Key 3 | 1 | `SET_DIFFICULTY_1` | 4 |
| Key 2 | 2 | `SET_DIFFICULTY_2` | 8 |
| Key 1 | 3 | `SET_DIFFICULTY_3` | 16 |

Spawn threshold formula in `BUILD_MAP`:

```
threshold C = 2 * (2 ^ difficultyValue)
```

Implementation details (lines ~2820–2860 in `asterion_high_rom.asm`):
1. `A = (INPUT_HOLDER)` is loaded into `B`.
2. `A` is set to `0x2`.
3. Loop doubles `A` (`ADD A,A`) B times → `C = 2,4,8,16`.
4. Compare `DUNGEON_LEVEL` to `C`; if the current level is below the threshold, Minotaur insertion is skipped.
5. When level ≥ threshold, a `[C,$9F]` pair is written early into the sparse item/monster table, guaranteeing the WHITE Minotaur appears from that level onward.

Important clarifications:
- There is NO direct difficulty multiplier applied to monster HP or damage in the combat initialization path (`SUB_ram_f22b` → `CALC_WEAPON_VALUE`). All scaling there comes from color bits, DUNGEON_LEVEL-derived value `C`, and random subtraction (`E`).
- Apparent “difficulty-based HP increase” for the Minotaur is a side effect of it spawning later on higher difficulty settings (the player typically reaches a higher `DUNGEON_LEVEL`, so level-derived additions in damage/HP routines are larger by the time the boss appears).
- `GAME_BOOLEANS` currently uses bits for: bit0 = game started; bit1 = shift mode / HC control state; bit2 = map possession. Difficulty is not bit-packed there.
- If future code adds true stat multipliers keyed off difficulty, they would need to reference `INPUT_HOLDER` or repack difficulty bits into `GAME_BOOLEANS`; no such references exist presently (`grep` reveals only spawn threshold usage as described).

Recommended doc cross-link: See the Minotaur row (code `$9F`) and Map Generation section for how `[pos,$9F]` insertion interacts with the sparse table.

## Sparse Item Table Structure

The sparse item table at `$3900` (ITEM_TABLE) stores items/monsters as position-code pairs:
```
$3900: [pos,code] [pos,code] ... $FF
```
- First pair always ladder position/code `$42`.
- Runtime additions append to end until `$FF` terminator written.
- Lookup uses `NEW_CHK_ITEM_MAP` (linear scan, early exit on `$FF`).

## Item State Slots vs. Viewport

`NEW_ITEMS_CALC` populates per-frame proximity slots:
```
S0, SL0, SR0, S1, SL1, SR1, S2, SB
```
Mapped to memory addresses: ITEM_F0 ($37EA), ITEM_F1 ($37E9), ITEM_F2 ($37E8), etc.

Mapping offsets derived from `DIR_FACING` deltas (D/E). These feed into:
- Movement gating: `FW_WALLS_CLEAR_CHK_MONSTER` (line 370) checks `ITEM_F1 + 2 >= $7A` to block forward movement on monsters `>= $78`
- Interaction decisions (pickup, open/close, attack targeting)
- Mask remapping (`CALC_MASKS` + optional item presence remasking) controlling draw calls

## Rendering Pipeline

1. `ITEM_DRAW` invoked with:
   - `A = item byte` (raw code with color/level bits).
   - `B = distance offset` (passed from call sites indicating size class pointer offset logic).
2. Color derivation logic:
   - `SRL A` (strip bit 0 to Carry for YEL/WHITE path decision).
   - Additional `SRL` and conditional color merges produce final color in `D`.
   - Original item index reconstructed (`SLA` plus additions) to compute pointer offset into table at `$FFxx` region.
3. Graphics pointers:
   - Accessed via table where `H` preset `$FF`; `(HL)` low then high byte pulled into `DE`.
   - `B` loaded with computed color value.
   - Tail jump `JP GFX_DRAW` (no return to `ITEM_DRAW` body—tail call optimization). GFX interpreter handles multi-cell copy and returns to caller chain.
4. Monster rendering reuses same path; codes map to monster pointer blocks.

## Pickup & Interaction Logic Highlights

- Pickup attempt (`DO_PICK_UP`, line 2530 in `asterion_high_rom.asm`):
  - Fetch item at player map pos via `NEW_CHK_ITEM_MAP`.
  - Branch on code:
    - `< $04`: Below RING threshold (Buckler range).
    - `>= $04 && < $10`: Armor tier (RING to PAVISE) uses inventory slot upgrades (armor, helmet, ring). Level comparisons govern replacement.
    - `>= $10 && < $18`: Higher armor/shield composites / transitional items.
    - `$18–$1B` / `$30–$33`: Weapon sets (bow/crossbow) processed by `NEW_RIGHT_HAND_ITEM` for stat recalculation.
    - `$44–$47`: Chest; open converts to new item(s) (randomization in `DO_OPEN_CLOSE`).
    - `$48` boundary shifts to food/arrow handling: duplication loops guard caps (arrows max `$33`, food increments with BCD correction).
    - Map codes `$6C,$6D,$DE,$DF`: Set HAVE MAP bit and store map slot for color display.
    - Key and potion ranges trigger specialized use logic (restoration or unlocking).
    - Ladder `$42`: Not pickable (processed elsewhere via ladder use interaction `DO_USE_LADDER`, not standard pickup path).
- Box (Chest) open logic `DO_OPEN_CLOSE` uses SRL transformations to derive item-level and probabilities for spawned content.
- Weapon recalculations (`NEW_RIGHT_HAND_ITEM`) compute PHYS/SPRT damage values into BCD health/effect stats; color/level affects value scaling.

## Combat & Monster Death

- On monster kill (`MONSTER_KILLED`): forward cell code fetched; if Minotaur (`$9F`), special branch (`MINOTAUR_DEAD` not shown here). Otherwise map entry overwritten with `$FE` (empty), clearing monster presence.
- Item breakage (`CHK_ITEM_BREAK`) probabilistically converts weapon usage into poof animation (`PLAY_POOF_ANIM`) and resets right-hand slot when exceeding durability threshold.

## Masks & Visibility

`CALC_MASKS` builds bitfields in `WALL_MASK_BITS_00–03` from wall states and item states. Optional remasking sections adjust which items remain visible in overlapping perspective tiers (e.g., preventing far items from drawing over nearer walls). Presence bits align with slots S0..SB to control draw order (`NEW_VIEWPORT_REDRAW` sequence of `CHK_*` calls).

## Monster vs Item Distinctions

| Aspect          | Item                              | Monster                               |
|-----------------|-----------------------------------|----------------------------------------|
| Code range      | Mixed lower ranges; ladder `$42`  | `>= $78` (blocking threshold)          |
| Movement block  | Only if door/wall logic applies   | Forward cell S1 code `>= $78` blocks   |
| Pickup          | Many items (except ladder/map used differently) | Never picked up (removed on kill) |
| Death handling  | Poof animation for thrown/consumed | Poof + table entry set to `$FE`       |
| Color tiers     | RED/YEL/MAG/WHITE reflect level    | Usually single color set per monster   |

## Generation (High-Level Summary)

- `BUILD_MAP` / generation routines place ladder first.
- Items distributed avoiding player/ladder positions; duplicates filtered using `TEMP_MAP` staging.
- Monster codes inserted from a defined difficulty-dependent pool; high codes ensure separation from item logic.
- Final sparse list terminated with `$FF` for scanning.

## Ladder Usage

- Ladder code `$42` reserved and always present once per level. Interaction (not standard pickup) triggers descent to next dungeon level—handled outside standard item pickup path (`DO_USE_LADDER` referenced in HC shift actions).

## Known Special Codes / Sentinels

| Code | Purpose |
|------|---------|
| `$FE` | Empty space result (returned by `NEW_CHK_ITEM_MAP` or placed after removal). |
| `$FF` | End-of-table terminator in sparse item list; not a valid object code. |

## Future Clarifications (Potential Enhancements)

- Verify inferred monster/item groups against a full pointer-table index dump for absolute certainty.
- Detailed probability tables for chest contents and item spawning.
- Full weapon damage scaling chart (current logic spreads across `NEW_RIGHT_HAND_ITEM`, `CALC_WEAPON_VALUE`, and usage checks).
- Potion effect increments (phys/spirit BCD math) enumerated per color tier.

## References

### Key Functions and Labels

**asterion_high_rom.asm:**
- `CHK_ITEM` (line 3923) – decodes item code into graphics pointer and color base, tail calls `GFX_DRAW`.
- `GFX_DRAW` (line 6698) – core graphics rendering engine for all AQUASCII character-based graphics.
- `NEW_ITEMS_CALC` – populates proximity item state slots (F0, F1, F2, etc.).
- `NEW_CHK_ITEM_MAP` – sparse table linear search.
- `DO_PICK_UP` (line 2530) – main pickup entry point with item type branching.
- `DO_OPEN_CLOSE` – chest opening and loot generation.
- `DO_USE_ATTACK` – attack interaction entry point.
- `DO_USE_LADDER` (line 6350) – ladder descent to next level.
- `INIT_MONSTER_COMBAT` (line 6000) – combat initialization with monster type checks.
- `CHK_FOR_SKELETON` through `CHK_FOR_MINOTAUR` (lines 6180–6290) – individual monster stat setup.
- `CALC_WEAPON_VALUE` (line 6300) – damage calculation with BCD multiplication.
- `GET_RANDOM_0_TO_7` (line 6280) – HP randomization using screen saver timer.
- `WRITE_HP_TRIPLET` (line 6320) – HP storage format (value, doubled, carry).
- `MONSTER_KILLED` – monster removal and boss check.
- `FW_WALLS_CLEAR_CHK_MONSTER` (line 370) – movement blocking check.
- `CALC_MASKS` / remask sections – visibility + perspective control.
- `NEW_RIGHT_HAND_ITEM` – weapon stat recalculations.
- `MAP_ITEM_MONSTER` (line 882) – initializes item/monster list search.
- `UPDATE_ITEM_CELLS`, `UPDATE_MONSTER_CELLS_LOOP` – map display rendering.
- `ANIMATE_RH_ITEM_STEP`, `COPY_ITEM_GFX_TO_CHRRAM` – item animation system.

**asterion_func_low.asm:**
- `UPDATE_F0_ITEM` (line 688) – F0 distance item/wall updates.
- `PLAY_MONSTER_GROWL` (line 2294) – monster growl sound effect.
- `POOF_SOUND` (line 2309) – item/monster disappearance sound.
- `TOGGLE_ITEM_POOF_AND_WAIT` (line 3211) – poof animation timing helper.
- `REDRAW_MONSTER_HEALTH` – updates monster health bar display in combat.
- `FILL_CHRCOL_RECT` (line 98) – low-level rectangle fill for all rendering.

**asterion_gfx_pointers.asm:**
- `GFX_POINTERS` table (lines 1–224) – graphics pointer lookup table.
- Organized by item/monster type with variants: regular, _S (small), _T (tiny).
- Pointer order determines item/monster type codes.

**asterion_gfx.asm:**
- Graphics data definitions for all items and monsters.
- `BUCKLER`, `RING`, `HELMET`, `ARMOR`, `PAVISE` – defensive items.
- `BOW`, `SCROLL`, `AXE`, `FIREBALL`, `MACE`, `STAFF`, `CROSSBOW` – weapons.
- `LADDER`, `CHEST`, `FOOD`, `QUIVER`, `LOCKED_CHEST`, `KEY`, `AMULET`, `CHALICE` – dungeon items.
- `WARRIOR_POTION`, `MAGE_POTION`, `MAP`, `CHAOS_POTION` – consumables.
- `SKELETON`, `SNAKE`, `SPIDER`, `MIMIC`, `MALOCCHIO`, `DRAGON`, `MUMMY`, `NECROMANCER`, `GRYPHON`, `MINOTAUR` – monsters.
- Each with size variants (_S for small/1-space, _T for tiny/2-space distance).
- Comments include object type codes, indices, and gameplay behavior descriptions.

**asterion.inc:**
- Memory address constants: `CHRRAM_ITEM_IDX`, `CHRRAM_MONSTER_IDX`, `COLRAM_*_ITEM_IDX`.
- Item state slots: `ITEM_F0`, `ITEM_F1`, `ITEM_F2`, `ITEM_SL1`, `ITEM_SR1`, etc.
- `ITEM_TABLE` ($3900) – sparse item/monster table base address.
- `MAP_ITEM_SPACE` ($3902) – item table working space.
