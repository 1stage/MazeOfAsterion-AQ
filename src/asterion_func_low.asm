DRAW_DOOR_BOTTOM_SETUP:
    LD          DE,$29								; GRN on DKCYN
								                    ; (bottom of closed door)
DRAW_SINGLE_PIXEL_DOWN:
    LD          (HL),A
    SCF
    CCF
    SBC         HL,DE
DRAW_VERTICAL_LINE_3_DOWN:
    LD          (HL),A
    SCF
    CCF
    SBC         HL,DE
    LD          (HL),A
    SBC         HL,DE
    LD          (HL),A
    RET
    LD          DE,$29								; GRN on DKCYN
								                    ; (bottom of closed door)
DRAW_VERTICAL_LINE_3_UP:
    LD          (HL),A
    ADD         HL,DE
CONTINUE_VERTICAL_LINE_UP:
    LD          (HL),A
    ADD         HL,DE
    LD          (HL),A
    ADD         HL,DE
    LD          (HL),A
    RET
DRAW_CROSS_PATTERN_RIGHT:
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
DRAW_CROSS_PATTERN_LEFT:
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
DRAW_HORIZONTAL_LINE_3_RIGHT:
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
DRAW_HORIZONTAL_LINE_3_LEFT:
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
    LD          DE,$28								; DE = 40 (next line) / $28
DRAW_CELL:
    LD          (HL),A
    DEC         C
    RET         Z
    ADD         HL,DE								; Goto next row
    JP          DRAW_CELL
FILL_CHRCOL_RECT:
    LD          DE,$28								; DE = 40 / $28 (next row)
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
DRAW_F0_WALL:
    LD          HL,COLRAM_F0_WALL_MAP_IDX
    LD          BC,RECT(16,16)							; 16 x 16 rectangle
    LD          A,COLOR(BLU,BLU)								; BLU on BLU
    JP          FILL_CHRCOL_RECT
DRAW_F0_WALL_AND_CLOSED_DOOR:
    CALL        DRAW_F0_WALL
    LD          A,COLOR(GRN,GRN)								; GRN on GRN
DRAW_DOOR_F0:
    LD          HL,COLRAM_F0_DOOR_IDX
    LD          BC,RECT(8,12)								; 8 x 12 rectangle
    JP          FILL_CHRCOL_RECT
DRAW_WALL_F0_AND_OPEN_DOOR:
    CALL        DRAW_F0_WALL
    LD          A,$f0								; DKGRY on BLK
								                    ; WAS BLK on DKBLU
								                    ; WAS LD A,0xb
    JP          DRAW_DOOR_F0
DRAW_WALL_F1:
    LD          HL,CHRRAM_F1_WALL_IDX
    LD          BC,RECT(8,8)								; 8 x 8 rectangle
    LD          A,$20								; Change to SPACE 32 / $20
                                                    ; WAS d134 / $86 crosshatch char
                                                    ; WAS LD A, $86
    CALL        FILL_CHRCOL_RECT
    LD          C,0x8
    LD          HL,COLRAM_F0_DOOR_IDX
    LD          A,$4b								; BLU on DKBLU
    JP          DRAW_CHRCOLS
DRAW_WALL_F1_AND_CLOSED_DOOR:
    CALL        DRAW_WALL_F1
    LD          A,COLOR(GRN,DKGRN)								; GRN on DKGRN
DRAW_DOOR_F1_OPEN:
    LD          HL,COLRAM_F1_DOOR_IDX
    LD          BC,RECT(4,6)								; 4 x 6 rectangle
    JP          FILL_CHRCOL_RECT
DRAW_WALL_F1_AND_OPEN_DOOR:
    CALL        DRAW_WALL_F1
    LD          A,0x0								; BLK on BLK
    JP          DRAW_DOOR_F1_OPEN
DRAW_WALL_F2:
    LD          BC,RECT(4,4)								; 4 x 4 rectangle
    LD          HL,COLRAM_F1_DOOR_IDX
    LD          A,COLOR(DKGRY,DKGRY)								; DKGRY on DKGRY
                                                    ; WAS BLK on DKBLU
                                                    ; WAS LD A,0xb
    JP          FILL_CHRCOL_RECT
DRAW_DOOR_F2_OPEN:
    LD          HL,COLRAM_F1_DOOR_IDX
    LD          A,0x0								; BLK on BLK
UPDATE_F0_ITEM:
    LD          BC,$404								; 4 x 4 rectangle
    JP          FILL_CHRCOL_RECT
DRAW_WALL_FL0:
    LD          HL,COLRAM_FL00_WALL_IDX
    LD          A,$40								; BLU on BLK
                                                    ; WAS BLU on CYN
                                                    ; WAS LD A,$46
    CALL        DRAW_DOOR_BOTTOM_SETUP
    DEC         DE
    ADD         HL,DE
    LD          A,0x4								; BLK on BLU
    CALL        DRAW_CROSS_PATTERN_RIGHT
    ADD         HL,DE
    LD          BC,$410								; Jump into COLRAM and down one row
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    CALL        DRAW_HORIZONTAL_LINE_3_RIGHT
    ADD         HL,DE
    LD          A,$f4								; DKGRY on BLU
                                                    ; WAS DKCYN on BLU
                                                    ; WAS LD A,$94
    DEC         DE
    CALL        DRAW_SINGLE_PIXEL_DOWN
    LD          A,$c0
    LD          HL,DAT_ram_33c0
    CALL        DRAW_SINGLE_PIXEL_DOWN
    LD          HL,IDX_VIEWPORT_CHRRAM
    LD          A,$c1
    INC         DE
    INC         DE
    JP          DRAW_VERTICAL_LINE_3_UP
    RET
