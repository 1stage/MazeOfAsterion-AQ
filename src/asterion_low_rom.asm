NO_GFX:
    db          $FF
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
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
LEVEL_99_LOOP:
    db          "Looks like this dungeon",$01
    db          "is too small for you",$01
    db          "so we will put you back",$01
    db          "into a new floor #90.",$FF
STATS_TXT:
    db          "PHYS",$D6,"SPRT",$FF
    db          $D6,$00,$00,$00,$00,"Health",$01
    db          $D6,$00,$00,$00,$00,"Shield",$01
    db          $D6,$00,$00,$00,$00,"Weapon",$FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
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
RING:
    db          $01,$01,$01,$01,$01,$01,$01
    db          $00,"o",$FF
RING_S:
    db          $01,$01,$01
    db          $00,$C6,$FF
RING_T:
    db          $00,".",$FF
ARROW_FLYING_LEFT:
    db          $01,$01,$01,$01,$01,$01
    db          $9B,$AC,$FF
ARROW_FLYING_RIGHT:
    db          $01,$01,$01,$01,$01,$01
    db          $AC,$9A,$FF
QUIVER:
    db          $01,$01,$01,$01,$01,$01
    db          $7F,$7F,$A0,$D7,$A0,$06,$01
    db          $A2,$AC,$B2,$E9,$01
    db          $00,$00,$A2,$A1,$FF
QUIVER_S:
    db          $01,$01
    db          $00,$AF,$BD,$B0,$01
    db          $00,$00,$A2,$FF
QUIVER_T:
    db          $00,$F0,$FF
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
CHALICE:
    db          $01,$01,$01,$01,$01,$01
    db          $A0,$C3,$A0,$89,$97,$01
    db          $00,$9F,$01
    db          $E0,$0E,$B0,$FF
CHALICE_S:
    db          $01,$01
    db          $00,$9F,$01
    db          $00,$CC,$FF
CHALICE_T:
    db          $00,"Y",$FF
HELMET:
    db          $01,$01,$01,$01,$01,$01
    db          $00,$C0,$C1,$01
    db          $00,$BF,$EF,$FF
HELMET_S:
    db          $01,$01,$01
    db          $04,$00,$D2,$01
    db          $00,$A3,$FF
HELMET_T:
    db          $00,"^",$FF
KEY:
    db          $01,$01,$01,$01,$01,$01
    db          $90,$90,$B8,$C9,$01
    db          $10,$A0,$80,$A0,$A9,$D9,$FF
KEY_S:
    db          $01,$01,$01
    db          $BC,$C5,$FF
KEY_T:
    db          $FF,"-",$FF
BOW:
    db          $01,$01,$01,$01,$01
    db          $D7,$AC,$A3,$8E,$01
    db          $D6,$00,$CA,$01
    db          $B5,$CA,$01
    db          $9F,$00,$FF
BOW_S:
    db          $01,$01
    db          $D7,$AC,$C9,$01
    db          $D6,$CA,$01
    db          $C7,$FF
BOW_T:
    db          $00,"{",$FF
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
CHEST:
    db          $01,$01,$01,$01,$01
    db          $90,$88,$88,$90,$01
    db          $A0,$90,$88,$88,$90,$A0,$01
    db          $A0,$81,$90,$90,$A0,$91,$01
    db          $A0,$D7,$FC,$FC,$C9,$A0,$FF
LOCKED_CHEST:
    db          $01,$01,$01,$01,$01
    db          $90,$88,$88,$90,$01
    db          $A0,$90,$88,$88,$90,$A0,$01
    db          $A0,$81,$CB,$DB,$A0,$91,$01
    db          $A0,$D7,$FC,$FC,$C9,$A0,$FF
CHEST_S:
    db          $01,$E0,$1F,$1F,$B0,$01
    db          $A0,$99,$A0,$80,$80,$98,$01
    db          $A2,$00,$00,$A1,$FF
CHEST_T:
    db          $00,$FC,$FF
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
PAVICE:
    db          $01,$01,$01,$01,$01
    db          $E8,$F0,$F0,$B4,$01
    db          $EA,$7F,$7F,$B5,$01
    db          $EA,$7F,$7F,$B5,$01
    db          $00,$EF,$BF,$FF
PAVICE_S:
    db          $01,$01
    db          $00,$F4,$F8,$01
    db          $00,$7F,$7F,$01
    db          $00,$AB,$A7,$FF
PAVICE_T:
    db          $00,$7F,$01
    db          $00,$C2,$FF
AUTHORS:
    db          "   Originally programmed by Tom Loughry ",$01
    db          "  New GFX & routines by Sean Harrington ",$FF

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
GFX_BUFFER:
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
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
MIMIC:
    db          $04,$02,$D7,$96,$00,$00,$96,$C9,$01
    db          $02,$12,$F0,$1F,$1F,$F0,$12,$01
    db          $02,$D6,$11,$A0,$17,$8C,$A0,$0F,$D6,$01
    db          $02,$C7,$A0,$18,$8D,$18,$8D,$A0,$D9,$01
    db          $A0,$81,$90,$90,$A0,$91,$01
    db          $A0,$D7,$FC,$FC,$C9,$A0,$FF
MIMIC_S:
    db          $01,$E0,$1F,$1F,$B0,$01
    db          $A0,$99,$A0,$80,$80,$98,$01
    db          $A2,$00,$00,$A1,$FF
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
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
SUB_ram_c869:
    LD          DE,$29                                 ;GRN on DKCYN
                                                        ;(bottom of closed door)
SUB_ram_c86c:
    LD          (HL),A
    SCF
    CCF
    SBC         HL,DE
SUB_ram_c871:
    LD          (HL),A
    SCF
    CCF
    SBC         HL,DE
    LD          (HL),A
    SBC         HL,DE
    LD          (HL),A
    RET
    LD          DE,$29                                 ;GRN on DKCYN
                                                        ;(bottom of closed door)
SUB_ram_c87e:
    LD          (HL),A
    ADD         HL,DE
LAB_ram_c880:
    LD          (HL),A
    ADD         HL,DE
    LD          (HL),A
    ADD         HL,DE
    LD          (HL),A
    RET
SUB_ram_c886:
    LD          (HL),A
    ADD         HL,DE
    LD          (HL),A
    INC         HL
    LD          (HL),A
    ADD         HL,DE
    INC         HL
    LD          (HL),A
    DEC         HL
    LD          (HL),A
    DEC         HL
    LD          (HL),A
    RET
SUB_ram_c893:
    LD          (HL),A
    ADD         HL,DE
    LD          (HL),A
    DEC         HL
    LD          (HL),A
    ADD         HL,DE
    INC         HL
    LD          (HL),A
    DEC         HL
    LD          (HL),A
    DEC         HL
    LD          (HL),A
    RET
SUB_ram_c8a0:
    LD          (HL),A
    INC         HL
    LD          (HL),A
    INC         HL
    LD          (HL),A
    ADD         HL,DE
    DEC         HL
    LD          (HL),A
    DEC         HL
    LD          (HL),A
    ADD         HL,DE
    LD          (HL),A
    RET
SUB_ram_c8ad:
    LD          (HL),A
    INC         HL
    LD          (HL),A
    INC         HL
    LD          (HL),A
    ADD         HL,DE
    DEC         HL
    LD          (HL),A
    INC         HL
    LD          (HL),A
    ADD         HL,DE
    LD          (HL),A
    RET
DRAW_ROW:
    LD          (HL),A
    DEC         B
    RET         Z
    INC         HL
    JP          DRAW_ROW
    LD          DE,$28                                 ;DE = 40 (next line) / $28
DRAW_CELL:
    LD          (HL),A
    DEC         C
    RET         Z
    ADD         HL,DE                                   ;Goto next row
    JP          DRAW_CELL
FILL_CHRCOL_RECT:
    LD          DE,$28                                 ;DE = 40 / $28 (next row)
