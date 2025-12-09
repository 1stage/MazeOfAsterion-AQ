# Weapon Sprite Damage Routing Analysis

**Date:** December 9, 2025  
**Purpose:** Documents how each item code constant behaves when used as a monster's `xxx_WEAPON_SPRITE` value

## Combat Routing Logic

The combat system uses this logic (from `asterion_high_rom.asm` line ~1867):

```asm
LD   A,(MONSTER_SPRITE_FRAME)   ; Load weapon sprite value
AND  $FC                        ; Mask off level bits (0-1)
CP   $24                        ; Compare to $24 (Fireball base)
JP   NZ,MONSTER_PHYS_BRANCH     ; If NOT $24, use Physical path
; Otherwise: Spiritual path
```

**Key Rule:** Only sprite values where `(value & $FC) == $24` trigger **Spiritual** damage. Everything else uses **Physical** damage.

---

## Item Code Weapon Sprite Behavior Table

| Hex Code | Constant Name | Base (& $FC) | Damage Type | Shield Tested | HP Pool Damaged | Graphics Used | Notes |
|----------|---------------|--------------|-------------|---------------|-----------------|---------------|-------|
| **$00** | RED_BUCKLER_ITEM | $00 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Buckler (RED) | Shield item |
| **$01** | YEL_BUCKLER_ITEM | $00 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Buckler (YEL) | Shield item |
| **$02** | MAG_BUCKLER_ITEM | $00 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Buckler (MAG) | Shield item |
| **$03** | WHT_BUCKLER_ITEM | $00 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Buckler (WHT) | Shield item |
| **$04** | RED_RING_ITEM | $04 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Ring (RED) | Enchant item |
| **$05** | YEL_RING_ITEM | $04 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Ring (YEL) | Enchant item |
| **$06** | MAG_RING_ITEM | $04 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Ring (MAG) | Enchant item |
| **$07** | WHT_RING_ITEM | $04 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Ring (WHT) | Enchant item |
| **$08** | RED_HELMET_ITEM | $08 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Helmet (RED) | Enchant item |
| **$09** | YEL_HELMET_ITEM | $08 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Helmet (YEL) | Enchant item |
| **$0A** | MAG_HELMET_ITEM | $08 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Helmet (MAG) | Enchant item |
| **$0B** | WHT_HELMET_ITEM | $08 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Helmet (WHT) | Enchant item |
| **$0C** | RED_ARMOR_ITEM | $0C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Armor (RED) | Enchant item |
| **$0D** | YEL_ARMOR_ITEM | $0C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Armor (YEL) | Enchant item |
| **$0E** | MAG_ARMOR_ITEM | $0C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Armor (MAG) | Enchant item |
| **$0F** | WHT_ARMOR_ITEM | $0C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Armor (WHT) | Enchant item |
| **$10** | RED_PAVISE_ITEM | $10 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Pavise (RED) | Large shield |
| **$11** | YEL_PAVISE_ITEM | $10 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Pavise (YEL) | Large shield |
| **$12** | MAG_PAVISE_ITEM | $10 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Pavise (MAG) | Large shield |
| **$13** | WHT_PAVISE_ITEM | $10 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Pavise (WHT) | Large shield |
| **$14** | RED_ARROW_LEFT_ITEM | $14 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Arrow ← | Player weapon sprite |
| **$15** | YEL_ARROW_LEFT_ITEM | $14 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Arrow ← | Player weapon sprite |
| **$16** | WHT_ARROW_LEFT_ITEM | $14 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Arrow ← | Player weapon sprite |
| **$17** | MAG_ARROW_LEFT_ITEM | $14 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Arrow ← | Player weapon sprite |
| **$18** | RED_BOW_ITEM | $18 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Bow (RED) | Ranged weapon |
| **$19** | YEL_BOW_ITEM | $18 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Bow (YEL) | Ranged weapon |
| **$1A** | MAG_BOW_ITEM | $18 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Bow (MAG) | Ranged weapon |
| **$1B** | WHT_BOW_ITEM | $18 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Bow (WHT) | Ranged weapon |
| **$1C** | RED_SCROLL_ITEM | $1C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Scroll (RED) | Magical weapon |
| **$1D** | YEL_SCROLL_ITEM | $1C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Scroll (YEL) | Magical weapon |
| **$1E** | MAG_SCROLL_ITEM | $1C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Scroll (MAG) | Magical weapon |
| **$1F** | WHT_SCROLL_ITEM | $1C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Scroll (WHT) | Magical weapon |
| **$20** | RED_AXE_ITEM | $20 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Axe (RED) | Throwing weapon |
| **$21** | YEL_AXE_ITEM | $20 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Axe (YEL) | Throwing weapon |
| **$22** | MAG_AXE_ITEM | $20 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Axe (MAG) | Throwing weapon |
| **$23** | WHT_AXE_ITEM | $20 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Axe (WHT) | Throwing weapon |
| **$24** | RED_FIREBALL_ITEM | **$24** | **✨ SPIRITUAL** | SHIELD_SPRT | PLAYER_SPRT_HEALTH | Fireball (RED) | 🔥 ONLY spiritual base |
| **$25** | YEL_FIREBALL_ITEM | **$24** | **✨ SPIRITUAL** | SHIELD_SPRT | PLAYER_SPRT_HEALTH | Fireball (YEL) | Masked to $24 |
| **$26** | MAG_FIREBALL_ITEM | **$24** | **✨ SPIRITUAL** | SHIELD_SPRT | PLAYER_SPRT_HEALTH | Fireball (MAG) | Masked to $24 |
| **$27** | WHT_FIREBALL_ITEM | **$24** | **✨ SPIRITUAL** | SHIELD_SPRT | PLAYER_SPRT_HEALTH | Fireball (WHT) | Masked to $24 |
| **$28** | RED_MACE_ITEM | $28 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Mace (RED) | Throwing weapon |
| **$29** | YEL_MACE_ITEM | $28 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Mace (YEL) | Throwing weapon |
| **$2A** | MAG_MACE_ITEM | $28 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Mace (MAG) | Throwing weapon |
| **$2B** | WHT_MACE_ITEM | $28 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Mace (WHT) | Throwing weapon |
| **$2C** | RED_STAFF_ITEM | $2C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Staff (RED) | Advanced magical |
| **$2D** | YEL_STAFF_ITEM | $2C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Staff (YEL) | Advanced magical |
| **$2E** | MAG_STAFF_ITEM | $2C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Staff (MAG) | Advanced magical |
| **$2F** | WHT_STAFF_ITEM | $2C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Staff (WHT) | Advanced magical |
| **$30** | RED_CROSSBOW_ITEM | $30 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Crossbow (RED) | Advanced ranged |
| **$31** | YEL_CROSSBOW_ITEM | $30 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Crossbow (YEL) | Advanced ranged |
| **$32** | MAG_CROSSBOW_ITEM | $30 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Crossbow (MAG) | Advanced ranged |
| **$33** | WHT_CROSSBOW_ITEM | $30 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Crossbow (WHT) | Advanced ranged |
| **$34** | UNUSED | $34 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $34 base |
| **$35** | UNUSED | $34 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $34 base |
| **$36** | UNUSED | $34 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $34 base |
| **$37** | UNUSED | $34 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $34 base |
| **$38** | UNUSED | $38 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $38 base |
| **$39** | UNUSED | $38 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $38 base |
| **$3A** | UNUSED | $38 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $38 base |
| **$3B** | UNUSED | $38 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $38 base |
| **$3C** | RED_ARROW_RIGHT_ITEM | $3C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Arrow → | Monster weapon sprite |
| **$3D** | YEL_ARROW_RIGHT_ITEM | $3C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Arrow → | Monster weapon sprite |
| **$3E** | WHT_ARROW_RIGHT_ITEM | $3C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Arrow → | Monster weapon sprite |
| **$3F** | UNUSED | $3C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $3C base |
| **$40** | RED_LADDER_ITEM | $40 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Ladder (RED) | Level transition |
| **$41** | YEL_LADDER_ITEM | $40 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Ladder (YEL) | Level transition |
| **$42** | MAG_LADDER_ITEM | $40 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Ladder (MAG) | Level transition |
| **$43** | WHT_LADDER_ITEM | $40 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Ladder (WHT) | Level transition |
| **$44** | RED_CHEST_ITEM | $44 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Chest (RED) | Loot container |
| **$45** | YEL_CHEST_ITEM | $44 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Chest (YEL) | Loot container |
| **$46** | MAG_CHEST_ITEM | $44 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Chest (MAG) | Loot container |
| **$47** | WHT_CHEST_ITEM | $44 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Chest (WHT) | Loot container |
| **$48** | RED_FOOD_ITEM | $48 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Food (RED) | Rations |
| **$49** | YEL_FOOD_ITEM | $48 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Food (YEL) | Rations |
| **$4A** | MAG_FOOD_ITEM | $48 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Food (MAG) | Rations |
| **$4B** | WHT_FOOD_ITEM | $48 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Food (WHT) | Rations |
| **$4C** | RED_QUIVER_ITEM | $4C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Quiver (RED) | Arrow container |
| **$4D** | YEL_QUIVER_ITEM | $4C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Quiver (YEL) | Arrow container |
| **$4E** | MAG_QUIVER_ITEM | $4C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Quiver (MAG) | Arrow container |
| **$4F** | WHT_QUIVER_ITEM | $4C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Quiver (WHT) | Arrow container |
| **$50** | RED_LOCKED_CHEST_ITEM | $50 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Locked Chest (RED) | Requires key |
| **$51** | YEL_LOCKED_CHEST_ITEM | $50 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Locked Chest (YEL) | Requires key |
| **$52** | MAG_LOCKED_CHEST_ITEM | $50 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Locked Chest (MAG) | Requires key |
| **$53** | WHT_LOCKED_CHEST_ITEM | $50 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Locked Chest (WHT) | Requires key |
| **$5F** | WHT_CHALICE_ITEM | $5C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Chalice (WHT) | Treasure |
| **$60** | UNUSED | $60 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $60 base |
| **$61** | UNUSED | $60 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $60 base |
| **$62** | UNUSED | $60 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $60 base |
| **$63** | UNUSED | $60 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $60 base |
| **$64** | RED_WARRIOR_POTION_ITEM | $64 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Warrior Potion (RED) | Physical stat boost |
| **$56** | MAG_AMULET_ITEM | $54 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Amulet (MAG) | Treasure |
| **$57** | WHT_AMULET_ITEM | $54 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Amulet (WHT) | Treasure |
| **$58** | RED_KEY_ITEM | $58 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Key (RED) | Unlocks chests |
| **$59** | YEL_KEY_ITEM | $58 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Key (YEL) | Unlocks chests |
| **$5A** | MAG_KEY_ITEM | $58 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Key (MAG) | Unlocks chests |
| **$5B** | WHT_KEY_ITEM | $58 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Key (WHT) | Unlocks chests |
| **$5C** | RED_CHALICE_ITEM | $5C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Chalice (RED) | Treasure |
| **$5D** | YEL_CHALICE_ITEM | $5C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Chalice (YEL) | Treasure |
| **$5E** | MAG_CHALICE_ITEM | $5C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Chalice (MAG) | Treasure |
| **$5F** | WHT_CHALICE_ITEM | $5C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Chalice (WHT) | Treasure |
| **$64** | RED_WARRIOR_POTION_ITEM | $64 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Warrior Potion (RED) | Physical stat boost |
| **$65** | YEL_WARRIOR_POTION_ITEM | $64 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Warrior Potion (YEL) | Physical stat boost |
| **$66** | MAG_WARRIOR_POTION_ITEM | $64 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Warrior Potion (MAG) | Physical stat boost |
| **$67** | WHT_WARRIOR_POTION_ITEM | $64 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Warrior Potion (WHT) | Physical stat boost |
| **$68** | RED_MAGE_POTION_ITEM | $68 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Mage Potion (RED) | Spiritual stat boost |
| **$69** | YEL_MAGE_POTION_ITEM | $68 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Mage Potion (YEL) | Spiritual stat boost |
| **$6A** | MAG_MAGE_POTION_ITEM | $68 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Mage Potion (MAG) | Spiritual stat boost |
| **$6B** | WHT_MAGE_POTION_ITEM | $68 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Mage Potion (WHT) | Spiritual stat boost |
| **$6C** | RED_MAP_ITEM | $6C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Map (RED) | Reveals map |
| **$6D** | YEL_MAP_ITEM | $6C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Map (YEL) | Reveals map |
| **$6E** | MAG_MAP_ITEM | $6C | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Map (MAG) | Reveals map |
| **$73** | WHT_CHAOS_POTION_ITEM | $70 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | Chaos Potion (WHT) | Random effects |
| **$74** | UNUSED | $74 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $74 base |
| **$75** | UNUSED | $74 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $74 base |
| **$76** | UNUSED | $74 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $74 base |
| **$77** | UNUSED | $74 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $74 base |
| **$78** | UNUSED | $78 | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $78 base |
| ... | *Additional unused codes $79-$FB follow same pattern* | varies | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | All mask to physical damage |
| **$FC** | UNUSED | $FC | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $FC base |
| **$FD** | UNUSED | $FC | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (undefined) | Would mask to $FC base |
| **$FE** | NEW_RETURN_EMPTY_SPACE | $FC | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (empty space) | Special: empty item slot |
| **$FF** | ITEM_TABLE_TERMINATOR | $FC | **Physical** | SHIELD_PHYS | PLAYER_PHYS_HEALTH | (terminator) | Special: end of item list |
**Spiritual Damage Codes:** 4 ($24-$27 Fireball family only)  
**Physical Damage Codes:** 252 (everything else, including all unused codes)