DRAW_DOOR_FLO:
    CALL        DRAW_WALL_FL0
    LD          A,$f0								; DKGRY on BLK
                                                    ; WAS DKCYN on DKBLU
                                                    ; WAS LD A,$9b
    EX          AF,AF'
    LD          A,0x4								; BLK on BLU
                                                    ; WAS DKBLU on BLU
                                                    ; LD A,$b4
    JP          DRAW_FL0_DOOR_FRAME
SUB_ram_c996:
    CALL        DRAW_WALL_FL0
    LD          A,$f2								; DKGRY on GRN
                                                    ; WAS DKCYN on GRN
                                                    ; WAS LD A,$92
    EX          AF,AF'
    LD          A,$24								; GRN on BLU
DRAW_FL0_DOOR_FRAME:
    LD          HL,COLRAM_FL0_DOOR_FRAME_IDX
    CALL        DRAW_VERTICAL_LINE_3_DOWN
    DEC         DE
    ADD         HL,DE
    EX          AF,AF'
    CALL        DRAW_CROSS_PATTERN_RIGHT
    ADD         HL,DE
    LD          BC,$30c
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    CALL        DRAW_HORIZONTAL_LINE_3_RIGHT
    ADD         HL,DE
    DEC         DE
    CALL        DRAW_VERTICAL_LINE_3_DOWN
    LD          HL,DAT_ram_30c8
    LD          A,$c1
    INC         DE
    INC         DE
    JP          CONTINUE_VERTICAL_LINE_UP
    RET
SUB_ram_c9c5:
    LD          HL,DAT_ram_34c8
    LD          A,0x4								; BLK on BLU
    LD          BC,RECT(4,16)								; 4 x 16 rectangle
    JP          FILL_CHRCOL_RECT
SUB_ram_c9d0:
    LD          HL,CHRRAM_L1_WALL_IDX
    LD          BC,$408								; 4 x 8 rectangle
    LD          A,$20								; Change to SPACE 32 / $20
                                                    ; WAS d134 / $86 crosshatch char
                                                    ; WAS LD A, $86
    CALL        FILL_CHRCOL_RECT
    LD          HL,COLRAM_L1_WALL_IDX
    LD          C,0x8
    LD          A,$4b								; BLU on DKBLU
    JP          DRAW_CHRCOLS
SUB_ram_c9e5:
    CALL        SUB_ram_c9d0
    LD          A,$dd								; DKGRN on DKGRN
DRAW_L1_DOOR_PATTERN:
    LD          HL,COLRAM_L1_DOOR_PATTERN_IDX
    LD          BC,$206								; 2 x 6 rectangle
    JP          DRAW_CHRCOLS
SUB_ram_c9f3:
    CALL        SUB_ram_c9d0
    XOR         A
    JP          DRAW_L1_DOOR_PATTERN
SUB_ram_c9f9:
    LD          HL,CHRRAM_L1_WALL_IDX
    LD          A,$c1
    LD          (HL),A
    LD          DE,$28
    ADD         HL,DE
    INC         HL
    LD          (HL),A
    LD          HL,DAT_ram_3259
    LD          A,$c0
    LD          (HL),A
    ADD         HL,DE
    DEC         HL
    LD          (HL),A
    LD          HL,COLRAM_L1_WALL_IDX
    LD          A,$bf								; DKBLU on DKGRY
                                                    ; WAS DKBLU on DKCYN
                                                    ; WAS LD A,$b9
    LD          (HL),A
    ADD         HL,DE
    INC         HL
    LD          (HL),A
    DEC         HL
    LD          A,0xf								; BLK on DKGRY
                                                    ; WAS BLK on DKBLU
                                                    ; WAS LD A,0xb
    LD          (HL),A
    LD          BC,$204								; 2 x 4 rectangle
    ADD         HL,DE
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    LD          (HL),A
    INC         HL
    LD          A,0xf								; BLK on DKGRY
                                                    ; WAS DKCYN on DKBLU
                                                    ; WAS LD A,$9b
    LD          (HL),A
    ADD         HL,DE
    DEC         HL
    LD          (HL),A
    LD          HL,COLRAM_L1_DOOR_PATTERN_IDX
    LD          C,0x4
    LD          A,0x0
    JP          DRAW_CHRCOLS
DRAW_WALL_FL22:
    LD          HL,COLRAM_FL22_WALL_IDX
    LD          BC,RECT(4,4)								; 4 x 4 rectangle
    LD          A,COLOR(DKGRY,DKGRY)								; DKGRY on DKGRY
    JP          FILL_CHRCOL_RECT
