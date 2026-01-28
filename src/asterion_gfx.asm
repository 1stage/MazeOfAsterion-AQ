; ASTERION_GFX.ASM
; Updated 22 SEP 2025 by Sean P. Harrington
;

; Maze of Asterion Grpahics Draw Routine -
;   The routine that draws character-based graphics in Maze of Asterion is labelled GFX_DRAW .
;   -   Register B expects the FG/BG color value 
;   -   Register HL expects the CHRRAM screen address to start drawing
;       - Indexed starting points for ITEMS and MONSTERS within the VIEWPORT
;       - Indexed starting points for LEFT and RIGHT hands and inventory items
;       - Any other indexed locations (always starting in CHRRAM!!!)
;   -   Register DE expects the GFX start address (typically through the GFX_POINTERS table)
;   A graphic in Maze of Asterion is a block of AQUASCII characters, $FF terminated, with six defined “control” characters:
;   -   $00 = empty character (move right one column, NOT a space character!)
;   -   $01 = return character (move down and back to index)
;   -   $02 = backspace character (move left one column)
;   -   $03 = linefeed (move down one row)
;   -   $04 = previous line (move up one row)
;   -   $A0 = reverse colors (swap FG/BG)



; NO_GFX is a label used for an "empty" graphic, since it's only character is the end of graphic code, $FF
NO_GFX:
    db          $FF

; ITEMS:
;   - Items range from OBJECT INDEX $00 to $77, and OBJECT TYPE $00 to $1D
;   - OBJECT TYPE is the OBJECT INDEX bit-shifted RIGHT two times to remove the 2 bits of object level
;   - Items (if visible in the maze) have three sizes, depending on how far away they are from the PLAYER's position:
;       - Tiny (i.e. MAP_T): These items are either two spaces forward, or one space diagonal right or left forward from the player. These graphics are usually only a single character wide.
;       - Small (i.e. MAP_S): These items are one space forward from the player. These graphics are usually 2x2 characters in size.
;       - Regular (i.e. MAP): These items are in the same space as the player. These graphics are usually 4x4 characters in size, and this is the size used for items in the player's inventory pack.
;

; =================================
; BUCKLER -
;   OBJECT TYPE:  $00
;   OBJECT INDEX:
;       $00 - RED BUCKLER (Starting item, HARDEST level)
;       $01 - YELLOW BUCKLER (Starting item, HARD level)
;       $02 - MAGENTA BUCKLER (Starting item, MEDIUM level)
;       $03 - WHITE BUCKLER (Starting item, EASIEST level)
; The BUCKLER is a small shield item that can be picked up and swapped to the LEFT HAND for protection. 
;
BUCKLER:
    db          $01,$01,$01,$01,$01
    db          $D7,$FC,$C9,$01
    db          $A0,$98,$A0,$7F,$99,$01
    db          $C7,$AF,$D9,$FF
BUCKLER_S:
    db          $01,$01
    db          $00,$96,$FF
BUCKLER_T:
    db          $00,$87,$FF

; =================================
; RING -
;   OBJECT TYPE:  $01
;   OBJECT INDEX:
;       $04 - RED RING
;       $05 - YELLOW RING
;       $06 - MAGENTA RING
;       $07 - WHITE RING
; The RING is an enchantment item that increases protection. Once picked up they are worn immediately and cannot be removed. They are not kept in inventory. If another RING of greater level it is picked up and worn, and the old RING disappears.
;
RING:
    db          $01,$01,$01,$01,$01
    db          $01,$01
    db          $00,"o",$FF
RING_S:
    db          $01,$01,$01
    db          $00,$C6,$FF
RING_T:
    db          $00,".",$FF

; =================================
; HELMET -
;   OBJECT TYPE:  $02
;   OBJECT INDEX:
;       $08 - RED HELMET
;       $09 - YELLOW HELMET
;       $0A - MAGENTA HELMET
;       $0B - WHITE HELMET
; The HELMET is an enchantment item that increases protection. Once picked up they are worn immediately and cannot be removed. They are not kept in inventory. If another HELMET of greater level it is picked up and worn, and the old HELMET disappears.
;
HELMET:
    db          $01,$01,$01,$01,$01
    db          $01
    db          $00,$C0,$C1,$01
    db          $00,$BF,$EF,$FF
HELMET_S:
    db          $01,$01,$01
    db          $04,$00,$D2,$01
    db          $00,$A3,$FF
HELMET_T:
    db          $00,"^",$FF

; =================================
; ARMOR -
;   OBJECT TYPE:  $03
;   OBJECT INDEX:
;       $0C - RED ARMOR
;       $0D - YELLOW ARMOR
;       $0E - MAGENTA ARMOR
;       $0F - WHITE ARMOR
; The ARMOR is an enchantment item that increases protection. Once picked up they are worn immediately and cannot be removed. They are not kept in inventory. If another ARMOR of greater level it is picked up and worn, and the old ARMOR disappears.
;
ARMOR:
    db          $01,$01,$01,$01,$01
    db          $A0,$C9,$C7,$D9,$D7,$A0,$01
    db          $EA,$7F,$7F,$B5,$01
    db          $A0,$C3,$88,$88,$A0,$97,$FF
ARMOR_S:
    db          $01,$01
    db          $C7,$A0,$C7,$D9,$A0,$D9,$01
    db          $00,$7F,$7F,$01
    db          $00,$D9,$C7,$FF
ARMOR_T:
    db          $00,$A0,$C7,$D9,$01
    db          $00,$97,$A0,$C3,$FF

; =================================
; PAVISE -
;   OBJECT TYPE:  $04
;   OBJECT INDEX:
;       $00 - RED PAVISE
;       $01 - YELLOW PAVISE
;       $02 - MAGENTA PAVISE
;       $03 - WHITE PAVISE
; The PAVISE is a large shield item that can be picked up and swapped to the LEFT HAND for protection. 
;
PAVISE:
    db          $01,$01,$01,$01,$01
    db          $E8,$F0,$F0,$B4,$01
    db          $EA,$7F,$7F,$B5,$01
    db          $EA,$7F,$7F,$B5,$01
    db          $00,$EF,$BF,$FF