DRAW_CHRCOLS:
    PUSH        HL
    PUSH        BC
    CALL        DRAW_ROW
    POP         BC
    POP         HL
    DEC         C
    RET         Z
    ADD         HL,DE
    JP          DRAW_CHRCOLS
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
DRAW_F0_WALL:
    LD          HL,COLRAM_F0_WALL_MAP_IDX               ;= $60    `
    LD          BC,$1010                               ;16 x 16 rectangle
    LD          A,$44                                  ;BLU on BLU
    JP          FILL_CHRCOL_RECT
DRAW_F0_WALL_AND_CLOSED_DOOR:
    CALL        DRAW_F0_WALL
    LD          A,$22                                  ;GRN on GRN
DRAW_DOOR_F0:
    LD          HL,COLRAM_F0_DOOR_IDX                   ;= $60
    LD          BC,$80c                                ;8 x 12 rectangle
    JP          FILL_CHRCOL_RECT
DRAW_WALL_F0_AND_OPEN_DOOR:
    CALL        DRAW_F0_WALL
    LD          A,$f0                                  ;DKGRY on BLK
                                                        ;WAS BLK on DKBLU
                                                        ;WAS LD A,0xb
    JR          DRAW_DOOR_F0
DRAW_WALL_F1:
    LD          HL,CHRRAM_F1_WALL_IDX                   ;= $20
    LD          BC,$808                                ;8 x 8 rectangle
    LD          A,$20                                  ;Change to SPACE 32 / $20
                                                        ;WAS d134 / $86 crosshatch char
                                                        ;WAS LD A, $86
    CALL        FILL_CHRCOL_RECT
    LD          C,0x8
    LD          HL,COLRAM_F0_DOOR_IDX                   ;= $60
    LD          A,$4b                                  ;BLU on DKBLU
    JP          DRAW_CHRCOLS
DRAW_WALL_F1_AND_CLOSED_DOOR:
    CALL        DRAW_WALL_F1
    LD          A,$2d                                  ;GRN on DKGRN
DRAW_DOOR_F1_OPEN:
    LD          HL,COLRAM_F1_DOOR_IDX                   ;= $60    `
    LD          BC,$406                                ;4 x 6 rectangle
    JP          FILL_CHRCOL_RECT
DRAW_WALL_F1_AND_OPEN_DOOR:
    CALL        DRAW_WALL_F1
    LD          A,0x0                                   ;BLK on BLK
    JR          DRAW_DOOR_F1_OPEN
DRAW_WALL_F2:
    LD          BC,$404                                ;4 x 4 rectangle
    LD          HL,COLRAM_F1_DOOR_IDX                   ;= $60    `
    LD          A,$ff                                  ;DKGRY on DKGRY
                                                        ;WAS BLK on DKBLU
                                                        ;WAS LD A,0xb
    JP          FILL_CHRCOL_RECT
DRAW_DOOR_F2_OPEN:
    LD          HL,COLRAM_F1_DOOR_IDX                   ;= $60    `
    LD          A,0x0                                   ;BLK on BLK
UPDATE_FO_ITEM:
    LD          BC,$404                                ;4 x 4 rectangle
    JP          FILL_CHRCOL_RECT
DRAW_WALL_FL0:
    LD          HL,COLRAM_FL00_WALL_IDX                 ;= $60    `
    LD          A,$40                                  ;BLU on BLK
                                                        ;WAS BLU on CYN
                                                        ;WAS LD A,$46
    CALL        SUB_ram_c869
    DEC         DE
    ADD         HL,DE
    LD          A,0x4                                   ;BLK on BLU
    CALL        SUB_ram_c886
    ADD         HL,DE
    LD          BC,$410                                ;Jump into COLRAM and down one row
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    CALL        SUB_ram_c8a0
    ADD         HL,DE
    LD          A,$f4                                  ;DKGRY on BLU
                                                        ;WAS DKCYN on BLU
                                                        ;WAS LD A,$94
    DEC         DE
    CALL        SUB_ram_c86c
    LD          A,$c0
    LD          HL,DAT_ram_33c0                         ;= $20
    CALL        SUB_ram_c86c
    LD          HL,IDX_VIEWPORT_CHRRAM                  ;= $20
    LD          A,$c1
    INC         DE
    INC         DE
    JP          SUB_ram_c87e
    RET
DRAW_DOOR_FLO:
    CALL        DRAW_WALL_FL0
    LD          A,$f0                                  ;DKGRY on BLK
                                                        ;WAS DKCYN on DKBLU
                                                        ;WAS LD A,$9b
    EX          AF,AF'
    LD          A,0x4                                   ;BLK on BLU
                                                        ;WAS DKBLU on BLU
                                                        ;LD A,$b4
    JR          LAB_ram_c99e
SUB_ram_c996:
    CALL        DRAW_WALL_FL0
    LD          A,$f2                                  ;DKGRY on GRN
                                                        ;WAS DKCYN on GRN
                                                        ;WAS LD A,$92
    EX          AF,AF'
    LD          A,$24                                  ;GRN on BLU
LAB_ram_c99e:
    LD          HL,DAT_ram_351a                         ;= $60    `
    CALL        SUB_ram_c871
    DEC         DE
    ADD         HL,DE
    EX          AF,AF'
    CALL        SUB_ram_c886
    ADD         HL,DE
    LD          BC,$30c
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    CALL        SUB_ram_c8a0
    ADD         HL,DE
    DEC         DE
    CALL        SUB_ram_c871
    LD          HL,DAT_ram_30c8                         ;= $20
    LD          A,$c1
    INC         DE
    INC         DE
    JP          LAB_ram_c880
    RET
SUB_ram_c9c5:
    LD          HL,DAT_ram_34c8                         ;= $60    `
    LD          A,0x4                                   ;BLK on BLU
    LD          BC,$410                                ;4 x 10 rectangle
    JP          FILL_CHRCOL_RECT
SUB_ram_c9d0:
    LD          HL,DAT_ram_3168                         ;= $20
    LD          BC,$408                                ;4 x 8 rectangle
    LD          A,$20                                  ;Change to SPACE 32 / $20
                                                        ;WAS d134 / $86 crosshatch char
                                                        ;WAS LD A, $86
    CALL        FILL_CHRCOL_RECT
    LD          HL,DAT_ram_3568                         ;= $60
    LD          C,0x8
    LD          A,$4b                                  ;BLU on DKBLU
    JP          DRAW_CHRCOLS
SUB_ram_c9e5:
    CALL        SUB_ram_c9d0
    LD          A,$dd                                  ;DKGRN on DKGRN
LAB_ram_c9ea:
    LD          HL,DAT_ram_35ba                         ;= $60    `
    LD          BC,$206                                ;2 x 6 rectangle
    JP          DRAW_CHRCOLS
SUB_ram_c9f3:
    CALL        SUB_ram_c9d0
    XOR         A
    JR          LAB_ram_c9ea
SUB_ram_c9f9:
    LD          HL,DAT_ram_3168                         ;= $20
    LD          A,$c1
    LD          (HL),A                    ;= $20
    LD          DE,$28
    ADD         HL,DE
    INC         HL
    LD          (HL),A                    ;= $20
    LD          HL,DAT_ram_3259                         ;= $20
    LD          A,$c0
    LD          (HL),A                    ;= $20
    ADD         HL,DE
    DEC         HL
    LD          (HL),A                    ;= $20
    LD          HL,DAT_ram_3568                         ;= $60
    LD          A,$bf                                  ;DKBLU on DKGRY
                                                        ;WAS DKBLU on DKCYN
                                                        ;WAS LD A,$b9
    LD          (HL),A                    ;= $60
    ADD         HL,DE
    INC         HL
    LD          (HL),A                    ;= $60
    DEC         HL
    LD          A,0xf                                   ;BLK on DKGRY
                                                        ;WAS BLK on DKBLU
                                                        ;WAS LD A,0xb
    LD          (HL),A                    ;= $60
    LD          BC,$204                                ;2 x 4 rectangle
    ADD         HL,DE             ;= $60    `
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    LD          (HL),A                    ;= $60
    INC         HL
    LD          A,0xf                                   ;BLK on DKGRY
                                                        ;WAS DKCYN on DKBLU
                                                        ;WAS LD A,$9b
    LD          (HL),A                    ;= $60
    ADD         HL,DE
    DEC         HL
    LD          (HL),A                    ;= $60
    LD          HL,DAT_ram_35ba                         ;= $60    `
    LD          C,0x4
    LD          A,0x0
    JP          DRAW_CHRCOLS