DRAW_L1_WALL:
    LD          HL,CHRRAM_FL1_WALL_IDX
    LD          A,$c1								; LEFT angle CHR
    CALL        DRAW_DOOR_BOTTOM_SETUP
    DEC         DE
    ADD         HL,DE
    LD          A,$20								; Change to SPACE 32 / $20
                                                    ; WAS d134 / $86 crosshatch char
                                                    ; WAS LD A, $86
    CALL        DRAW_CROSS_PATTERN_RIGHT
    ADD         HL,DE
    LD          BC,$408								; 4 x 8 rectangle
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    CALL        DRAW_HORIZONTAL_LINE_3_RIGHT
    ADD         HL,DE
    LD          A,$c0								; RIGHT angle CHR
    DEC         DE
    CALL        DRAW_SINGLE_PIXEL_DOWN
    LD          HL,DAT_ram_3547
    LD          A,$b0								; DKBLU on BLK
								; WAS DKBLU on CYN
								; WAS LD A,$b6
    CALL        DRAW_DOOR_BOTTOM_SETUP
    DEC         DE
    ADD         HL,DE
    LD          A,$4b								; BLU on DKBLU
    CALL        DRAW_CROSS_PATTERN_RIGHT
    ADD         HL,DE
    LD          BC,$408								; Jump to COLRAM + 32 cells
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    CALL        DRAW_HORIZONTAL_LINE_3_RIGHT
    ADD         HL,DE
    LD          A,$fb								; DKGRY on DKBLU
								; WAS DKCYN on DKBLU
								; WAS LD A,$9b
    DEC         DE
    JP          DRAW_SINGLE_PIXEL_DOWN
    RET
DRAW_FL1_DOOR:
    CALL        DRAW_L1_WALL
    LD          A,$f0								; DKGRY on BLK
								; WAS DKCYN on BLK
								; WAS LD A,$90
    PUSH        AF
    LD          A,$b0								; DKBLU on BLK
    PUSH        AF
    LD          A,0xb								; BLK on DKGRY
								; WAS BLK on DKBLU
								; WAS LD A,0xb
    JP          DRAW_L1_DOOR
DRAW_L1:
    CALL        DRAW_L1_WALL
    LD          A,$fd								; DKGRY on DKGRN
								; WAS DKCYN on DKGRN
								; WAS LD A,$9d
    PUSH        AF
    LD          A,$2d								; GRN on DKGRN
    PUSH        AF
    LD          A,$db								; DKGRN on DKBLU
DRAW_L1_DOOR:
    LD          HL,COLRAM_L1_DOOR_IDX
    LD          BC,$207								; 2 x 7 rectangle
    CALL        SUB_ram_cb1c
    LD          HL,CHRRAM_L1_DOOR_IDX
    LD          A,$c1								; LEFT ANGLE CHR
    LD          (HL),A
    LD          DE,$29
    ADD         HL,DE
    LD          (HL),A
    RET
SUB_ram_cab0:
    LD          HL,DAT_ram_356c
    LD          BC,RECT(4,8)								; 4 x 8 rectangle
    LD          A,COLOR(BLU,DKBLU)								; BLU on DKBLU
    CALL        FILL_CHRCOL_RECT
    LD          HL,DAT_ram_316c
    LD          C,0x8
    LD          A,$20								; Change to SPACE 32 / $20
								; WAS d134 / $86 crosshatch char
								; WAS LD A, $86
    JP          DRAW_CHRCOLS
SUB_ram_cac5:
    CALL        SUB_ram_cab0
    XOR         A
    JP          DRAW_L1_DOOR_2
DRAW_L1_DOOR_CLOSED:
    CALL        SUB_ram_cab0
    LD          A,$dd								; DKGRN on DKGRN
DRAW_L1_DOOR_2:
    LD          HL,COLRAM_FL2_WALL_IDX
    LD          BC,$206								; 2 x 6 rectangle
    JP          DRAW_CHRCOLS
DRAW_WALL_FL2:
    LD          HL,COLRAM_FL2_WALL_IDX
    LD          BC,RECT(2,4)								; 2 x 4 rectangle
    LD          A,COLOR(RED,RED)								; RED on RED
    CALL        FILL_CHRCOL_RECT
    LD          C,0x4
    LD          HL,COLRAM_FL2_PLUS_WALL_IDX
    LD          A,$22								; BLK on DKGRY
								; WAS BLK on DKBLU
								; WAS LD A,0xb
    JP          DRAW_CHRCOLS
DRAW_WALL_FL2_EMPTY:
    LD          HL,COLRAM_FL2_WALL_IDX
    LD          BC,RECT(4,4)								; 4 x 4 rectangle
    LD          A,COLOR(BLK,BLK)								; BLK on BLK
    JP          FILL_CHRCOL_RECT
DRAW_WALL_L2:
    LD          A,$ca								; Right slash char
    PUSH        AF
    LD          A,$20								; GRN on BLK
    PUSH        AF
    LD          HL,CHRRAM_F1_WALL_IDX
    LD          A,$c1								; Left angle char
    LD          BC,$204								; 2 x 4 rectangle
    CALL        SUB_ram_cb1c
    LD          A,0xf								; FL2 Bottom Color
								; BLK on DKGRY
								; WAS DKCYN on DKBLU
								; WAS LD A,$9b
    PUSH        AF
    LD          A,0xf								; FL2 Wall Color
								; BLK on DKGRY
								; WAS BLK on DKBLU
								; WAS LD A,0xb
    PUSH        AF
    LD          HL,COLRAM_F0_DOOR_IDX
    LD          A,$f0								; FL2 Top Color
								; DKGRY on BLK
								; WAS DKBLU on CYN
								; WAS LD A,$b6
    LD          BC,$204								; 2 x 4 rectangle
    CALL        SUB_ram_cb1c
    RET
SUB_ram_cb1c:
    POP         IX
    LD          (HL),A
    LD          DE,$29								; EDIT MEdb?
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
    LD          HL,DAT_ram_35c0
    LD          BC,$204								; 2 x 4 rectangle
    LD          A,0xf								; BLK on DKGRY
								; WAS BLK on DKBLU
								; WAS LD A,0xb
    JP          FILL_CHRCOL_RECT