PAVISE_S:
    db          $01,$01
    db          $00,$F4,$F8,$01
    db          $00,$7F,$7F,$01
    db          $00,$AB,$A7,$FF
PAVISE_T:
    db          $00,$7F,$01
    db          $00,$C2,$FF

; =================================
; ARROW_FLYING_RIGHT -
;   OBJECT TYPE:  $05
;   OBJECT INDEX: $14
; The ARROW_FLYING_RIGHT is the object used in animation when a MONSTER performs a PHYSICAL attack on the PLAYER. Note that this item/object does not appear in the maze and cannot be picked up.
;
ARROW_FLYING_RIGHT:
    db          $01,$01,$01,$01,$01
    db          $01
    db          $AC,$9A,$FF

; =================================
; BOW -
;   OBJECT TYPE:  $06
;   OBJECT INDEX:
;       $18 - RED BOW (Starting item, all levels)
;       $19 - YELLOW BOW
;       $1A - MAGENTA BOW
;       $1B - WHITE BOW
; The BOW is a basic WEAPON that can be used with ARROWS by the PLAYER to make a PHYSICAL attack on a MONSTER. 
;
BOW:
    db          $01,$01,$01,$01,$01
    db          $D7,$AC,$A3,$8E,$01
    db          $D6,$00,$CA,$01
    db          $98,$CA,$01
    db          $9F,$FF
BOW_S:
    db          $01,$01
    db          $D7,$AC,$C9,$01
    db          $D6,$CA,$01
    db          $C7,$FF
BOW_T:
    db          $00,"{",$FF

; =================================
; SCROLL -
;   OBJECT TYPE:  $07
;   OBJECT INDEX:
;       $1C - RED SCROLL
;       $1D - YELLOW SCROLL
;       $1E - MAGENTA SCROLL
;       $1F - WHITE SCROLL
; The SCROLL is a WEAPON that can be used by the PLAYER to make a MAGICAL attack on a MONSTER. 
;
SCROLL:
    db          $01,$01,$01,$01,$01
    db          "\t",$90,$90,"\t",$01
    db          $12,$8F,$8E,$12,$01
    db          $12,$9E,$9F,$12,$01
    db          "\b",$A0,$80,$80,$A0,"\b",$FF
SCROLL_S:
    db          $01,$01
    db          $00,$CD,$DD,$01
    db          $00,$CD,$DD,$FF
SCROLL_T:
    db          $00,"H",$FF

; =================================
; AXE -
;   OBJECT TYPE:  $08
;   OBJECT INDEX:
;       $20 - RED AXE
;       $21 - YELLOW AXE
;       $22 - MAGENTA AXE
;       $23 - WHITE AXE
; The AXE is a WEAPON that can be thrown by the PLAYER to make a PHYSICAL attack on a MONSTER. Once used, it (usually) relocates to another part of the maze.
;
AXE:
    db          $01,$01,$01,$01,$01
    db          $00,$7F,$B7,$01
    db          $00,$D9,$98,$01
    db          $00,$00,$B5,$01
    db          $00,$00,$99,$FF
AXE_S:
    db          $01,$01
    db          $00,$A0,$D7,$A0,$B7,$01
    db          $00,$00,$98,$01
    db          $00,$00,$B5,$FF
AXE_T:
    db          $00,$11,$FF

; =================================
; FIREBALL -
;   OBJECT TYPE:  $09
;   OBJECT INDEX:
;       $24 - RED FIREBALL
;       $25 - YELLOW FIREBALL
;       $26 - MAGENTA FIREBALL
;       $27 - WHITE FIREBALL
; The FIREBALL is a WEAPON that can be thrown by the PLAYER to make a MAGICAL attack on a MONSTER. Once used, it disappears.
;
FIREBALL:
    db          $01,$01,$01,$01,$01
    db          $BA,$B9,$E1,$01
    db          $B8,$BE,$B9,$01
    db          $A8,$E1,$B6,$FF
FIREBALL_S:
    db          $01,$01
    db          $00,$D1,$FF
FIREBALL_T:
    db          $00,$D3,$FF

; =================================
; MACE -
;   OBJECT TYPE:  $0A
;   OBJECT INDEX:
;       $28 - RED MACE
;       $29 - YELLOW MACE
;       $2A - MAGENTA MACE
;       $2B - WHITE MACE
; The MACE is a WEAPON that can be thrown by the PLAYER to make a PHYSICAL attack on a MONSTER. Once used, it (usually) relocates to another part of the maze.
;
MACE:
    db          $01,$01,$01,$01,$01
    db          $00,$9E,$8E,$01
    db          $00,$A0,$C3,$A0,$97,$01
    db          $00,$A0,$C3,$A0,$97,$01
    db          $00,$A0,$99,$A0,$98,$FF
MACE_S:
    db          $01,$01
    db          $00,$E0,$B0,$01
    db          $00,$A0,$91,$A0,$81,$01
    db          $00,$A0,$C3,$A0,$97,$FF
MACE_T:
    db          $00,"T",$FF

; =================================
; STAFF -
;   OBJECT TYPE:  $0B
;   OBJECT INDEX:
;       $2C - RED STAFF
;       $2D - YELLOW STAFF
;       $2E - MAGENTA STAFF
;       $2F - WHITE STAFF
; The STAFF is an advanced WEAPON that can be used by the PLAYER to make a MAGICAL attack on a MONSTER. 
;
STAFF:
    db          $01,$01,$01,$01,$01
    db          $D5,$01
    db          $00,$DA,$01
    db          $00,$00,$DA,$01
    db          $00,$00,$00,$DA,$FF