DRAW_WALL_FL22:
    LD          HL,COLRAM_FL22_WALL_IDX                 ;= $60    `
    LD          BC,$404                                ;4 x 4 rectangle
    LD          A,$ff                                  ;DKGRY on DKGRY
    JP          FILL_CHRCOL_RECT
DRAW_L1_WALL:
    LD          HL,CHRRAM_FL1_WALL_IDX                  ;= $20
    LD          A,$c1                                  ;LEFT angle CHR
    CALL        SUB_ram_c869
    DEC         DE
    ADD         HL,DE
    LD          A,$20                                  ;Change to SPACE 32 / $20
                                                        ;WAS d134 / $86 crosshatch char
                                                        ;WAS LD A, $86
    CALL        SUB_ram_c886
    ADD         HL,DE
    LD          BC,$408                                ;4 x 8 rectangle
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    CALL        SUB_ram_c8a0
    ADD         HL,DE
    LD          A,$c0                                  ;RIGHT angle CHR
    DEC         DE
    CALL        SUB_ram_c86c
    LD          HL,DAT_ram_3547                         ;= $60    `
    LD          A,$b0                                  ;DKBLU on BLK
                                                        ;WAS DKBLU on CYN
                                                        ;WAS LD A,$b6
    CALL        SUB_ram_c869
    DEC         DE
    ADD         HL,DE
    LD          A,$4b                                  ;BLU on DKBLU
    CALL        SUB_ram_c886
    ADD         HL,DE
    LD          BC,$408                                ;Jump to COLRAM + 32 cells
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    CALL        SUB_ram_c8a0
    ADD         HL,DE
    LD          A,$fb                                  ;DKGRY on DKBLU
                                                        ;WAS DKCYN on DKBLU
                                                        ;WAS LD A,$9b
    DEC         DE
    JP          SUB_ram_c86c
    RET
DRAW_FL1_DOOR:
    CALL        DRAW_L1_WALL
    LD          A,$f0                                  ;DKGRY on BLK
                                                        ;WAS DKCYN on BLK
                                                        ;WAS LD A,$90
    PUSH        AF
    LD          A,$b0                                  ;DKBLU on BLK
    PUSH        AF
    LD          A,0xb                                   ;BLK on DKGRY
                                                        ;WAS BLK on DKBLU
                                                        ;WAS LD A,0xb
    JR          DRAW_L1_DOOR
DRAW_L1:
    CALL        DRAW_L1_WALL
    LD          A,$fd                                  ;DKGRY on DKGRN
                                                        ;WAS DKCYN on DKGRN
                                                        ;WAS LD A,$9d
    PUSH        AF
    LD          A,$2d                                  ;GRN on DKGRN
    PUSH        AF
    LD          A,$db                                  ;DKGRN on DKBLU
DRAW_L1_DOOR:
    LD          HL,COLRAM_L1_DOOR_IDX                   ;= $60    `
    LD          BC,$207                                ;2 x 7 rectangle
    CALL        SUB_ram_cb1c
    LD          HL,CHRRAM_L1_DOOR_IDX                   ;= $20
    LD          A,$c1                                  ;LEFT ANGLE CHR
    LD          (HL),A              ;= $20
    LD          DE,$29
    ADD         HL,DE
    LD          (HL),A                    ;= $20
    RET
SUB_ram_cab0:
    LD          HL,DAT_ram_356c                         ;= $60    `
    LD          BC,$408                                ;4 x 8 rectangle
    LD          A,$4b                                  ;BLU on DKBLU
    CALL        FILL_CHRCOL_RECT
    LD          HL,DAT_ram_316c                         ;= $20
    LD          C,0x8
    LD          A,$20                                  ;Change to SPACE 32 / $20
                                                        ;WAS d134 / $86 crosshatch char
                                                        ;WAS LD A, $86
    JP          DRAW_CHRCOLS
SUB_ram_cac5:
    CALL        SUB_ram_cab0
    XOR         A
    JR          DRAW_L1_DOOR_2
DRAW_L1_DOOR_CLOSED:
    CALL        SUB_ram_cab0
    LD          A,$dd                                  ;DKGRN on DKGRN
DRAW_L1_DOOR_2:
    LD          HL,COLRAM_FL2_WALL_IDX                  ;= $60    `
    LD          BC,$206                                ;2 x 6 rectangle
    JP          DRAW_CHRCOLS
DRAW_WALL_FL2:
    LD          HL,COLRAM_FL2_WALL_IDX                  ;= $60    `
    LD          BC,$204                                ;2 x 4 rectangle
    LD          A,$11                                  ;BLK on DKGRY
    CALL        FILL_CHRCOL_RECT
    LD          C,0x4
    LD          HL,COLRAM_FL2_PLUS_WALL_IDX             ;= $60    `
    LD          A,$22                                  ;BLK on DKGRY
                                                        ;WAS BLK on DKBLU
                                                        ;WAS LD A,0xb
    JP          DRAW_CHRCOLS
DRAW_WALL_FL2_EMPTY:
    LD          HL,COLRAM_FL2_WALL_IDX                  ;= $60    `
    LD          BC,$404                                ;4 x 4 rectangle
    LD          A,0x0                                   ;BLK on BLK
    JP          FILL_CHRCOL_RECT
DRAW_WALL_L2:
    LD          A,$ca                                  ;Right slash char
    PUSH        AF
    LD          A,$20                                  ;GRN on BLK
    PUSH        AF
    LD          HL,CHRRAM_F1_WALL_IDX                   ;= $20
    LD          A,$c1                                  ;Left angle char
    LD          BC,$204                                ;2 x 4 rectangle
    CALL        SUB_ram_cb1c
    LD          A,0xf                                   ;FL2 Bottom Color
                                                        ;BLK on DKGRY
                                                        ;WAS DKCYN on DKBLU
                                                        ;WAS LD A,$9b
    PUSH        AF
    LD          A,0xf                                   ;FL2 Wall Color
                                                        ;BLK on DKGRY
                                                        ;WAS BLK on DKBLU
                                                        ;WAS LD A,0xb
    PUSH        AF
    LD          HL,COLRAM_F0_DOOR_IDX                   ;= $60
    LD          A,$f0                                  ;FL2 Top Color
                                                        ;DKGRY on BLK
                                                        ;WAS DKBLU on CYN
                                                        ;WAS LD A,$b6
    LD          BC,$204                                ;2 x 4 rectangle
    CALL        SUB_ram_cb1c
    RET
SUB_ram_cb1c:
    POP         IX
    LD          (HL),A
    LD          DE,$29                                 ;EDIT MEdb?
    ADD         HL,DE
    LD          (HL),A
    DEC         HL
    DEC         DE
    POP         AF
    LD          (HL),A
    ADD         HL,DE
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    LD          (HL),A
    ADD         HL,DE
    POP         AF
    LD          (HL),A
    SCF
    CCF
    SBC         HL,DE
    INC         HL
    LD          (HL),A
    JP          (IX)
DRAW_WALL_L2_C:
    LD          HL,DAT_ram_35c0                         ;= $60    `
    LD          BC,$204                                ;2 x 4 rectangle
    LD          A,0xf                                   ;BLK on DKGRY
                                                        ;WAS BLK on DKBLU
                                                        ;WAS LD A,0xb
    JP          FILL_CHRCOL_RECT
DRAW_WALL_L2_C_EMPTY:
    LD          HL,DAT_ram_35c0                         ;= $60    `
    LD          BC,$204                                ;2 x 4 rectangle
    LD          A,0x0                                   ;BLK on BLK
    JP          FILL_CHRCOL_RECT