DRAW_WALL_L2_C_EMPTY:
    LD          HL,DAT_ram_35c0
    LD          BC,$204								; 2 x 4 rectangle
    LD          A,0x0								; BLK on BLK
    JP          FILL_CHRCOL_RECT
SUB_ram_cb4f:
    LD          A,$f4								; DKGRY on BLU
								; WAS DKCYN on BLU
								; WAS LD A,$94
    PUSH        AF
    LD          BC,$410
    LD          A,0x4								; BLK on BLU
    PUSH        AF
    LD          A,$40								; BLU on BLK
								; WAS BLU on CYN
								; WAS LD A, $46
    LD          HL,DAT_ram_34b4
    CALL        SUB_ram_cc4d
    LD          HL,DAT_ram_303f
    LD          A,$c0								; Right angle char
    LD          DE,$27
    CALL        DRAW_VERTICAL_LINE_3_UP
    LD          HL,DAT_ram_335c
    INC         A
    INC         DE
    INC         DE
    JP          DRAW_VERTICAL_LINE_3_UP
DRAW_FR0_DOOR:
    CALL        SUB_ram_cb4f
    LD          A,$f0								; DKGRY on BLK
								; WAS DKCYN on DKBLU
								; WAS LD A,$9b
    EX          AF,AF'
    LD          A,0x4								; BLK on BLU
								; WAS DKBLU on BLU
								; WAS LDA A,$b4
    JP          LAB_ram_cb86
SUB_ram_cb7e:
    CALL        SUB_ram_cb4f
    LD          A,$f2								; DKGRY on GRN
								; WAS DKCYN on GRN
								; WAS LD A,$92
    EX          AF,AF'
    LD          A,$24								; GRN on BLU
LAB_ram_cb86:
    LD          HL,DAT_ram_352d
    DEC         DE
    DEC         DE
    CALL        DRAW_VERTICAL_LINE_3_DOWN
    INC         DE
    ADD         HL,DE
    EX          AF,AF'
    CALL        DRAW_CROSS_PATTERN_LEFT
    ADD         HL,DE
    LD          BC,$30c
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    CALL        DRAW_HORIZONTAL_LINE_3_LEFT
    ADD         HL,DE
    INC         DE
    CALL        DRAW_VERTICAL_LINE_3_DOWN
    LD          HL,DAT_ram_30df
    LD          A,$c0								; Right angle char
    DEC         DE
    DEC         DE
    JP          CONTINUE_VERTICAL_LINE_UP
SUB_ram_cbae:
    LD          HL,DAT_ram_34dc
    LD          A,0x4								; BLK on BLU
    LD          BC,RECT(4,16)								; 4 x 16 rectangle
    JP          FILL_CHRCOL_RECT
SUB_ram_cbb9:
    LD          HL,DAT_ram_317c
    LD          BC,$408
    LD          A,$20								; Change to SPACE 32 / $20
								; WAS d134 / $86 crosshatch char
								; WAS LD A, $86
    CALL        FILL_CHRCOL_RECT
    LD          HL,DAT_ram_357c
    LD          C,0x8
    LD          A,$4b								; BLU on DKBLU
    JP          DRAW_CHRCOLS
SUB_ram_cbce:
    CALL        SUB_ram_cbb9
    XOR         A
    JP          LAB_ram_cbd9
SUB_ram_cbd4:
    CALL        SUB_ram_cbb9
    LD          A,$dd								; DKGRN on DKGRNdb?
LAB_ram_cbd9:
    LD          HL,DAT_ram_35cc
    LD          BC,$206								; 2 x 6 rectangledb?
    JP          DRAW_CHRCOLS
SUB_ram_cbe2:
    LD          HL,DAT_ram_317f
    LD          A,$c0								; Right angle char
    LD          (HL),A
    LD          DE,$28
    ADD         HL,DE
    DEC         HL
    LD          (HL),A
    LD          HL,DAT_ram_326e
    LD          A,$c1								; Left angle char
    LD          (HL),A
    ADD         HL,DE
    INC         HL
    LD          (HL),A
    LD          HL,DAT_ram_357f
    LD          A,$bf								; DKBLU on DKGRY
								; WAS DKBLU on DKCYN
								; WAS LD A,$b9
    LD          (HL),A
    ADD         HL,DE
    DEC         HL
    LD          (HL),A
    INC         HL
    LD          A,0xf								; BLK on DKGRY
								; WAS BLK on DKBLU
								; WAS LD A,0xb
    LD          (HL),A
    LD          BC,$204								; 2 x 4 rectangle
    ADD         HL,DE
    DEC         HL
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    INC         HL
    LD          (HL),A
    DEC         HL
    LD          A,0xf								; BLK on DKGRY
								; WAS DKCYN on DKBLU
								; WAS LD A,$9b
    LD          (HL),A
    ADD         HL,DE
    INC         HL
    LD          (HL),A
    LD          HL,DAT_ram_35cc
    LD          C,0x4
    LD          A,0x0
    JP          DRAW_CHRCOLS
DRAW_WALL_FR222_EMPTY:
    LD          HL,DAT_ram_35cc
    LD          BC,$404								; 4 x 4 rectangle
    LD          A,0x0								; BLK on BLK
    JP          FILL_CHRCOL_RECT