STAFF_S:
    db          $01,$01
    db          $00,$D3,$01
    db          $00,$00,$DA,$FF
STAFF_T:
    db          $00,"\\",$FF

; =================================
; CROSSBOW -
;   OBJECT TYPE:  $0C
;   OBJECT INDEX:
;       $30 - RED CROSSBOW
;       $31 - YELLOW CROSSBOW
;       $32 - MAGENTA CROSSBOW
;       $33 - WHITE CROSSBOW
; The CROSSBOW is an advanced WEAPON that can be used with ARROWS by the PLAYER to make a PHYSICAL attack on a MONSTER. 
;
CROSSBOW:
    db          $01,$01,$01,$01,$01
    db          $00,$00,$90,$F0,$01
    db          $00,"\f",$B7,$A0,$91,$A0,$01
    db          $A0,$91,$A0,$B7,$ED,$A0,$91,$A0,$01
    db          $A0,$99,$A0,$90,$90,$A0,$D7,$A0,$FF
CROSSBOW_S:
    db          $01,$01
    db          $D7,$DC,$01
    db          $CD,"\r",$FF
CROSSBOW_T:
    db          $A0,$91,$A0,$D8,$02,$04,$90,$FF

; =================================
; SPIDER_WEB -
;   OBJECT TYPE:  $0D
;   OBJECT INDEX: $34
; The purpose of this item is unknown, but maybe used for the flying animation for AXE or MACE. Note that this item/object does not appear in the maze and cannot be picked up.

SPIDER_WEB:
    db          $01,$01,$01,$01,$01
    db          $00,47,216,92,$01
    db          $00,216,216,216,$01
    db          $00,92,216,47,$FF

; =================================
; UNKNOWN ITEM -
;   OBJECT TYPE:  $0E
;   OBJECT INDEX: $38
; The purpose of this item is unknown, but maybe used for the flying animation for AXE or MACE. Note that this item/object does not appear in the maze and cannot be picked up.

; =================================
; ARROW_FLYING_LEFT -
;   OBJECT TYPE:  $0F
;   OBJECT INDEX: $3C
; The ARROW_FLYING_LEFTT is the object used in animation when the PLAYER performs a PHYSICAL attack on a MONSTER. Note that this item/object does not appear in the maze and cannot be picked up. 
;
ARROW_FLYING_LEFT:
    db          $01,$01,$01,$01,$01
    db          $01
    db          $9B,$AC,$FF

; =================================
; LADDDER -
;   OBJECT TYPE:  $10
;   OBJECT INDEX: $42 (MAGENTA LADDER)
; The LADDER is the object that allows progressing to the next lower level of the maze. Note that this item/object cannot be picked up and only shows up in the MAGENTA form.
;
LADDER:
    db          $01,$01,$01,$01,$01
    db          $EA,$00,$00,$B5,$01
    db          $EA,$AF,$AF,$B5,$01
    db          $FA,$FC,$FC,$F5,$01
    db          $AB,$F0,$F0,$A7,$FF
LADDER_S:
    db          $01,$01
    db          $00,$B4,$E8,$01
    db          $D7,$B7,$EB,$C9,$01
    db          $C7,$AF,$AF,$D9,$FF
LADDER_T:
    db          $00,$CD,$97,$FF

; =================================
; CHEST -
;   OBJECT TYPE:  $11
;   OBJECT INDEX:
;       $44 - RED CHEST
;       $45 - YELLOW CHEST
;       $46 - MAGENTA CHEST
;       $47 - WHITE CHEST
; The CHEST is an ITEM that can be picked up or opened when on the ground in front of the PLAYER. When opened, it disappears and becomes a TREASURE item, a POTION, a KEY, or a MAP. Note that the CHEST can also be thrown as a WEAPON for a PHYSICAL attack, but does not inflict much damage.
;
CHEST:
    db          $01,$01,$01,$01,$01
    db          $90,$88,$88,$90,$01
    db          $A0,$90,$88,$88,$90,$A0,$01
    db          $A0,$81,$90,$90,$A0,$91,$01
    db          $A0,$D7,$FC,$FC,$C9,$A0,$FF
CHEST_S:
    db          $01,$E0,$1F,$1F,$B0,$01
    db          $A0,$99,$A0,$80,$80,$98,$01
    db          $A2,$00,$00,$A1,$FF
CHEST_T:
    db          $00,$FC,$FF

; =================================
; FOOD -
;   OBJECT TYPE:  $12
;   OBJECT INDEX:
;       $48 - RED FOOD
;       $49 - YELLOW FOOD
;       $4A - MAGENTA FOOD
;       $4B - WHITE FOOD
; The FOOD is an ITEM that can be picked up and added to the PLAYER's rations, a separate inventory. Picking FOOD up causes it to disappear.
;
FOOD:
    db          $01,$01,$01,$01,$01
    db          $E4,$1F,$F6,$01
    db          $A0,$C3,$CB,$DB,$A0,$97,$01
    db          $00,$BB,$A0,$1F,$A0,$A9,$FF
FOOD_S:
    db          $01,$01
    db          $E0,$BE,$B0,$01
    db          $00,$E9,$A7,$FF
FOOD_T:
    db          $00,"#",$FF

; =================================
; QUIVER -
;   OBJECT TYPE:  $13
;   OBJECT INDEX:
;       $4C - RED QUIVER
;       $4D - YELLOW QUIVER
;       $4E - MAGENTA QUIVER
;       $4F - WHITE QUIVER
; The QUIVER is an ITEM that can be picked up and added to the PLAYER's arrows, a separate inventory. Picking QUIVER up causes it to disappear.
;
QUIVER:
    db          $01,$01,$01,$01,$01
    db          $01
    db          $7F,$7F,$A0,$D7,$A0,$06,$01
    db          $A2,$AC,$B2,$E9,$01
    db          $00,$00,$A2,$A1,$FF
