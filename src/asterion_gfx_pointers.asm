GFX_POINTERS:
    db          0h
GFX_PTR_BUCKLER:
    dw        BUCKLER                                 ;= $01,$01,$01,$01,$01
GFX_PTR_BUCKLER_S:
    dw        BUCKLER_S                               ;= $01,$01
GFX_PTR_BUCKLER_T:
    dw        BUCKLER_T                               ;= $00,$87,$FF
GFX_PTR_RING:
    dw        RING                                    ;= $01,$01,$01,$01,$01,$01,$01
GFX_PTR_RING_S:
    dw        RING_S                                  ;= $01,$01,$01
GFX_PTR_RING_T:
    dw        RING_T                                  ;= $00,".",$FF
GFX_PTR_HELMET:
    dw        HELMET                                  ;= $01,$01,$01,$01,$01,$01
GFX_PTR_HELMET_S:
    dw        HELMET_S                                ;= $01,$01,$01
GFX_PTR_HELMET_T:
    dw        HELMET_T                                ;= $00,"^",$FF
GFX_PTR_ARMOR:
    dw        ARMOR                                   ;= $01,$01,$01,$01,$01
GFX_PTR_ARMOR_S:
    dw        ARMOR_S                                 ;= $01,$01
GFX_PTR_ARMOR_T:
    dw        ARMOR_T                                 ;= $00,$A0,$C7,$D9,$01
GFX_PTR_PAVISE:
    dw        PAVISE                                  ;= $01,$01,$01,$01,$01
GFX_PTR_PAVISE_S:
    dw        PAVISE_S                                ;= $01,$01
GFX_PTR_PAVISE_T:
    dw        PAVISE_T                                ;= $00,$7F,$01
GFX_PTR_ARROW_L:
    dw        ARROW_FLYING_LEFT                       ;= $01,$01,$01,$01,$01,$01
GFX_PTR_ARROW_R:
    dw        ARROW_FLYING_RIGHT                      ;= $01,$01,$01,$01,$01,$01
GFX_PTR_ARROW_L_2:
    dw        ARROW_FLYING_LEFT                       ;= $01,$01,$01,$01,$01,$01
GFX_PTR_BOW:
    dw        BOW                                     ;= $01,$01,$01,$01,$01
GFX_PTR_BOW_S:
    dw        BOW_S                                   ;= $01,$01
GFX_PTR_BOW_T:
    dw        BOW_T                                   ;= $00,"{",$FF
GFX_PTR_SCROLL:
    dw        SCROLL                                  ;= $01,$01,$01,$01,$01
GFX_PTR_SCROLL_S:
    dw        SCROLL_S                                ;= $01,$01
GFX_PTR_SCROLL_NEW_T:
    dw        SCROLL_T                                ;= $00,"H",$FF
GFX_PTR_AXE:
    dw        AXE                                     ;= $01,$01,$01,$01,$01
GFX_PTR_AXE_S:
    dw        AXE_S                                   ;= $01,$01
GFX_PTR_AXE_T:
    dw        AXE_T                                   ;= $00,$11,$FF
GFX_PTR_FIREBALL:
    dw        FIREBALL                                ;= $01,$01,$01,$01,$01
GFX_PTR_FIREBALL_S:
    dw        FIREBALL_S                              ;= $01,$01
GFX_PTR_FIREBALL_T:
    dw        FIREBALL_T                              ;= $00,$D3,$FF
GFX_PTR_MACE:
    dw        MACE                                    ;= $01,$01,$01,$01,$01
GFX_PTR_MACE_S:
    dw        MACE_S                                  ;= $01,$01
GFX_PTR_MACE_T:
    dw        MACE_T                                  ;= $00,"T",$FF
GFX_PTR_STAFF:
    dw        STAFF                                   ;= $01,$01,$01,$01,$01
GFX_PTR_STAFF_S:
    dw        STAFF_S                                 ;= $01,$01
GFX_PTR_STAFF_T:
    dw        STAFF_T                                 ;= $00,"\\",$FF
GFX_PTR_CROSSBOW:
    dw        CROSSBOW                                ;= $01,$01,$01,$01,$01