DRAW_WALL_FR1:
    LD          A,$c1
    PUSH        AF
    LD          BC,$408								; 4 x 8 rectangle
    LD          A,$20								; Change to SPACE 32 / $20
								; WAS d134 / $86 crosshatch char
								; WAS LD A, $86
    PUSH        AF
    LD          A,$c0								; Right angle char
    LD          HL,DAT_ram_3150
    CALL        SUB_ram_cc4d
    LD          A,$fb								; DKGRY on DKBLU
								; WAS DKCYN on DKBLU
								; WAS LD $9b
    PUSH        AF
    LD          C,0x8
    LD          A,$4b								; BLU on DKBLU
    PUSH        AF
    LD          A,$b0								; DKBLU on BLK
								; WAS DKBLU on CYN
								; WAS LD A,$b6
    LD          HL,DAT_ram_3550
    CALL        SUB_ram_cc4d
    RET
SUB_ram_cc4d:
    POP         IX
    LD          DE,$27
    CALL        DRAW_SINGLE_PIXEL_DOWN
    INC         DE
    ADD         HL,DE
    POP         AF
    CALL        DRAW_CROSS_PATTERN_LEFT
    ADD         HL,DE
    DEC         HL
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    INC         HL
    CALL        DRAW_HORIZONTAL_LINE_3_LEFT
    ADD         HL,DE
    POP         AF
    INC         DE
    CALL        DRAW_SINGLE_PIXEL_DOWN
    JP          (IX)
SUB_ram_cc6d:
    CALL        DRAW_WALL_FR1
    LD          A,$f0								; DKGRY on BLK
								; WAS DKCYN on BLK
								; WAS LD A,$90
    PUSH        AF
    LD          A,$b0								; DKBLU on BLK
    PUSH        AF
    LD          A,0xb								; BLK on DKBLU
    JP          LAB_ram_cc85
SUB_ram_cc7a:
    CALL        DRAW_WALL_FR1
    LD          A,$fd								; DKGRY on DKGRN
								; WAS DKCYN on DKGRN
								; WAS LD A,$9d
    PUSH        AF
    LD          A,$2d								; GRN on DKGRN
    PUSH        AF
    LD          A,$db								; DKGRN on DKBLU
LAB_ram_cc85:
    LD          HL,DAT_ram_357a
    LD          BC,$207								; 2 x 7 rectangle
    CALL        SUB_ram_cd07
    LD          HL,DAT_ram_317a
    LD          A,$c0								; Right angle char
    LD          (HL),A
    LD          DE,$27
    ADD         HL,DE
    LD          (HL),A
    RET
SUB_ram_cc9a:
    LD          HL,DAT_ram_3578
    LD          BC,RECT(4,8)								; 4 x 8 rectangle
    LD          A,COLOR(BLU,DKBLU)								; BLU on DKBLU
    CALL        FILL_CHRCOL_RECT
    LD          HL,DAT_ram_3178
    LD          C,0x8
    LD          A,$20								; Change to SPACE 32 / $20
								; WAS d134 / $86 crosshatch char
								; WAS LD A, $86
    JP          DRAW_CHRCOLS
SUB_ram_ccaf:
    CALL        SUB_ram_cc9a
    XOR         A
    JP          LAB_ram_ccba
SUB_ram_ccb5:
    CALL        SUB_ram_cc9a
    LD          A,$dd								; DKGRN on DKGRN
LAB_ram_ccba:
    LD          HL,DAT_ram_35ca
    LD          BC,$206								; 2 x 6 rectangle
    JP          DRAW_CHRCOLS
SUB_ram_ccc3:
    LD          HL,DAT_ram_35ca
    LD          BC,RECT(2,4)								; 2 x 4 rectangle
    LD          A,COLOR(BLK,BLK)								; BLK on BLK
    CALL        FILL_CHRCOL_RECT
    LD          C,0x4
    LD          HL,DAT_ram_35c8
    LD          A,0xf								; BLK on DKGRY
								; WAS BLK on DKBLU
								; WAS LD A, 0xb
    JP          DRAW_CHRCOLS
DRAW_WALL_FR2_EMPTY:
    LD          HL,DAT_ram_35c8
    LD          BC,$404								; 4 x 4 rectangle
    LD          A,0x0								; BLK on BLK
    JP          FILL_CHRCOL_RECT
DRAW_WALL_FR2:
    LD          A,0xf								; FR2 Bottom
								; BLK on DKGRY
								; WAS DKCYN on DKBLU
								; WAS LD A,$9b
    PUSH        AF
    LD          A,0xf								; FR2 Wall
								; BLK on DKGRY
								; WAS BLK on DKBLU
								; WAS LD A,0xb
    PUSH        AF
    LD          A,$f0								; FR2 Top
								; DKGRY on BLK
								; WAS DKBLU on CYN
								; WAS LD A,$b6
    LD          HL,DAT_ram_3577
    LD          BC,$204								; 2 x 4 rectangle
    CALL        SUB_ram_cd07
    LD          HL,DAT_ram_3266
    LD          A,$da								; Left slash char
    LD          (HL),A
    ADD         HL,DE
    LD          (HL),A
    LD          HL,DAT_ram_3177
    LD          A,$c0								; Right angle char
    LD          (HL),A
    DEC         DE
    DEC         DE
    ADD         HL,DE
    LD          (HL),A
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
    LD          HL,DAT_ram_35c6
    LD          BC,$204								; 2 x 4 rectangle
    LD          A,0xf								; BLK on DKGRY
								; WAS BLK on DKBLU
								; WAS LD A,0xb
    JP          FILL_CHRCOL_RECT