QUIVER_S:
    db          $01,$01
    db          $00,$AF,$BD,$B0,$01
    db          $00,$00,$A2,$FF
QUIVER_T:
    db          $00,$F0,$FF

; =================================
; LOCKED_CHEST -
;   OBJECT TYPE:  $14
;   OBJECT INDEX:
;       $50 - RED LOCKED_CHEST
;       $51 - YELLOW LOCKED_CHEST
;       $52 - MAGENTA LOCKED_CHEST
;       $53 - WHITE LOCKED_CHEST
; The LOCKED_CHEST is an ITEM that can be picked up or unlocked/opened with a KEY of similar or greater level when on the ground in front of the PLAYER. When unlocked/opened, it disappears and becomes a TREASURE item, a POTION, a KEY, or a MAP. Note that the LOCKED_CHEST can also be thrown as a WEAPON for a PHYSICAL attack, but does not inflict much damage.
; A tiny or small LOCKED_CHEST looks like a regular CHEST from afar, so it uses those graphics.
;
LOCKED_CHEST:
    db          $01,$01,$01,$01,$01
    db          $90,$88,$88,$90,$01
    db          $A0,$90,$88,$88,$90,$A0,$01
    db          $A0,$81,$CB,$DB,$A0,$91,$01
    db          $A0,$D7,$FC,$FC,$C9,$A0,$FF

; =================================
; UNKNOWN ITEM -
;   OBJECT TYPE:  $15
;   OBJECT INDEX: $54
; The purpose of this item is unknown, but maybe used for the flying animation for FIREBALL. Note that this item/object does not appear in the maze and cannot be picked up.

; =================================
; KEY -
;   OBJECT TYPE:  $16
;   OBJECT INDEX:
;       $58 - RED KEY
;       $59 - YELLOW KEY
;       $5A - MAGENTA KEY
;       $5B - WHITE KEY
; The KEY is an ITEM that can be picked up or used to unlock/open a LOCKED_CHEST of similar or lesser level when the LOCKED_CHEST is on the ground in front of the PLAYER. When used it disappears.
;
KEY:
    db          $01,$01,$01,$01,$01
    db          $01
    db          $90,$90,$B8,$C9,$01
    db          $10,$A0,$80,$A0,$A9,$D9,$FF
KEY_S:
    db          $01,$01,$01
    db          $BC,$C5,$FF
KEY_T:
    db          $FF,"-",$FF

; =================================
; AMULET -
;   OBJECT TYPE:  $17
;   OBJECT INDEX:
;       $5C - RED AMULET
;       $5D - YELLOW AMULET
;       $5E - MAGENTA AMULET
;       $5F - WHITE AMULET
; The AMULET is a TREASURE item that increases the PLAYER's score. When picked up it disappears. Note in future versions of this game, the score will be removed, and picking up an AMULET will perform other functions.
;
AMULET:
    db          $01,$01,$01,$01,$01
    db          $D7,$AC,$C9,$01
    db          $C7,$AC,$C8,$C9,$01
    db          $D7,$AC,$D9,$D6,$01
    db          $C7,$AC,$05,$D9,$FF
AMULET_S:
    db          $01,$01
    db          $00,$D7,$C9,$01
    db          $00,$C7,$C8,$C9,$01
    db          $00,$CB,$F1,$A5,$FF
AMULET_T:
    db          $00,"&",$FF

; =================================
; CHALICE -
;   OBJECT TYPE:  $18
;   OBJECT INDEX:
;       $60 - RED CHALICE
;       $61 - YELLOW CHALICE
;       $62 - MAGENTA CHALICE
;       $63 - WHITE CHALICE
; The CHALICE is a TREASURE item that increases the PLAYER's score. When picked up it disappears. Note in future versions of this game, the score will be removed, and picking up an CHALICE will perform other functions.
;
CHALICE:
    db          $01,$01,$01,$01,$01
    db          $01
    db          $A0,$C3,$A0,$89,$97,$01
    db          $00,$9F,$01
    db          $E0,$0E,$B0,$FF
CHALICE_S:
    db          $01,$01
    db          $00,$9F,$01
    db          $00,$CC,$FF
CHALICE_T:
    db          $00,"Y",$FF

; =================================
; WARRIOR_POTION -
;   OBJECT TYPE:  $19
;   OBJECT INDEX:
;       $64 - RED WARRIOR_POTION
;       $65 - YELLOW WARRIOR_POTION
;       $66 - MAGENTA WARRIOR_POTION
;       $67 - WHITE WARRIOR_POTION
; The WARRIOR_POTION is a potion that can be picked up or used. When used, it disappears and usually affects the PLAYER's PHYSICAL traits. It removes any other currently active POTION effect. Note all potions use the POTION_T for their tiny view.
;
WARRIOR_POTION:
    db          $01,$01,$01,$01,$01
    db          $00,"+",$D4,$01
    db          $00,$11,$0F,$01
    db          $00,$CD,$DD,$01
    db          $00,$C7,$D9,$FF
WARRIOR_POTION_S:
    db          $01,$01
    db          $00,$D4,$01
    db          $00,$14,$01
    db          $00,$C2,$FF
POTION_T:
    db          $00,"U",$02,$04,"_",$FF

; =================================
; MAGE_POTION -
;   OBJECT TYPE:  $1A
;   OBJECT INDEX:
;       $68 - RED MAGE_POTION
;       $69 - YELLOW MAGE_POTION
;       $6A - MAGENTA MAGE_POTION
;       $6B - WHITE MAGE_POTION
; The MAGE_POTION is a potion that can be picked up or used. When used, it disappears and usually affects the PLAYER's SPIRITUAL traits. It removes any other currently active POTION effect. Note all potions use the POTION_T for their tiny view.
;
MAGE_POTION:
    db          $01,$01,$01,$01,$01
    db          $00,"+",$D5,$01
    db          $00,$11,$0F,$01
    db          $00,$CD,$DD,$01
    db          $00,$C7,$D9,$FF