SUB_ram_cb4f:
    LD          A,$f4                                  ;DKGRY on BLU
                                                        ;WAS DKCYN on BLU
                                                        ;WAS LD A,$94
    PUSH        AF
    LD          BC,$410
    LD          A,0x4                                   ;BLK on BLU
    PUSH        AF
    LD          A,$40                                  ;BLU on BLK
                                                        ;WAS BLU on CYN
                                                        ;WAS LD A, $46
    LD          HL,DAT_ram_34b4                         ;= $60    `
    CALL        SUB_ram_cc4d
    LD          HL,DAT_ram_303f                         ;= $20
    LD          A,$c0                                  ;Right angle char
    LD          DE,$27
    CALL        SUB_ram_c87e
    LD          HL,DAT_ram_335c                         ;= $20
    INC         A
    INC         DE
    INC         DE
    JP          SUB_ram_c87e
DRAW_FRO_DOOR:
    CALL        SUB_ram_cb4f
    LD          A,$f0                                  ;DKGRY on BLK
                                                        ;WAS DKCYN on DKBLU
                                                        ;WAS LD A,$9b
    EX          AF,AF'
    LD          A,0x4                                   ;BLK on BLU
                                                        ;WAS DKBLU on BLU
                                                        ;WAS LDA A,$b4
    JR          LAB_ram_cb86
SUB_ram_cb7e:
    CALL        SUB_ram_cb4f
    LD          A,$f2                                  ;DKGRY on GRN
                                                        ;WAS DKCYN on GRN
                                                        ;WAS LD A,$92
    EX          AF,AF'
    LD          A,$24                                  ;GRN on BLU
LAB_ram_cb86:
    LD          HL,DAT_ram_352d                         ;= $60    `
    DEC         DE
    DEC         DE
    CALL        SUB_ram_c871
    INC         DE
    ADD         HL,DE
    EX          AF,AF'
    CALL        SUB_ram_c893
    ADD         HL,DE
    LD          BC,$30c
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    CALL        SUB_ram_c8ad
    ADD         HL,DE
    INC         DE
    CALL        SUB_ram_c871
    LD          HL,DAT_ram_30df                         ;= $20
    LD          A,$c0                                  ;Right angle char
    DEC         DE
    DEC         DE
    JP          LAB_ram_c880
SUB_ram_cbae:
    LD          HL,DAT_ram_34dc                         ;= $60    `
    LD          A,0x4                                   ;BLK on BLU
    LD          BC,$410                                ;4 x 10 rectangle
    JP          FILL_CHRCOL_RECT
SUB_ram_cbb9:
    LD          HL,DAT_ram_317c                         ;= $20
    LD          BC,$408
    LD          A,$20                                  ;Change to SPACE 32 / $20
                                                        ;WAS d134 / $86 crosshatch char
                                                        ;WAS LD A, $86
    CALL        FILL_CHRCOL_RECT
    LD          HL,DAT_ram_357c                         ;= $60    `
    LD          C,0x8
    LD          A,$4b                                  ;BLU on DKBLU
    JP          DRAW_CHRCOLS
SUB_ram_cbce:
    CALL        SUB_ram_cbb9
    XOR         A
    JR          LAB_ram_cbd9
SUB_ram_cbd4:
    CALL        SUB_ram_cbb9
    LD          A,$dd                                  ;DKGRN on DKGRNdb?
LAB_ram_cbd9:
    LD          HL,DAT_ram_35cc                         ;= $60    `
    LD          BC,$206                                ;2 x 6 rectangledb?
    JP          DRAW_CHRCOLS
SUB_ram_cbe2:
    LD          HL,DAT_ram_317f                         ;= $20
    LD          A,$c0                                  ;Right angle char
    LD          (HL),A                    ;= $20
    LD          DE,$28
    ADD         HL,DE
    DEC         HL
    LD          (HL),A                    ;= $20
    LD          HL,DAT_ram_326e                         ;= $20
    LD          A,$c1                                  ;Left angle char
    LD          (HL),A                    ;= $20
    ADD         HL,DE
    INC         HL
    LD          (HL),A                    ;= $20
    LD          HL,DAT_ram_357f                         ;= $60
    LD          A,$bf                                  ;DKBLU on DKGRY
                                                        ;WAS DKBLU on DKCYN
                                                        ;WAS LD A,$b9
    LD          (HL),A                    ;= $60
    ADD         HL,DE
    DEC         HL
    LD          (HL),A                    ;= $60
    INC         HL
    LD          A,0xf                                   ;BLK on DKGRY
                                                        ;WAS BLK on DKBLU
                                                        ;WAS LD A,0xb
    LD          (HL),A                    ;= $60
    LD          BC,$204                                ;2 x 4 rectangle
    ADD         HL,DE
    DEC         HL                        ;= $60    `
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    INC         HL
    LD          (HL),A                    ;= $60
    DEC         HL
    LD          A,0xf                                   ;BLK on DKGRY
                                                        ;WAS DKCYN on DKBLU
                                                        ;WAS LD A,$9b
    LD          (HL),A                    ;= $60
    ADD         HL,DE
    INC         HL
    LD          (HL),A                    ;= $60
    LD          HL,DAT_ram_35cc                         ;= $60    `
    LD          C,0x4
    LD          A,0x0
    JP          DRAW_CHRCOLS
DRAW_WALL_FR222_EMPTY:
    LD          HL,DAT_ram_35cc                         ;= $60    `
    LD          BC,$404                                ;4 x 4 rectangle
    LD          A,0x0                                   ;BLK on BLK
    JP          FILL_CHRCOL_RECT
DRAW_WALL_FR1:
    LD          A,$c1
    PUSH        AF
    LD          BC,$408                                ;4 x 8 rectangle
    LD          A,$20                                  ;Change to SPACE 32 / $20
                                                        ;WAS d134 / $86 crosshatch char
                                                        ;WAS LD A, $86
    PUSH        AF
    LD          A,$c0                                  ;Right angle char
    LD          HL,DAT_ram_3150                         ;= $20
    CALL        SUB_ram_cc4d
    LD          A,$fb                                  ;DKGRY on DKBLU
                                                        ;WAS DKCYN on DKBLU
                                                        ;WAS LD $9b
    PUSH        AF
    LD          C,0x8
    LD          A,$4b                                  ;BLU on DKBLU
    PUSH        AF
    LD          A,$b0                                  ;DKBLU on BLK
                                                        ;WAS DKBLU on CYN
                                                        ;WAS LD A,$b6
    LD          HL,DAT_ram_3550                         ;= $60    `
    CALL        SUB_ram_cc4d
    RET
SUB_ram_cc4d:
    POP         IX
    LD          DE,$27
    CALL        SUB_ram_c86c
    INC         DE
    ADD         HL,DE
    POP         AF
    CALL        SUB_ram_c893
    ADD         HL,DE
    DEC         HL
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    INC         HL
    CALL        SUB_ram_c8ad
    ADD         HL,DE
    POP         AF
    INC         DE
    CALL        SUB_ram_c86c
    JP          (IX)
SUB_ram_cc6d:
    CALL        DRAW_WALL_FR1
    LD          A,$f0                                  ;DKGRY on BLK
                                                        ;WAS DKCYN on BLK
                                                        ;WAS LD A,$90
    PUSH        AF
    LD          A,$b0                                  ;DKBLU on BLK
    PUSH        AF
    LD          A,0xb                                   ;BLK on DKBLU
    JR          LAB_ram_cc85
SUB_ram_cc7a:
    CALL        DRAW_WALL_FR1
    LD          A,$fd                                  ;DKGRY on DKGRN
                                                        ;WAS DKCYN on DKGRN
                                                        ;WAS LD A,$9d
    PUSH        AF
    LD          A,$2d                                  ;GRN on DKGRN
    PUSH        AF
    LD          A,$db                                  ;DKGRN on DKBLU
LAB_ram_cc85:
    LD          HL,DAT_ram_357a                         ;= $60    `
    LD          BC,$207                                ;2 x 7 rectangle
    CALL        SUB_ram_cd07
    LD          HL,DAT_ram_317a                         ;= $20
    LD          A,$c0                                  ;Right angle char
    LD          (HL),A                    ;= $20
    LD          DE,$27
    ADD         HL,DE
    LD          (HL),A                    ;= $20
    RET
