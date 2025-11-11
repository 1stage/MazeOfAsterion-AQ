GAMEINIT:
    LD          SP,$3fff                      ;Set SP to top of BANK0 RAM
    CALL        WIPE_VARIABLE_SPACE                     ;Wipe variable space first...
    LD          (HL),0x2              ;($3a62) = 0x2
    INC         L                                       ;HL = $3a63
    LD          A,$32                                  ;A = $32
    LD          (HL),A                          ;($3a63) = $32
    INC         L                                       ;HL = $3a64
    LD          (HL),A                          ;($3a64) = $32
    INC         L                                       ;HL = $3a65
    LD          (HL),A                          ;($3a65) = $32
    INC         L                                       ;HL = $3a66
    DEC         A                                       ;A = $31
    LD          (HL),A                          ;($3a66) = $31
    INC         L                                       ;HL = $3a67
    LD          (HL),A                          ;($3a67) = $31
    INC         L                                       ;HL = $3a68
    LD          B,$12                                  ;B = $12
    XOR         A                                       ;A = 0x0, F = $44 (Z and P set)
LAB_ram_e029:
    LD          (HL),A                   ;($3a68) = $00
    INC         L                                       ;HL = $3a69 to $3a7a,
                                                        ;A = 0x0, F = $28
    DJNZ        LAB_ram_e029                            ;Loop if Not Z (B is decremented)
    LD          A,$18                                  ;A = $18 (HL = $3a7a, B = 0x0)
    LD          (HL),A                         ;($3a7a) = $18
    INC         HL                                      ;HL = $3a7b
    LD          A,$fe                                  ;A = $fe
    LD          B,$10                                  ;B = $10