MAGE_POTION_S:
    db          $01,$01
    db          $00,$D5,$01
    db          $00,$14,$01
    db          $00,$C2,$FF

; =================================
; MAP -
;   OBJECT TYPE:  $1B
;   OBJECT INDEX:
;       $6C - RED MAP
;       $6D - YELLOW MAP
;       $6E - MAGENTA MAP
;       $6F - WHITE MAP
; The MAP is an ITEM that can be picked up or used to view the floorplan of the current maze level.
;
MAP:
    db          $01,$01,$01,$01,$01
    db          $F0,$1F,$C8,$98,$01
    db          $12,$C8,$CC,$B5,$01
    db          $A0,$B5,$A0,$CD,$CC,$12,$01
    db          $A0,$99,$A0,$CC,$A0,$1F,$FC,$A0,$FF
MAP_S:
    db          $01,$01
    db          $00,$D7,$01
    db          $C7,$A0,$D5,$A0,$C9,$01
    db          $00,$D9,$FF
MAP_T:
    db          $00,$D5,$FF

; =================================
; CHAOS_POTION -
;   OBJECT TYPE:  $1C
;   OBJECT INDEX:
;       $70 - RED CHAOS_POTION
;       $71 - YELLOW CHAOS_POTION
;       $72 - MAGENTA CHAOS_POTION
;       $73 - WHITE CHAOS_POTION
; The CHAOS_POTION is a potion that can be picked up or used. When used, it disappears and can randomly affects the PLAYER's SPIRITUAL, HEALTH, or PHYSICAL traits. It removes any other currently active POTION effect. Note all potions use the POTION_T for their tiny view.
;
CHAOS_POTION:
    db          $01,$01,$01,$01,$01
    db          $00,"??",$01
    db          $00,$11,$0F,$01
    db          $00,$CD,$DD,$01
    db          $00,$C7,$D9,$FF
CHAOS_POTION_S:
    db          $01,$01
    db          $00,"?",$01
    db          $00,$14,$01
    db          $00,$C2,$FF

; =================================
; UNKNOWN ITEM -
;   OBJECT TYPE:  $1D
;   OBJECT INDEX: $74
; The purpose of this item is unknown, but maybe used for the text for the PLAYER's death sequence.
;
EXCL_MARK_GFX:
    db          "!",$FF
    

; MONSTERS
;   - Monsters range from OBJECT INDEX $78 to $9F, and OBJECT TYPE $1E to $27
;   - OBJECT TYPE is the OBJECT INDEX bit-shifted RIGHT two times to remove the 2 bits of object level
;   - Monsters have two sizes, depending on how far away they are from the PLAYER's position:
;       - Small (i.e. SKELETON_S): These monsters are two spaces forward, or one space diagonal left or right forward from the player. These graphics are usually 4x4 characters in size.
;       - Regular (i.e. SKELETON): These items are one space forward from the player. These graphics are usually 8x8 characters in size.
;

; =================================
; SKELETON -
;   OBJECT TYPE:  $1E
;   OBJECT INDEX:
;       $78 - RED SKELETON
;       $79 - YELLOW SKELETON
;       $7A - MAGENTA SKELETON
;       $7B - WHITE SKELETON
; The SKELETON is a basic monster.
;
SKELETON:
    db          $04,$04,$04,$04
    db          $02,$8A,$00,$EE,$ED,$01
    db          $02,$D6,$00,$A0,$17,$A0,$A7,$01
    db          $02,$D6,$E0,$AC,$B9,$E4,$01
    db          $02,"#",$A6,$E2,$E6,$A2,$B4,$01
    db          $02,$D6,$00,$F8,$ED,$B0,"#",$01
    db          $02,$D6,$E8,$A1,$00,$E5,$01
    db          $02,$D6,$A2,$E4,$00,$BA,$01
    db          $02,$D6,$00,$A6,$A8,$F1,$FF
SKELETON_S:
    db          $04,$04,$04
    db          "\b",$E2,$A5,$01
    db          $CD,$B8,$B7,$B4,$01
    db          $D6,$B8,$A9,$B0,$01
    db          $D6,$A2,$E8,$B1,$FF

; =================================
; SNAKE -
;   OBJECT TYPE:  $1F
;   OBJECT INDEX:
;       $7C - RED SNAKE
;       $7D - YELLOW SNAKE
;       $7E - MAGENTA SNAKE
;       $7F - WHITE SNAKE
; The SNAKE is a basic monster.
;
SNAKE:                                                      
    db          $04,$04,$04                                                                     
    db          $02,$B8,$BE,$F7,$BD,$B0,$01                                                     
    db          $02,$11,$11,$E2,$E9,$EA,$01                                                     
    db          $02,$D7,$AD,$E1,$B7,$B6,$01                                                     
    db          $02,$8D,$00,$B6,$FA,$E0,$F0,$01                                                 
    db          $02,$02,$B8,$A6,$FB,$B2,$FA,$F1,$A4,$E9,$01                                     
    db          $02,$02,$B5,$A2,$EA,$B2,$B2,$B4,$E0,$E6,$01                                     
    db          $02,$02,$A2,$AC,$A3,$E6,$F2,$AE,$E1,$BB,$FF                                     
SNAKE_S:
    db          $04,$04,$04
    db          $00,$FE,$F9,$01
    db          $00,"\"",$A0,$85,$A0,$97,$01
    db          $B8,$B6,$F6,$E4,$01
    db          $E5,$E7,$F9,$E6,$FF