SUB_ram_cd2c:
    LD          HL,DAT_ram_35c6
    LD          BC,$204								; 2 x 4 rectangle
    LD          A,0x0								; BLK on BLK
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
    JP          DOINK_SOUND
END_OF_GAME_SOUND:
    LD          A,0x4								; Was LD A,0x7
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
    LD          BC,0xe
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
    OR          L								; Clear flags
    JP          NZ,PLAY_PITCH_CHANGE_LOOP
    POP         AF
    OUT         (SPEAKER),A
    XOR         0x1
    PUSH        AF
    DEC         BC
    LD          A,B
    OR          C
    JP          NZ,INCREASE_PITCH
    POP         AF
    LD          HL,(SND_CYCLE_HOLDER)
    RET
INCREASE_PITCH:
    LD          HL,PITCH_UP_BOOL
    BIT         0x0,(HL)
    JP          Z,DECREASE_PITCH
    LD          HL,(SND_CYCLE_HOLDER)
    SBC         HL,DE
    JP          PLAY_PITCH_CHANGE
DECREASE_PITCH:
    LD          HL,(SND_CYCLE_HOLDER)
    ADD         HL,DE
    JP          PLAY_PITCH_CHANGE
HC_JOY_INPUT_COMPARE:
    LD          A,(RAM_AE)
    CP          $31								; Compare to "1" db?
    JP          NZ,WAIT_FOR_INPUT
    LD          HL,(HC_INPUT_HOLDER)
    LD          A,$f3								; Compare to JOY disc UUL
    CP          L
    JP          Z,DO_MOVE_FW_CHK_WALLS
    CP          H
    JP          Z,DO_MOVE_FW_CHK_WALLS
    LD          A,$fb								; Compare to JOY disc UP
    CP          L
    JP          Z,DO_MOVE_FW_CHK_WALLS
    CP          H
    JP          Z,DO_MOVE_FW_CHK_WALLS
    LD          A,$eb								; Compare to JOY disc UUR
    CP          H
    JP          Z,DO_MOVE_FW_CHK_WALLS
    CP          L
    JP          Z,DO_MOVE_FW_CHK_WALLS
    LD          A,$e9								; Compare to JOY disc UR
    CP          L
    JP          Z,DO_TURN_RIGHT
    CP          H
    JP          Z,DO_TURN_RIGHT
    LD          A,$f9								; Compare to JOY disc RUR
    CP          L
    JP          Z,DO_TURN_RIGHT
    CP          H
    JP          Z,DO_TURN_RIGHT
    LD          A,$fd								; Compare to JOY disc RIGHT
    CP          L
    JP          Z,DO_TURN_RIGHT
    CP          H
    JP          Z,DO_TURN_RIGHT
    LD          A,$e7								; Compare to JOY disc LUL
    CP          L
    JP          Z,DO_TURN_LEFT
    CP          H
    JP          Z,DO_TURN_LEFT
    LD          A,$e3								; Compare to JOY disc UL
    CP          L
    JP          Z,DO_TURN_LEFT
    CP          H
    JP          Z,DO_TURN_LEFT
    LD          A,$f7								; Compare to JOY disc LEFT
    CP          L
    JP          Z,DO_TURN_LEFT
    CP          H
    JP          Z,DO_TURN_LEFT
    LD          A,$f6								; Compare to JOY disc LDL
    CP          L
    JP          Z,DO_GLANCE_LEFT
    CP          H
    JP          Z,DO_GLANCE_LEFT
    LD          A,$e6								; Compare to JOY disc DL
    CP          L
    JP          Z,DO_GLANCE_LEFT
    CP          H
    JP          Z,DO_GLANCE_LEFT
    LD          A,$ed								; Compare to JOY disc RDR
    CP          L
    JP          Z,DO_GLANCE_RIGHT
    CP          H
    JP          Z,DO_GLANCE_RIGHT
    LD          A,$ec								; Compare to JOY disc DR
    CP          L
    JP          Z,DO_GLANCE_RIGHT
    CP          H
    JP          Z,DO_GLANCE_RIGHT
    LD          A,$fc								; Compare to JOY disc DDR
    CP          L
    JP          Z,DO_JUMP_BACK
    CP          H
    JP          Z,DO_JUMP_BACK
    LD          A,$fe								; Compare to JOY disc DOWN
    CP          L
    JP          Z,DO_JUMP_BACK
    CP          H
    JP          Z,DO_JUMP_BACK
    LD          A,$ee								; Compare to JOY disc DDL
    CP          L
    JP          Z,DO_JUMP_BACK
    CP          H
    JP          Z,DO_JUMP_BACK
    LD          A,$df								; Compare to JOY K4
    CP          L
    JP          Z,TOGGLE_SHIFT_MODE
    CP          H
    JP          Z,TOGGLE_SHIFT_MODE
    LD          A,(GAME_BOOLEANS)
    BIT         0x1,A
    JP          NZ,DO_HC_SHIFT_ACTIONS