GFX_PTR_CROSSBOW_S:
    dw        CROSSBOW_S                              ;= $01,$01
GFX_PTR_CROSSBOW_T:
    dw        CROSSBOW_T                              ;= $A0,$91,$A0,$D8,$02,$04,$90,$FF
    dw        EXCL_MARK_GFX
    dw        EXCL_MARK_GFX
    dw        EXCL_MARK_GFX
    dw        EXCL_MARK_GFX
    dw        EXCL_MARK_GFX
    dw        EXCL_MARK_GFX
GFX_PTR_ARROW_R_2:
    dw        ARROW_FLYING_RIGHT                      ;= $01,$01,$01,$01,$01,$01
    dw        EXCL_MARK_GFX
    dw        EXCL_MARK_GFX
GFX_PTR_LADDER:
    dw        LADDER                                  ;= $01,$01,$01,$01,$01
GFX_PTR_LADDER_S:
    dw        LADDER_S                                ;= $01,$01
GFX_PTR_LADDER_T:
    dw        LADDER_T                                ;= $00,$CD,$97,$FF
GFX_PTR_CHEST:
    dw        CHEST                                   ;= $01,$01,$01,$01,$01
GFX_PTR_CHEST_S:
    dw        CHEST_S                                 ;= $01,$E0,$1F,$1F,$B0,$01
GFX_PTR_CHEST_T:
    dw        CHEST_T                                 ;= $00,$FC,$FF
GFX_PTR_FOOD:
    dw        FOOD                                    ;= $01,$01,$01,$01,$01
GFX_PTR_FOOD_S:
    dw        FOOD_S                                  ;= $01,$01
GFX_PTR_FOOD_T:
    dw        FOOD_T                                  ;= $00,"#",$FF
GFX_PTR_QUIVER:
    dw        QUIVER                                  ;= $01,$01,$01,$01,$01,$01
GFX_PTR_QUIVER_S:
    dw        QUIVER_S                                ;= $01,$01
GFX_PTR_QUIVER_T:
    dw        QUIVER_T                                ;= $00,$F0,$FF
GFX_PTR_LOCK_CHEST:
    dw        LOCKED_CHEST                            ;= $01,$01,$01,$01,$01
GFX_PTR_LOCK_CHEST_S:
    dw        CHEST_S                                 ;= $01,$E0,$1F,$1F,$B0,$01
GFX_PTR_LOCK_CHEST_T:
    dw        CHEST_T                                 ;= $00,$FC,$FF
    dw        EXCL_MARK_GFX
    dw        EXCL_MARK_GFX
    dw        EXCL_MARK_GFX
GFX_PTR_KEY:
    dw        KEY                                     ;= $01,$01,$01,$01,$01,$01
GFX_PTR_KEY_S:
    dw        KEY_S                                   ;= $01,$01,$01
GFX_PTR_KEY_T:
    dw        KEY_T                                   ;= $FF,"-",$FF
GFX_PTR_AMULET:
    dw        AMULET                                  ;= $01,$01,$01,$01,$01
GFX_PTR_AMULET_S:
    dw        AMULET_S                                ;= $01,$01
GFX_PTR_AMULET_T:
    dw        AMULET_T                                ;= $00,"&",$FF
GFX_PTR_CHALICE:
    dw        CHALICE                                 ;= $01,$01,$01,$01,$01,$01
GFX_PTR_CHALICE_S:
    dw        CHALICE_S                               ;= $01,$01
GFX_PTR_CHALICE_T:
    dw        CHALICE_T                               ;= $00,"Y",$FF
GFX_PTR_WARRIOR_POTION:
    dw        WARRIOR_POTION                          ;= $01,$01,$01,$01,$01
GFX_PTR_WARRIOR_POTION_S:
    dw        WARRIOR_POTION_S                        ;= $01,$01
GFX_PTR_WARRIOR_POTION_T:
    dw        POTION_T                                ;= $00,"U",$02,$04,"_",$FF
GFX_PTR_MAGE_POTION:
    dw        MAGE_POTION                             ;= $01,$01,$01,$01,$01