; =================================
; SPIDER -
;   OBJECT TYPE:  $20
;   OBJECT INDEX:
;       $80 - RED SPIDER
;       $81 - YELLOW SPIDER
;       $82 - MAGENTA SPIDER
;       $83 - WHITE SPIDER
; The SPIDER is a basic monster.
;
SPIDER:
    db          $04,$04
    db          $00,$BE,$FD,$01
    db          $A0,$99,$A0,$F7,$EE,$98,$01
    db          $02,$B6,$B9,$FB,$F7,$E6,$E9,$01
    db          $02,$F7,$E6,$EE,$BD,$B9,$FB,$01
    db          $02,$12,$D6,$A0,$17,$8C,$A0,$D6,$12,$01
    db          $02,$A0,$99,$A0,$C7,"`'",$D9,$98,$FF
SPIDER_S:
    db          $04,$04,$04,$04
    db          $00,$D7,$C9,$01
    db          $D7,$95,$85,$C9,$01
    db          "M",$A0,$17,$8C,$A0,"M",$01
    db          "X`'X",$FF

; =================================
; MIMIC -
;   OBJECT TYPE:  $21
;   OBJECT INDEX:
;       $84 - RED MIMIC
;       $85 - YELLOW MIMIC
;       $86 - MAGENTA MIMIC
;       $87 - WHITE MIMIC
; The MIMIC is a basic monster.
;
MIMIC:
    db          $04,$02,$D7,$96,$00,$00,$96,$C9,$01
    db          $02,$12,$F0,$1F,$1F,$F0,$12,$01
    db          $02,$D6,$11,$A0,$17,$8C,$A0,$0F,$D6,$01
    db          $02,$C7,$A0,$18,$8D,$18,$8D,$A0,$D9,$01
    db          $A0,$81,$90,$90,$A0,$91,$01
    db          $A0,$D7,$FC,$FC,$C9,$A0,$FF
MIMIC_S:
    db          $04,$04,$01,$E0,$1F,$1F,$B0,$01
    db          $A0,$99,$A0,$80,$80,$98,$01
    db          $A2,$00,$00,$A1,$FF

; =================================
; MALOCCHIO -
;   OBJECT TYPE:  $22
;   OBJECT INDEX:
;       $88 - RED MIMIC
;       $89 - YELLOW MIMIC
;       $8A - MAGENTA MIMIC
;       $8B - WHITE MIMIC
; The MALOCCHIO is a basic monster.
;
MALOCCHIO:
    db          $04,$04,$04,$04
    db          $02,$A8,$B0,$B6,$00,$B6,$B0,$01
    db          $02,$B4,$E5,$BE,$EE,$B8,$E1,$01
    db          $02,$E2,$7F,$F6,$F8,$7F,$B1,$01
    db          $02,$A5,$A0,$14,$14,$14,$14,$A0,$EA,$01
    db          $02,$E8,$AB,$7F,$7F,$A7,$B4,$01
    db          $02,$C7,$A4,$00,$00,$A8,$D9,$FF
MALOCCHIO_S:
    db          $04,$04,$04,$04
    db          $00,$B6,$B8,$E0,$01
    db          $E3,$BE,$E9,$F1,$01
    db          $B9,$A0,$84,$84,$A0,$E4,$01
    db          $A2,$A6,$A1,$A5,$FF

; =================================
; DRAGON -
;   OBJECT TYPE:  $23
;   OBJECT INDEX:
;       $8C - RED DRAGON
;       $8D - YELLOW DRAGON
;       $8E - MAGENTA DRAGON
;       $8F - WHITE DRAGON
; The DRAGON is an advanced monster.
;
DRAGON:
    db          $04,$04,$04,$04
    db          $02,$B0,$E0,$00,$C0,$A0,$C2,$A0,$C1,$01
    db          $02,$02,$A0,$99,$A0,$C9,$D7,$98,$A0,$95,$95,$85,$A0,$81,$01
    db          $02,$02,$A0,$C3,$A4,$A8,$12,$85,$86,$85,$A0,$97,$01
    db          $02,$A0,$17,$8C,$A5," ",$94,$A0,$94,$A5,$01
    db          $02,$02,$D7,$F6,$F9,$7F,$7F,$7F,$7F,$B4,$01
    db          $02,$02,$A0,$B5,$95,$86," ",$84," ",$B0,$A0,$99,$01
    db          $02,$02,$A0,$C3,$D7,$A0,$94,$A0,$C9,$A0,$DB,$18,$A2,$C3,$01
    db          $02,$18,$00,$8D,$00,$00,$E8,$99,$01
    db          $00,$9E,$EC,$1F,$BF,$A1,$FF
DRAGON_S:
    db          $04,$04,$04,$C9,$C9,$C0,$C0,$01
    db          $ED,$A5,$A0,$95,$95,$A0,$01
    db          $A0,$92,$A0,$F9,$A0,$CA,$A0,$A7,$01
    db          $BA,$BF,$EF,$E9,$01
    db          $D9,$D9,"\a",$AB,$FF

; =================================
; MUMMY -
;   OBJECT TYPE:  $24
;   OBJECT INDEX:
;       $90 - RED MUMMY
;       $91 - YELLOW MUMMY
;       $92 - MAGENTA MUMMY
;       $93 - WHITE MUMMY
; The MUMMY is an advanced monster.
;
MUMMY:                                                      
    db          $04,$04,$04,$04                                                                 
    db          $D7,$FC,$C9,$01                                                                 
    db          $02,$02,$D7,$C9,$95,$A0,$93,$A0,$B4,$00,$D7,$C9,$01                             
    db          $02,$02,$A0,$97,$A0,$84,$A0,$94,$84,$94,$A0,$84,$A0,$D9,$A0,$97,$01             
    db          $02,$02,$A0,$B5,$F8,$C9,$84,$94,$D2,$D6,$A0,$01                                 
    db          $02,$02,$A0,$C3,$A0,$00,$95,$A0,$84,$94,$7F,$12,$A0,$01                         
    db          $02,$02,$A0,$91,$BF,$94,$E0,$94,$AA,$91,$A0,$01                                 
    db          $02,$95,$A0,$95,$A0,$00,$11,$A0,$95,$A0,$01                                     
    db          $02,$A0,$D9,$A0,$85,$00,"'",$A0,$85,$A0,$C9,$FF                                 