DO_HC_BUTTON_ACTIONS:
    LD          A,$bf								; Compare to JOY K1
    CP          L
    JP          Z,DO_USE_ATTACK
    CP          H
    JP          Z,DO_USE_ATTACK
    LD          A,$7b								; Compare to JOY K2
    CP          L
    JP          Z,DO_OPEN_CLOSE
    CP          H
    JP          Z,DO_OPEN_CLOSE
    LD          A,$5f								; Compare to JOY K3
    CP          L
    JP          Z,DO_PICK_UP
    CP          H
    JP          Z,DO_PICK_UP
    LD          A,$7d								; Compare to JOY K5
    CP          L
    JP          Z,DO_SWAP_PACK
    CP          H
    JP          Z,DO_SWAP_PACK
    LD          A,$7e								; Compare to JOY K6
    CP          L
    JP          Z,DO_ROTATE_PACK
    CP          H
    JP          Z,DO_ROTATE_PACK
    JP          NO_ACTION_TAKEN
DO_HC_SHIFT_ACTIONS:
    LD          A,$bf								; Compare to JOY K1
    CP          L
    JP          Z,DO_USE_LADDER
    CP          H
    JP          Z,DO_USE_LADDER
    LD          A,$7b								; Compare to JOY K2
    CP          L
    JP          Z,DO_COUNT_FOOD
    CP          H
    JP          Z,DO_COUNT_FOOD
    LD          A,$5f								; Compare to JOY K3
    CP          L
    JP          Z,DO_COUNT_ARROWS
    CP          H
    JP          Z,DO_COUNT_ARROWS
    LD          A,$7d								; Compare to JOY K5
    CP          L
    JP          Z,DO_SWAP_HANDS
    CP          H
    JP          Z,DO_SWAP_HANDS
    LD          A,$7e								; Compare to JOY K6
    CP          L
    JP          Z,DO_REST
    CP          H
    JP          Z,DO_REST
    LD          A,$cc								; Compare to K4 + DR chord
    CP          L
    JP          Z,MAX_HEALTH_ARROWS_FOOD
    CP          H
    JP          Z,MAX_HEALTH_ARROWS_FOOD
    LD          A,$c6								; Compare to K4 + DL chord
    CP          L
    JP          Z,DO_TELEPORT
    CP          H
    JP          Z,DO_TELEPORT
    JP          NO_ACTION_TAKEN
DRAW_BKGD:
    LD          A,$20								;  Set VIEWPORT fill chars to SPACE
    LD          HL,IDX_VIEWPORT_CHRRAM								;  Set CHRRAM starting point at the beginning of the VIEWPORT
    LD          BC,RECT(24,24)								;  24 x 24 cells
    CALL        FILL_CHRCOL_RECT
    LD          C,0x8								;  8 rows of ceiling
    LD          HL,COLRAM_VIEWPORT_IDX								;  Set COLRAM starting point at the beginning of the VIEWPORT
    LD          A,$f0								;  DKGRY on BLK
    CALL        DRAW_CHRCOLS
    LD          C,0x6								;  6 more rows of ceiling
    ADD         HL,DE
    LD          A,0x0								;  BLK on BLK
    CALL        DRAW_CHRCOLS
    LD          C,0xa								;  10 rows of floor
    ADD         HL,DE
    LD          A,$df								;  DKGRN on DKGRY
    CALL        DRAW_CHRCOLS
    LD          A,(CURR_MONSTER_PHYS)
    CP          0x0
    JP          Z,NOT_IN_BATTLE
    LD          A,(CURR_MONSTER_SPRT)
    CP          0x0
    JP          Z,NOT_IN_BATTLE
    CALL        REDRAW_MONSTER_HEALTH
    RET
NOT_IN_BATTLE:
    RET
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
    JP          UPDATE_ITEM_CELLS
    JP          DRAW_PURPLE_MAP
PLAY_POOF_ANIM:
    PUSH        HL								; Save HL register value
    LD          DE,POOF_1								; DE = Start of POOF animation graphic
    LD          B,$70								; Set color to WHT on BLK
    EXX								; Swap BC DE HL with BC' DE' HL'
    CALL        POOF_SOUND
    EXX								; Swap BC DE HL with BC' DE' HL'
    CALL        GFX_DRAW
    POP         HL								; Restore DE register value
    CALL        TOGGLE_ITEM_POOF_AND_WAIT
    PUSH        HL
    CALL        GFX_DRAW
    POP         HL
    PUSH        DE
    LD          DE,$29
    SBC         HL,DE
    POP         DE								; = $D7,$C9,$01
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
    LD          BC,DAT_ram_3200
    CALL        SLEEP								; byte SLEEP(short cycleCount)
    EXX
    RET
MONSTER_KILLED:
    LD          HL,CHRRAM_MONSTER_POOF_IDX
    CALL        PLAY_POOF_ANIM
    LD          A,(PLAYER_MAP_POS)								; A  = Player position in map
    LD          HL,(DIR_FACING_FW)								; HL = FW adjustment value
    ADD         A,H								; A  = Player position in map
								; one step forward
    CALL        ITEM_MAP_CHECK								; Upon return,
								; A  = itemNum one step forward
								; BC = itemMapRAMLocation
    CP          $9f								; Check to see if it is
								; the Minotaur ($9f)
    JP          Z,MINOTAUR_DEAD
    LD          A,$fe								; A  = $fe (empty item space)
    LD          (BC),A								; itemMapLocRAM = $fe (empty)
    CALL        CLEAR_MONSTER_STATS
    POP         HL
    JP          UPDATE_VIEWPORT
TOGGLE_SHIFT_MODE:
    LD          A,(GAME_BOOLEANS)
    BIT         0x1,A								; NZ if SHIFT MODE
    JP          NZ,RESET_SHIFT_MODE