GFX_PTR_MAGE_POTION_S:
    dw        MAGE_POTION_S                           ;= $01,$01
GFX_PTR_MAGE_POTION_T:
    dw        POTION_T                                ;= $00,"U",$02,$04,"_",$FF
GFX_PTR_MAP:
    dw        MAP                                     ;= $01,$01,$01,$01,$01
GFX_PTR_MAP_S:
    dw        MAP_S                                   ;= $01,$01
GFX_PTR_MAP_T:
    dw        MAP_T                                   ;= $00,$D5,$FF
GFX_PTR_CHAOS_POTION:
    dw        CHAOS_POTION                            ;= $01,$01,$01,$01,$01
GFX_PTR_CHAOS_POTION_S:
    dw        CHAOS_POTION_S                          ;= $01,$01
GFX_PTR_CHAOS_POTION_T:
    dw        POTION_T                                ;= $00,"U",$02,$04,"_",$FF
    dw        EXCL_MARK_GFX
    dw        EXCL_MARK_GFX
    dw        EXCL_MARK_GFX
GFX_END_PT1:
    dw        NO_GFX                                  ;= $FF
GFX_PTR_SKELETON:
    dw        SKELETON                                ;= $04,$04,$04,$04
GFX_PTR_SKELETON_S:
    dw        SKELETON_S                              ;= $04,$04,$04
    dw        NO_GFX                                  ;= $FF
GFX_PTR_SNAKE:
    dw        SNAKE                                   ;= $04,$04,$04
GFX_PTR_SNAKE_S:
    dw        SNAKE_S                                 ;= $04,$04,$04
    dw        NO_GFX                                  ;= $FF
GFX_PTR_SPIDER:
    dw        SPIDER                                  ;= $04,$04
GFX_PTR_SPIDER_S:
    dw        SPIDER_S                                ;= $04,$04,$04,$04
    dw        NO_GFX                                  ;= $FF
GFX_PTR_MIMIC:
    dw        MIMIC                                   ;= $04,$02,$D7,$96,$00,$00,$96,$C9,$01
GFX_PTR_MIMIC_S:
    dw        MIMIC_S                                 ;= $01,$E0,$1F,$1F,$B0,$01
    dw        NO_GFX                                  ;= $FF
GFX_PTR_MALOCCHIO:
    dw        MALOCCHIO                               ;= $04,$04,$04,$04
GFX_PTR_MALOCCHIO_S:
    dw        MALOCCHIO_S                             ;= $04,$04,$04,$04
    dw        NO_GFX                                  ;= $FF
GFX_PTR_DRAGON:
    dw        DRAGON                                  ;= $04,$04,$04,$04
GFX_PTR_DRAGON_S:
    dw        DRAGON_S                                ;= $04,$04,$04,$C9,$C9,$C0,$C0,$01
GFX_PTR_END_A:
    dw        NO_GFX                                  ;= $FF
GFX_PTR_MUMMY:
    dw        MUMMY                                   ;= $04,$04,$04,$04
GFX_PTR_MUMMY_S:
    dw        MUMMY_S                                 ;= $04,$04,$04
GFX_PTR_END_B:
    dw        NO_GFX                                  ;= $FF
GFX_PTR_NECRO:
    dw        NECROMANCER                             ;= $04,$04,$04,$04
GFX_PTR_NECRO_S:
    dw        NECROMANCER_S                           ;= $04,$04,$04
GFX_PTR_END_C:
    dw        NO_GFX                                  ;= $FF
GFX_PTR_GRYPHON:
    dw        GRYPHON                                 ;= $04,$04,$04,$04
GFX_PTR_GRYPHON_S:
    dw        GRYPHON_S                               ;= $04,$04,$04,$B8,$B8,$B0,$01
GFX_PTR_END_D:
    dw        NO_GFX                                  ;= $FF
GFX_PTR_MINOTAUR:
    dw        MINOTAUR                                ;= $04,$04,$04,$04
GFX_PTR_MINOTAUR_S:
    dw        MINOTAUR_S                              ;= $04,$04,$04,$04