MUMMY_S:
    db          $04,$04,$04
    db          $1C,$EA,$B1,$1A,$01
    db          $11,$EF,$BF,$0F,$01
    db          $D6,$A0,$D9,$C7,$A0,"`",$01
    db          $E0,$B5,$EA,$B0,$FF

; =================================
; NECROMANCER -
;   OBJECT TYPE:  $25
;   OBJECT INDEX:
;       $94 - RED NECROMANCER
;       $95 - YELLOW NECROMANCER
;       $96 - MAGENTA NECROMANCER
;       $97 - WHITE NECROMANCER
; The NECROMANCER is an advanced monster.
;
NECROMANCER:                                                
    db          $04,$04,$04,$04                                                                 
    db          $02,$D7,$D0,$A0,$11,$0F,$A0,$D0,$C9,$01                                         
    db          $02,$02,$D7,$8D,$D1,$A4,$A4,$D1,$18,$C9,$01                                     
    db          $02,$02,$D6,$E9,$A0,$D9,$A0,$9C,$D7,$A0,$C7,$A0,$B6,$D6,$01                     
    db          $02,$02,$12,$FA,$EF,$A0,$C2,$A0,$7F,$BF,$F5,$12,$01                             
    db          $02,$02,$C7,$A7,$E2,$AF,$ED,$B1,$AB,$D9,$01                                     
    db          $7F,$A0,$D6,$A0,$7F,$FD,$01                                                     
    db          $02,$A0,$99," ",$19,"  ",$A0,$98,$01,$02,$C7,$A0,$88," ",$90,$F0,$A0,$D9,$FF    
NECROMANCER_S:
    db          $04,$04,$04
    db          "\v",$E2,$DB,"\f",$01
    db          $9F,$A0,$C9,$D7,$A0,$9F,$01
    db          $00,$12,$99,$01
    db          $00,$FD,$91,$FF

; =================================
; GRYPHON -
;   OBJECT TYPE:  $26
;   OBJECT INDEX:
;       $98 - RED GRYPHON
;       $99 - YELLOW GRYPHON
;       $9A - MAGENTA GRYPHON
;       $9B - WHITE GRYPHON
; The GRYPHON is an advanced monster.
;
GRYPHON:                                                    
    db          $04,$04,$04,$04                                                                 
    db          $02,$88,$90,$88,$F0,$01                                                         
    db          $02,$02,$BE,$A0,$AC,$A0,$ED,$95,$A0,$85,$A0,$F5,$01                             
    db          $02,$02,$A0,$95,$95,$95,$A0,$B5,$86,$91,$01                                     
    db          $02,$02,$A0,$95,$95,$95,$A0,$C3,$95,$E5,$A0,$C7,$A0,$B0,$01                     
    db          $02,$02,$A0,$95,$95,$A0,$A1,$EF,$F4,$EF,$F5,$A0,",",$A0,$01                     
    db          $02,$02,$12,$B9,$7F,$F5,$7F,$F5,"\r",$C7,$01                                    
    db          $02,$02,$B6,$EA,$F7,$E7,$7F,$EB,$F5,$01                                         
    db          $02,$02,$8B,$C7,$BF,$B6,$EF,$ED,$EB,$E5,$FF                                     
GRYPHON_S:
    db          $04,$04,$04,$B8,$B8,$B0,$01
    db          $A0,$95,$95,$A0,$12,$C9,$01
    db          $E1,$A0,$D9,$D9,$A0,$8D,$01
    db          "(",$E7,$E7,$E5,$FF

; =================================
; MINOTAUR -
;   OBJECT TYPE:  $27
;   OBJECT INDEX:
;       $9C - RED MINOTAUR
;       $9D - YELLOW MINOTAUR
;       $9E - MAGENTA MINOTAUR
;       $9F - WHITE MINOTAUR
; The MINOTAUR is an boss level monster. Killing a MINOTAUR completes the game.
;
MINOTAUR:                                                   
    db          $04,$04,$04,$04                                                                 
    db          $E8,$A1,$E9,$01                                                                 
    db          $EB,$EF,$EF,$A1,$01                                                             
    db          $02,$02,$E0,$B8,$B4,$FB,$B1,$E4,$F0,$01                                         
    db          $02,$02,$F6,$E6,$FE,$F4,$E8,$ED,$FD,$ED,$01                                     
    db          $02,$02,$E9,$B5,$BF,$E1,$EA,$FB,$FE,$FB,$01                                     
    db          $02,$02,$A1,$E0,$FE,$7F,$FD,$B9,$AD,$A1,$01                                     
    db          $02,$A2,$7F,$B4,$FE,$B7,$01,$02,$BE,$B6,$00,$A2,$BE,$B4,$FF                     
MINOTAUR_S:
    db          $04,$04,$04,$04
    db          $00,$ED,$BE,$01
    db          $D7,$E6,$B9,$D2,$01
    db          "\n",$8E,$ED,$C2,$01
    db          $00,$16,$83,$FF


; OTHER GRAPHICS

; STATS
;   Stats labels are shown in the right side of the screen to identify a player's health and other statistics in real-time.
;
STATS_TXT:
    db          "PHYS",$D6,"SPRT",$FF
    db          $D6,$00,$00,$00,$00,"Health",$01
    db          $D6,$00,$00,$00,$00,"Shield",$01
    db          $D6,$00,$00,$00,$00,"Weapon",$FF