SUB_ram_cc9a:
    LD          HL,DAT_ram_3578                         ;= $60    `
    LD          BC,$408                                ;4 x 8 rectangle
    LD          A,$4b                                  ;BLU on DKBLU
    CALL        FILL_CHRCOL_RECT
    LD          HL,DAT_ram_3178                         ;= $20
    LD          C,0x8
    LD          A,$20                                  ;Change to SPACE 32 / $20
                                                        ;WAS d134 / $86 crosshatch char
                                                        ;WAS LD A, $86
    JP          DRAW_CHRCOLS
SUB_ram_ccaf:
    CALL        SUB_ram_cc9a
    XOR         A
    JR          LAB_ram_ccba
SUB_ram_ccb5:
    CALL        SUB_ram_cc9a
    LD          A,$dd                                  ;DKGRN on DKGRN
LAB_ram_ccba:
    LD          HL,DAT_ram_35ca                         ;= $60    `
    LD          BC,$206                                ;2 x 6 rectangle
    JP          DRAW_CHRCOLS
SUB_ram_ccc3:
    LD          HL,DAT_ram_35ca                         ;= $60    `
    LD          BC,$204                                ;2 x 4 rectangle
    LD          A,0x0                                   ;BLK on BLK
    CALL        FILL_CHRCOL_RECT
    LD          C,0x4
    LD          HL,DAT_ram_35c8                         ;= $60    `
    LD          A,0xf                                   ;BLK on DKGRY
                                                        ;WAS BLK on DKBLU
                                                        ;WAS LD A, 0xb
    JP          DRAW_CHRCOLS
DRAW_WALL_FR2_EMPTY:
    LD          HL,DAT_ram_35c8                         ;= $60    `
    LD          BC,$404                                ;4 x 4 rectangle
    LD          A,0x0                                   ;BLK on BLK
    JP          FILL_CHRCOL_RECT
DRAW_WALL_FR2:
    LD          A,0xf                                   ;FR2 Bottom
                                                        ;BLK on DKGRY
                                                        ;WAS DKCYN on DKBLU
                                                        ;WAS LD A,$9b
    PUSH        AF
    LD          A,0xf                                   ;FR2 Wall
                                                        ;BLK on DKGRY
                                                        ;WAS BLK on DKBLU
                                                        ;WAS LD A,0xb
    PUSH        AF
    LD          A,$f0                                  ;FR2 Top
                                                        ;DKGRY on BLK
                                                        ;WAS DKBLU on CYN
                                                        ;WAS LD A,$b6
    LD          HL,DAT_ram_3577                         ;= $60    `
    LD          BC,$204                                ;2 x 4 rectangle
    CALL        SUB_ram_cd07
    LD          HL,DAT_ram_3266                         ;= $20
    LD          A,$da                                  ;Left slash char
    LD          (HL),A                    ;= $20
    ADD         HL,DE
    LD          (HL),A                    ;= $20
    LD          HL,DAT_ram_3177                         ;= $20
    LD          A,$c0                                  ;Right angle char
    LD          (HL),A                    ;= $20
    DEC         DE
    DEC         DE
    ADD         HL,DE
    LD          (HL),A                    ;= $20
    RET
SUB_ram_cd07:
    POP         IX
    LD          (HL),A
    LD          DE,$27
    ADD         HL,DE
    LD          (HL),A
    INC         HL
    POP         AF
    LD          (HL),A
    ADD         HL,DE
    INC         DE
    CALL        DRAW_CHRCOLS
    INC         DE
    ADD         HL,DE
    LD          (HL),A
    DEC         HL
    POP         AF
    LD          (HL),A
    ADD         HL,DE
    LD          (HL),A
    JP          (IX)
SUB_ram_cd21:
    LD          HL,DAT_ram_35c6                         ;= $60    `
    LD          BC,$204                                ;2 x 4 rectangle
    LD          A,0xf                                   ;BLK on DKGRY
                                                        ;WAS BLK on DKBLU
                                                        ;WAS LD A,0xb
    JP          FILL_CHRCOL_RECT
SUB_ram_cd2c:
    LD          HL,DAT_ram_35c6                         ;= $60    `
    LD          BC,$204                                ;2 x 4 rectangle
    LD          A,0x0                                   ;BLK on BLK
    JP          FILL_CHRCOL_RECT
    LD          A,0x8
    LD          (SOUND_REPEAT_COUNT),A
    LD          B,A
LAB_ram_cd3d:
    PUSH        BC
    CALL        SOUND_04
    CALL        SUB_ram_cde7
    CALL        SOUND_02
    CALL        SOUND_01
    POP         BC
    DJNZ        LAB_ram_cd3d
    RET
    LD          A,0x7
    LD          (SOUND_REPEAT_COUNT),A
    LD          B,A
LAB_ram_cd54:
    PUSH        BC
    CALL        SOUND_02
    CALL        SOUND_03
    POP         BC
    DJNZ        LAB_ram_cd54
    RET
SUB_ram_cd5f:
    LD          A,0xa
    LD          (SOUND_REPEAT_COUNT),A
    LD          B,A
LAB_ram_cd65:
    PUSH        BC
    CALL        SOUND_04
    CALL        SOUND_05
    POP         BC
    DJNZ        LAB_ram_cd65
    JP          SUB_ram_cdbf
POOF_SOUND:
    LD          A,0x7
    LD          (SOUND_REPEAT_COUNT),A
    LD          B,0x1
    JR          DOINK_SOUND
END_OF_GAME_SOUND:
    LD          A,0x4                                   ;Was LD A,0x7
    LD          (SOUND_REPEAT_COUNT),A
    LD          B,A
DOINK_SOUND:
    PUSH        BC
    CALL        SOUND_02
    CALL        SUB_ram_cde7
    CALL        SOUND_03
    POP         BC
    DJNZ        DOINK_SOUND
    RET
    CALL        SUB_ram_cde7
    CALL        SUB_ram_cde7
    CALL        SUB_ram_cde7
    CALL        SUB_ram_cde7
    CALL        SUB_ram_cde7
    CALL        SUB_ram_cde7
    CALL        SUB_ram_cde7
    CALL        SUB_ram_cde7
    CALL        SUB_ram_cde7
    CALL        SUB_ram_cde7
    CALL        SUB_ram_cde7
    CALL        SOUND_05
    CALL        SOUND_05
    CALL        SOUND_05
    CALL        SOUND_05
    JP          SOUND_05
SUB_ram_cdbf:
    LD          A,0x0
    PUSH        AF
    LD          BC,$40
    LD          DE,$15
    LD          HL,$400
    LD          A,0x0
    LD          (PITCH_UP_BOOL),A
    JP          PLAY_PITCH_CHANGE
SUB_ram_cdd3:
    LD          A,0x0
    PUSH        AF
    LD          BC,$a0
    LD          DE,0x8
    LD          HL,$800
    LD          A,0x0
    LD          (PITCH_UP_BOOL),A
    JP          PLAY_PITCH_CHANGE
SUB_ram_cde7:
    LD          A,0x0
    PUSH        AF
    LD          BC,$a0
    LD          DE,0x1
    LD          HL,0x2
    LD          A,0x0
    LD          (PITCH_UP_BOOL),A
    JP          PLAY_PITCH_CHANGE
SETUP_OPEN_DOOR_SOUND:
    LD          DE,0xf
    LD          HL,$580