SET_SHIFT_MODE:
    SET         0x1,A								; Set SHIFT MODE boolean
    LD          (GAME_BOOLEANS),A
    LD          A,$d0								; DKGRN on BLK
    LD          (COLRAM_SHIFT_MODE_IDX),A
    JP          INPUT_DEBOUNCE
RESET_SHIFT_MODE:
    LD          A,(GAME_BOOLEANS)								; Reset SHIFT MODE boolean
    RES         0x1,A
    LD          (GAME_BOOLEANS),A
    LD          A,$f0
    LD          (COLRAM_SHIFT_MODE_IDX),A
    JP          INPUT_DEBOUNCE
SHOW_AUTHOR:
    LD          HL,CHRRAM_AUTHORS_IDX
    LD          DE,AUTHORS								; = "   Originally programmed by Tom L...
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
    JP          Z,STILL_ON_TITLE
    JP          BLINK_EXIT_AF
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
    JP          NZ,BLINK_EXIT_BCAF
    LD          A,R
    LD          (NEXT_BLINK_CHECK),A
    PUSH        HL
    PUSH        DE
    CALL        DO_CLOSE_EYES
    LD          BC,$8000
    CALL        SLEEP								; byte SLEEP(short cycleCount)
    CALL        DO_OPEN_EYES
    JP          BLINK_EXIT_ALL
DO_OPEN_EYES:
    LD          DE,$32d6
    LD          HL,TS_EYES_OPEN_CHR								;  Pinned to TITLE_SCREEN (0xD800) + 726; WAS 0xdad6
    LD          BC,$44
    LDIR
    LD          DE,$36d6
    LD          HL,TS_EYES_OPTN_COL								;  Pinned to TITLE_SCREEN (0XD800) + 1750; WAS 0xded6
    LD          BC,$44
    LDIR
    RET
DO_CLOSE_EYES:
    LD          HL,$32d6
    LD          BC,$d1d0								;  Value, not an address 
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
    LD          BC,$f00f								;  Value, not an address
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
DRAW_ICON_BAR:
    PUSH        AF
    PUSH        HL
    LD          HL,CHRRAM_LEVEL_IND_L
    LD          (HL),$85								; Right side halftone CHR
    INC         HL
    INC         HL
    INC         HL
    LD          (HL),$95								; Left side halftone CHR
    INC         HL
    LD          (HL),0x8								; Up arrow CHR
    INC         HL
    INC         HL
    LD          (HL),$48								; Ladder (H) CHR
    INC         HL
    INC         HL
    LD          (HL),$d3								; Item CHR
    INC         HL
    INC         HL
    LD          (HL),$93								; Monster CHR
    INC         HL
    INC         HL
    LD          (HL),$85								; Right side halftone CHR
    INC         HL
    INC         HL
    INC         HL
    INC         HL								; Map CHR
    LD          (HL),$d1
    INC         HL
    INC         HL								; Armor CHR
    LD          (HL),$9d
    INC         HL
    INC         HL								; Helmet CHR
    LD          (HL),0xe
    INC         HL
    INC         HL								; Ring (o) CHR
    LD          (HL),$6f
    POP         HL
    POP         AF
    RET
DRAW_COMPASS:
    PUSH        AF								; DKBLU on BLK
    PUSH        BC
    PUSH        HL
    PUSH        DE
    LD          B,$b0
    LD          HL,DAT_ram_31af
    LD          DE,COMPASS								; = $D7,"n",$C9,$01
    CALL        GFX_DRAW
    LD          HL,DAT_ram_35d8
    LD          (HL),$10
    POP         DE
    POP         HL
    POP         BC
    POP         AF
    RET
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
DRAW_WALL_FL22_EMPTY:
    LD          HL,COLRAM_FL22_WALL_IDX
    LD          BC,RECT(4,4)								; 4 x 4 rectangle
    LD          A,COLOR(BLK,BLK)								; BLK on BLK
    CALL        FILL_CHRCOL_RECT
    LD          HL,DAT_ram_3230
    LD          BC,RECT(4,1)								; 4 x 1 rectangle
    LD          A,$20								; SPACE char
    JP          FILL_CHRCOL_RECT
DRAW_WALL_FL2_NEW:
    LD          HL,$3234								; Bottom CHARRAM IDX of FL2
    LD          BC,RECT(4,1)								; 4 x 1 rectangle
    LD          A,$90								; Thin base line char
    CALL        FILL_CHRCOL_RECT
    LD          HL,$35bc
    LD          BC,RECT(2,4)								; 2 x 4 rectangle
    LD          A,COLOR(BLK,DKGRY)								; BLK on DKGRY
    CALL        FILL_CHRCOL_RECT
    LD          C,0x4
    LD          HL,$35be
    LD          A,0xf
    JP          DRAW_CHRCOLS
FIX_ICON_COLORS:
    LD          HL,COLRAM_LEVEL_IDX_L
    LD          A,(INPUT_HOLDER)
    ADD         A,A
    SUB         0x1
    LD          (HL),A
    INC         L
    LD          (HL),A
    INC         L
    LD          (HL),A
    INC         L
    LD          (HL),A
    LD          HL,COLRAM_SHIFT_MODE_IDX
    LD          BC,$1300
    DEC         HL
ICON_GREY_FILL_LOOP:
    INC         HL
    LD          (HL),$f0
    DJNZ        ICON_GREY_FILL_LOOP
    RET