; COMPASS
;   The compass is the right side of the screen, and points in the direction that the PLAYER is currently facing.
;
COMPASS:
    db          $D7,"n",$C9,$01
    db          "w\be",$01
    db          $C7,"s",$D9,$FF

; POOF Animation
;   The POOF animation is played when a MONSTER or ITEM disappears.
;       - For MONSTERS, it is when they are killed by the player. Their graphic is replaced with the POOF Animation, and then the empty maze space is rerendered as blank.
;       = For ITEMS, they can disappear if they break or are used up (like a POTION). This occurs in the PLAYER's RIGHT HAND.
;
POOF_1:
    db          $D7,$C9,$01
    db          $C7,$D9,$FF
POOF_2:
    db          $D1,$D1,$01
    db          $D1,$D1,$FF
POOF_3:
    db          $D1,$D1,$D1,$D1,$01
    db          $D1,$D0,$D0,$D1,$01
    db          $D1,$D0,$D0,$D1,$01
    db          $D1,$D1,$D1,$D1,$FF
POOF_4:
    db          $01,$00,$D0,$D0,$01
    db          $00,$D0,$D0,$FF
POOF_5:
    db          $D0,$D0,$D0,$D0,$01
    db          $D0,$00,$00,$D0,$01
    db          $D0,$00,$00,$D0,$01
    db          $D0,$D0,$D0,$D0,$FF
POOF_6:
    db          "    ",$01
    db          "    ",$01
    db          "    ",$01
    db          "    ",$FF

; AUTHORS
;   The Author's credits can be viewed on the TITLE SCREEN when the A (About) key is pressed on the keyboard.
;
AUTHORS:
    db          "   Originally programmed by Tom Loughry ",$01
    db          "  New GFX & routines by Sean Harrington ",$FF

; LEVEL_99_LOOP
;   The level 99 overflow text is shown when the player completes maze level 99 without killing the MINOTAUR. Their level is set back to 90, and they continue playing.
;
; LEVEL_99_LOOP:
;     db          "Looks like this dungeon",$01
;     db          "is too small for you",$01
;     db          "so we will put you back",$01
;     db          "into a new floor #90.",$FF

; Characters for the pointer on the COMPASS
WEST_TXT:
    db          "\a",$FF
NORTH_TXT:
    db          "\b",$FF
SOUTH_TXT:
    db          "\t",$FF
EAST_TXT:
    db          $06,$FF

VP_LH_GAP:
    db          $A0,127,$01
    db          195,$01
    db          181,$01
    db          195,$01
    db          127,$FF

VP_RH_GAP:
    db          $A0,127,$01
    db          $A0,151,$01
    db          181,$01
    db          151,$01
    db          $A0,127,$FF

PACK_BKGD:
    db          0,0,0,144,136,240,240,31,31,31,240,240,136,144,$01
    db          0,248,$A0,31,252,137,128,128,0,0,0,128,128,137,252,31,$A0,244,$02,$03,27,$01
    db          $04,234,29,$01
    db          18,$01
    db          18,$01
    db          18,$01
    db          18,$01
    db          18,$01
    db          18,$01
    db          18,$01
    db          18,$01
    db          18,$01
    db          234,28,$01
    db          0,171,31,136,144,0,0,0,0,0,0,0,144,136,31,167,$FF

END_PORTAL_TEXT:
    db          "  Asterion the Minotaur ",$01
    db          "is dead. A portal opens,",$01
    db          "allowing you to exit the",$01
    db          "Maze to the world above.",$01,$01
    db          "  PRESS ANY KEY TO EXIT ",$FF
    
END_PORTAL:
    db          $04,$04,$04,$04
    db          208,208,208,208,$01
    db          $02,208,209,209,209,209,208,$01
    db          $02,$02,208,209,127,127,127,127,209,208,$01
    db          $02,$02,208,209,127,127,127,127,209,208,$01
    db          $02,$02,208,209,127,127,127,127,209,208,$01
    db          $02,$02,208,209,127,127,127,127,209,208,$01
    db          $02,$02,208,209,127,127,127,127,209,208,$01
    db          $02,$02,208,209,127,127,127,127,209,208,$FF
    
MAP_LEGEND_WALLS:
    db          196,$00,"walls",$FF
MAP_LEGEND_PLAYER:
    db          196,$00,"player",$FF
MAP_LEGEND_LADDER:
    db          196,$00,"ladder",$FF
MAP_LEGEND_MONSTERS:
    db          196,$00,"monsters",$FF
MAP_LEGEND_ITEMS:
    db          196,$00,"items",$FF

PLAYER_DIES_TEXT:
    db          "     You have died.     ",$FF
PLAYER_SKELETON_TEXT:
    db          " The azure stone of the ",$01
    db          " maze absorbs your body ",$01
    db          "   and reanimates the   ",$01
    db          "   bones as a servant   ",$01
    db          "      of Asterion...    ",$01,$01
    db          "  PRESS ANY KEY TO EXIT ",$FF

PLAYER_AS_SKELETON:
    db          $04,$04,$04,$04
    db          190,189,$00,$00,8,$01
    db          239,$A0,140,$A0,$00,$00,214,$01
    db          $02,224,190,176,$00,$00,35,$01
    db          $02,168,187,182,172,227,35,$01
    db          $02,162,182,162,166,161,214,$01
    db          $02,170,190,228,176,$00,214,$01
    db          233,$00,234,$00,214,$01
    db          $02,187,228,181,226,228,214,$FF

LEVEL_99_START_TEXT:
    db          $01,$01
    db          "Well, aren't you clever?",$FF
LEVEL_99_DETAIL_TEXT:
    db          $01,$01
    db          "Your talent has exceeded",$01
    db          "the bounds of this maze.",$01
    db          "    But you shall not   ",$01
    db          "    escape so easily!   ",$01,$01
    db          "      PREPARE TO BE     ",$01
    db          "       TELEPORTED...    ",$FF