LO_HI_PITCH_SOUND:
    LD          BC,0x8
    LD          A,0x0
    PUSH        AF
    LD          A,0x1
    LD          (PITCH_UP_BOOL),A
    JP          PLAY_PITCH_CHANGE
SETUP_CLOSE_DOOR_SOUND:
    LD          HL,0x5
    LD          DE,0xc
HI_LO_PITCH_SOUND:
    LD          BC,0xe                                  ;H
    XOR         A
    PUSH        AF
    LD          (PITCH_UP_BOOL),A
    JP          PLAY_PITCH_CHANGE
SOUND_01:
    LD          A,0x0
    PUSH        AF
    LD          BC,$30
    LD          DE,0x2
    LD          HL,$100
    LD          A,0x1
    LD          (PITCH_UP_BOOL),A
    JP          PLAY_PITCH_CHANGE
SOUND_02:
    LD          A,0x0
    PUSH        AF
    LD          BC,$1a
    LD          DE,$10
    LD          HL,$300
    LD          A,0x1
    LD          (PITCH_UP_BOOL),A
    JP          PLAY_PITCH_CHANGE
SOUND_03:
    LD          A,0x0
    PUSH        AF
    LD          BC,$2a
    LD          DE,0xa
    LD          HL,0x4
    LD          A,0x0
    LD          (PITCH_UP_BOOL),A
    JP          PLAY_PITCH_CHANGE
SOUND_04:
    LD          A,0x0
    PUSH        AF
    LD          BC,$20
    LD          DE,0x2
    LD          HL,$55
    LD          A,0x1
    LD          (PITCH_UP_BOOL),A
    JP          PLAY_PITCH_CHANGE
SOUND_05:
    LD          A,0x0
    PUSH        AF
    LD          BC,$30
    LD          DE,0x1
    LD          HL,0x1
    LD          A,0x0
    LD          (PITCH_UP_BOOL),A
    JP          PLAY_PITCH_CHANGE
PLAY_PITCH_CHANGE:
    LD          (SND_CYCLE_HOLDER),HL
PLAY_PITCH_CHANGE_LOOP:
    DEC         HL
    LD          A,H
    OR          L                                       ;Clear flags
    JR          NZ,PLAY_PITCH_CHANGE_LOOP
    POP         AF
    OUT         (SPEAKER),A                             ;= db
    XOR         0x1
    PUSH        AF
    DEC         BC
    LD          A,B
    OR          C
    JR          NZ,INCREASE_PITCH
    POP         AF
    LD          HL,(SND_CYCLE_HOLDER)
    RET
INCREASE_PITCH:
    LD          HL,PITCH_UP_BOOL
    BIT         0x0,(HL)
    JR          Z,DECREASE_PITCH
    LD          HL,(SND_CYCLE_HOLDER)
    SBC         HL,DE
    JR          PLAY_PITCH_CHANGE
DECREASE_PITCH:
    LD          HL,(SND_CYCLE_HOLDER)
    ADD         HL,DE
    JR          PLAY_PITCH_CHANGE
HC_JOY_INPUT_COMPARE:
    LD          A,(RAM_AE)
    CP          $31                                    ;Compare to "1" db?
    JP          NZ,WAIT_FOR_INPUT
    LD          HL,(HC_INPUT_HOLDER)                    ;= $6060
    LD          A,$f3                                  ;Compare to JOY disc UUL
    CP          L
    JP          Z,DO_MOVE_FW_CHK_WALLS
    CP          H
    JP          Z,DO_MOVE_FW_CHK_WALLS
    LD          A,$fb                                  ;Compare to JOY disc UP
    CP          L
    JP          Z,DO_MOVE_FW_CHK_WALLS
    CP          H
    JP          Z,DO_MOVE_FW_CHK_WALLS
    LD          A,$eb                                  ;Compare to JOY disc UUR
    CP          H
    JP          Z,DO_MOVE_FW_CHK_WALLS
    CP          L
    JP          Z,DO_MOVE_FW_CHK_WALLS
    LD          A,$e9                                  ;Compare to JOY disc UR
    CP          L
    JP          Z,DO_TURN_RIGHT
    CP          H
    JP          Z,DO_TURN_RIGHT
    LD          A,$f9                                  ;Compare to JOY disc RUR
    CP          L
    JP          Z,DO_TURN_RIGHT
    CP          H
    JP          Z,DO_TURN_RIGHT
    LD          A,$fd                                  ;Compare to JOY disc RIGHT
    CP          L
    JP          Z,DO_TURN_RIGHT
    CP          H
    JP          Z,DO_TURN_RIGHT
    LD          A,$e7                                  ;Compare to JOY disc LUL
    CP          L
    JP          Z,DO_TURN_LEFT
    CP          H
    JP          Z,DO_TURN_LEFT
    LD          A,$e3                                  ;Compare to JOY disc UL
    CP          L
    JP          Z,DO_TURN_LEFT
    CP          H
    JP          Z,DO_TURN_LEFT
    LD          A,$f7                                  ;Compare to JOY disc LEFT
    CP          L
    JP          Z,DO_TURN_LEFT
    CP          H
    JP          Z,DO_TURN_LEFT
    LD          A,$f6                                  ;Compare to JOY disc LDL
    CP          L
    JP          Z,DO_GLANCE_LEFT
    CP          H
    JP          Z,DO_GLANCE_LEFT
    LD          A,$e6                                  ;Compare to JOY disc DL
    CP          L
    JP          Z,DO_GLANCE_LEFT
    CP          H
    JP          Z,DO_GLANCE_LEFT
    LD          A,$ed                                  ;Compare to JOY disc RDR
    CP          L
    JP          Z,DO_GLANCE_RIGHT
    CP          H
    JP          Z,DO_GLANCE_RIGHT
    LD          A,$ec                                  ;Compare to JOY disc DR
    CP          L
    JP          Z,DO_GLANCE_RIGHT
    CP          H
    JP          Z,DO_GLANCE_RIGHT
    LD          A,$fc                                  ;Compare to JOY disc DDR
    CP          L
    JP          Z,DO_JUMP_BACK
    CP          H
    JP          Z,DO_JUMP_BACK
    LD          A,$fe                                  ;Compare to JOY disc DOWN
    CP          L
    JP          Z,DO_JUMP_BACK
    CP          H
    JP          Z,DO_JUMP_BACK
    LD          A,$ee                                  ;Compare to JOY disc DDL
    CP          L
    JP          Z,DO_JUMP_BACK
    CP          H
    JP          Z,DO_JUMP_BACK
    LD          A,$df                                  ;Compare to JOY K4
    CP          L
    JP          Z,TOGGLE_SHIFT_MODE
    CP          H
    JP          Z,TOGGLE_SHIFT_MODE
    LD          A,(GAME_BOOLEANS)
    BIT         0x1,A
    JP          NZ,DO_HC_SHIFT_ACTIONS
DO_HC_BUTTON_ACTIONS:
    LD          A,$bf                                  ;Compare to JOY K1
    CP          L
    JP          Z,DO_USE_ATTACK
    CP          H
    JP          Z,DO_USE_ATTACK
    LD          A,$7b                                  ;Compare to JOY K2
    CP          L
    JP          Z,DO_OPEN_CLOSE
    CP          H
    JP          Z,DO_OPEN_CLOSE
    LD          A,$5f                                  ;Compare to JOY K3
    CP          L
    JP          Z,DO_PICK_UP
    CP          H
    JP          Z,DO_PICK_UP
    LD          A,$7d                                  ;Compare to JOY K5
    CP          L
    JP          Z,DO_SWAP_PACK
    CP          H
    JP          Z,DO_SWAP_PACK
    LD          A,$7e                                  ;Compare to JOY K6
    CP          L
    JP          Z,DO_ROTATE_PACK
    CP          H
    JP          Z,DO_ROTATE_PACK
    JP          NO_ACTION_TAKEN