## Summary

**Total Defined Item Codes:** 74  
**Total Possible Values:** 256 ($00-$FF)  
**Unused Codes:** 182

## Summary

**Total Item Codes:** 74  
**Spiritual Damage Codes:** 4 ($24-$27 Fireball family only)  
**Physical Damage Codes:** 70 (everything else)

### Key Observations:

1. **Only ONE weapon sprite base triggers spiritual damage:** $24 (Fireball family)
2. **All other item codes use physical damage,** including:
   - Magical-themed items (Scroll, Staff, Mage Potion)
   - Non-weapon items (Ladder, Chest, Food, etc.)
   - Arrow sprites:
     - Arrow Left family ($14-$17): Player weapon sprites, arrow points left ←
     - Arrow Right family ($3C-$3E): Monster weapon sprites, arrow points right →
   - All other weapon sprites (Axe, Mace, etc.)

3. **The level bits (0-1) are stripped** during damage routing (`AND $FC`)
4. **Graphics displayed** depend on the full sprite value (base + level)
5. **Damage magnitude** is calculated separately using the monster's base damage and level

### Recommended Usage:

For **Spiritual damage** monsters, use:
- `RED_FIREBALL_ITEM` ($24)
- `YEL_FIREBALL_ITEM` ($25)
- `MAG_FIREBALL_ITEM` ($26)
- `WHT_FIREBALL_ITEM` ($27)

For **Physical damage** monsters, use any other sprite:
- `RED_ARROW_RIGHT_ITEM` ($3C) - standard monster arrow (points right →)
- `YEL_ARROW_RIGHT_ITEM` ($3D) - yellow monster arrow
- `WHT_ARROW_RIGHT_ITEM` ($3E) - white monster arrow
- `RED_MACE_ITEM` ($28) - alternative physical weapon
- Any other item code (all route to physical damage)

For **Player weapon sprites** (when needed):
- `RED_ARROW_LEFT_ITEM` ($14) - player arrow (points left ←)
- `YEL_ARROW_LEFT_ITEM` ($15) - yellow player arrow
- `WHT_ARROW_LEFT_ITEM` ($16) - white player arrow
- `MAG_ARROW_LEFT_ITEM` ($17) - magenta player arrow

---

**Note:** While items like Scroll, Staff, and Mage Potion are thematically "magical," they route to **physical** damage when used as monster weapon sprites because their base codes ($1C, $2C, $68) do not equal $24.