LAB_ram_e035:
    LD          (HL),A                         ;= $60
    INC         HL
    DJNZ        LAB_ram_e035                            ;Loop if Not Z (B is decremented)
    LD          B,$20                                  ;Set fill CHR to SPACE 32/$20
    LD          HL,CHRRAM                               ;HL = $3000 (Start of CHRRAM)
    CALL        FILL_FULL_1024                          ;byte FILL_FULL_1024(word chrColValue...
    LD          HL,$5e                                 ;HL = $005e
    LD          (TIMER_E),HL                            ;($3a9c) = $0053
    LD          A,R                                     ;Semi-random number into A
    LD          H,A
    LD          (RNDHOLD_AA),HL
    LD          BC,$7f
    LD          A,0x7
    OUT         (C),A                          ;= db
    DEC         C
    LD          A,$3f
    OUT         (C),A                          ;= db
    LD          B,0x6                                   ;BLK on CYN
    LD          HL,COLRAM                               ;= $60
    CALL        FILL_FULL_1024                          ;byte FILL_FULL_1024(word chrColValue...
    CALL        CHK_ITEM
    CALL        DRAW_TITLE
    JP          INPUT_DEBOUNCE
DRAW_TITLE:
    LD          DE,CHRRAM                               ;= $20
    LD          HL,TITLE_SCREEN                    ; Pinned to TITLE_SCREEN ; WAS 0xD800
    LD          BC,$3e8
    LDIR                                                ;= $20
    LD          DE,COLRAM                               ;= $60
    LD          HL,TITLE_SCREEN_COL                    ; Pinned to TITLE_SCREEN ; WAS 0xD800 + 1024
    LD          BC,$3e8
    LDIR                                                ;= $60
                                                        ;= $70
    RET
BLANK_SCRN:
    LD          HL,CHRRAM                               ;= $20
    LD          B,$20                                  ;SPACE char
    CALL        FILL_FULL_1024                          ;byte FILL_FULL_1024(word chrColValue...
    LD          HL,COLRAM                               ;= $60
    LD          B,$d0                                  ;DKGRN on BLK
    CALL        FILL_FULL_1024                          ;byte FILL_FULL_1024(word chrColValue...
    LD          DE,STATS_TXT                            ;DE = STATS_TXT
    LD          HL,CHRRAM_STATS_TOP                     ;HL = CHRRAM_STATS_TOP
    LD          B,$d0                                  ;DKGRN on BLK
    CALL        GFX_DRAW
    LD          HL,IDX_HEALTH_SPACER                    ;= $20
    CALL        GFX_DRAW
    LD          HL,$30                                 ;Set starting PHYS HEALTH = 30
    LD          E,$15                                  ;Set starting SPRT HEALTH = 15
    LD          (PLAYER_PHYS_HEALTH),HL
    LD          (PLAYER_PHYS_HEALTH_MAX),HL
    LD          A,E
    LD          (PLAYER_SPRT_HEALTH),A
    LD          (PLAYER_SPRT_HEALTH_MAX),A
    CALL        REDRAW_STATS
    LD          HL,$20
    LD          (BYTE_ram_3aa9),HL
    LD          A,$14
    LD          (FOOD_INV),A                            ;Set starting FOOD_INV  = 14
    LD          (ARROW_INV),A                           ;Set starting ARROW INV = 14
    LD          B,$10                                  ;RED on BLK
    LD          HL,CHRRAM_LEFT_HAND_ITEM_IDX            ;= $20
    LD          DE,BOW                                  ;= $01,$01,$01,$01,$01
    CALL        GFX_DRAW
    CALL        FIX_ICON_COLORS
    CALL        DRAW_COMPASS
    DEC         A
    LD          B,A
    LD          A,0x3
    SUB         B
    LD          (RIGHT_HAND_ITEM),A
    RRCA
    JP          C,LAB_ram_e103
    LD          B,$10                                  ;Right hand RED SHIELD_L
    JP          ADJUST_SHIELD_LEVEL
LAB_ram_e103:
    LD          B,$30
ADJUST_SHIELD_LEVEL:
    RRCA
    JP          NC,LAB_ram_e10c
    LD          A,$40
    ADD         A,B
    LD          B,A
LAB_ram_e10c:
    LD          A,$18                                  ;Left hand RED BOW
    LD          (LEFT_HAND_ITEM),A
    LD          HL,CHRRAM_RIGHT_HAND_ITEM_IDX           ;= $20
    LD          DE,BUCKLER                              ;= $01,$01,$01,$01,$01
    CALL        GFX_DRAW
    CALL        BUILD_MAP
    CALL        SUB_ram_cdbf
    CALL        SUB_ram_f2c4
    CALL        REDRAW_START
    CALL        REDRAW_VIEWPORT
    JP          DO_SWAP_HANDS

DO_MOVE_FW_CHK_WALLS:
    LD          A,(WALL_F0_STATE)                       ;= $20
    CP          0x0                                     ;Check for no wall in F0
    JP          Z,FW_WALLS_CLEAR_CHK_MONSTER
    BIT         0x2,A                                   ;Check for closed door
    JP          Z,NO_ACTION_TAKEN
FW_WALLS_CLEAR_CHK_MONSTER:
    LD          A,(ITEM_F1)                             ;= $60
    INC         A
    INC         A
    CP          $7a                                    ;Check for monster in F1
    JP          NC,NO_ACTION_TAKEN                      ;Monster in your way!
                                                        ;Do nothing.
    LD          BC,(DIR_FACING_FW)                      ;Way is clear!
                                                        ;Move forward.
    LD          (PREV_DIR_VECTOR),BC
    LD          A,(DIR_FACING_SHORT)
    LD          (PREV_DIR_FACING),A
    LD          A,(PLAYER_MAP_POS)
    LD          (PLAYER_PREV_MAP_LOC),A
    ADD         A,B
    LD          (PLAYER_MAP_POS),A
    JP          UPDATE_VIEWPORT
DO_JUMP_BACK:
    LD          HL,PLAYER_MAP_POS
    LD          A,(PLAYER_PREV_MAP_LOC)
    CP          (HL)
    JP          Z,LAB_ram_e201
    EX          AF,AF'
    LD          HL,(PREV_DIR_VECTOR)
    LD          A,(DIR_FACING_BW)
    NEG                                                 ;Negate A
    CP          H
    JP          Z,NO_ACTION_TAKEN
    EX          AF,AF'
    LD          (PLAYER_MAP_POS),A
    LD          (DIR_FACING_FW),HL
    LD          A,(PREV_DIR_FACING)
    LD          (DIR_FACING_SHORT),A
    LD          A,(COMBAT_BUSY_FLAG)
    AND         A
    JP          Z,UPDATE_VIEWPORT
    CALL        CLEAR_MONSTER_STATS
    JP          INIT_MELEE_ANIM
LAB_ram_e201:
    LD          BC,$500
    LD          DE,$20
    CALL        PLAY_SOUND_LOOP
    LD          A,(COMBAT_BUSY_FLAG)
    AND         A
    JP          Z,WAIT_FOR_INPUT
    JP          INIT_MELEE_ANIM
DO_COUNT_FOOD:
    LD          A,(FOOD_INV)
COUNT_INV:
    LD          D,A
    INC         D
    XOR         A
PLAY_INV_COUNT_BLIPS:
    DEC         D
    JP          Z,INPUT_DEBOUNCE
    EX          AF,AF'
    LD          BC,BYTE_ram_2400                        ;= $FF
    CALL        SLEEP                                   ;byte SLEEP(short cycleCount)
    EX          AF,AF'
    OUT         (SPEAKER),A                             ;= db
    DEC         A
    JP          PLAY_INV_COUNT_BLIPS
DO_COUNT_ARROWS:
    LD          A,(ARROW_INV)
    JP          COUNT_INV
NO_ACTION_TAKEN:
    LD          BC,$500
    LD          DE,$20
    CALL        PLAY_SOUND_LOOP
    JP          WAIT_FOR_INPUT
PLAY_SOUND_LOOP:
    DEC         DE
    LD          A,E
    OR          D
    RET         Z
    OUT         (SPEAKER),A                             ;Send sound to speaker
    LD          H,B
    LD          L,C
LAB_ram_e244:
    DEC         HL
    LD          A,L
    OR          H
    JP          NZ,LAB_ram_e244
    JP          PLAY_SOUND_LOOP
USE_MAP:
    LD          A,(GAME_BOOLEANS)
    BIT         0x2,A                                   ;See if HAVE MAP bit is set
    JP          Z,NO_ACTION_TAKEN
    LD          A,(MAP_INV_SLOT)
    AND         A
    JP          Z,INIT_MELEE_ANIM
    EXX                                                 ;Swap BC  DE  HL
                                                        ;with BC' DE' HL'
    LD          BC,$1818                               ;24 x 24
    LD          HL,IDX_VIEWPORT_CHRRAM                  ;= $20
    LD          A,$20                                  ;SPACE character fill
    CALL        FILL_CHRCOL_RECT                        ;Fill map CHARs with SPACES
    CALL        SOUND_03
    LD          BC,$1818                               ;24 x 24
    LD          HL,COLRAM_VIEWPORT_IDX                  ;= $60    `
    LD          A,$b0                                  ;DKBLU on BLK
                                                        ;Was DKGN on BLK
    CALL        FILL_CHRCOL_RECT                        ;Fill map colors
    EXX                                                 ;Swap BC  DE  HL
                                                        ;with BC' DE' HL'
    PUSH        AF
    LD          A,(MAP_INV_SLOT)
    LD          B,A
    POP         AF
    DEC         B
    JP          Z,DRAW_RED_MAP                          ;Walls and player
    DEC         B
    JP          Z,DRAW_YELLOW_MAP                       ;Walls, player, and ladder
    DEC         B
    JP          Z,DRAW_PURPLE_MAP                       ;Walls, player, ladder,
                                                        ;and monsters
    JP          DRAW_WHITE_MAP                          ;Walls, player, ladder,
                                                        ;monsters, and items
DRAW_PURPLE_MAP:
    LD          HL,$78a8                               ;Item range for monsters:
                                                        ;78 - skeleton
                                                        ;a8 - db?
    CALL        MAP_ITEM_MONSTER
UPDATE_MONSTER_CELLS:
    JP          Z,DRAW_YELLOW_MAP
    LD          A,(BC)
    INC         C
    INC         C
    EXX                                                 ;Swap BC  DE  HL
                                                        ;with BC' DE' HL'
    LD          D,$b1                                  ;Set current map position color
                                                        ;to $b1 DKBLU on RED
                                                        ;was DKGRN on YEL
    CALL        UPDATE_COLRAM_FROM_OFFSET
    EXX                                                 ;Swap BC  DE  HL
                                                        ;with BC' DE' HL'
    CALL        FIND_NEXT_ITEM_MONSTER_LOOP
    JP          UPDATE_MONSTER_CELLS
DRAW_YELLOW_MAP:
    LD          D,$b5                                  ;Set current map position color
                                                        ;to $b5, DKBLU on PUR
                                                        ;was DKGRN on PUR
    LD          A,(ITEM_HOLDER)
    CALL        UPDATE_COLRAM_FROM_OFFSET
DRAW_RED_MAP:
    LD          BC,$1018                               ;16 x 20
    LD          DE,HC_LAST_INPUT
    LD          HL,CHRRAM_WALL_F0_IDX                   ;= $20
CALC_MINIMAP_WALL:
    INC         DE
    LD          A,D
    CP          $39
    JP          Z,SET_MINIMAP_PLAYER_LOC
    LD          A,(DE)
    OR          A
    JP          Z,SET_MINIMAP_NO_WALLS
    AND         0xf
    JP          NZ,LAB_ram_e2d6
SET_MINIMAP_N_WALL:
    LD          A,$a3                                  ;A = $a3, map CHAR N wall
    JP          DRAW_MINIMAP_WALL
SET_MINIMAP_NO_WALLS:
    LD          A,$a0                                  ;A = $a0, map CHAR no walls
    JP          DRAW_MINIMAP_WALL
SET_MINIMAP_NW_WALLS:
    LD          A,$b7                                  ;A = $b7, map CHAR N and W walls
    JP          DRAW_MINIMAP_WALL
LAB_ram_e2d6:
    LD          A,(DE)
    AND         $f0
    JP          NZ,SET_MINIMAP_NW_WALLS
SET_MINIMAP_W_WALL:
    LD          A,$b5                                  ;A = $b5, map CHAR W wall
DRAW_MINIMAP_WALL:
    LD          (HL),A              ;= $20
    INC         HL
    DJNZ        CALC_MINIMAP_WALL
    ADD         HL,BC
    LD          B,$10
    JP          CALC_MINIMAP_WALL
SET_MINIMAP_PLAYER_LOC:
    LD          A,(PLAYER_MAP_POS)
    LD          D,$b7                                  ;Set player position color
                                                        ;to $b7 DKBLU on WHT
                                                        ;was DKGRN on WHT
    CALL        UPDATE_COLRAM_FROM_OFFSET
    CALL        WAIT_A_TICK
READ_KEY:
    LD          BC,$ff
    IN          A,(C)
    INC         A
    JP          NZ,READ_KEY
ENABLE_HC:
    LD          C,$f7
    LD          A,0xf
    OUT         (C),A                              ;= db
    DEC         C
READ_HC:
    IN          A,(C)                     ;= db
    INC         A
    JP          NZ,READ_KEY
    INC         C
    LD          A,0xe
DISABLE_HC:
    OUT         (C),A                              ;= db
    DEC         C
    IN          A,(C)                     ;= db
    INC         A
    JP          NZ,READ_KEY
    JP          UPDATE_VIEWPORT
MAP_ITEM_MONSTER:
    LD          BC,MAP_LADDER_OFFSET
FIND_NEXT_ITEM_MONSTER_LOOP:
    LD          A,(BC)
    INC         BC
    INC         A
    RET         Z
    LD          A,(BC)
    CP          H                                       ;CP A to H (low end of itemRange)
    INC         BC
    JP          C,FIND_NEXT_ITEM_MONSTER_LOOP
    CP          L                                       ;CP A to L (high end of itemRange)
    JP          NC,FIND_NEXT_ITEM_MONSTER_LOOP
    DEC         C
    DEC         BC
    RET
UPDATE_COLRAM_FROM_OFFSET:
    PUSH        AF
    AND         0xf
    LD          HL,COLRAM_F0_WALL_MAP_IDX               ;= $60    `
    LD          C,A
    LD          B,0x0
    ADD         HL,BC
    POP         AF
    AND         $f0
    RRA
    LD          C,A
    ADD         HL,BC
    RLA
    RLA
    RL          B
    LD          C,A
    ADD         HL,BC
    LD          (HL),D                                  ;LD (HL),D
    RET
CHK_ITEM_BREAK:
    LD          A,B                                     ;A  = itemLevel (0-3)
    RLCA                                                ;A  = A * 2
    RLCA                                                ;A  = A * 2
    RLCA                                                ;A  = A * 2
    LD          C,A                                     ;B  = A
    CALL        MAKE_RANDOM_BYTE                        ;A  = Random Byte
    ADD         A,C                                     ;A  = A + B (orig A * 8)
    JP          C,ITEM_POOFS_RH                         ;If A > 255, item breaks
    ADD         A,0x5                                   ;A  = A + 5
    RET         NC                                      ;If A < 255, item doesn't break
ITEM_POOFS_RH:
    SCF                                                 ;Set C
    EX          AF,AF'
    LD          HL,CHRRAM_RH_POOF_IDX                   ;= $20
    CALL        PLAY_POOF_ANIM
FIX_RH_COLORS:
    PUSH        AF
    PUSH        BC
    PUSH        HL
    LD          A,$f0                                  ;DKGRN on BLK
    LD          BC,$404                                ; 4 x 4 rectangle
    LD          HL,COLRAM_RH_ITEM_IDX                   ;= $60    `
    CALL        FILL_CHRCOL_RECT
    POP         HL
    POP         BC
    POP         AF
    SCF
    RET
SUB_ram_e39a:
    CALL        SOUND_05
    LD          A,(ITEM_ANIM_STATE)
    LD          HL,(ITEM_ANIM_LOOP_COUNT)
    DEC         A
    JP          NZ,LAB_ram_e3cd
    DEC         L
    JP          NZ,LAB_ram_e3b6
    DEC         H
    JP          Z,LAB_ram_e45a
    LD          A,$31
    LD          (RAM_AC),A
    LD          L,0x4
LAB_ram_e3b6:
    LD          A,0x4
    LD          (ITEM_ANIM_STATE),A
    LD          (ITEM_ANIM_LOOP_COUNT),HL
    LD          HL,(ITEM_ANIM_CHRRAM_PTR)
    LD          BC,$29
    XOR         A
    SBC         HL,BC
    LD          (ITEM_ANIM_CHRRAM_PTR),HL
    JP          LAB_ram_e3d7
LAB_ram_e3cd:
    LD          (ITEM_ANIM_STATE),A
    LD          HL,(ITEM_ANIM_CHRRAM_PTR)
    DEC         HL
    LD          (ITEM_ANIM_CHRRAM_PTR),HL
LAB_ram_e3d7:
    LD          BC,$c8
    XOR         A
    SBC         HL,BC
    PUSH        HL
    ADD         HL,BC
    LD          DE,ITEM_MOVE_CHR_BUFFER
    CALL        UPDATE_MELEE_OBJECTS
    POP         HL
    LD          C,L
    LD          A,(RAM_AC)
    LD          (MON_FS),A
    LD          A,(ITEM_SPRITE_INDEX)
    CALL        CHK_ITEM
    LD          A,$32
    LD          (MON_FS),A
    LD          A,(TIMER_A)
    ADD         A,$ff
    LD          (ITEM_ANIM_TIMER_COPY),A
    RET
SUB_ram_e401:
    LD          A,L
    AND         0xf
    LD          B,A
    INC         B
    CALL        SUB_ram_e41d
    LD          C,A
    LD          A,L
    AND         $f0
    RLCA
    RLCA
    RLCA
    RLCA
    LD          B,A
    INC         B
    CALL        SUB_ram_e41d
    RLCA
    RLCA
    RLCA
    RLCA
    ADD         A,C
    LD          L,A
    RET
SUB_ram_e41d:
    CALL        UPDATE_SCR_SAVER_TIMER
    AND         0xf
LAB_ram_e422:
    SUB         B
    JP          NC,LAB_ram_e422
    ADD         A,B
    RET
SUB_ram_e427:
    LD          A,L
    ADD         A,E
    DAA
    LD          L,A
    LD          A,D
    ADC         A,H
    DAA
    LD          H,A
    RET
RECALC_PHYS_HEALTH:
    LD          A,L
    SUB         E
    DAA                                                 ;Normalize BCD
    LD          L,A
    LD          A,H
    SBC         A,D
    DAA                                                 ;Normalize BCD
    LD          H,A
    RET
SUB_ram_e439:
    XOR         A
    RR          H
    JP          NC,LAB_ram_e446
    RR          L
    LD          A,L
    SUB         $30
    LD          L,A
    JP          LAB_ram_e448
LAB_ram_e446:
    RR          L
LAB_ram_e448:
    BIT         0x3,L
    RET         Z
    LD          A,L
    SUB         0x3
    LD          L,A
    RET
SUB_ram_e450:
    LD          DE,(ITEM_ANIM_CHRRAM_PTR)
    LD          HL,ITEM_MOVE_CHR_BUFFER
    JP          SUB_ram_e97d
LAB_ram_e45a:
    CALL        SUB_ram_e450
    LD          A,$32
    LD          (RAM_AC),A
    LD          (RAM_AD),A
    LD          A,(WEAPON_SPRT)
    LD          E,A
    LD          D,0x0
    CP          0x0
    JP          NZ,LAB_ram_e50f
    LD          DE,(WEAPON_PHYS)
    EXX
    CALL        NEW_RIGHT_HAND_ITEM
    EXX
    LD          HL,(PLAYER_PHYS_HEALTH_MAX)
    CALL        SUB_ram_e439
    CALL        RECALC_PHYS_HEALTH
    JP          NC,LAB_ram_e487
    LD          HL,0x0
LAB_ram_e487:
    CALL        SUB_ram_e401
    LD          L,H
    LD          H,A
    CALL        SUB_ram_e401
    LD          L,H
    LD          H,A
    EX          DE,HL
    CALL        SUB_ram_e439
    EX          DE,HL
    CALL        SUB_ram_e427
    EX          DE,HL
    CALL        SUB_ram_e401
    CALL        SUB_ram_e427
    LD          DE,(NEW_DAMAGE)
    CALL        RECALC_PHYS_HEALTH
    JP          C,LAB_ram_e4bb
LAB_ram_e4a9:
    EX          DE,HL
    LD          HL,(CURR_MONSTER_PHYS)
    CALL        RECALC_PHYS_HEALTH
    JP          C,LAB_ram_e4c3
    OR          L
    JP          Z,LAB_ram_e4c3
    LD          (CURR_MONSTER_PHYS),HL
    JP          REDRAW_MONSTER_HEALTH
LAB_ram_e4bb:
    LD          HL,0x6
    CALL        SUB_ram_e401
    JP          LAB_ram_e4a9
LAB_ram_e4c3:
    EXX
    LD          HL,0x0
    LD          (CURR_MONSTER_PHYS),HL
    CALL        REDRAW_MONSTER_HEALTH
    EXX
    INC         L
    LD          A,$99
    CP          H
    JP          NZ,MONSTER_KILLED
    LD          A,$61
    CP          L
    JP          NC,MONSTER_KILLED
    LD          A,(COLRAM_PHYS_STATS_1000)              ;= $60
    CALL        SUB_ram_e5ba
    LD          HL,(PLAYER_PHYS_HEALTH_MAX)
    CALL        SUB_ram_e439
    LD          A,L
    CP          B
    JP          NC,MONSTER_KILLED
LAB_ram_e4ec:
    CALL        UPDATE_SCR_SAVER_TIMER
    SUB         $40
    JP          C,INCREASE_MAX_PHYS_HEALTH
    CP          C
    JP          NC,MONSTER_KILLED
INCREASE_MAX_PHYS_HEALTH:
    LD          HL,(PLAYER_PHYS_HEALTH_MAX)
    LD          A,L
    ADD         A,0x1
    DAA                                                 ;Correct for BCD
    LD          L,A
    LD          A,H
    ADC         A,0x0
    LD          H,A
    LD          (PLAYER_PHYS_HEALTH_MAX),HL
    LD          A,C
    SUB         $10
    JP          C,MONSTER_KILLED
    LD          C,A
    JP          LAB_ram_e4ec
LAB_ram_e50f:
    LD          A,(PLAYER_SPRT_HEALTH_MAX)
    LD          H,0x0
    LD          L,A
    EXX
    CALL        NEW_RIGHT_HAND_ITEM
    EXX
    CALL        SUB_ram_e439
    LD          A,L
    SUB         E
    DAA
    LD          L,A
    JP          NC,LAB_ram_e525
    LD          L,0x0
LAB_ram_e525:
    CALL        SUB_ram_e401
    EX          DE,HL
    CALL        SUB_ram_e439
    LD          A,L
    ADD         A,E
    DAA
    LD          E,A
    CALL        SUB_ram_e401
    ADD         A,E
    DAA
    LD          L,A
    LD          A,(BYTE_ram_3aa5)
    LD          E,A
    LD          A,L
    SUB         E
    DAA
    JP          C,LAB_ram_e54f
    LD          L,A
MONSTER_TAKES_SPRT_DAMAGE:
    LD          A,(CURR_MONSTER_SPRT)
    SUB         L
    DAA
    JP          C,LAB_ram_e557
    JP          Z,LAB_ram_e557
    LD          (CURR_MONSTER_SPRT),A
    JP          REDRAW_MONSTER_HEALTH
LAB_ram_e54f:
    LD          HL,0x3
    CALL        SUB_ram_e401
    JP          MONSTER_TAKES_SPRT_DAMAGE
LAB_ram_e557:
    PUSH        AF
    XOR         A
    LD          (CURR_MONSTER_SPRT),A
    CALL        REDRAW_MONSTER_HEALTH
    POP         AF
    DEC         A
    CP          $86
    JP          C,ITEM_USED_UP
    LD          A,(COLRAM_SPRT_STATS_10)                ;= $60
    CALL        SUB_ram_e5ba
    LD          A,(PLAYER_SPRT_HEALTH_MAX)
    CP          B
    JP          NC,ITEM_USED_UP
REDUCE_ITEM_BY_30:
    CALL        UPDATE_SCR_SAVER_TIMER
    SUB         $30
    JP          C,INCREASE_MAX_SPRT_HEALTH
    CP          C
    JP          NC,ITEM_USED_UP
INCREASE_MAX_SPRT_HEALTH:
    LD          A,(PLAYER_SPRT_HEALTH_MAX)
    ADD         A,0x1
    DAA                                                 ;Correct for BCD
    LD          (PLAYER_SPRT_HEALTH_MAX),A
    LD          A,C
    SUB         $10
    JP          C,ITEM_USED_UP
    LD          C,A
    JP          REDUCE_ITEM_BY_30
ITEM_USED_UP:
    JP          MONSTER_KILLED
CLEAR_MONSTER_STATS:
    XOR         A                                       ;A  = $fe on entry (usually)
                                                        ;A  = $00 after
                                                        ;Reset C & N, Set Z
                                                        ;
    LD          (COMBAT_BUSY_FLAG),A                    ;Clear combat busy flag
    LD          BC,$403
    LD          HL,CHRRAM_LEVEL_IDX                     ;= $20
    LD          A,$20
    JP          FILL_CHRCOL_RECT
SUB_ram_e5ba:
    AND         0xf
    INC         A
    INC         A
    LD          B,A
    RLCA
    RLCA
    RLCA
    RLCA
    LD          C,A
    LD          A,B
    ADD         A,A
    DAA
    ADD         A,A
    DAA
    ADD         A,A
    DAA
    ADD         A,A
    DAA
    LD          B,A
    RET
MELEE_ANIM_LOOP:
    CALL        SOUND_05
    LD          A,(MELEE_ANIM_STATE)
    LD          HL,(MONSTER_ATT_POS_COUNT)
    DEC         A
    JP          NZ,LAB_ram_e600
    DEC         L
    JP          NZ,LAB_ram_e5eb
    DEC         H
    JP          Z,LAB_ram_e63f
    LD          A,$32
    LD          (RAM_AF),A
    LD          L,0x2
LAB_ram_e5eb:
    LD          A,0x3
    LD          (MELEE_ANIM_STATE),A
    LD          (MONSTER_ATT_POS_COUNT),HL
    LD          HL,(MONSTER_ATT_POS_OFFSET)
    LD          BC,$29
    ADD         HL,BC
    LD          (MONSTER_ATT_POS_OFFSET),HL
    JP          ANIMATE_MELEE_ROUND
LAB_ram_e600:
    LD          (MELEE_ANIM_STATE),A
    LD          HL,(MONSTER_ATT_POS_OFFSET)
    INC         HL
    LD          (MONSTER_ATT_POS_OFFSET),HL
ANIMATE_MELEE_ROUND:
    LD          BC,$c8
    XOR         A
    SBC         HL,BC
    PUSH        HL
    ADD         HL,BC
    LD          DE,BYTE_ram_3a20
    CALL        UPDATE_MELEE_OBJECTS
    POP         BC
    LD          B,0x0
    LD          A,(RAM_AF)
    LD          (MON_FS),A
    LD          A,(MONSTER_SPRITE_FRAME)
    CALL        CHK_ITEM
    LD          A,$32
    LD          (MON_FS),A
    LD          A,(TIMER_A)
    ADD         A,$ff
    LD          (MONSTER_ANIM_TIMER_COPY),A
    RET
SUB_ram_e635:
    LD          DE,(MONSTER_ATT_POS_OFFSET)
    LD          HL,BYTE_ram_3a20
    JP          SUB_ram_e97d
LAB_ram_e63f:
    CALL        SUB_ram_e635
    LD          A,$31
    LD          (RAM_AF),A
    LD          (RAM_AE),A
    LD          A,(INPUT_HOLDER)
    LD          B,A
    LD          H,0x0
    LD          A,(WEAPON_VALUE_HOLDER)
    LD          L,A
    JP          LAB_ram_e658
LAB_ram_e656:
    ADD         A,L
    DAA
LAB_ram_e658:
    DJNZ        LAB_ram_e656
    LD          L,A
    LD          A,(MONSTER_SPRITE_FRAME)
    AND         $fc
    CP          $24
    JP          NZ,LAB_ram_e693
    LD          A,(SHIELD_SPRT)
    LD          E,A
    CALL        SUB_ram_e439
    LD          D,L
    CALL        SUB_ram_e401
    LD          A,L
    ADD         A,D
    DAA
    SUB         E
    DAA
    JP          C,LAB_ram_e68a
    LD          E,A
LAB_ram_e677:
    LD          A,(PLAYER_SPRT_HEALTH)
    SUB         E
    DAA
    JP          C,PLAYER_DIES
    JP          Z,PLAYER_DIES
    LD          (PLAYER_SPRT_HEALTH),A
    CALL        REDRAW_STATS
    JP          LAB_ram_e6be
LAB_ram_e68a:
    LD          HL,0x2
    CALL        SUB_ram_e401
    LD          E,L
    JP          LAB_ram_e677
LAB_ram_e693:
    CALL        SUB_ram_e401
    LD          A,(WEAPON_VALUE_HOLDER)
    ADD         A,L
    DAA
    LD          L,A
    LD          A,H
    ADC         A,0x0
    DAA
    LD          H,A
    LD          DE,(SHIELD_PHYS)
    CALL        RECALC_PHYS_HEALTH
    JP          C,LAB_ram_e6c4
LAB_ram_e6aa:
    EX          DE,HL
    LD          HL,(PLAYER_PHYS_HEALTH)
    CALL        RECALC_PHYS_HEALTH
    JP          C,PLAYER_DIES
    OR          L
    JP          Z,PLAYER_DIES
    LD          (PLAYER_PHYS_HEALTH),HL
    CALL        REDRAW_STATS
LAB_ram_e6be:
    CALL        REDRAW_START
    JP          REDRAW_VIEWPORT
LAB_ram_e6c4:
    LD          HL,0x3
    CALL        SUB_ram_e401
    JP          LAB_ram_e6aa
DO_SWAP_HANDS:
    LD          HL,RIGHT_HAND_ITEM
    LD          BC,LEFT_HAND_ITEM
    CALL        SUB_ram_ea62
    LD          HL,CHRRAM_RIGHT_HD_GFX_IDX              ;= $20
    LD          DE,ITEM_MOVE_CHR_BUFFER
    CALL        UPDATE_MELEE_OBJECTS
    LD          HL,CHRRAM_LEFT_HD_GFX_IDX               ;= $20
    LD          DE,CHRRAM_RIGHT_HD_GFX_IDX              ;= $20
    CALL        SUB_ram_e99e
    LD          HL,ITEM_MOVE_CHR_BUFFER
    LD          DE,CHRRAM_LEFT_HD_GFX_IDX               ;= $20
    CALL        SUB_ram_e97d
    CALL        NEW_RIGHT_HAND_ITEM
    LD          BC,0x0
    LD          HL,RIGHT_HAND_ITEM
    CALL        SUB_ram_e720
    LD          A,(SHIELD_SPRT)
    SUB         C
    DAA
    LD          (SHIELD_SPRT),A
    LD          A,(SHIELD_PHYS)
    SUB         B
    DAA
    LD          (SHIELD_PHYS),A
    LD          A,(SHIELD_PHYS+1)
    SBC         A,0x0
    LD          (SHIELD_PHYS+1),A
    LD          BC,0x0
    LD          HL,LEFT_HAND_ITEM
    CALL        SUB_ram_e720
    JP          LAB_ram_e812
SUB_ram_e720:
    LD          A,(HL)
    CP          $14
    RET         NC
    CP          $10
    JP          NC,LAB_ram_e72b
    CP          0x4
    RET         NC
LAB_ram_e72b:
    AND         0x3
    INC         A
    CALL        SUB_ram_e9c1
    LD          A,(HL)
    AND         $fc
    RET         NZ
    LD          H,0x0
    LD          L,B
    CALL        SUB_ram_e439
    LD          B,L
    LD          L,C
    CALL        SUB_ram_e439
    LD          C,L
    RET
NEW_RIGHT_HAND_ITEM:
    LD          A,(RIGHT_HAND_ITEM)
    CP          $18                                    ;Less than RED Bow
    JP          C,LAB_ram_e7c0
    CP          $34                                    ;Greater than WHITE Crossbow
    JP          NC,LAB_ram_e7c0
    LD          BC,0x0                                  ;C = 0
    LD          E,0x0                                   ;E = 0
    SRL         A                                       ;Div A by 2
    RR          B
    RRA
    RL          B
    RL          B
    SUB         0x6
    JP          NZ,LAB_ram_e763
    LD          D,0x6
    JP          LAB_ram_e78b
LAB_ram_e763:
    DEC         A
    JP          NZ,LAB_ram_e76a
    LD          D,0x6
    JP          LAB_ram_e79e
LAB_ram_e76a:
    DEC         A
    JP          NZ,LAB_ram_e771
    LD          D,$16
    JP          LAB_ram_e78b
LAB_ram_e771:
    DEC         A
    JP          NZ,LAB_ram_e778
    LD          D,$20
    JP          LAB_ram_e79e
LAB_ram_e778:
    DEC         A
    JP          NZ,LAB_ram_e77f
    LD          D,$24
    JP          LAB_ram_e78b
LAB_ram_e77f:
    DEC         A
    JP          NZ,LAB_ram_e786
    LD          D,$15
    JP          LAB_ram_e79e
LAB_ram_e786:
    DEC         A
    LD          D,$18
LAB_ram_e78b:
    CALL        CALC_WEAPON_VALUE
    ADD         A,A
    DAA                                                 ;BCD Correction
    LD          L,A
    LD          A,0x0
    RLA
    LD          H,A
    LD          (WEAPON_PHYS),HL
    XOR         A
    LD          (WEAPON_SPRT),A
    JP          LAB_ram_e7aa
LAB_ram_e79e:
    CALL        CALC_WEAPON_VALUE
    LD          (WEAPON_SPRT),A
    LD          HL,0x0
    LD          (WEAPON_PHYS),HL
LAB_ram_e7aa:
    LD          DE,CHRRAM_PHYS_WEAPON_IDX               ;= $20
    LD          HL,WEAPON_PHYS
    LD          B,0x2
    CALL        RECALC_AND_REDRAW_BCD
    LD          DE,CHRRAM_SPRT_WEAPON_IDX               ;= $20
    LD          HL,WEAPON_SPRT
    LD          B,0x1
    JP          RECALC_AND_REDRAW_BCD
LAB_ram_e7c0:
    LD          HL,0x0                                  ;HL = 0
    XOR         A                                       ;A  = 0
    LD          (WEAPON_PHYS),HL
    LD          (WEAPON_SPRT),A
    JP          LAB_ram_e7aa
DO_PICK_UP:
    LD          A,(ITEM_HOLDER)
    LD          B,A
    LD          A,(PLAYER_MAP_POS)
    CP          B                                       ;Check difference between
                                                        ;item and item location
    JP          Z,NO_ACTION_TAKEN
    INC         A
    JP          Z,NO_ACTION_TAKEN
    DEC         A
    CALL        ITEM_MAP_CHECK
    JP          Z,LAB_ram_e844
    CP          0x4                                     ;Compare to RING (0x4)
    JP          C,CHECK_FOOD_ARROWS                     ;Jump if less than RING (C)
    CP          $10                                     ;Compare to PAVISE ($10)
    JP          NC,CHECK_FOOD_ARROWS                    ;Jump if PAVISE or greater (NC)
PROCESS_RHA:
    CALL        PICK_UP_F0_ITEM
    LD          HL,ARMOR_INV_SLOT                       ;Start with ARMOR slot
    DEC         A                                       ;Subtract 1 from A:
                                                        ;- Armor
    JP          NZ,NOT_ARMOR                            ;Treat as NOT ARMOR
    INC         HL                                      ;HL = HELMET_INV_SLOT
    INC         HL                                      ;HL = RING_INV_SLOT
NOT_ARMOR:
    DEC         A
    JP          NZ,NOT_HELMET
    INC         HL
NOT_HELMET:
    LD          A,(HL)
    INC         D
    CP          D
    JP          NC,INPUT_DEBOUNCE
    EX          AF,AF'
    LD          A,D
    LD          (HL),A
    CALL        SUB_ram_e9c1
    LD          E,C
    LD          D,B
    EX          AF,AF'
    CALL        SUB_ram_e9c1
    LD          A,E
    SUB         C
    DAA                                                 ;BCD Correction
    LD          C,A
    LD          A,D
    SUB         B
    DAA                                                 ;BCD Correction
    LD          B,A
LAB_ram_e812:
    LD          A,(SHIELD_SPRT)
    ADD         A,C
    DAA                                                 ;BCD Correction
    LD          (SHIELD_SPRT),A
    LD          A,(SHIELD_PHYS)
    ADD         A,B
    DAA                                                 ;BCD Correction
    LD          (SHIELD_PHYS),A
    LD          A,(SHIELD_PHYS+1)
    ADC         A,0x0
    DAA                                                 ;BCD Correction
    LD          (SHIELD_PHYS+1),A
    LD          HL,SHIELD_PHYS
    LD          DE,CHRRAM_PHYS_SHIELD_IDX               ;= $20
    LD          B,0x2
    CALL        RECALC_AND_REDRAW_BCD
    LD          HL,SHIELD_SPRT
    LD          DE,CHRRAM_SPRT_SHIELD_IDX               ;= $20
    LD          B,0x1
    CALL        RECALC_AND_REDRAW_BCD
    JP          RHA_REDRAW                              ;Was JP AWAITING_INPUT
                                                        ;(c3 9c ea)
LAB_ram_e844:
    CALL        Z,SUB_ram_e9e1
CHECK_FOOD_ARROWS:
    CP          $48
    JP          C,CHECK_MAP_NECKLACE_CHARMS             ;CHEST or lower
    CP          $50
    JP          NC,CHECK_MAP_NECKLACE_CHARMS            ;LOCKED CHEST or higher
    CALL        PICK_UP_F0_ITEM
    INC         D
    RL          D
    INC         D
    CP          $12
    JP          NZ,PICK_UP_ARROWS
    PUSH        DE
    CALL        PICK_UP_FOOD
    POP         DE
    CALL        PICK_UP_FOOD
    JP          INPUT_DEBOUNCE
PICK_UP_FOOD:
    LD          A,(FOOD_INV)
    ADD         A,D
    JP          NC,LAB_ram_e872
    INC         A
    LD          C,A
    LD          A,D
    SUB         C
    LD          D,A
    JP          PICK_UP_FOOD
LAB_ram_e872:
    LD          (FOOD_INV),A
    LD          HL,(BYTE_ram_3aa9)
    LD          A,D
    ADD         A,L
    DAA                                                 ;BCD correct
    LD          L,A
    LD          A,H
    ADC         A,0x0
    DAA                                                 ;BCD correct
    LD          H,A
    LD          (BYTE_ram_3aa9),HL
    RET
PICK_UP_ARROWS:
    LD          A,(ARROW_INV)
    ADD         A,D
    CP          $33
    JP          C,ADD_ARROWS_TO_INV
    LD          A,$32
ADD_ARROWS_TO_INV:
    LD          (ARROW_INV),A
    JP          INPUT_DEBOUNCE
CHECK_MAP_NECKLACE_CHARMS:
    CP          $6c                                    ;Red MAP
    JP          Z,PROCESS_MAP
    CP          $6d                                    ;Yellow MAP
    JP          Z,PROCESS_MAP
    CP          $de                                    ;Purple MAP
    JP          Z,PROCESS_MAP
    CP          $df                                    ;White MAP
    JP          Z,PROCESS_MAP
    CP          $5c                                    ;WHITE KEY or lower
    JP          C,PICK_UP_NON_TREASURE
    CP          $64
    JP          NC,PICK_UP_NON_TREASURE                 ;WARRIOR POTION or higher
    CALL        PICK_UP_F0_ITEM
    JP          INPUT_DEBOUNCE
PROCESS_MAP:
    PUSH        AF
    LD          A,(GAME_BOOLEANS)
    SET         0x2,A
    LD          (GAME_BOOLEANS),A
    POP         AF
    CALL        PICK_UP_F0_ITEM
    LD          (MAP_INV_SLOT),DE
    PUSH        AF
    LD          A,(MAP_INV_SLOT)
    CALL        LEVEL_TO_COLRAM_FIX
    LD          (COLRAM_MAP_IDX),A                      ;= $60    `
    POP         AF
    JP          INPUT_DEBOUNCE
PICK_UP_NON_TREASURE:
    LD          HL,RIGHT_HAND_ITEM
    LD          A,(HL)
    LD          (ITEM_F0),A                             ;= $60
    CALL        SUB_ram_ea62
    LD          HL,CHRRAM_RIGHT_HD_GFX_IDX              ;= $20
    LD          DE,ITEM_MOVE_CHR_BUFFER
    CALL        UPDATE_MELEE_OBJECTS
    LD          HL,CHRRAM_FO_ITEM_IDX                   ;= $20
    LD          DE,CHRRAM_RIGHT_HD_GFX_IDX              ;= $20
    CALL        SUB_ram_e99e
    LD          HL,ITEM_MOVE_CHR_BUFFER
    LD          DE,CHRRAM_FO_ITEM_IDX                   ;= $20
    CALL        SUB_ram_e97d
    LD          HL,COLRAM_FO_ITEM_IDX                   ;= $60    `
    LD          DE,$f00                                ;BLK on DKGY /
                                                        ;BLK on BLK
                                                        ;WAS BLK on DKCYN /
                                                        ;    BLK on BLK
                                                        ;WAS LD DE,$0900
    LD          C,$f0                                  ;Floor color (for compare)
                                                        ;DKGRY on BLK
                                                        ;WAS DKCYN on BLK
    CALL        RECOLOR_ITEM
    LD          HL,COLRAM_RH_ITEM_IDX                   ;= $60    `
    LD          DE,$f0                                 ;Floor color (for fill)
                                                        ;DKGRY on BLK
                                                        ;WAS DKCYN on BLK
    LD          C,0x0
    CALL        RECOLOR_ITEM
    CALL        NEW_RIGHT_HAND_ITEM
    JP          INPUT_DEBOUNCE
RECOLOR_ITEM:
    LD          A,0x4
LAB_ram_e91c:
    EX          AF,AF'
    LD          B,0x4
LAB_ram_e91f:
    LD          A,(HL)
    AND         $f0
    CP          E
    JP          Z,LAB_ram_e935
    OR          D
LAB_ram_e926:
    LD          (HL),A
    INC         HL
    DJNZ        LAB_ram_e91f
    PUSH        DE
    LD          DE,$24                                 ;Jump ahead 36 cells
                                                        ;(40 - 4)
    ADD         HL,DE
    POP         DE
    EX          AF,AF'
    DEC         A
    JP          NZ,LAB_ram_e91c
    RET
LAB_ram_e935:
    LD          A,(HL)
    AND         0xf
    OR          C
    JP          LAB_ram_e926
WAIT_A_TICK:
    LD          BC,$8600                               ;Sleep for 134 "cycles"
    JP          SLEEP                                   ;byte SLEEP(short cycleCount)
PICK_UP_F0_ITEM:
    AND         A                                       ;Reset flags
    EX          AF,AF'                                  ;Save item
    LD          A,$fe                                  ;Empty item
    LD          (BC),A
    LD          HL,CHRRAM_FO_ITEM_IDX                   ;= $20
    LD          A,$20                                  ;SPACE char
    CALL        UPDATE_FO_ITEM
    LD          HL,COLRAM_FO_ITEM_IDX                   ;= $60    `
    LD          A,$df                                  ;DKGRN on DKGRY
    CALL        UPDATE_FO_ITEM
    EX          AF,AF'                                  ;Restore item
    RRA                                                 ;Rotate A right, A:0 to carry
    RR          D                                       ;Rotate D right
                                                        ;Carry (from A:0) to D:7
    RRA                                                 ;Rotate A right, A:0 (was A:1) to carry
    RL          D                                       ;Rotate D left, carry to D:0
                                                        ;D:7 to carry
    RL          D                                       ;Rotate D left, carry to D;0
                                                        ;D:7 to carry
                                                        ;D  = item level
    RET
UPDATE_MELEE_OBJECTS:
    LD          A,0x4
LAB_ram_e962:
    LD          BC,0x4
    LDIR                                                ;= "OM"
    DEC         A
    JP          Z,LAB_ram_e972
    LD          BC,$24
    ADD         HL,BC
    JP          LAB_ram_e962
LAB_ram_e972:
    LD          A,H
    CP          $34
    RET         NC
    LD          BC,$384
    ADD         HL,BC
    JP          UPDATE_MELEE_OBJECTS
SUB_ram_e97d:
    LD          A,0x4
LAB_ram_e97f:
    LD          BC,0x4
    LDIR                                                ;= "OM"
    DEC         A
    JP          Z,LAB_ram_e991
    EX          DE,HL
    LD          BC,$24
    ADD         HL,BC
    EX          DE,HL
    JP          LAB_ram_e97f
LAB_ram_e991:
    LD          A,D
    CP          $34
    RET         NC
    LD          BC,$384
    EX          DE,HL
    ADD         HL,BC
    EX          DE,HL
    JP          SUB_ram_e97d
SUB_ram_e99e:
    LD          A,0x4
LAB_ram_e9a0:
    LD          BC,0x4
    LDIR                                                ;= "OM"
    DEC         A
    JP          Z,LAB_ram_e9b3
    LD          BC,$24
    ADD         HL,BC
    EX          DE,HL
    ADD         HL,BC
    EX          DE,HL
    JP          LAB_ram_e9a0
LAB_ram_e9b3:
    LD          A,H
    CP          $34
    RET         NC
    LD          BC,$384
    ADD         HL,BC
    EX          DE,HL
    ADD         HL,BC
    EX          DE,HL
    JP          SUB_ram_e99e
SUB_ram_e9c1:
    DEC         A
    JP          NZ,LAB_ram_e9c8
    LD          BC,$501                                ;PHYS = 5
                                                        ;SPRT = 1
    RET
LAB_ram_e9c8:
    DEC         A
    JP          NZ,LAB_ram_e9cf
    LD          BC,$804
    RET
LAB_ram_e9cf:
    DEC         A
    JP          NZ,LAB_ram_e9d6
    LD          BC,LAB_ram_1208
    RET
LAB_ram_e9d6:
    DEC         A
    JP          NZ,LAB_ram_e9dd
    LD          BC,BYTE_ram_2613                        ;= $FF
    RET
LAB_ram_e9dd:
    LD          BC,0x0
    RET
SUB_ram_e9e1:
    LD          A,(RIGHT_HAND_ITEM)
    CP          $fe
    JP          NZ,LAB_ram_e9ec
    POP         HL
    JP          NO_ACTION_TAKEN
LAB_ram_e9ec:
    LD          A,$ff
    LD          (BC),A
    DEC         C
    DEC         C
    LD          A,H
    LD          (BC),A
    INC         C
    LD          A,$fe
    LD          (BC),A
    RET
DO_ROTATE_PACK:
    LD          HL,INV_ITEM_SLOT_1
    LD          BC,ITEM_MOVE_COL_BUFFER
    XOR         A
    LD          (BC),A
    CALL        SUB_ram_ea62
    INC         HL
    LD          BC,INV_ITEM_SLOT_1
    CALL        SUB_ram_ea62
    LD          E,0x4
LAB_ram_ea0c:
    INC         HL
    INC         BC
    CALL        SUB_ram_ea62
    DEC         E
    JP          NZ,LAB_ram_ea0c
    LD          HL,ITEM_MOVE_COL_BUFFER
    INC         BC
    CALL        SUB_ram_ea62
    LD          HL,DAT_ram_31b4                         ;= $20
    LD          DE,ITEM_MOVE_CHR_BUFFER
    CALL        UPDATE_MELEE_OBJECTS
    LD          HL,DAT_ram_3111                         ;= $20
    LD          DE,DAT_ram_31b4                         ;= $20
    CALL        SUB_ram_e99e
    LD          HL,DAT_ram_310c                         ;= $20
    LD          DE,DAT_ram_3111                         ;= $20
    CALL        SUB_ram_e99e
    LD          HL,CHHRAM_INV_4_IDX                     ;= $20
    LD          DE,DAT_ram_310c                         ;= $20
    CALL        SUB_ram_e99e
    LD          HL,DAT_ram_324c                         ;= $20
    LD          DE,CHHRAM_INV_4_IDX                     ;= $20
    CALL        SUB_ram_e99e
    LD          HL,CHHRAM_INV_6_IDX                     ;= $20
    LD          DE,DAT_ram_324c                         ;= $20
    CALL        SUB_ram_e99e
    LD          HL,WAIT_FOR_INPUT                    ; WAIT FOR INPUT label --- UNDO???
    PUSH        HL
    LD          HL,ITEM_MOVE_CHR_BUFFER
    LD          DE,CHHRAM_INV_6_IDX                     ;= $20
    CALL        SUB_ram_e97d
    JP          WAIT_A_TICK
SUB_ram_ea62:
    LD          D,(HL)
    LD          A,(BC)
    LD          (HL),A
    LD          A,D
    LD          (BC),A
    RET
DO_SWAP_PACK:
    LD          HL,INV_ITEM_SLOT_1
    LD          BC,RIGHT_HAND_ITEM
    CALL        SUB_ram_ea62
    LD          HL,CHRRAM_RIGHT_HD_GFX_IDX              ;= $20
    LD          DE,ITEM_MOVE_CHR_BUFFER
    CALL        UPDATE_MELEE_OBJECTS
    LD          HL,DAT_ram_31b4                         ;= $20
    LD          DE,CHRRAM_RIGHT_HD_GFX_IDX              ;= $20
    CALL        SUB_ram_e99e
    LD          HL,WAIT_FOR_INPUT                    ; WAIT FOR INPUT label --- UNDO???
    PUSH        HL
    LD          HL,ITEM_MOVE_CHR_BUFFER
    LD          DE,DAT_ram_31b4                         ;= $20
    CALL        SUB_ram_e97d
    CALL        NEW_RIGHT_HAND_ITEM
    JP          WAIT_A_TICK
UPDATE_VIEWPORT:
    CALL        REDRAW_START
    CALL        REDRAW_VIEWPORT
INPUT_DEBOUNCE:
    CALL        WAIT_A_TICK
WAIT_FOR_INPUT:
    CALL        TIMER_UPDATE
    CALL        BLINK_ROUTINE
    JP          NC,TIMER_UPDATED_CHECK_INPUT
    LD          HL,TIMER_C
    INC         (HL)
    LD          A,(HL)
    CP          $15
    JP          C,TIMER_UPDATED_CHECK_INPUT
    XOR         A
    LD          (HL),A
SCREEN_SAVER_FULL_SCREEN:
    LD          HL,$800
SCREEN_SAVER_REDRAW_LOOP:
    LD          DE,COLRAM                               ;= $60
RECALC_SCREEN_SAVER_COLORS:
    LD          A,(DE)                          ;= $60
    RRCA
    LD          (DE),A                          ;= $60
    INC         DE
    LD          A,$38
    CP          D
    JP          NZ,RECALC_SCREEN_SAVER_COLORS
    DEC         H
    JP          NZ,CHECK_INPUT_DURING_SCREEN_SAVER
    LD          H,0x8
CHECK_INPUT_DURING_SCREEN_SAVER:
    DEC         L
    JP          Z,SCREEN_SAVER_REDRAW_LOOP
    LD          BC,$140
    CALL        SLEEP                                   ;byte SLEEP(short cycleCount)
    LD          BC,$ff
    IN          A,(C)
    INC         A
    JP          NZ,LAB_ram_eaf5
    LD          C,$f7
    LD          A,0xf
    OUT         (C),A                              ;= db
    DEC         C
    IN          A,(C)                     ;= db
    INC         A
    JP          NZ,LAB_ram_eaf5
    INC         C
    LD          A,0xe
    OUT         (C),A                              ;= db
    DEC         C
    IN          A,(C)                     ;= db
    INC         A
    JP          Z,CHECK_INPUT_DURING_SCREEN_SAVER
LAB_ram_eaf5:
    LD          DE,COLRAM                               ;= $60
LAB_ram_eaf8:
    LD          B,H
    LD          A,(DE)                          ;= $60
LAB_ram_eafa:
    RRCA
    DJNZ        LAB_ram_eafa
    LD          (DE),A                          ;= $60
    INC         DE                  ;= $60
    LD          A,$38
    CP          D
    JP          NZ,LAB_ram_eaf8
    JP          INPUT_DEBOUNCE
TIMER_UPDATED_CHECK_INPUT:
    LD          A,(RAM_AD)
    CP          $32
    JP          Z,LAB_ram_eb53
    LD          A,(RAM_AE)
    CP          $31
    JP          NZ,LAB_ram_eb27
    LD          HL,TIMER_A
    LD          A,(ITEM_ANIM_TIMER_COPY)
    CP          (HL)
    JP          NZ,WAIT_FOR_INPUT
    CALL        SUB_ram_e450
    CALL        SUB_ram_e39a
    JP          WAIT_FOR_INPUT
LAB_ram_eb27:
    LD          HL,TIMER_A
    LD          A,(MONSTER_ANIM_TIMER_COPY)
    CP          (HL)
    JP          NZ,WAIT_FOR_INPUT
    CALL        SUB_ram_e635
    CALL        SUB_ram_e450
    CALL        SUB_ram_e39a
    CALL        MELEE_ANIM_LOOP
    JP          WAIT_FOR_INPUT
LAB_ram_eb40:
    LD          HL,TIMER_A
    LD          A,(MONSTER_ANIM_TIMER_COPY)
    CP          (HL)
    JP          NZ,WAIT_FOR_INPUT
    CALL        SUB_ram_e635
    CALL        MELEE_ANIM_LOOP
    JP          WAIT_FOR_INPUT
LAB_ram_eb53:
    LD          A,(RAM_AE)
    CP          $31
    JP          NZ,LAB_ram_eb40
    CALL        UPDATE_SCR_SAVER_TIMER
    LD          A,(COMBAT_BUSY_FLAG)
    AND         A
    JP          NZ,LAB_ram_ebd6
    LD          B,0x4
    LD          HL,ITEM_F1                              ;= $60
    LD          A,(HL)                         ;= $60
    INC         A
    INC         A
    LD          HL,ITEM_FR1                             ;= $60
LAB_ram_eb6f:
    CP          $7a
    JP          NC,LAB_ram_eb7b
    INC         HL
    LD          A,(HL)                         ;= $60
    INC         A
    INC         A
    DJNZ        LAB_ram_eb6f
    JP          LAB_ram_ebd6
LAB_ram_eb7b:
    LD          A,(TIMER_D)
    CP          0x5
    JP          NC,LAB_ram_ebd6
    CALL        MAKE_RANDOM_BYTE
    ADD         A,0x8
    JP          NC,LAB_ram_ebd6
    DEC         B
    JP          NZ,LAB_ram_eb9e
    LD          A,(DAT_ram_33fd)                        ;= $20
    BIT         0x2,A
    JP          NZ,LAB_ram_eb96
    AND         A
    JP          NZ,LAB_ram_ebd6
LAB_ram_eb96:
    CALL        ROTATE_FACING_RIGHT
    CALL        ROTATE_FACING_RIGHT
    JP          LAB_ram_ebc0
LAB_ram_eb9e:
    DEC         B
    JP          NZ,LAB_ram_ebb0
    LD          A,(DAT_ram_33f5)                        ;= $20
    BIT         0x2,A
    JP          NZ,LAB_ram_ebab
    AND         A
    JP          NZ,LAB_ram_ebd6
LAB_ram_ebab:
    CALL        ROTATE_FACING_LEFT
    JP          LAB_ram_ebc0
LAB_ram_ebb0:
    DEC         B
    JP          NZ,LAB_ram_ebcc
    LD          A,(DAT_ram_33f9)                        ;= $20
    BIT         0x2,A
    JP          NZ,LAB_ram_ebbd
    AND         A
    JP          NZ,LAB_ram_ebd6
LAB_ram_ebbd:
    CALL        ROTATE_FACING_RIGHT
LAB_ram_ebc0:
    CALL        REDRAW_START
    CALL        REDRAW_VIEWPORT
LAB_ram_ebc6:
    CALL        SUB_ram_cd5f
    JP          INIT_MONSTER_COMBAT
LAB_ram_ebcc:
    LD          A,(WALL_F0_STATE)                       ;= $20
    BIT         0x2,A
    JP          NZ,LAB_ram_ebc6
    AND         A
    JP          Z,LAB_ram_ebc6
LAB_ram_ebd6:
    LD          BC,$ff
    IN          A,(C)
    INC         A
    JP          NZ,LAB_ram_ec52
    LD          C,$f7
    LD          A,0xf
    OUT         (C),A                              ;= db
    DEC         C
    IN          A,(C)                     ;= db
    INC         A
    JP          NZ,LAB_ram_ebf7
    INC         C
    LD          A,0xe
    OUT         (C),A                              ;= db
    DEC         C
    IN          A,(C)                     ;= db
    INC         A
    JP          Z,WAIT_FOR_INPUT
LAB_ram_ebf7:
    CALL        PLAY_DESCENDING_SOUND
    LD          HL,HC_INPUT_HOLDER                      ;= $6060
DISABLE_JOY_04:
    LD          C,$f7
    LD          A,0xf
    OUT         (C),A                              ;= db
    DEC         C
    IN          A,(C)                     ;= db
    LD          (HL),A                 ;= $6060
    INC         HL
    INC         C
ENABLE_JOY_04:
    LD          A,0xe
    OUT         (C),A                              ;= db
    DEC         C
    IN          A,(C)                     ;= db
    LD          (HL),A
    LD          A,(INPUT_HOLDER)
    AND         A
    JP          NZ,HC_JOY_INPUT_COMPARE
    LD          A,(DUNGEON_LEVEL)
    AND         A
    JP          NZ,GAMEINIT
    LD          A,(HL)
    INC         A
    JP          Z,TITLE_CHK_FOR_HC_INPUT
HC_LEVEL_SELECT_LOOP:
    CP          $60                                    ;K3 pressed on title screen
    JP          Z,SET_DIFFICULTY_1
    CP          $7c
    JP          Z,SET_DIFFICULTY_2
    CP          $c0
    JP          Z,SET_DIFFICULTY_3
    JP          SET_DIFFICULTY_4
TITLE_CHK_FOR_HC_INPUT:
    DEC         HL
    LD          A,(HL)                 ;= $6060
    INC         A
    JP          HC_LEVEL_SELECT_LOOP
PLAY_DESCENDING_SOUND:
    XOR         A
    LD          (TIMER_A),A
    LD          (TIMER_B),A
    LD          (TIMER_C),A
    OUT         (SPEAKER),A                             ;= db
    LD          BC,$f0
    CALL        SLEEP                                   ;byte SLEEP(short cycleCount)
    INC         A
    OUT         (SPEAKER),A                             ;= db
    LD          BC,$4c0
    CALL        SLEEP                                   ;byte SLEEP(short cycleCount)
    RET
LAB_ram_ec52:
    CALL        PLAY_DESCENDING_SOUND
    LD          HL,KEY_INPUT_COL0                       ;= $60
    LD          BC,0xfeff                               ; Was LD, BC, GFX_POINTERS
    LD          D,0x8
SELECT_DIFFICULTY_LOOP:
    IN          A,(C)
    LD          (HL),A                  ;= $20
                                                        ;= $60
    INC         L
    RLC         B
    DEC         D
    JP          NZ,SELECT_DIFFICULTY_LOOP
    LD          A,(INPUT_HOLDER)
    AND         A
    JP          NZ,KEY_COMPARE                          ;OLD = e12c ; NEW = fbe0
    LD          A,(DUNGEON_LEVEL)
    AND         A
    JP          NZ,GAMEINIT
    LD          A,(KEY_INPUT_COL6)                      ;= $60
    CP          $fe
    JP          Z,SET_DIFFICULTY_1                      ;Key 3 pressed on Title Screen
    CP          $df
    JP          Z,SHOW_AUTHOR                           ;Key A pressed (and held)
                                                        ;on title screen
    LD          A,(KEY_INPUT_COL7)                      ;= $60
    CP          $fe
    JP          Z,SET_DIFFICULTY_2                      ;Key 2 pressed on Title Screen
    CP          $fb
    JP          Z,SET_DIFFICULTY_3                      ;Key 1 pressed on Title Screen
SET_DIFFICULTY_4:
    LD          A,0x0                                   ;Some other key pressed on Title Screen
GOTO_GAME_START:
    LD          (INPUT_HOLDER),A
    LD          A,(GAME_BOOLEANS)
    SET         0x0,A
    LD          (GAME_BOOLEANS),A
    JP          BLANK_SCRN
SET_DIFFICULTY_1:
    LD          A,0x1
    JP          GOTO_GAME_START
SET_DIFFICULTY_2:
    LD          A,0x2
    JP          GOTO_GAME_START
SET_DIFFICULTY_3:
    LD          A,0x3
    JP          GOTO_GAME_START
CHK_ITEM:
    CP          $fe                             ; Compare A to $FE
    RET         Z                               ; If A == Z, exit ($FE = no item)
    SRL         A                               ; Shift A right logical, Bit 0 to C
    LD          E,A                             ; New value A into E
    JP          C,ITEM_WAS_YL_WH                ; If C (ITEM was YEL or WHT), jump ahead
    LD          D,$10                           ; (ITEM was RED or MAG) D = $10
    JP          ITEM_WAS_RD_MG                  ; Jump ahead
ITEM_WAS_YL_WH:
    LD          D,$30                           ; (ITEM was YEL or WHTD D = $30
ITEM_WAS_RD_MG:
    SRL         A                               ; Shift A right logical, Bit 0 to C
    JP          NC,ITEM_NOT_RD_YL               ; If not C (ITEM was not RED or YEL), jump ahead
    LD          A,$40                           ; A = $40
    ADD         A,D                             ; Add D to A
    LD          D,A                             ; D = $40 + $10 (RD MG) or D = $40 + $30 (YL WH)
ITEM_NOT_RD_YL:
    RES         0x0,E                           ; Set Bit 0 of E (old ITEM SRL)
    LD          A,E                             ; Save E back into A
    SLA         A                               ; Shift A right logical
    ADD         A,E                             ; Add E () to A
    ADD         A,B                             ; Add B (color?) to A
    LD          B,D                             ; Put D ($10, $30, or $40) into B
    LD          L,A                             ; Put A into L
    LD          H,$ff                           ; Put $FF into H
    LD          E,(HL)                          ; ITEM/MONSTER GFX_PTR, E = low byte
    INC         HL                              ; Increment HL
    LD          D,(HL)                          ; ITEM/MONSTER GFX_PTR, D = high byte
    LD          A,(MON_FS)
    LD          H,A
    LD          L,C
    JP          GFX_DRAW
DO_OPEN_CLOSE:
    LD          A,(ITEM_F0)                             ;= $60
    LD          C,0x0                                   ;C  = 0
    SRL         A                                       ;Move item LEVEL
                                                        ;into C
    RR          C
    SRL         A
    RL          C
    RL          C
    CP          $11                                    ;Compare to BOX
                                                        ;44,45,46,47 2 @ SRL = 11
    JP          NZ,LAB_ram_ed1b
    LD          A,C                                     ;A = C (item level)
    AND         A
    JP          Z,DO_OPEN_BOX
    CALL        UPDATE_SCR_SAVER_TIMER
    INC         C
LAB_ram_ecf6:
    SUB         C
    JP          NC,LAB_ram_ecf6
    ADD         A,C
    LD          C,A
DO_OPEN_BOX:
    LD          A,R                                     ;Semi-random number into A
    AND         0x7
PICK_RANDOM_ITEM:
    SUB         0x7
    JP          NC,PICK_RANDOM_ITEM
    ADD         A,$1d                                  ;$1d is +1 above range
    RR          C
    RR          B
    RR          C                                       ;C = C/8
    RLA
    RL          B
    RLA
    EX          AF,AF'
    LD          A,(PLAYER_MAP_POS)
    CALL        ITEM_MAP_CHECK
    EX          AF,AF'
    LD          (BC),A
    JP          UPDATE_VIEWPORT
LAB_ram_ed1b:
    LD          A,(PLAYER_MAP_POS)
    LD          H,$38
    LD          L,A
    LD          A,(DIR_FACING_SHORT)
    DEC         A
    JP          Z,NORTH_OPEN_CLOSE_DOOR                 ;Is facing NORTH
    DEC         A
    JP          Z,SHIFT_EAST_OPEN_CLOSE_DOOR            ;Is facing EAST
    DEC         A
    JP          NZ,LAB_ram_ed4b                         ;Is facing WEST
    LD          A,L                                     ;Is facing SOUTH
    ADD         A,$10
    LD          L,A                                     ;Shift SOUTH and process as NORTH
NORTH_OPEN_CLOSE_DOOR:
    BIT         0x6,(HL)                                ;N WALL check
    JP          Z,NO_ACTION_TAKEN                       ;...if no N WALL
    BIT         0x5,(HL)                                ;N hidden DOOR check
    JP          Z,SET_N_DOOR_MASK                       ;...if no N hidden DOOR
    LD          A,$44                                  ;WALL mask
    JP          OPEN_N_CHECK
SET_N_DOOR_MASK:
    LD          A,$22                                  ;DOOR mask
OPEN_N_CHECK:
    BIT         0x7,(HL)                                ;N DOOR-OPEN check
    JP          NZ,CLOSE_N_DOOR                         ;...if N DOOR not OPEN
    SET         0x7,(HL)                                ;Set N door closed on wall map
    JP          SET_F0_DOOR_OPEN
SHIFT_EAST_OPEN_CLOSE_DOOR:
    INC         L                                       ;Shift EAST and process as WEST
LAB_ram_ed4b:
    BIT         0x1,(HL)                                ;W WALL check
    JP          Z,NO_ACTION_TAKEN                       ;...if no W WALL
    BIT         0x0,(HL)                                ;W DOOR check
    JP          Z,SET_W_DOOR_MASK                       ;...if no W DOOR
    LD          A,$44                                  ;WALL mask
    JP          LAB_ram_ed5c
SET_W_DOOR_MASK:
    LD          A,$22
LAB_ram_ed5c:
    BIT         0x2,(HL)                                ;DOOR-OPEN check
    JP          NZ,CLOSE_W_DOOR                         ;...if DOOR-OPEN
    SET         0x2,(HL)                                ;Set W door closed on wall map
SET_F0_DOOR_OPEN:
    LD          HL,WALL_F0_STATE                        ;= $20
    SET         0x2,(HL)                 ;= $20
    EX          AF,AF'                                  ;Save MASK state from A
WAIT_TO_REDRAW_F0_DOOR:
    IN          A,(VSYNC)                               ;= db
    INC         A
    JP          Z,WAIT_TO_REDRAW_F0_DOOR
    LD          A,0x0                                   ;BLK on BLK
                                                        ;WAS BLU on BLU
                                                        ;WAS LD A,$bb
    CALL        DRAW_DOOR_F0
    LD          A,(ITEM_F1)                             ;= $60
    LD          BC,$28a
    CALL        CHK_ITEM
    LD          HL,COLRAM_F0_DOOR_IDX                   ;= $60
    LD          DE,ITEM_MOVE_CHR_BUFFER
    CALL        SUB_ram_edaf
    CALL        SETUP_OPEN_DOOR_SOUND
    EXX
    LD          HL,BYTE_ram_3a58
    LD          DE,DAT_ram_3728                         ;= $60
    LD          A,0xc
LAB_ram_ed91:
    EX          AF,AF'
    EXX
    CALL        LO_HI_PITCH_SOUND
    EXX
    LD          BC,0x8
    LDIR                                                ;= $60
    LD          BC,$10
    SBC         HL,BC
    EX          DE,HL
    LD          BC,$30
    SBC         HL,BC
    EX          DE,HL
    EX          AF,AF'
    DEC         A
    JP          Z,WAIT_FOR_INPUT
    JP          LAB_ram_ed91
SUB_ram_edaf:
    LD          A,0xc
LAB_ram_edb1:
    LD          BC,0x8
    LDIR
    LD          BC,$20
    ADD         HL,BC
    DEC         A
    JP          NZ,LAB_ram_edb1
    EX          AF,AF'
    JP          DRAW_DOOR_F0
CLOSE_N_DOOR:
    RES         0x7,(HL)                                ;Set N Door map flag to closed
    JP          START_DOOR_CLOSE_ANIM
CLOSE_W_DOOR:
    RES         0x2,(HL)                                ;Set W Door map flag to closed
START_DOOR_CLOSE_ANIM:
    LD          HL,WALL_F0_STATE                        ;= $20
    RES         0x2,(HL)                 ;= $20
    EX          AF,AF'
    LD          A,(PLAYER_MAP_POS)
    LD          (PLAYER_PREV_MAP_LOC),A
    CALL        SETUP_CLOSE_DOOR_SOUND
    EXX
    EX          AF,AF'
    LD          HL,COLRAM_F0_DOOR_IDX                   ;= $60
    LD          DE,$20
    LD          BC,$c08
DOOR_CLOSE_ANIM_LOOP:
    LD          (HL),A              ;= $60
    INC         L
    DEC         C
    JP          NZ,DOOR_CLOSE_ANIM_LOOP
    EXX
    EX          AF,AF'
    CALL        HI_LO_PITCH_SOUND
    EX          AF,AF'
    EXX
    LD          C,0x8
    ADD         HL,DE
    DJNZ        DOOR_CLOSE_ANIM_LOOP
    CALL        CLEAR_MONSTER_STATS
    JP          WAIT_FOR_INPUT
    LD          BC,$1600
    JP          SLEEP                                   ;byte SLEEP(short cycleCount)
DO_TURN_LEFT:
    LD          A,(COMBAT_BUSY_FLAG)
    AND         A
    JP          NZ,NO_ACTION_TAKEN
    LD          HL,UPDATE_VIEWPORT
    PUSH        HL
ROTATE_FACING_LEFT:                                      ; Decrement DIR_FACING_SHORT (1-4 wraps to 4-1).
    ; Called by DO_TURN_LEFT and DO_GLANCE_LEFT.
    ; Effects: Updates DIR_FACING_SHORT (4->3->2->1->4 cycle)
    LD          A,(DIR_FACING_SHORT)
    DEC         A
    JP          NZ,STORE_LEFT_FACING
    LD          A,0x4                                   ; Wrap: 1 decremented becomes 4
STORE_LEFT_FACING:
    LD          (DIR_FACING_SHORT),A
    RET
DO_TURN_RIGHT:
    LD          A,(COMBAT_BUSY_FLAG)
    AND         A
    JP          NZ,NO_ACTION_TAKEN
    LD          HL,UPDATE_VIEWPORT
    PUSH        HL
ROTATE_FACING_RIGHT:                                     ; Increment DIR_FACING_SHORT (1-4 wraps to 1).
    ; Called by DO_TURN_RIGHT and DO_GLANCE_RIGHT.
    ; Effects: Updates DIR_FACING_SHORT (1->2->3->4->1 cycle)
    LD          A,(DIR_FACING_SHORT)
    INC         A
    CP          0x5
    JP          NZ,STORE_RIGHT_FACING
    LD          A,0x1                                   ; Wrap: 5 becomes 1
STORE_RIGHT_FACING:
    LD          (DIR_FACING_SHORT),A
    RET
DO_GLANCE_RIGHT:
    LD          A,(COMBAT_BUSY_FLAG)
    AND         A
    JP          NZ,NO_ACTION_TAKEN
    CALL        ROTATE_FACING_RIGHT
    CALL        REDRAW_START
    CALL        REDRAW_VIEWPORT
    CALL        SLEEP_ZERO                              ;byte SLEEP_ZERO(void)
    JP          DO_TURN_LEFT
DO_GLANCE_LEFT:
    LD          A,(COMBAT_BUSY_FLAG)
    AND         A
    JP          NZ,NO_ACTION_TAKEN
    CALL        ROTATE_FACING_LEFT
    CALL        REDRAW_START
    CALL        REDRAW_VIEWPORT
    CALL        SLEEP_ZERO                              ;byte SLEEP_ZERO(void)
    JP          DO_TURN_RIGHT
DO_USE_ATTACK:
    LD          A,(RIGHT_HAND_ITEM)
    LD          B,0x0
    SRL         A                                       ;Remove "color/level" in bit 0
                                                        ;to compare item type, below.
    RR          B                                       ;Push bit 0 from A
                                                        ;(via Carry Flag) to B
    SRL         A                                       ;Remove second "color/level" in bit 1
                                                        ;to compare item type, below
    RL          B                                       ;Move bits 0 & 1
                                                        ;from A to B...
    RL          B                                       ;B now has the LEVEL value (0-3)
    CP          $16                                    ;Compare to KEY
                                                        ;58,59,5A,5B 2 @ SRL = 16
    JP          Z,DO_USE_KEY
    CP          $19                                    ;Compare to PHYS POTION
                                                        ;64,65,66,67 2 @ SRL = 19
    JP          Z,DO_USE_PHYS_POTION
    CP          $1a                                    ;Compare to SPRT POTION
                                                        ;68,69,6A,6B 2 @ SRL = 1A
    JP          Z,DO_USE_SPRT_POTION
    CP          $1c                                    ;Compare to CHAOS POTION
                                                        ;70,71,72,73 2 @ SRL = 1c
    JP          NZ,USE_SOMETHING_ELSE
DO_USE_CHAOS_POTION:
    CALL        PLAY_USE_PHYS_POTION_SOUND
    INC         B
    DEC         B
    JP          NZ,CHECK_YELLOW_L_POTION                ;If NZ, handle other colors
                                                        ;of LARGE POTION
    CALL        TOTAL_HEAL                              ;LARGE Potion is RED
                                                        ;so do TOTAL HEAL
PROCESS_POTION_UPDATES:
    CALL        REDRAW_STATS
    LD          A,(COMBAT_BUSY_FLAG)
    AND         A
    JP          NZ,INIT_MELEE_ANIM
    JP          INPUT_DEBOUNCE
PLAY_USE_PHYS_POTION_SOUND:
    EXX
    CALL        SOUND_03
    CALL        SOUND_03
    CALL        SOUND_03
    JP          CLEAR_RIGHT_HAND
SWAP_TO_ALT_REGS:                                        ; Swap to alternate register set (EXX).
    ; Used before clearing right hand item to preserve main register state.
    EXX
CLEAR_RIGHT_HAND:                                        ; Clear right-hand item slot and draw empty sprite.
    ; Effects: Sets RIGHT_HAND_ITEM to $FE (empty), draws "poof" animation in right-hand area.
    LD          A,$fe
    LD          (RIGHT_HAND_ITEM),A
    LD          DE,POOF_6                               ;= "    ",$01
    LD          HL,CHRRAM_RIGHT_HD_GFX_IDX              ;= $20
    LD          B,$d0
    CALL        GFX_DRAW
    EXX
    RET
TOTAL_HEAL:
    LD          HL,(PLAYER_PHYS_HEALTH_MAX)
    LD          (PLAYER_PHYS_HEALTH),HL
    LD          A,(PLAYER_SPRT_HEALTH_MAX)
    LD          (PLAYER_SPRT_HEALTH),A
    RET
REDRAW_STATS_OLD:
    LD          HL,PLAYER_PHYS_HEALTH
    LD          DE,CHRRAM_PHYS_HEALTH_1000              ;= $20
    LD          B,0x2
    CALL        RECALC_AND_REDRAW_BCD
    LD          HL,PLAYER_SPRT_HEALTH
    LD          DE,CHRRAM_SPRT_HEALTH_10                ;= $20
    LD          B,0x1
    JP          RECALC_AND_REDRAW_BCD                   ;Waz JP FUN_ram_f2fd
                                                        ;(c3 fd f2)
CHECK_YELLOW_L_POTION:
    DEC         B
    JP          NZ,CHECK_PURPLE_L_POTION
    LD          BC,$10                                 ;Set PHYS increase to 10
    LD          E,0x0                                   ;Set SPRT increase to 0
PROCESS_LARGE_POTION:
    CALL        CALC_CURR_PHYS_HEALTH
    CALL        CALC_MAX_PHYS_HEALTH
    JP          PROCESS_POTION_UPDATES
CHECK_PURPLE_L_POTION:
    DEC         B
    JP          NZ,CHECK_WHITE_L_POTION
    LD          BC,0x0                                  ;Set PHYS increase to 0
    LD          E,0x6                    ;Set SPRT increase to 6
    JP          PROCESS_LARGE_POTION
CHECK_WHITE_L_POTION:
    CALL        MAKE_RANDOM_BYTE                        ;Get RANDOM BYTE
                                                        ;and put into A
    AND         0x3                                     ;Range it to 0-3
    DEC         A
    JP          NZ,LAB_ram_ef08                         ;If NZ, check for case 1
    LD          E,0x0                    ;Case 0: set SPRT increase to 0
    LD          BC,$20                                 ;Set PHYS increase to 20
    JP          PROCESS_LARGE_POTION                    ;...and reprocess
LAB_ram_ef08:
    DEC         A
    JP          NZ,LAB_ram_ef12
    LD          BC,0x0                                  ;Set PHYS increase to 0
    LD          E,$12                ;Set SPRT increase to 12
    JP          PROCESS_LARGE_POTION
LAB_ram_ef12:
    DEC         A
    JP          NZ,CHECK_CASE_3_WL_POTION
    CALL        TOTAL_HEAL                              ;Fill up PHYS and SPRT
    LD          BC,$10                                 ;Set PHYS increase to 10
    LD          E,0x6                    ;Set SPRT increase to 6
    JP          PROCESS_LARGE_POTION
CHECK_CASE_3_WL_POTION:
    LD          BC,$30                                 ;Set PHYS decrease to 30
    LD          E,$15                                  ;Set SPRT decrease to 15
    CALL        REDUCE_HEALTH_BIG
    LD          BC,$15
    LD          E,0x7
    CALL        REDUCE_HEALTH_SMALL
    JP          PROCESS_POTION_UPDATES
CALC_CURR_PHYS_HEALTH:
    LD          HL,(PLAYER_PHYS_HEALTH)                 ;Load current PHYS Health
                                                        ;into HL
    LD          A,L
    ADD         A,C
    DAA                                                 ;Correct 1000s & 100s
                                                        ;for BCD
    LD          L,A
    LD          A,H
    ADC         A,B
    DAA                                                 ;Correct 10s & 1s
                                                        ;for BCD
    CP          0x2
    LD          H,A
    JP          NZ,UPDATE_HEALTH_VALUES
    LD          H,0x1
    LD          L,$99                                  ;Max PHYS Health of 199
UPDATE_HEALTH_VALUES:
    LD          (PLAYER_PHYS_HEALTH),HL
    LD          A,(PLAYER_SPRT_HEALTH)
    ADD         A,E
    DAA                                                 ;Correct for BCD
    LD          (PLAYER_SPRT_HEALTH),A
    RET         NC
    LD          A,$99                                  ;Max SPRT Health of 99
    LD          (PLAYER_SPRT_HEALTH),A
    RET
CALC_MAX_PHYS_HEALTH:
    LD          HL,(PLAYER_PHYS_HEALTH)
    LD          BC,(PLAYER_PHYS_HEALTH_MAX)
    LD          A,H
    CP          B
    JP          C,CALC_MAX_SPRT_HEALTH
    LD          A,L
    CP          C
    JP          C,CALC_MAX_SPRT_HEALTH
    LD          (PLAYER_PHYS_HEALTH_MAX),HL
CALC_MAX_SPRT_HEALTH:
    LD          HL,PLAYER_SPRT_HEALTH_MAX
    LD          A,(PLAYER_SPRT_HEALTH)
    CP          (HL)
    RET         C
    LD          (HL),A
    RET
REDUCE_HEALTH_BIG:
    LD          HL,(PLAYER_PHYS_HEALTH)
    LD          A,L
    SUB         C
    DAA
    LD          L,A
    LD          A,H
    SBC         A,B
    DAA
    LD          H,A
    JP          C,PLAYER_DIES
    LD          (PLAYER_PHYS_HEALTH),HL
    LD          A,(PLAYER_SPRT_HEALTH)
    SUB         E
    DAA
    JP          C,PLAYER_DIES
    LD          (PLAYER_SPRT_HEALTH),A
    RET
REDUCE_HEALTH_SMALL:
    LD          HL,(PLAYER_PHYS_HEALTH_MAX)
    LD          A,L
    SUB         C
    DAA
    LD          L,A
    LD          A,H
    SBC         A,B
    DAA
    LD          H,A
    JP          C,PLAYER_DIES
    LD          (PLAYER_PHYS_HEALTH_MAX),HL
    LD          A,(PLAYER_SPRT_HEALTH_MAX)
    SUB         E
    DAA
    JP          C,PLAYER_DIES
    LD          (PLAYER_SPRT_HEALTH_MAX),A
    RET
PLAYER_DIES:
    LD          HL,COLRAM_VIEWPORT_IDX                  ;= $60    `
    LD          BC,$1818                               ;18 x 18 rectangle
    XOR         A
    CALL        FILL_CHRCOL_RECT
    LD          HL,CHRRAM_YOU_DIED_IDX                  ;= $20
    LD          DE,YOU_DIED_TXT
    LD          A,(INPUT_HOLDER)
    LD          (COMBAT_BUSY_FLAG),A
    RLCA
    RLCA
    RLCA
    RLCA
    LD          B,A
    CALL        GFX_DRAW
    LD          HL,0x0
    LD          (PLAYER_PHYS_HEALTH),HL
    XOR         A
    LD          (PLAYER_SPRT_HEALTH),A
    LD          (INPUT_HOLDER),A
    CALL        REDRAW_STATS
    LD          A,$32
    LD          (RAM_AD),A
    CALL        SUB_ram_cdd3
    CALL        SLEEP_ZERO                              ;byte SLEEP_ZERO(void)
    JP          SCREEN_SAVER_FULL_SCREEN

DO_USE_PHYS_POTION:
    CALL        PLAY_USE_PHYS_POTION_SOUND
    INC         B                                       ;Change from LEVEL to
                                                        ;COLOR value (Level + 1)
    LD          H,B
    LD          L,B
    LD          (COLRAM_PHYS_STATS_1000),HL             ;Update PHYS color (1000s & 100s)
                                                        ;to potion level on BLK
    LD          (COLRAM_PHYS_STATS_10),HL               ;Update PHYS color (10s & 1s)
                                                        ;to potion level on BLK
    LD          H,$d0                                  ;DKGRN on BLK
    LD          L,H
    LD          (COLRAM_SPRT_STATS_10),HL               ;Update SPRT color (10s)
                                                        ;to DKGRN on BLACK
    LD          (COLRAM_SPRT_STATS_1),HL                ;Update SPRT color (1s)
                                                        ;to DKGRN on BLACK
    JP          PROCESS_POTION_UPDATES
DO_USE_SPRT_POTION:
    CALL        PLAY_USE_PHYS_POTION_SOUND
    INC         B                                       ;Change from LEVEL to
                                                        ;COLOR value (Level + 1)
    LD          H,B
    LD          L,B
    LD          (COLRAM_SPRT_STATS_10),HL               ;Update SPRT color (10s)
                                                        ;to potion level on BLK
    LD          (COLRAM_SPRT_STATS_1),HL                ;Update SPRT color (1s)
                                                        ;to potion level on BLK
    LD          H,$d0                                  ;DKGRN on BLK
    LD          L,H
    LD          (COLRAM_PHYS_STATS_1000),HL             ;Update PHYS color (1000s & 100s)
                                                        ;to DKGRN on BLK
    LD          (COLRAM_PHYS_STATS_10),HL               ;Update PHYS color (10s & 1s)
                                                        ;to DKGRN on BLK
    JP          PROCESS_POTION_UPDATES
DO_USE_KEY:
    LD          A,(ITEM_F0)                             ;= $60
    LD          C,0x0
    SRL         A
    RR          C
    SRL         A
    RL          C
    RL          C
    CP          $14
    JP          NZ,NO_ACTION_TAKEN
    LD          A,B
    CP          C
    JP          C,NO_ACTION_TAKEN
    LD          A,C
    LD          B,A
    AND         A
    JP          Z,LAB_ram_f048
    CALL        UPDATE_SCR_SAVER_TIMER
    INC         C
LAB_ram_f043:
    SUB         C
    JP          NC,LAB_ram_f043
    ADD         A,C
    LD          B,A
LAB_ram_f048:
    LD          A,R                                     ;Semi-random number into A
    AND         0x7
LAB_ram_f04c:
    JP          Z,LAB_ram_f071
    SUB         0x7
LAB_ram_f050:
    JP          NC,LAB_ram_f04c
    ADD         A,$1d
LAB_ram_f054:
    RR          B
    RR          C
    RR          B
    RLA
    RL          C
    RLA
    EX          AF,AF'
    LD          A,(PLAYER_MAP_POS)
    CALL        ITEM_MAP_CHECK
    EX          AF,AF'
    LD          (BC),A
    LD          A,(COMBAT_BUSY_FLAG)
    AND         A
    JP          NZ,INIT_MELEE_ANIM
    JP          UPDATE_VIEWPORT
LAB_ram_f071:
    LD          A,C
    CP          0x4
    JP          Z,LAB_ram_f07c
    LD          B,A
    LD          A,$16
    JP          LAB_ram_f054
LAB_ram_f07c:
    LD          B,0x3
    LD          A,$1c
    JP          LAB_ram_f054
USE_SOMETHING_ELSE:
    EX          AF,AF'
    LD          A,(WALL_F0_STATE)                       ;= $20
    AND         A
    JP          Z,CHECK_FOR_NON_ITEMS
    BIT         0x2,A
    JP          Z,CHECK_FOR_END_ITEM
CHECK_FOR_NON_ITEMS:
    LD          A,(ITEM_F1)                             ;= $60
    CP          $fe                                    ;Compare to EMPTY
    JP          Z,CHECK_FOR_END_ITEM
    CP          $78                                    ;Compare to MONSTERS
    JP          NC,CHECK_IF_BOW_XBOW
CHECK_FOR_END_ITEM:
    EX          AF,AF'
    CP          $ff                                    ;Compare to EMPTY-END
    JP          NZ,NO_ACTION_TAKEN
    EX          AF,AF'
CHECK_IF_BOW_XBOW:
    EX          AF,AF'
    CP          0x6                                     ;Compare to BOW
    JP          NZ,CHECK_IF_SCROLL_STAFF
USE_BOW_XBOW:
    PUSH        BC                                      ;Save BC
    LD          A,(ARROW_INV)                           ;Get Arrow Inventory
    SUB         0x1                                     ;Decrease by 1
    JP          C,NO_ACTION_TAKEN                       ;If Arrow Inv <1, end
    LD          (ARROW_INV),A
    CALL        CHK_ITEM_BREAK
    POP         BC
    JP          NC,BOW_XBOW_NO_BREAK
    LD          A,$fe                                  ;$fe = EMPTY ITEM
    LD          (RIGHT_HAND_ITEM),A                     ;Put EMPTY ITEM into Right Hand
BOW_XBOW_NO_BREAK:
    LD          D,0x5
    JP          LAB_ram_f0e9
CHECK_IF_SCROLL_STAFF:
    CP          0x7                                     ;Compare to SCROLL
    JP          NZ,CHECK_OTHERS
USE_SCROLL_STAFF:
    PUSH        BC
    CALL        CHK_ITEM_BREAK
    POP         BC
    JP          NC,SCROLL_STAFF_NO_BREAK
    LD          A,$fe
    LD          (RIGHT_HAND_ITEM),A
SCROLL_STAFF_NO_BREAK:
    LD          D,0x9                                   ;Use FIREBALL ammo
    JP          LAB_ram_f0e9
CHECK_OTHERS:
    CP          0xb                                     ;Compare to STAFF
    JP          Z,USE_SCROLL_STAFF
    CP          0xc                                     ;Compare to XBOW
    JP          Z,USE_BOW_XBOW
    CP          0x6                                     ;Compare to BOW
    JP          C,NO_ACTION_TAKEN
    CP          $10                                    ;Compare to LADDER
    JP          NC,LAB_ram_f113
    LD          D,A
    CALL        SWAP_TO_ALT_REGS
LAB_ram_f0e9:
    CALL        SETUP_ITEM_ANIMATION
    JP          INIT_MONSTER_COMBAT
CLEAR_RIGHT_ITEM_AND_SETUP_ANIM:                         ; Clear right-hand item and set up animation.
    ; Used when consumable weapons break (bow/crossbow/scroll/staff).
    CALL        SWAP_TO_ALT_REGS
SETUP_ITEM_ANIMATION:                                    ; Configure item animation parameters.
    ; Inputs: D = item type, B = item level
    ; Effects: Sets ITEM_ANIM_STATE, ITEM_SPRITE_INDEX, ITEM_ANIM_LOOP_COUNT, ITEM_ANIM_CHRRAM_PTR
    ; and initiates animation via LAB_ram_e3d7.
    LD          A,0x3
    LD          (ITEM_ANIM_STATE),A
    LD          A,D
    SLA         A
    SLA         A
    OR          B
    LD          (ITEM_SPRITE_INDEX),A
    LD          HL,$203
    LD          (ITEM_ANIM_LOOP_COUNT),HL
    LD          HL,CHRRAM_RIGHT_HD_GFX_IDX              ;= $20
    LD          (ITEM_ANIM_CHRRAM_PTR),HL
    LD          A,L
    LD          (RAM_AD),A
    JP          LAB_ram_e3d7
LAB_ram_f113:
    CP          $11
    JP          NZ,LAB_ram_f119
    JP          LAB_ram_f11e
LAB_ram_f119:
    CP          $14
    JP          NZ,NO_ACTION_TAKEN
LAB_ram_f11e:
    LD          D,A
    LD          A,(COMBAT_BUSY_FLAG)
    AND         A
    JP          Z,NO_ACTION_TAKEN
    XOR         A                                       ;A  = $00
                                                        ;Reset C & N, Set Z
    LD          (COMBAT_BUSY_FLAG),A
    CALL        CLEAR_RIGHT_ITEM_AND_SETUP_ANIM
    JP          WAIT_FOR_INPUT
INIT_MONSTER_COMBAT:                                     ; Monster combat round initializer.
    ; Preconditions: Right-hand item already decoded into B (weapon level) and ITEM_F1 holds
    ; monster/item code at player position. COMBAT_BUSY_FLAG must be 0 for a new round.
    ; Effects:
    ;   - Sets COMBAT_BUSY_FLAG to 1 (gates movement / turning until resolution)
    ;   - Extracts monster "color" (difficulty tier) & level bits from ITEM_F1
    ;   - Derives additive damage component C from dungeon level (BCD math with RLD)
    ;   - Selects monster base damage seed D and HP (HL) via branch table
    ;   - Computes weapon value (via CALC_WEAPON_VALUE later) after random reductions
    ;   - Stores monster sprite frame index into MONSTER_SPRITE_FRAME for draw routines
    ;   - Seeds CURR_MONSTER_SPRT and BYTE_ram_3aa5 (physical/spiritual HP triplets)
    LD          A,(COMBAT_BUSY_FLAG)
    AND         A
    JP          NZ,INIT_MELEE_ANIM
    INC         A
    LD          (COMBAT_BUSY_FLAG),A
    LD          A,(ITEM_F1)                             ;= $60
    LD          B,0x0
    SRL         A
    RR          B
    RRA
    RL          B
    RL          B
    EX          AF,AF'
    XOR         A
    LD          HL,DUNGEON_LEVEL
    RLD
    LD          D,A
    SRL         A
    JP          NC,LAB_ram_f157
    ADD         A,$50
LAB_ram_f157:
    RLCA
    RLCA
    RLCA
    RLCA
    LD          E,A
    LD          A,D
    RLD
    LD          D,A
    SRL         A
    ADD         A,E
    ADD         A,0x3
    DAA
    LD          C,A
    LD          A,D
    RLD
    EX          AF,AF'
    ; ===== MONSTER TYPE DISPATCH TABLE =====
    ; Switches on monster code ($1E-$27) to set base damage D, HP (HL), and sprite frame base.
    ; Each entry sets:
    ;   D = base damage seed (BCD)
    ;   HL = HP pair (H=spiritual HP, L=physical HP) - note: order reversed in some docs
    ;   MONSTER_SPRITE_FRAME = sprite base ($24=physical/red, $3C=spiritual/purple) + level (B=0-3)
    SUB         $1e                                    ; Monster codes start at $1E
    JP          NZ,LAB_ram_f17d
    ; [$1E] Skeleton: D=7, HP=(3,4), Sprite=$3C+level (spiritual/purple)
    LD          D,0x7
    LD          HL,$304
    LD          A,$3c
    ADD         A,B
    LD          (MONSTER_SPRITE_FRAME),A
    JP          SEED_MONSTER_HP_AND_ATTACK
LAB_ram_f17d:
    ; [$1F] Zombie: D=3, HP=(1,1), Sprite=$3C+level (spiritual/purple)
    DEC         A
    JP          NZ,LAB_ram_f18e
    LD          D,0x3
    LD          HL,$101
    LD          A,$3c
    ADD         A,B
    LD          (MONSTER_SPRITE_FRAME),A
    JP          SEED_MONSTER_HP_AND_ATTACK
LAB_ram_f18e:
    ; [$20] Ghost/Wraith: D=4, HP=(0,2), Sprite=$24+level (physical/red)
    DEC         A
    JP          NZ,LAB_ram_f19f
    LD          D,0x4
    LD          HL,0x2
    LD          A,$24
    ADD         A,B
    LD          (MONSTER_SPRITE_FRAME),A
    JP          SEED_MONSTER_HP_AND_ATTACK
LAB_ram_f19f:
    ; [$21] Demon: D=5, HP=(2,3), Sprite=$3C+level (spiritual/purple)
    DEC         A
    JP          NZ,LAB_ram_f1af
    LD          D,0x5
    LD          HL,$203
    LD          A,$3c
    ADD         A,B
    LD          (MONSTER_SPRITE_FRAME),A
    JP          SEED_MONSTER_HP_AND_ATTACK
LAB_ram_f1af:
    ; [$22] Goblin: D=3, HP=(3,2), Sprite=$24+level (physical/red)
    DEC         A
    JP          NZ,LAB_ram_f1bf
    LD          D,0x3
    LD          HL,$302
    LD          A,$24
    ADD         A,B
    LD          (MONSTER_SPRITE_FRAME),A
    JP          SEED_MONSTER_HP_AND_ATTACK
LAB_ram_f1bf:
    ; [$23] Troll: D=8, HP=(4,5), Sprite=$24+level (physical/red)
    DEC         A
    JP          NZ,LAB_ram_f1cf
    LD          D,0x8
    LD          HL,$405
    LD          A,$24
    ADD         A,B
    LD          (MONSTER_SPRITE_FRAME),A
    JP          SEED_MONSTER_HP_AND_ATTACK
LAB_ram_f1cf:
    ; [$24] Vampire: D=6, HP=(2,4), Sprite=$3C+level (spiritual/purple)
    DEC         A
    JP          NZ,LAB_ram_f1e0
    LD          D,0x6
    LD          HL,$204
    LD          A,$3c
    ADD         A,B
    LD          (MONSTER_SPRITE_FRAME),A
    JP          SEED_MONSTER_HP_AND_ATTACK
LAB_ram_f1e0:
    ; [$25] Dragon: D=19, HP=(5,5), Sprite=$24+level (physical/red)
    DEC         A
    JP          NZ,LAB_ram_f1f0
    LD          D,$13
    LD          HL,$505
    LD          A,$24
    ADD         A,B
    LD          (MONSTER_SPRITE_FRAME),A
    JP          SEED_MONSTER_HP_AND_ATTACK
LAB_ram_f1f0:
    ; [$26] Harpy: D=4, HP=(4,5), Sprite=$3C+level (spiritual/purple)
    DEC         A
    JP          NZ,LAB_ram_f200
    LD          D,0x4
    LD          HL,$405
    LD          A,$3c
    ADD         A,B
    LD          (MONSTER_SPRITE_FRAME),A
    JP          SEED_MONSTER_HP_AND_ATTACK
LAB_ram_f200:
    ; [$27] Minotaur/Boss: D=17, HP=(4,5), Sprite varies by player health
    ;   If PHYS+SPRT > damage: $24+level (physical/red); else $3C+level (spiritual/purple - mercy)
    DEC         A
    JP          NZ,INVALID_MONSTER_CODE
    LD          D,$11
    LD          HL,$405
    EXX
    LD          HL,(PLAYER_PHYS_HEALTH)
    CALL        SUB_ram_e439
    EX          DE,HL
    LD          A,(PLAYER_SPRT_HEALTH)
    LD          L,A
    LD          H,0x0
    CALL        RECALC_PHYS_HEALTH
    EXX
    JP          NC,MINOTAUR_MERCY_SPRITE
    LD          A,$24                                  ; Player survives: physical sprite (harder)
MINOTAUR_SET_SPRITE:
    ADD         A,B
    LD          (MONSTER_SPRITE_FRAME),A
    JP          SEED_MONSTER_HP_AND_ATTACK
MINOTAUR_MERCY_SPRITE:
    LD          A,$3c                                  ; Player would die: spiritual sprite (easier)
    JP          MINOTAUR_SET_SPRITE
INVALID_MONSTER_CODE:
    JP          NO_ACTION_TAKEN
SEED_MONSTER_HP_AND_ATTACK:                              ; Seeds monster HP and calculates initial attack value.
    ; Uses D (base damage), HL (HP pair) from dispatch table above.
    ; Outputs: CURR_MONSTER_SPRT, BYTE_ram_3aa5 (HP triplets), WEAPON_VALUE_HOLDER (attack BCD)
    CALL        GET_RANDOM_0_TO_7                       ; Get random 0-7, then compute monster spiritual HP
    PUSH        HL
    LD          HL,CURR_MONSTER_SPRT
    CALL        WRITE_HP_TRIPLET                        ; Write spiritual HP triplet
    POP         HL
    LD          D,H
    CALL        GET_RANDOM_0_TO_7                       ; Get random 0-7, then compute monster physical HP
    PUSH        HL
    LD          HL,BYTE_ram_3aa5
    CALL        WRITE_HP_TRIPLET                        ; Write physical HP triplet
    POP         HL
    LD          D,L
    LD          E,0x0
    CALL        CALC_WEAPON_VALUE
    LD          (WEAPON_VALUE_HOLDER),A
    CALL        REDRAW_MONSTER_HEALTH
INIT_MELEE_ANIM:
    LD          A,0x3                                   ;A  = $03
    LD          (MELEE_ANIM_STATE),A
    LD          HL,$206                                ;HL = $ce
    LD          (MONSTER_ATT_POS_COUNT),HL
    LD          HL,$31ea                               ;HL = $0020 db?
                                                        ;Always $20 (SPACE char)?
    LD          (MONSTER_ATT_POS_OFFSET),HL
    LD          A,L
    LD          (RAM_AE),A
    CALL        ANIMATE_MELEE_ROUND
    JP          WAIT_FOR_INPUT
REDRAW_MONSTER_HEALTH:
    LD          DE,CHRRAM_MONSTER_PHYS                  ;WAS LD DE,$333d
    LD          HL,CURR_MONSTER_PHYS
    LD          B,0x2
    CALL        RECALC_AND_REDRAW_BCD
    LD          DE,CHRRAM_MONSTER_SPRT                  ;WAS LD DE,$338f
    LD          HL,CURR_MONSTER_SPRT
    LD          B,0x1
    JP          RECALC_AND_REDRAW_BCD
GET_RANDOM_0_TO_7:                                       ; Get random value 0-7 for damage reduction.
    ; Outputs: E = random value 0-7
    ; Side effects: Updates screen saver timer, falls through to CALC_WEAPON_VALUE
    CALL        UPDATE_SCR_SAVER_TIMER
    AND         0x7
    LD          E,A
CALC_WEAPON_VALUE:                                       ; Compute BCD attack/damage value.
    ; Inputs:
    ;   B = weapon level (0-3)
    ;   D = base damage seed
    ;   E = random subtraction value (0-7)
    ;   C = level-derived additive component (BCD)
    ; Outputs:
    ;   A = final weapon value in BCD
    ; Formula: A = (D * (B+1)) - E + C, all BCD normalized, with underflow protection
    PUSH        BC                                      ;Save original weaponLevel
    INC         B                                       ;B = B + 1
    LD          A,D                                     ;A = D
    JP          LAB_ram_f28c
LAB_ram_f28a:
    ADD         A,D                                     ;A = A + D
    DAA                                                 ;Normalize for BCD
LAB_ram_f28c:
    DJNZ        LAB_ram_f28a                            ;B = B - 1
    SUB         E                                       ;A = A - E
    DAA                                                 ;Normalize for BCD
    JP          NC,LAB_ram_f294
    ADC         A,E                                     ;A = A + E (and CARRY) to undo underflow
    DAA                                                 ;Normalize for BCD
LAB_ram_f294:
    ADD         A,C                                     ;A = A + C
    DAA                                                 ;Normalize for BCD
    POP         BC                                      ;BC = Original weaponLevel
    RET                                                 ;A = new weaponValue
WRITE_HP_TRIPLET:                                       ; Write BCD HP value as triplet: value, doubled, carry.
    ; Inputs: A = BCD health value, HL = destination pointer
    ; Effects: Writes (HL) = A, (HL+1) = A*2 (BCD), (HL+2) = carry from doubling
    ; Used to store health stats in a 3-byte normalized format.
    LD          (HL),A
    INC         HL
    ADD         A,A
    DAA
    LD          (HL),A
    INC         HL
    LD          A,0x0
    RLA
    LD          (HL),A
    RET
DO_USE_LADDER:
    LD          A,(COMBAT_BUSY_FLAG)
    AND         A
    JP          NZ,NO_ACTION_TAKEN
    LD          A,(ITEM_F0)                             ;= $60
    CP          $42
    JP          NZ,NO_ACTION_TAKEN
    LD          A,(PLAYER_MAP_POS)
    LD          (PLAYER_PREV_MAP_LOC),A
    CALL        BUILD_MAP
    CALL        SUB_ram_cdbf
    CALL        SUB_ram_f2c4
    JP          RESET_SHIFT_MODE
SUB_ram_f2c4:
    LD          DE,$3002                               ;WAS $33df
    LD          HL,DUNGEON_LEVEL
    LD          A,0x1
    ADD         A,(HL)
    DAA
    JP          C,DRAW_99_LOOP_NOTICE
LAB_ram_f2d0:
    LD          (HL),A
    LD          B,0x1
    CALL        RECALC_AND_REDRAW_BCD
    CALL        REDRAW_START
    JP          REDRAW_VIEWPORT
DRAW_99_LOOP_NOTICE:
    CALL        DRAW_BKGD
    LD          HL,DAT_ram_3051                         ;= $20
    LD          DE,LEVEL_99_LOOP                        ;= "Looks like this dungeon",$01
    LD          B,$f0
    CALL        GFX_DRAW
    LD          B,$1e
LAB_ram_f2ec:
    EXX
    CALL        SLEEP_ZERO                              ;byte SLEEP_ZERO(void)
    EXX
    DJNZ        LAB_ram_f2ec
    LD          A,$90
    LD          HL,DUNGEON_LEVEL
    LD          DE,CHHRAM_LVL_IDX                       ;= $20
    JP          LAB_ram_f2d0
RECALC_AND_REDRAW_BCD:
    PUSH        DE
    LD          DE,$3a50
    LD          A,B
    SLA         A
    DEC         A
    EX          AF,AF'
LAB_ram_f306:
    LD          A,(HL)
    AND         0xf                                     ;Wipe upper nybble
    ADD         A,$30                                  ;Numeric char offset
    LD          (DE),A
    LD          A,(HL)
    AND         $f0                                    ;Wipe lower nybble
    RRCA                                                ;Move upper
    RRCA                                                ;nybble to
    RRCA                                                ;lower
    RRCA                                                ;nybble
    ADD         A,$30                                  ;Numeric char offset
    INC         DE
    LD          (DE),A
    INC         DE
    INC         HL
    DJNZ        LAB_ram_f306
    DEC         DE
    POP         HL
    EX          AF,AF'
    LD          B,A
LAB_ram_f31f:
    LD          A,(DE)
    CP          $30                                    ;Numeric char offset
    JP          NZ,LAB_ram_f32d
    LD          (HL),$20                               ;SPACE char for ZERO
    INC         HL                                      ;Move forward one cell
    DEC         DE                                      ;Move backwards one byte
                                                        ;(big endian)
    DJNZ        LAB_ram_f31f
    LD          A,(DE)
    JP          LAB_ram_f333
LAB_ram_f32d:
    LD          (HL),A
    INC         HL                                      ;Move forward one cell
    DEC         DE                                      ;Move backwards one byte
                                                        ;(big endian)
    LD          A,(DE)
    DJNZ        LAB_ram_f32d
LAB_ram_f333:
    LD          (HL),A
    RET
GFX_DRAW:
    PUSH        HL
    LD          C,$28                                  ;$28 = +40, down one row
LAB_ram_f338:
    LD          A,(DE)                       ;= "\b",$FF
                                                        ;= $FF
    INC         DE
    INC         A
    JP          NZ,LAB_ram_f33f                         ;Check for $ff end of graphic char
    POP         HL
    RET
LAB_ram_f33f:
    DEC         A                                       ;$00 = no char, move right one column...
    JP          NZ,LAB_ram_f345
    INC         HL
    JP          LAB_ram_f338
LAB_ram_f345:
    CP          0x1                                     ;$01 = down one row, back to index
    JP          NZ,LAB_ram_f352
    LD          A,B
    LD          B,0x0
    POP         HL
    ADD         HL,BC
    PUSH        HL
    LD          B,A
    JP          LAB_ram_f338
LAB_ram_f352:
    CP          0x2                                     ;$02 = back up one column
    JP          NZ,LAB_ram_f359
    DEC         HL
    JP          LAB_ram_f338
LAB_ram_f359:
    CP          0x3                                     ;$03 = down one row, same column
    JP          NZ,LAB_ram_f367
    LD          A,B
    LD          B,0x0
    ADD         HL,BC
    EX          (SP),HL
    ADD         HL,BC
    EX          (SP),HL
    LD          B,A
    JP          LAB_ram_f338
LAB_ram_f367:
    CP          0x4                                     ;$04 = up one row, same column
    JP          NZ,LAB_ram_f377
    LD          A,B
    LD          B,0x0
    SBC         HL,BC
    EX          (SP),HL
    SBC         HL,BC
    EX          (SP),HL
    LD          B,A
    JP          LAB_ram_f338
LAB_ram_f377:
    CP          $a0                                    ;$a0 = reverse FG & BG colors
    JP          NZ,LAB_ram_f385
    RRC         B                                       ;Swap hi and lo nybbles (FG & BG colo...
    RRC         B
    RRC         B
    RRC         B
    JP          LAB_ram_f338
LAB_ram_f385:
    LD          (HL),A              ;= $20
    INC         H
    INC         H
    INC         H
    INC         H
    LD          A,0xf
    CP          B
    LD          A,(HL)                    ;= $60
    JP          C,LAB_ram_f398
    RLCA
    RLCA
    RLCA
    RLCA
    AND         $f0
    JP          LAB_ram_f39a
LAB_ram_f398:
    AND         0xf
LAB_ram_f39a:
    OR          B
    LD          (HL),A                    ;= $60
    DEC         H
    DEC         H
    DEC         H
    DEC         H
    INC         HL
    JP          LAB_ram_f338
BUILD_MAP:
    LD          HL,MAPSPACE_WALLS
    LD          B,0x0
GENERATE_MAPWALLS_LOOP:
    CALL        MAKE_RANDOM_BYTE
    LD          E,A
    CALL        MAKE_RANDOM_BYTE
    AND         E
    AND         $63
    LD          (HL),A
    INC         L
    DJNZ        GENERATE_MAPWALLS_LOOP
    LD          A,(PLAYER_MAP_POS)
    LD          L,A
    LD          (HL),$42
GEN_MAP_NW_WALL_LOOP:
    CALL        UPDATE_SCR_SAVER_TIMER
    INC         A
    JP          Z,GEN_MAP_NW_WALL_LOOP
    DEC         A
    LD          (ITEM_HOLDER),A
    LD          L,A
    LD          (HL),$63
    LD          HL,MAP_LADDER_OFFSET
    LD          (HL),A
    INC         L
    LD          (HL),$42                   ;Put ladder object into map
                                                        ;(always 1st item after offset)
    INC         L
    LD          A,(INPUT_HOLDER)
    LD          B,A
    LD          A,0x2
    JP          LAB_ram_f3db
LAB_ram_f3d9:
    ADD         A,A
    DAA
LAB_ram_f3db:
    DJNZ        LAB_ram_f3d9
    LD          C,A
    LD          A,(DUNGEON_LEVEL)
    CP          C
    JP          C,LAB_ram_f3fd
GEN_ITEM_MAP:
    CALL        UPDATE_SCR_SAVER_TIMER
    INC         A
    JP          Z,GEN_ITEM_MAP
    DEC         A
    LD          C,A
    LD          A,(ITEM_HOLDER)
    CP          C
    JP          Z,GEN_ITEM_MAP
    LD          A,(PLAYER_MAP_POS)
    CP          C
    JP          Z,GEN_ITEM_MAP
    LD          (HL),C
    INC         HL
    LD          (HL),$9f                ;Full ITEM_monster range $009f
    INC         HL
LAB_ram_f3fd:
    LD          B,$50                                  ;Max 50 items+monstersdb?
GEN_RND_ITEM:
    CALL        MAKE_RANDOM_BYTE
    INC         A
    JP          Z,GEN_RND_ITEM
    DEC         A
    EX          AF,AF'
    LD          A,(DUNGEON_LEVEL)
    AND         A
    JP          NZ,LAB_ram_f417
    EX          AF,AF'
    CP          0x1
    JP          Z,GEN_RND_ITEM
    CP          $10
    JP          Z,GEN_RND_ITEM
    EX          AF,AF'
LAB_ram_f417:
    EX          AF,AF'
    LD          E,A
    LD          A,(PLAYER_MAP_POS)
    CP          E
    JP          Z,GEN_RND_ITEM
    LD          A,(ITEM_HOLDER)
    CP          E
    JP          Z,GEN_RND_ITEM
    LD          (HL),E
    INC         L
    CALL        UPDATE_SCR_SAVER_TIMER
    AND         $c0
    RLCA
    RLCA
    DEC         A
    JP          NZ,LAB_ram_f437
    LD          C,0x5
    LD          D,0x0
    JP          LAB_ram_f465
LAB_ram_f437:
    DEC         A
    JP          NZ,LAB_ram_f449
    LD          C,0x5
    LD          D,0x6
    LD          A,(DUNGEON_LEVEL)
    CP          0x6
    JP          C,LAB_ram_f465
    LD          C,0x7
    JP          LAB_ram_f465
LAB_ram_f449:
    DEC         A
    JP          NZ,LAB_ram_f452
    LD          C,0x4
    LD          D,$11
    JP          LAB_ram_f465
LAB_ram_f452:
    LD          D,$1e
    LD          C,0x5
    LD          A,(DUNGEON_LEVEL)
    CP          0x6
    JP          C,LAB_ram_f465
    LD          C,0x7
    CP          $16
    JP          C,LAB_ram_f465
    LD          C,0x9
LAB_ram_f465:
    CALL        MAKE_RANDOM_BYTE
    AND         0xf
LAB_ram_f46a:
    SUB         C
    JP          NC,LAB_ram_f46a
    ADD         A,C
    ADD         A,D
    LD          C,A
    LD          A,(DUNGEON_LEVEL)
    INC         A
    INC         A
    SRL         A
    LD          D,A
    CALL        UPDATE_SCR_SAVER_TIMER
    LD          E,A
    CALL        MAKE_RANDOM_BYTE
    AND         E
    AND         0x3
LAB_ram_f482:
    SUB         D
    JP          NC,LAB_ram_f482
    ADD         A,D
    RRA
    RRA
    RL          C
    RLA
    RL          C
    LD          (HL),C
    INC         L
    DEC         B
    JP          NZ,GEN_RND_ITEM
    LD          (HL),$ff
    LD          DE,TEMP_MAP
    LD          HL,MAP_LADDER_OFFSET
    LD          B,0x0
LAB_ram_f49d:
    LD          A,(HL)
    CP          $ff
    JP          Z,SETUP_MAP_COPY
    INC         B
    CALL        SUB_ram_f4d4
    EXX
    JP          Z,LAB_ram_f4b7
    LD          (DE),A
    INC         DE
    INC         HL
    LD          A,(HL)
    CP          $fe
    JP          Z,LAB_ram_f4bc
    INC         B
    LD          (DE),A
    INC         DE
    INC         HL
    JP          LAB_ram_f49d
LAB_ram_f4b7:
    INC         HL
    INC         HL
    DEC         B
    JP          LAB_ram_f49d
LAB_ram_f4bc:
    INC         HL
    DEC         DE
    DEC         B
    JP          LAB_ram_f49d
SETUP_MAP_COPY:
    LD          DE,TEMP_MAP                             ;DE = Temp Map
    LD          HL,MAP_LADDER_OFFSET                    ;HL = Real Map
    INC         B
    DEC         B
    JP          Z,MAP_DONE
COPY_TEMP_MAP_TO_REAL_MAP:
    LD          A,(DE)
    LD          (HL),A
    INC         HL
    INC         DE
    DJNZ        COPY_TEMP_MAP_TO_REAL_MAP               ;Loop while B is not zero
MAP_DONE:
    LD          (HL),$ff
    RET
SUB_ram_f4d4:
    PUSH        BC
    EXX
    POP         BC
    DEC         B
    JP          Z,LAB_ram_f4e4
    LD          HL,TEMP_MAP
LAB_ram_f4dd:
    CP          (HL)
    RET         Z
    DEC         B
    INC         HL
    INC         HL
    DJNZ        LAB_ram_f4dd
LAB_ram_f4e4:
    DEC         B
    RET
REDRAW_START:
    LD          HL,CALC_WEST_REDRAW_2                            ; CALC_WEST_REDRAW (0xF79B) + 7... UNDO? was 0xF7A1
    PUSH        HL
    LD          HL,PLAYER_MAP_POS
    LD          E,(HL)
    LD          D,$38                                  ;DE = Player map position in RAM
    LD          HL,WALL_F0_STATE                        ;= $20
    LD          C,0x5
    LD          A,(DIR_FACING_SHORT)
    DEC         A
    JP          Z,FACING_NORTH
    DEC         A
    JP          Z,FACING_EAST
    DEC         A
    JP          Z,FACING_SOUTH
    LD          A,(DE)
    AND         0x7                                     ;Keep low 3 bits, reset top 5 bits
    LD          (HL),A                   ;= $20
    DEC         E
    CALL        CALC_WEST_REDRAW
    DEC         E
    CALL        CALC_WEST_REDRAW
    LD          A,E
    ADD         A,$10
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A                   ;= $20
    LD          A,(DE)
    AND         0x7
    CALL        REDRAW_NORTH
    LD          A,E
    SUB         $10
    LD          E,A
    CALL        REDRAW_VIEW
    LD          (HL),A                   ;= $20
    LD          A,E
    SUB         $10
    LD          E,A
    LD          A,(DE)
    AND         0x7
    CALL        REDRAW_NORTH
    LD          A,E
    ADD         A,$21
    LD          E,A
    CALL        REDRAW_VIEW
    LD          (HL),A                   ;= $20
    LD          A,(DE)
    AND         0x7
    CALL        REDRAW_NORTH
    LD          A,E
    SUB         $10
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A                   ;= $20
    LD          A,E
    SUB         $10
    LD          E,A
    LD          A,(DE)
    AND         0x7
    CALL        REDRAW_NORTH
    LD          A,E
    ADD         A,$21
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A                   ;= $20
    CALL        CALC_WEST_REDRAW
    LD          A,E
    ADD         A,0xe
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    INC         L
    LD          (HL),A                    ;= $20
    LD          A,E
    SUB         $1e
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A                    ;= $20
    LD          A,E
    SUB         $10
    LD          E,A
    CALL        CALC_WEST_REDRAW
    DEC         E
    DEC         E
    CALL        REDRAW_VIEW
    INC         L
    INC         L
    LD          (HL),A                    ;= $20
    LD          A,E
    ADD         A,$13
    LD          E,A
    CALL        CALC_WEST_REDRAW
    LD          D,$ff
    LD          E,$f0
    LD          (DIR_FACING_FW),DE                      ;DE = 0xFFF0 (WEST)
    LD          B,$10                                  ;RED on BLK
    LD          HL,CHRRAM_POINTER_IDX                   ;WAS $31d6
    LD          DE,WEST_TXT                             ;= "\a",$FF
    JP          GFX_DRAW
REDRAW_VIEW:
    LD          A,(DE)
    AND         $e0
    RLCA
    RLCA
    RLCA
    RET
REDRAW_NORTH:
    INC         L
    LD          (HL),A
    LD          B,A
    LD          A,L
    ADD         A,C
    LD          L,A
    LD          (HL),B
    LD          A,L
    SUB         C
    LD          L,A
    INC         L
    INC         C
    RET
FACING_NORTH:
    CALL        REDRAW_VIEW
    LD          (HL),A
    LD          A,E
    SUB         $10
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A
    LD          A,E
    SUB         $10
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A
    CALL        CALC_WEST_REDRAW
    DEC         E
    CALL        REDRAW_VIEW
    CALL        REDRAW_NORTH
    INC         E
    INC         E
    LD          A,(DE)
    AND         0x7
    LD          (HL),A
    CALL        REDRAW_VIEW
    CALL        REDRAW_NORTH
    LD          A,E
    ADD         A,0xf
    LD          E,A
    LD          A,(DE)
    AND         0x7
    LD          (HL),A
    DEC         E
    CALL        REDRAW_VIEW
    CALL        REDRAW_NORTH
    INC         E
    INC         E
    CALL        CALC_WEST_REDRAW
    CALL        REDRAW_VIEW
    CALL        REDRAW_NORTH
    LD          A,E
    ADD         A,0xf
    LD          E,A
    CALL        CALC_WEST_REDRAW
    DEC         E
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A
    LD          A,E
    SUB         $20
    LD          E,A
    LD          A,(DE)
    AND         0x7
    INC         L
    INC         L
    LD          (HL),A
    LD          A,E
    ADD         A,$22
    LD          E,A
    CALL        CALC_WEST_REDRAW
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A
    LD          A,E
    SUB         $1f
    LD          E,A
    LD          A,(DE)
    AND         0x7
    INC         L
    INC         L
    LD          (HL),A
    LD          A,E
    ADD         A,$2e
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A
    LD          D,$f0
    LD          E,0x1
    LD          (DIR_FACING_FW),DE
    LD          B,$10                                  ;RED on BLK
    LD          HL,CHRRAM_POINTER_IDX                   ;WAS $31d6
    LD          DE,NORTH_TXT                            ;= "\b",$FF
    JP          GFX_DRAW
FACING_SOUTH:
    LD          A,E
    ADD         A,$10
    LD          E,A
    CALL        REDRAW_VIEW
    LD          (HL),A                   ;= $20
    LD          A,E
    ADD         A,$10
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A                   ;= $20
    LD          A,E
    ADD         A,$10
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A                   ;= $20
    LD          A,E
    SUB         0xf
    LD          E,A
    CALL        CALC_WEST_REDRAW
    LD          A,E
    ADD         A,$10
    LD          E,A
    CALL        REDRAW_VIEW
    CALL        REDRAW_NORTH
    LD          A,E
    SUB         $11
    LD          E,A
    LD          A,(DE)
    AND         0x7
    LD          (HL),A                   ;= $20
    LD          A,E
    ADD         A,0xf
    LD          E,A
    CALL        REDRAW_VIEW
    CALL        REDRAW_NORTH
    LD          A,E
    SUB         $1e
    LD          E,A
    LD          A,(DE)
    AND         0x7
    LD          (HL),A                   ;= $20
    LD          A,E
    ADD         A,$10
    LD          E,A
    CALL        REDRAW_VIEW
    CALL        REDRAW_NORTH
    LD          A,E
    SUB         $11
    LD          E,A
    CALL        CALC_WEST_REDRAW
    LD          A,E
    ADD         A,0xf
    LD          E,A
    CALL        REDRAW_VIEW
    CALL        REDRAW_NORTH
    LD          A,E
    SUB         $1e
    LD          E,A
    CALL        CALC_WEST_REDRAW
    LD          A,E
    ADD         A,$10
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A                   ;= $20
    LD          A,E
    ADD         A,$11
    LD          E,A
    LD          A,(DE)
    AND         0x7
    INC         L
    INC         L
    LD          (HL),A                    ;= $20
    LD          A,E
    SUB         $22
    LD          E,A
    CALL        CALC_WEST_REDRAW
    LD          A,E
    ADD         A,0xf
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A                    ;= $20
    LD          A,E
    ADD         A,$10
    LD          E,A
    LD          A,(DE)
    AND         0x7
    INC         L
    INC         L
    LD          (HL),A                    ;= $20
    LD          A,E
    SUB         $1f
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A                    ;= $20
    LD          D,$10
    LD          E,$ff
    LD          (DIR_FACING_FW),DE
    LD          B,$10                                  ;RED on BLK
    LD          HL,CHRRAM_POINTER_IDX                   ;WAS $31d6
    LD          DE,SOUTH_TXT                            ;= "\t",$FF
    JP          GFX_DRAW
FACING_EAST:
    INC         E
    LD          A,(DE)
    AND         0x7
    LD          (HL),A                   ;= $20
    INC         E
    CALL        CALC_WEST_REDRAW
    INC         E
    CALL        CALC_WEST_REDRAW
    DEC         E
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A                   ;= $20
    LD          A,E
    SUB         0xf
    LD          E,A
    LD          A,(DE)
    AND         0x7
    CALL        REDRAW_NORTH
    LD          A,E
    ADD         A,$1f
    LD          E,A
    CALL        REDRAW_VIEW
    LD          (HL),A                   ;= $20
    INC         E
    LD          A,(DE)
    AND         0x7
    CALL        REDRAW_NORTH
    LD          A,E
    SUB         $12
    LD          E,A
    CALL        REDRAW_VIEW
    LD          (HL),A                   ;= $20
    LD          A,E
    SUB         0xf
    LD          E,A
    LD          A,(DE)
    AND         0x7
    CALL        REDRAW_NORTH
    LD          A,E
    ADD         A,$1f
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A                   ;= $20
    INC         E
    LD          A,(DE)
    AND         0x7
    CALL        REDRAW_NORTH
    LD          A,E
    SUB         $12
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A                   ;= $20
    LD          A,E
    SUB         0xf
    LD          E,A
    CALL        CALC_WEST_REDRAW
    INC         E
    CALL        REDRAW_VIEW
    INC         L
    INC         L
    LD          (HL),A                    ;= $20
    LD          A,E
    ADD         A,$1e
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    LD          (HL),A                    ;= $20
    INC         E
    CALL        CALC_WEST_REDRAW
    LD          A,E
    ADD         A,$11
    LD          E,A
    CALL        REDRAW_VIEW
    INC         L
    INC         L
    LD          (HL),A                    ;= $20
    LD          A,E
    SUB         $22
    LD          E,A
    CALL        CALC_WEST_REDRAW
    LD          D,0x1
    LD          E,$10
    LD          (DIR_FACING_FW),DE
    LD          B,$10                                  ;RED on BLK
    LD          HL,CHRRAM_POINTER_IDX                   ;WAS $31d6
    LD          DE,EAST_TXT                             ;= $06,$FF
    JP          GFX_DRAW
CALC_WEST_REDRAW:
    LD          A,(DE)
    AND         0x7
    INC         L
    LD          (HL),A
    RET
CALC_WEST_REDRAW_2:
    LD          IX,ITEM_F2                              ;= $60
    LD          DE,(DIR_FACING_FW)
    LD          A,(PLAYER_MAP_POS)
    ADD         A,D
    ADD         A,D
    CALL        ITEM_MAP_CHECK
    LD          (IX+0),A                     ;= $60
    LD          A,H
    SUB         D
    CALL        ITEM_MAP_CHECK
    LD          (IX+1),A                     ;= $60
    LD          A,H
    SUB         D
    CALL        ITEM_MAP_CHECK
    LD          (IX+2),A                     ;= $60
    LD          A,H
    ADD         A,D
    SUB         E
    CALL        ITEM_MAP_CHECK
    LD          (IX+3),A                    ;= $60
    LD          A,H
    ADD         A,E
    ADD         A,E
    CALL        ITEM_MAP_CHECK
    LD          (IX+4),A                    ;= $60
    LD          A,H
    SUB         D
    CALL        ITEM_MAP_CHECK
    LD          (IX+5),A                     ;= $60
    LD          A,H
    SUB         E
    SUB         E
    CALL        ITEM_MAP_CHECK
    LD          (IX+6),A                     ;= $60
    LD          A,H
    SUB         D
    ADD         A,E
    CALL        ITEM_MAP_CHECK
    LD          (IX+7),A                     ;= $60
LAB_ram_f7f0:
    LD          A,$fe
    RET
ITEM_MAP_CHECK:
    LD          H,A
    LD          BC,MAP_LADDER_OFFSET
LAB_ram_f7f7:
    LD          A,(BC)
    INC         BC
    INC         BC
    INC         A
    JP          Z,LAB_ram_f7f0
    DEC         A
    CP          H
    JP          NZ,LAB_ram_f7f7
    DEC         C
    LD          A,(BC)
    RET
REDRAW_VIEWPORT:
    CALL        DRAW_BKGD
    LD          BC,ITEM_F2                              ;BC = ITEM_F2
    LD          DE,WALL_F0_STATE                        ;DE = wallAheadTemp
    LD          A,(DE)                   ;A = (wallAheadTemp)
    RRCA
    JP          NC,F0_NO_HD                             ;Jump if no hidden door
    EX          AF,AF'
    CALL        DRAW_F0_WALL
    EX          AF,AF'
    RRCA
    JP          NC,F0_HD_NO_WALL                        ;Jump if no wall
    RRCA
    JP          NC,F0_HD_NO_WALL                        ;Jump if door closed
F0_NO_HD_WALL_OPEN:
    CALL        DRAW_WALL_F0_AND_OPEN_DOOR
    JP          LAB_ram_f986
F0_NO_HD:
    RRCA
    JP          NC,F0_NO_HD_NO_WALL                     ;Jump if no wall
    RRCA
    JP          C,F0_NO_HD_WALL_OPEN                    ;Jump if door open
    CALL        DRAW_F0_WALL_AND_CLOSED_DOOR
    JP          F0_HD_NO_WALL
F0_NO_HD_NO_WALL:
    INC         DE
    LD          A,(DE)                   ;= $20
    RRCA
    JP          NC,F1_NO_HD                             ;Jump if no hidden door
    EX          AF,AF'
    CALL        DRAW_WALL_F1
    EX          AF,AF'
    RRCA
    JP          NC,F1_HD_NO_WALL                        ;Jump if no wall
    RRCA
    JP          NC,F1_HD_NO_WALL                        ;Jump if door closed
F1_NO_HD_WALL_OPEN:
    CALL        DRAW_WALL_F1_AND_OPEN_DOOR
    JP          LAB_ram_f8b7
F1_NO_HD:
    RRCA
    JP          NC,LAB_ram_f85a
    RRCA
    JP          C,F1_NO_HD_WALL_OPEN
    CALL        DRAW_WALL_F1_AND_CLOSED_DOOR
    JP          F1_HD_NO_WALL
LAB_ram_f85a:
    INC         DE
    LD          A,(DE)                   ;= $20
    RRCA
    JP          NC,CHECK_WALL_F2
F2_WALL:
    CALL        DRAW_WALL_F2
    JP          LAB_ram_f86d
CHECK_WALL_F2:
    RRCA
    JP          C,F2_WALL
    CALL        DRAW_DOOR_F2_OPEN
LAB_ram_f86d:
    LD          DE,WALL_F3_STATE                        ;= $20
    LD          A,(DE)                   ;= $20
    RRCA
    JP          NC,LAB_ram_f87b
LAB_ram_f875:
    CALL        DRAW_WALL_FL2_EMPTY
    JP          LAB_ram_f892
LAB_ram_f87b:
    RRCA
    JP          C,LAB_ram_f875
    INC         DE
    LD          A,(DE)                    ;= $20
    RRCA
    JP          NC,LAB_ram_f88b
LAB_ram_f885:
    CALL        DRAW_WALL_L2_C
    JP          LAB_ram_f892
LAB_ram_f88b:
    RRCA
    JP          C,LAB_ram_f885
    CALL        DRAW_WALL_L2_C_EMPTY
LAB_ram_f892:
    LD          DE,DAT_ram_33ed                         ;= $20
    LD          A,(DE)                    ;= $20
    RRCA
    JP          NC,LAB_ram_f8a0
LAB_ram_f89a:
    CALL        DRAW_WALL_FR2
    JP          LAB_ram_f8b7
LAB_ram_f8a0:
    RRCA
    JP          C,LAB_ram_f89a
    INC         DE
    LD          A,(DE)                    ;= $20
    RRCA
    JP          NC,LAB_ram_f8b0
LAB_ram_f8aa:
    CALL        SUB_ram_cd21
    JP          LAB_ram_f8b7
LAB_ram_f8b0:
    RRCA
    JP          C,LAB_ram_f8aa
    CALL        SUB_ram_cd2c
LAB_ram_f8b7:
    LD          A,(ITEM_F2)                             ;= $60
    LD          BC,$48a
    CALL        CHK_ITEM
F1_HD_NO_WALL:
    LD          DE,DAT_ram_33ef                         ;= $20
    LD          A,(DE)                    ;= $20
    RRCA
    JP          NC,LAB_ram_f8db
    EX          AF,AF'
    CALL        DRAW_L1_WALL
    EX          AF,AF'
    RRCA
    JP          NC,LAB_ram_f923
    RRCA
    JP          NC,LAB_ram_f923
LAB_ram_f8d5:
    CALL        DRAW_FL1_DOOR
    JP          LAB_ram_f923
LAB_ram_f8db:
    RRCA
    JP          NC,LAB_ram_f8e9
    RRCA
    JP          C,LAB_ram_f8d5
    CALL        DRAW_L1
    JP          LAB_ram_f923
LAB_ram_f8e9:
    INC         E
    LD          A,(DE)                    ;= $20
    RRCA
    JP          NC,LAB_ram_f902
    EX          AF,AF'
    CALL        SUB_ram_cab0
    EX          AF,AF'
    RRCA
    JP          NC,LAB_ram_f923
    RRCA
    JP          NC,LAB_ram_f923
LAB_ram_f8fc:
    CALL        SUB_ram_cac5
    JP          LAB_ram_f923
LAB_ram_f902:
    RRCA
    JP          NC,LAB_ram_f910
    RRCA
    JP          C,LAB_ram_f8fc
    CALL        DRAW_L1_DOOR_CLOSED
    JP          LAB_ram_f923
LAB_ram_f910:
    INC         E
    LD          A,(DE)                    ;= $20
    RRCA
    JP          NC,LAB_ram_f91c
LAB_ram_f916:
    CALL        DRAW_WALL_FL2_NEW
    JP          LAB_ram_f923
LAB_ram_f91c:
    RRCA
    JP          C,LAB_ram_f916
    CALL        DRAW_WALL_FL2_EMPTY
LAB_ram_f923:
    LD          DE,DAT_ram_33f2                         ;= $20
    LD          A,(DE)                    ;= $20
    RRCA
    JP          NC,LAB_ram_f93e
    EX          AF,AF'
    CALL        DRAW_WALL_FR1
    EX          AF,AF'
    RRCA
    JP          NC,LAB_ram_f986
    RRCA
    JP          NC,LAB_ram_f986
LAB_ram_f938:
    CALL        SUB_ram_cc6d
    JP          LAB_ram_f986
LAB_ram_f93e:
    RRCA
    JP          NC,LAB_ram_f94c
    RRCA
    JP          C,LAB_ram_f938
    CALL        SUB_ram_cc7a
    JP          LAB_ram_f986
LAB_ram_f94c:
    INC         E
    LD          A,(DE)                    ;= $20
    RRCA
    JP          NC,LAB_ram_f965
    EX          AF,AF'
    CALL        SUB_ram_cc9a
    EX          AF,AF'
    RRCA
    JP          NC,LAB_ram_f986
    RRCA
    JP          NC,LAB_ram_f986
LAB_ram_f95f:
    CALL        SUB_ram_ccaf
    JP          LAB_ram_f986
LAB_ram_f965:
    RRCA
    JP          NC,LAB_ram_f973
    RRCA
    JP          C,LAB_ram_f95f
    CALL        SUB_ram_ccb5
    JP          LAB_ram_f986
LAB_ram_f973:
    INC         E
    LD          A,(DE)                    ;= $20
    RRCA
    JP          NC,LAB_ram_f97f
LAB_ram_f979:
    CALL        SUB_ram_ccc3
    JP          LAB_ram_f986
LAB_ram_f97f:
    RRCA
    JP          C,LAB_ram_f979
    CALL        DRAW_WALL_FR2_EMPTY
LAB_ram_f986:
    LD          A,(ITEM_F1)                             ;= $60
    LD          BC,$28a
    CALL        CHK_ITEM
F0_HD_NO_WALL:
    LD          DE,DAT_ram_33f5                         ;= $20
    LD          A,(DE)                    ;= $20
    RRCA
    JP          NC,LAB_ram_f9aa
    EX          AF,AF'
    CALL        DRAW_WALL_FL0
    EX          AF,AF'
    RRCA
    JP          NC,LAB_ram_fa19
    RRCA
    JP          NC,LAB_ram_fa19
LAB_ram_f9a4:
    CALL        DRAW_DOOR_FLO
    JP          LAB_ram_fa19
LAB_ram_f9aa:
    RRCA
    JP          NC,LAB_ram_f9b8
    RRCA
    JP          C,LAB_ram_f9a4
    CALL        SUB_ram_c996
    JP          LAB_ram_fa19
LAB_ram_f9b8:
    INC         E
    LD          A,(DE)                    ;= $20
    RRCA
    JP          NC,LAB_ram_f9c4
LAB_ram_f9be:
    CALL        SUB_ram_c9c5
    JP          LAB_ram_fa19
LAB_ram_f9c4:
    RRCA
    JP          C,LAB_ram_f9be
    INC         E
    LD          A,(DE)                    ;= $20
    RRCA
    JP          NC,LAB_ram_f9f0
    EX          AF,AF'
    CALL        SUB_ram_c9d0
    CALL        SUB_ram_f9e7
    EX          AF,AF'
    RRCA
    JP          NC,LAB_ram_fa19
    RRCA
    JP          NC,LAB_ram_fa19
LAB_ram_f9de:
    CALL        SUB_ram_c9f3
    CALL        SUB_ram_f9e7
    JP          LAB_ram_fa19
SUB_ram_f9e7:
    LD          A,(ITEM_FL1)                            ;= $60
    LD          BC,$4d0
    JP          CHK_ITEM
LAB_ram_f9f0:
    RRCA
    JP          NC,LAB_ram_fa01
    RRCA
    JP          C,LAB_ram_f9de
    CALL        SUB_ram_c9e5
    CALL        SUB_ram_f9e7
    JP          LAB_ram_fa19
LAB_ram_fa01:
    INC         E
    RRCA
    JP          NC,LAB_ram_fa0f
LAB_ram_fa06:
    CALL        SUB_ram_c9f9
    CALL        SUB_ram_f9e7
    JP          LAB_ram_fa19
LAB_ram_fa0f:
    RRCA
    JP          C,LAB_ram_fa06
    CALL        DRAW_WALL_FL22_EMPTY
    CALL        SUB_ram_f9e7
LAB_ram_fa19:
    LD          DE,DAT_ram_33f9                         ;= $20
    LD          A,(DE)                    ;= $20
    RRCA
    JP          NC,LAB_ram_fa34
    EX          AF,AF'
    CALL        SUB_ram_cb4f
    EX          AF,AF'
    RRCA
    JP          NC,LAB_ram_faa3
    RRCA
    JP          NC,LAB_ram_faa3
LAB_ram_fa2e:
    CALL        DRAW_FRO_DOOR
    JP          LAB_ram_faa3
LAB_ram_fa34:
    RRCA
    JP          NC,LAB_ram_fa42
    RRCA
    JP          C,LAB_ram_fa2e
    CALL        SUB_ram_cb7e
    JP          LAB_ram_faa3
LAB_ram_fa42:
    INC         E
    LD          A,(DE)                    ;= $20
    RRCA
    JP          NC,LAB_ram_fa57
LAB_ram_fa48:
    CALL        SUB_ram_cbae
    JP          LAB_ram_faa3
SUB_ram_fa4e:
    LD          A,(ITEM_FR1)                            ;= $60
    LD          BC,$4e4
    JP          CHK_ITEM
LAB_ram_fa57:
    RRCA
    JP          C,LAB_ram_fa48
    INC         E
    LD          A,(DE)                    ;= $20
    RRCA
    JP          NC,LAB_ram_fa7a
    EX          AF,AF'
    CALL        SUB_ram_cbb9
    CALL        SUB_ram_fa4e
    EX          AF,AF'
    RRCA
    JP          NC,LAB_ram_faa3
    RRCA
    JP          NC,LAB_ram_faa3
LAB_ram_fa71:
    CALL        SUB_ram_cbce
    CALL        SUB_ram_fa4e
    JP          LAB_ram_faa3
LAB_ram_fa7a:
    RRCA
    JP          NC,LAB_ram_fa8b
    RRCA
    JP          C,LAB_ram_fa71
    CALL        SUB_ram_cbd4
    CALL        SUB_ram_fa4e
    JP          LAB_ram_faa3
LAB_ram_fa8b:
    INC         E
    RRCA
    JP          NC,LAB_ram_fa99
LAB_ram_fa90:
    CALL        SUB_ram_cbe2
    CALL        SUB_ram_fa4e
    JP          LAB_ram_faa3
LAB_ram_fa99:
    RRCA
    JP          C,LAB_ram_fa90
    CALL        DRAW_WALL_FR222_EMPTY
    CALL        SUB_ram_fa4e
LAB_ram_faa3:
    LD          A,(ITEM_F0)                             ;= $60
    LD          BC,$8a
    JP          CHK_ITEM
MAKE_RANDOM_BYTE:
    PUSH        BC
    PUSH        HL
    LD          B,0x5                                   ;Run data randomizer 5x
    LD          HL,(RNDHOLD_AA)
RANDOM_BYTE_LOOP:
    SLA         L                                       ;L x 2
    RL          H
    JP          C,FINISH_BYTE_LOOP
    LD          A,$87
    XOR         L
    LD          L,A
    LD          A,$1d
    XOR         H
    LD          H,A
FINISH_BYTE_LOOP:
    DJNZ        RANDOM_BYTE_LOOP
    LD          (RNDHOLD_AA),HL
    LD          A,H
    POP         HL
    POP         BC
    RET
UPDATE_SCR_SAVER_TIMER:
    PUSH        BC
    PUSH        HL
    LD          HL,(TIMER_E)
    LD          B,H
    LD          C,L
    SLA         C
    RL          B
    SLA         C
    RL          B
    ADD         HL,BC
    LD          A,H
    XOR         L
    LD          (TIMER_D),A
    LD          B,H
    LD          C,L
    SLA         C
    RL          B
    SLA         C
    RL          B
    ADD         HL,BC
    LD          BC,$13
    ADD         HL,BC
    LD          (TIMER_E),HL
    POP         HL
    POP         BC
    RET
MINOTAUR_DEAD:
    CALL        DRAW_BKGD
    LD          HL,DAT_ram_3050                         ;= $20
    LD          DE,THE_END_PART_A                       ;WAS LD DE, 0xC25D
    LD          B,$10                                  ;RED on BLK
    CALL        GFX_DRAW
    LD          HL,DAT_ram_30a0                         ;= $20
    CALL        GFX_DRAW
    CALL        MAKE_RANDOM_BYTE
    AND         0x3
    ADD         A,0xa
    LD          B,A
    LD          A,(INPUT_HOLDER)
    RLCA
    RLCA
    RLCA
    RLCA
    LD          B,A
    XOR         A
    LD          (INPUT_HOLDER),A
    LD          DE,MINOTAUR                             ;= $04,$04,$04,$04
    LD          HL,DAT_ram_32da                         ;= $20
    CALL        GFX_DRAW
    CALL        TOTAL_HEAL
    CALL        REDRAW_STATS
    LD          B,0x2                                   ;Was LD B,0x6
MINOTAUR_DEAD_SOUND_LOOP:
    EXX
    CALL        SUB_ram_cd5f
    CALL        END_OF_GAME_SOUND
    EXX
    DJNZ        MINOTAUR_DEAD_SOUND_LOOP
    JP          SCREEN_SAVER_FULL_SCREEN
DO_REST:
    LD          A,(COMBAT_BUSY_FLAG)                   ;Load combat busy flag into A (was mislabeled)
    AND         A
    JP          NZ,NO_ACTION_TAKEN                      ;If food is empty, do nothing
CHK_NEEDS_HEALING:
    LD          HL,(PLAYER_PHYS_HEALTH_MAX)             ;HL = max PHYS health
    LD          DE,(PLAYER_PHYS_HEALTH)                 ;DE = current PHYS health
    CALL        RECALC_PHYS_HEALTH
    OR          L
    JP          NZ,HEAL_PLAYER_PHYS_HEALTH
    LD          A,(PLAYER_SPRT_HEALTH_MAX)
    LD          C,A
    LD          A,(PLAYER_SPRT_HEALTH)
    CP          C
    JP          Z,INPUT_DEBOUNCE
    JP          HEAL_PLAYER_SPRT_HEALTH
HEAL_PLAYER_PHYS_HEALTH:
    LD          HL,(BYTE_ram_3aa9)
    LD          DE,0x1
    CALL        RECALC_PHYS_HEALTH
    JP          C,INPUT_DEBOUNCE
    LD          (BYTE_ram_3aa9),HL
    LD          HL,FOOD_INV
    DEC         (HL)
    LD          HL,(PLAYER_PHYS_HEALTH)
    CALL        SUB_ram_e427
    LD          (PLAYER_PHYS_HEALTH),HL
    CALL        REDRAW_STATS
    LD          A,(PLAYER_SPRT_HEALTH_MAX)
    LD          C,A
    LD          A,(PLAYER_SPRT_HEALTH)
    CP          C
    JP          Z,CHK_NEEDS_HEALING
HEAL_PLAYER_SPRT_HEALTH:
    LD          HL,(BYTE_ram_3aa9)
    LD          DE,0x1
    CALL        RECALC_PHYS_HEALTH
    JP          C,INPUT_DEBOUNCE
    LD          (BYTE_ram_3aa9),HL
    LD          HL,FOOD_INV
    DEC         (HL)
    LD          A,(PLAYER_SPRT_HEALTH)
    ADD         A,0x1
    DAA
    LD          (PLAYER_SPRT_HEALTH),A
    CALL        REDRAW_STATS
    JP          CHK_NEEDS_HEALING
KEY_COMPARE:
    LD          A,(RAM_AE)
    CP          $31                                    ;Compare to "1" db?
    JP          NZ,WAIT_FOR_INPUT
KEY_COL_0:
    LD          HL,KEY_INPUT_COL0                       ;= $60
    LD          A,(HL)                  ;A = Key Column 0
    CP          $fe                                    ;If Key Row = 0 "="
    JP          Z,NO_ACTION_TAKEN
    CP          $fd                                    ;If Key Row = 1 "BKSP"
    JP          Z,NO_ACTION_TAKEN
    CP          $fb                                    ;If Key Row = 2 ":"
    JP          Z,NO_ACTION_TAKEN
    CP          $f7                                    ;If Key Row = 3 "RET"
    JP          Z,NO_ACTION_TAKEN
    CP          $ef                                    ;If Key Row = 4 ";"
    JP          Z,DO_GLANCE_RIGHT
    CP          $df                                    ;If Key Row = 5 "."
    JP          Z,DO_TURN_RIGHT
KEY_COL_1:
    INC         L
    LD          A,(HL)                  ;A = Key Column 1
    CP          $fe                                    ;If Key Row = 0 "-"
    JP          Z,NO_ACTION_TAKEN
    CP          $fd                                    ;If Key Row = 1 "/"
    JP          Z,NO_ACTION_TAKEN
    CP          $fb                                    ;If Key Row = 2 "0"
    JP          Z,NO_ACTION_TAKEN
    CP          $f7                                    ;If Key Row = 3 "P"
    JP          Z,NO_ACTION_TAKEN
    CP          $ef                                    ;If Key Row = 4 "L"
    JP          Z,DO_MOVE_FW_CHK_WALLS
    CP          $df                                    ;If Key Row = 5 ","
    JP          Z,DO_JUMP_BACK
KEY_COL_2:
    INC         L
    LD          A,(HL)                  ;A = Key Column 2
    CP          $fe                                    ;If Key Row = 0 "9"
    JP          Z,NO_ACTION_TAKEN
    CP          $fd                                    ;If Key Row = 1 "O"
    JP          Z,NO_ACTION_TAKEN
    CP          $fb                                    ;If Key Row = 2 "K"
    JP          Z,DO_MOVE_FW_CHK_WALLS
    CP          $f7                                    ;If Key Row = 3 "M"
    JP          Z,DO_TURN_LEFT
    CP          $ef                                    ;If Key Row = 4 "N"
    JP          Z,DO_USE_ATTACK
    CP          $df                                    ;If Key Row = 5 "J"
    JP          Z,DO_GLANCE_LEFT
KEY_COL_3:
    INC         L
    LD          A,(HL)                  ;A = Key Column 3
    CP          $fe                                    ;If Key Row = 0 "8"
    JP          Z,NO_ACTION_TAKEN
    CP          $fd                                    ;If Key Row = 1 "I"
    JP          Z,NO_ACTION_TAKEN
    CP          $fb                                    ;If Key Row = 2 "7"
    JP          Z,NO_ACTION_TAKEN
    CP          $f7                                    ;If Key Row = 3 "U"
    JP          Z,NO_ACTION_TAKEN
    CP          $ef                                    ;If Key Row = 4 "H"
    JP          Z,DO_OPEN_CLOSE
    CP          $df                                    ;If Key Row = 5 "B"
    JP          Z,NO_ACTION_TAKEN
KEY_COL_4:
    INC         L
    LD          A,(HL)                  ;A = Key Column 4
    CP          $fe                                    ;If Key Row = 0 "6"
    JP          Z,NO_ACTION_TAKEN
    CP          $fd                                    ;If Key Row = 1 "Y"
    JP          Z,USE_MAP
    CP          $fb                                    ;If Key Row = 2 "G"
    JP          Z,NO_ACTION_TAKEN
    CP          $f7                                    ;If Key Row = 3 "V"
    JP          Z,NO_ACTION_TAKEN
    CP          $ef                                    ;If Key Row = 4 "C"
    JP          Z,DO_COUNT_ARROWS
    CP          $df                                    ;If Key Row = 5 "F"
    JP          Z,DO_REST
KEY_COL_5:
    INC         L
    LD          A,(HL)                  ;A = Key Column 5
    CP          $fe                                    ;If Key Row = 0 "5"
    JP          Z,NO_ACTION_TAKEN
    CP          $fd                                    ;If Key Row = 1 "T"
    JP          Z,DO_TELEPORT
    CP          $fb                                    ;If Key Row = 2 "4"
    JP          Z,NO_ACTION_TAKEN
    CP          $f7                                    ;If Key Row = 3 "R"
    JP          Z,DO_SWAP_PACK
    CP          $ef                                    ;If Key Row = 4 "D"
    JP          Z,DO_USE_LADDER
    CP          $df                                    ;If Key Row = 5 "X"
    JP          Z,DO_COUNT_FOOD
KEY_COL_6:
    INC         L
    LD          A,(HL)                  ;A = Key Column 6
    CP          $fe                                    ;If Key Row = 0 "3"
    JP          Z,NO_ACTION_TAKEN
    CP          $fd                                    ;If Key Row = 1 "E"
    JP          Z,DO_SWAP_HANDS
    CP          $fb                                    ;If Key Row = 2 "S"
    JP          Z,DO_ROTATE_PACK
    CP          $f7                                    ;If Key Row = 3 "Z"
    JP          Z,WIPE_WALLS
    CP          $ef                                    ;If Key Row = 4 "SPC"
    JP          Z,NO_ACTION_TAKEN
    CP          $df                                    ;If Key Row = 5 "A"
    JP          Z,NO_ACTION_TAKEN
KEY_COL_7:
    INC         L
    LD          A,(HL)                  ;A = Key Column 7
    CP          $fe                                    ;If Key Row = 0 "2"
    JP          Z,NO_ACTION_TAKEN
    CP          $fd                                    ;If Key Row = 1 "W"
    JP          Z,DO_PICK_UP
    CP          $fb                                    ;If Key Row = 2 "1"
    JP          Z,NO_ACTION_TAKEN
    CP          $f7                                    ;If Key Row = 3 "Q"
    JP          Z,MAX_HEALTH_ARROWS_FOOD
    CP          $ef                                    ;If Key Row = 4 "SHFT"
    JP          Z,NO_ACTION_TAKEN
    CP          $df                                    ;If Key Row = 5 "CTRL"
    JP          Z,NO_ACTION_TAKEN
    JP          NO_ACTION_TAKEN
MAX_HEALTH_ARROWS_FOOD:
    LD          HL,PLAYER_PHYS_HEALTH
    LD          A,$99
    LD          (HL),A
    INC         HL
    LD          (HL),A
    INC         HL
    LD          (HL),A
    INC         HL
    LD          (HL),A
    INC         HL
    LD          (HL),A
    INC         HL
    LD          (HL),A
    LD          HL,FOOD_INV
    LD          (HL),A
    INC         HL
    LD          (HL),A
    CALL        PLAY_POWER_UP_SOUND
    CALL        REDRAW_STATS
    JP          INPUT_DEBOUNCE
DO_TELEPORT:
    LD          A,(MAP_LADDER_OFFSET)
    LD          (PLAYER_MAP_POS),A
    CALL        PLAY_TELEPORT_SOUND
    JP          UPDATE_VIEWPORT
REDRAW_STATS:
    CALL        DRAW_ICON_BAR
    LD          HL,PLAYER_PHYS_HEALTH
    LD          DE,CHRRAM_PHYS_HEALTH_1000              ;= $20
    LD          B,0x2
    CALL        RECALC_AND_REDRAW_BCD
    LD          HL,PLAYER_SPRT_HEALTH
    LD          DE,CHRRAM_SPRT_HEALTH_10                ;= $20
    LD          B,0x1
    JP          RECALC_AND_REDRAW_BCD
CHECK_RING:
    PUSH        AF
    LD          A,(RING_INV_SLOT)
    CALL        LEVEL_TO_COLRAM_FIX
    LD          (COLRAM_RING_IDX),A                     ;= $60    `
    POP         AF
    RET
CHECK_HELMET:
    PUSH        AF
    LD          A,(HELMET_INV_SLOT)
    CALL        LEVEL_TO_COLRAM_FIX
    LD          (COLRAM_HELMET_IDX),A                   ;= $60    `
    POP         AF
    RET
CHECK_ARMOR:
    PUSH        AF
    LD          A,(ARMOR_INV_SLOT)
    CALL        LEVEL_TO_COLRAM_FIX
    LD          (COLRAM_ARMOR_IDX),A                    ;= $60    `
    POP         AF
    RET
LEVEL_TO_COLRAM_FIX:
    ADD         A,A
    SUB         0x1
    SLA         A
    SLA         A
    SLA         A
    SLA         A
    RET
RHA_REDRAW:
    CALL        CHECK_RING
    CALL        CHECK_HELMET
    CALL        CHECK_ARMOR
    JP          INPUT_DEBOUNCE
PLAY_TELEPORT_SOUND:
    LD          BC,$220
    LD          DE,$18
    CALL        PLAY_SOUND_LOOP
    LD          BC,$110
    LD          DE,$18
    CALL        PLAY_SOUND_LOOP
    LD          BC,$88
    LD          DE,$18
    CALL        PLAY_SOUND_LOOP
    LD          BC,$44
    LD          DE,$18
    CALL        PLAY_SOUND_LOOP
    RET
PLAY_POWER_UP_SOUND:
    LD          BC,$220
    LD          DE,$18
    CALL        PLAY_SOUND_LOOP
    LD          BC,$200
    LD          DE,$18
    CALL        PLAY_SOUND_LOOP
    LD          BC,$1e0
    LD          DE,$18
    CALL        PLAY_SOUND_LOOP
    LD          BC,$1c0
    LD          DE,$60
    CALL        PLAY_SOUND_LOOP
    RET