DO_HC_SHIFT_ACTIONS:
    LD          A,$bf                                  ;Compare to JOY K1
    CP          L
    JP          Z,DO_USE_LADDER
    CP          H
    JP          Z,DO_USE_LADDER
    LD          A,$7b                                  ;Compare to JOY K2
    CP          L
    JP          Z,DO_COUNT_FOOD
    CP          H
    JP          Z,DO_COUNT_FOOD
    LD          A,$5f                                  ;Compare to JOY K3
    CP          L
    JP          Z,DO_COUNT_ARROWS
    CP          H
    JP          Z,DO_COUNT_ARROWS
    LD          A,$7d                                  ;Compare to JOY K5
    CP          L
    JP          Z,DO_SWAP_HANDS
    CP          H
    JP          Z,DO_SWAP_HANDS
    LD          A,$7e                                  ;Compare to JOY K6
    CP          L
    JP          Z,DO_REST
    CP          H
    JP          Z,DO_REST
    LD          A,$cc                                  ;Compare to K4 + DR chord
    CP          L
    JP          Z,MAX_HEALTH_ARROWS_FOOD
    CP          H
    JP          Z,MAX_HEALTH_ARROWS_FOOD
    LD          A,$c6                                  ;Compare to K4 + DL chord
    CP          L
    JP          Z,DO_TELEPORT
    CP          H
    JP          Z,DO_TELEPORT
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    JP          NO_ACTION_TAKEN
    NOP
    db          $FF
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
WARRIOR_POTION:
    db          $01,$01,$01,$01,$01
    db          $00,"+",$D4,$01
    db          $00,$11,$0F,$01
    db          $00,$CD,$DD,$01
    db          $00,$C7,$D9,$FF
MAGE_POTION:
    db          $01,$01,$01,$01,$01
    db          $00,"+",$D5,$01
    db          $00,$11,$0F,$01
    db          $00,$CD,$DD,$01
    db          $00,$C7,$D9,$FF
CHAOS_POTION:
    db          $01,$01,$01,$01,$01
    db          $00,"??",$01
    db          $00,$11,$0F,$01
    db          $00,$CD,$DD,$01
    db          $00,$C7,$D9,$FF
WARRIOR_POTION_S:
    db          $01,$01
    db          $00,$D4,$01
    db          $00,$14,$01
    db          $00,$C2,$FF
MAGE_POTION_S:
    db          $01,$01
    db          $00,$D5,$01
    db          $00,$14,$01
    db          $00,$C2,$FF
CHAOS_POTION_S:
    db          $01,$01
    db          $00,"?",$01
    db          $00,$14,$01
    db          $00,$C2,$FF
POTION_T:
    db          $00,"U",$02,$04,"_",$FF
THE_END_PART_A:
    db          " Asterion, the minotaur ",$FF
THE_END_PART_B:
    db          " is dead. ",$FF
COMPASS:
    db          $D7,"n",$C9,$01
    db          "w\be",$01
    db          $C7,"s",$D9,$FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
DRAW_BKGD:
    LD          A,$20                                  ;Set VIEWPORT fill chars to SPACE
    LD          HL,$3028
    LD          BC,$1818                               ;24 x 24 cells
    CALL        FILL_CHRCOL_RECT
    LD          C,0x8                                   ;8 rows of ceiling
    LD          HL,$3428
    LD          A,$f0                                  ;DKGRY on BLK
    CALL        DRAW_CHRCOLS
    LD          C,0x6                                   ;6 more rows of ceiling
    ADD         HL,DE
    LD          A,0x0                                   ;BLK on BLK
    CALL        DRAW_CHRCOLS
    LD          C,0xa                                   ;10 rows of floor
    ADD         HL,DE
    LD          A,$df                                  ;DKGRN on DKGRY
    CALL        DRAW_CHRCOLS
    LD          A,(CURR_MONSTER_PHYS)
    CP          0x0
    JR          Z,NOT_IN_BATTLE
    LD          A,(CURR_MONSTER_SPRT)
    CP          0x0
    JR          Z,NOT_IN_BATTLE
    CALL        REDRAW_MONSTER_HEALTH
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    RET
NOT_IN_BATTLE:
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    RET
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
WIPE_VARIABLE_SPACE:
    LD          A,0x0
    LD          HL,$3900
    LD          B,$ff
CLEAR_MAP_SPACE:
    LD          (HL),A
    INC         HL
    LD          (HL),A
    INC         HL
    LD          (HL),A
    INC         HL
    DJNZ        CLEAR_MAP_SPACE
    LD          HL,$3a62
    LD          (NEXT_BLINK_CHECK),HL
    RET
    db          $FF
    db          $FF
    db          $FF
DRAW_WHITE_MAP:
    LD          HL,$74
    CALL        MAP_ITEM_MONSTER
UPDATE_ITEM_CELLS:
    JP          Z,DRAW_PURPLE_MAP
    LD          A,(BC)
    INC         C
    INC         C
    EXX
    LD          D,$b6
    CALL        UPDATE_COLRAM_FROM_OFFSET
    EXX
    CALL        FIND_NEXT_ITEM_MONSTER_LOOP
    JR          UPDATE_ITEM_CELLS
    JP          DRAW_PURPLE_MAP
    db          $00
SHOW_MAP:
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $F4
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FA
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
PLAY_POOF_ANIM:
    PUSH        HL                                      ;Save HL register value
    LD          DE,POOF_1                               ;DE = Start of POOF animation graphic
    LD          B,$70                                  ;Set color to WHT on BLK
    EXX                                                 ;Swap BC DE HL with BC' DE' HL'
    CALL        POOF_SOUND
    EXX                                                 ;Swap BC DE HL with BC' DE' HL'
    CALL        GFX_DRAW
    POP         HL                  ;Restore DE register value
    CALL        TOGGLE_ITEM_POOF_AND_WAIT
    PUSH        HL
    CALL        GFX_DRAW
    POP         HL
    PUSH        DE
    LD          DE,$29
    SBC         HL,DE
    POP         DE                              ;= $D7,$C9,$01
    CALL        TOGGLE_ITEM_POOF_AND_WAIT
    PUSH        HL
    CALL        GFX_DRAW
    POP         HL
    PUSH        HL
    LD          B,$80
    CALL        GFX_DRAW
    CALL        TOGGLE_ITEM_POOF_AND_WAIT
    POP         HL
    PUSH        HL
    CALL        GFX_DRAW
    CALL        TOGGLE_ITEM_POOF_AND_WAIT
    LD          B,$d0
    POP         HL
    CALL        GFX_DRAW
    EX          AF,AF'
    RET
TOGGLE_ITEM_POOF_AND_WAIT:
    EXX
    LD          BC,DAT_ram_3200                         ;= $20
    CALL        SLEEP                                   ;byte SLEEP(short cycleCount)
    EXX
    RET
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
    db          $FF
MONSTER_KILLED:
    LD          HL,CHRRAM_MONSTER_POOF_IDX              ;= $20
    CALL        PLAY_POOF_ANIM
    LD          A,(PLAYER_MAP_POS)                      ;A  = Player position in map
    LD          HL,(DIR_FACING_FW)                      ;HL = FW adjustment value
    ADD         A,H                                     ;A  = Player position in map
                                                        ;one step forward
    CALL        ITEM_MAP_CHECK                          ;Upon return,
                                                        ;A  = itemNum one step forward
                                                        ;BC = itemMapRAMLocation
    CP          $9f                                    ;Check to see if it is
                                                        ;the Minotaur ($9f)
    JP          Z,MINOTAUR_DEAD
    LD          A,$fe                                  ;A  = $fe (empty item space)
    LD          (BC),A                                  ;itemMapLocRAM = $fe (empty)
    CALL        CLEAR_MONSTER_STATS
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    POP         HL
    JP          UPDATE_VIEWPORT
TOGGLE_SHIFT_MODE:
    LD          A,(GAME_BOOLEANS)
    BIT         0x1,A                                   ;NZ if SHIFT MODE
    JR          NZ,RESET_SHIFT_MODE
SET_SHIFT_MODE:
    SET         0x1,A                                   ;Set SHIFT MODE boolean
    LD          (GAME_BOOLEANS),A
    LD          A,$d0                                  ;DKGRN on BLK
    LD          (COLRAM_SHIFT_MODE_IDX),A               ;= $60    `
    JP          INPUT_DEBOUNCE
RESET_SHIFT_MODE:
    LD          A,(GAME_BOOLEANS)                       ;Reset SHIFT MODE boolean
    RES         0x1,A
    LD          (GAME_BOOLEANS),A
    LD          A,$f0
    LD          (COLRAM_SHIFT_MODE_IDX),A               ;= $60    `
    JP          INPUT_DEBOUNCE
SHOW_AUTHOR:
    LD          HL,CHRRAM_AUTHORS_IDX                   ;= $20
    LD          DE,AUTHORS                              ;= "   Originally programmed by Tom L...
    LD          B,$20
    CALL        GFX_DRAW
    LD          A,$ff
    JP          WAIT_FOR_INPUT
TIMER_UPDATE:
    LD          HL,(TIMER_A)
    LD          BC,0x1
    ADD         HL,BC
    LD          (TIMER_A),HL
    RET
BLINK_ROUTINE:
    PUSH        AF
    LD          A,(GAME_BOOLEANS)
    BIT         0x0,A
    JR          Z,STILL_ON_TITLE
    JR          BLINK_EXIT_AF
BLINK_EXIT_ALL:
    POP         DE
    POP         HL
BLINK_EXIT_BCAF:
    POP         BC
BLINK_EXIT_AF:
    POP         AF
    RET
STILL_ON_TITLE:
    PUSH        BC
    LD          A,(TIMER_B)
    LD          B,A
    LD          A,(NEXT_BLINK_CHECK)
    CP          B
    JR          NZ,BLINK_EXIT_BCAF
    LD          A,R
    LD          (NEXT_BLINK_CHECK),A
    PUSH        HL
    PUSH        DE
    CALL        DO_CLOSE_EYES
    LD          BC,$8000
    CALL        SLEEP                                   ;byte SLEEP(short cycleCount)
    CALL        DO_OPEN_EYES
    JR          BLINK_EXIT_ALL
DO_OPEN_EYES:
    LD          DE,$32d6
    LD          HL,TS_EYES_OPEN_CHR                    ; Pinned to TITLE_SCREEN (0xD800) + 726; WAS 0xdad6
    LD          BC,$44
    LDIR
    LD          DE,$36d6
    LD          HL,TS_EYES_OPTN_COL                    ; Pinned to TITLE_SCREEN (0XD800) + 1750; WAS 0xded6
    LD          BC,$44
    LDIR
    RET
DO_CLOSE_EYES:
    LD          HL,$32d6
    LD          BC,$d1d0                    ; Value, not an address 
    LD          (HL),B
    INC         HL
    LD          (HL),B
    LD          DE,$1a
    ADD         HL,DE
    LD          (HL),B
    DEC         HL
    LD          (HL),B
    LD          HL,$32fe
    LD          (HL),C
    INC         HL
    LD          (HL),B
    ADD         HL,DE
    LD          (HL),B
    DEC         HL
    LD          (HL),C
    LD          HL,$36d6
    LD          BC,$f00f                    ; Value, not an address
    LD          (HL),B
    INC         HL
    LD          (HL),C
    ADD         HL,DE
    LD          (HL),C
    DEC         HL
    LD          (HL),B
    LD          HL,$36fe
    LD          (HL),B
    INC         HL
    LD          (HL),B
    ADD         HL,DE
    LD          (HL),B
    DEC         HL
    LD          (HL),B
    RET
    db          $00
    db          $00
    db          $00
DRAW_ICON_BAR:
    PUSH        AF
    PUSH        HL
    LD          HL,CHRRAM_LEVEL_IND_L                   ;= $20
    LD          (HL),$85           ;Right side halftone CHR
    INC         HL
    INC         HL
    INC         HL
    LD          (HL),$95           ;Left side halftone CHR
    INC         HL
    LD          (HL),0x8         ;Up arrow CHR
    INC         HL
    INC         HL
    LD          (HL),$48            ;Ladder (H) CHR
    INC         HL
    INC         HL
    LD          (HL),$d3              ;Item CHR
    INC         HL
    INC         HL
    LD          (HL),$93           ;Monster CHR
    INC         HL
    INC         HL
    LD          (HL),$85              ;Right side halftone CHR
    NOP
    NOP
    INC         HL
    INC         HL
    INC         HL
    INC         HL                                      ;Map CHR
    LD          (HL),$d1               ;= $20
    INC         HL
    INC         HL                                      ;Armor CHR
    LD          (HL),$9d             ;= $20
    INC         HL
    INC         HL                                      ;Helmet CHR
    LD          (HL),0xe             ;= $20
    INC         HL
    INC         HL                                      ;Ring (o) CHR
    LD          (HL),$6f              ;= $20
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    POP         HL
    POP         AF
    RET
DRAW_COMPASS:
    PUSH        AF                                      ;DKBLU on BLK
    PUSH        BC
    PUSH        HL
    PUSH        DE
    LD          B,$b0
    LD          HL,DAT_ram_31af                         ;= $20
    LD          DE,COMPASS                              ;= $D7,"n",$C9,$01
    CALL        GFX_DRAW
    LD          HL,DAT_ram_35d8                         ;= $60
    LD          (HL),$10                 ;= $60
    POP         DE
    POP         HL
    POP         BC
    POP         AF
    RET
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
WIPE_WALLS:
    PUSH        AF
    PUSH        BC
    PUSH        HL
    LD          HL,$3800
    LD          BC,0x0
    LD          A,0x0
WIPE_WALLS_LOOP:
    LD          (HL),A
    INC         HL
    DJNZ        WIPE_WALLS_LOOP
    POP         HL
    POP         BC
    POP         AF
    CALL        UPDATE_VIEWPORT
    JP          INPUT_DEBOUNCE
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
    db          $00
DRAW_WALL_FL22_EMPTY:
    LD          HL,COLRAM_FL22_WALL_IDX                 ;= $60    `
    LD          BC,$404                                ;4 x 4 rectangle
    LD          A,0x0                                   ;BLK on BLK
    CALL        FILL_CHRCOL_RECT
    LD          HL,DAT_ram_3230                         ;= $20
    LD          BC,$401                                ;4 x 1 rectangle
    LD          A,$20                                  ;SPACE char
    JP          FILL_CHRCOL_RECT
DRAW_WALL_FL2_NEW:
    LD          HL,$3234                               ;Bottom CHARRAM IDX of FL2
    LD          BC,$401                                ;4 x 1 rectangle
    LD          A,$90                                  ;Thin base line char
    CALL        FILL_CHRCOL_RECT
    LD          HL,$35bc
    LD          BC,$204                                ;2 x 4 rectangle
    LD          A,0xf                                   ;BLK on DKGRY
    CALL        FILL_CHRCOL_RECT
    LD          C,0x4
    LD          HL,$35be
    LD          A,0xf
    JP          DRAW_CHRCOLS
FIX_ICON_COLORS:
    LD          HL,COLRAM_LEVEL_IDX_L                   ;= $60
    LD          A,(INPUT_HOLDER)
    ADD         A,A
    SUB         0x1
    LD          (HL),A              ;= $60
    INC         L
    LD          (HL),A             ;= $60
    INC         L
    LD          (HL),A              ;= $60
    INC         L
    LD          (HL),A              ;= $60
    LD          HL,COLRAM_SHIFT_MODE_IDX                ;= $60    `
    LD          BC,$1300
    DEC         HL
ICON_GREY_FILL_LOOP:
    INC         HL
    LD          (HL),$f0
    DJNZ        ICON_GREY_FILL_LOOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    RET
