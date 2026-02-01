;==============================================================================
; DRAW_DOOR_BOTTOM_SETUP
;==============================================================================
; Prepares door bottom color and falls through to DRAW_SINGLE_CHAR_UP to draw
; door frame elements.
;
; Registers:
; --- Start ---
;   HL = screen position
;   A  = character
; --- In Process ---
;   DE = color value
; ---  End  ---
;   DE = COLOR(GRN,DKCYN)
;   Falls through to DRAW_SINGLE_CHAR_UP
;
; Memory Modified: (HL)
; Calls: Falls through to DRAW_SINGLE_CHAR_UP
;==============================================================================
DRAW_DOOR_BOTTOM_SETUP:
    LD          DE,COLOR(GRN,DKCYN)                 ; GRN on DKCYN (door bottom/frame color)
                                                    ; (bottom of closed door)

;==============================================================================
; DRAW_SINGLE_CHAR_UP
;==============================================================================
; Draws single character at current position and moves cursor up by DE amount.
;
; Registers:
; --- Start ---
;   HL = position
;   A  = character
;   DE = stride
; --- In Process ---
;   F  = carry cleared via SCF/CCF
; ---  End  ---
;   HL = HL - DE
;   A  = unchanged
;   DE = unchanged
;   F  = result of SBC
;
; Memory Modified: (HL) = A
; Calls: None
;==============================================================================
DRAW_SINGLE_CHAR_UP:
    LD          (HL),A                              ; Draw character at current position
    SCF                                             ; Set carry flag 
    CCF                                             ; Clear carry flag (prepare for SBC)
    SBC         HL,DE                               ; Move cursor up by DE amount
    
;==============================================================================
; DRAW_VERTICAL_LINE_3_UP
;==============================================================================
; Draws 3-character vertical line moving upward from starting position.
; Execution order: bottom (1) → middle (2) → top (3).
;
; Registers:
; --- Start ---
;   HL = starting position
;   A  = character
;   DE = row stride
; --- In Process ---
;   F  = carry cleared for SBC operations
; ---  End  ---
;   HL = HL - (DE * 2) final position
;   A  = unchanged
;   DE = unchanged
;   F  = result of final SBC
;
; Memory Modified: (HL), (HL-DE), (HL-DE*2)
; Calls: None
;==============================================================================
DRAW_VERTICAL_LINE_3_UP:
    LD          (HL),A                              ; Draw character at current position
    SCF                                             ; Set carry flag
    CCF                                             ; Clear carry flag (prepare for SBC)
    SBC         HL,DE                               ; Move cursor up one row
    LD          (HL),A                              ; Draw character at new position
    SBC         HL,DE                               ; Move cursor up another row
    LD          (HL),A                              ; Draw character at final position
    RET                                             ; Return with cursor 3 rows up

;==============================================================================
; DRAW_VERTICAL_LINE_4_DOWN
;==============================================================================
; Draws 4-character vertical line moving downward from starting position.
; Execution order: top (1) → (2) → (3) → bottom (4).
;
; Registers:
; --- Start ---
;   HL = starting position
;   A  = character
;   DE = row stride
; --- In Process ---
;   HL = incremented by DE each iteration
; ---  End  ---
;   HL = HL + (DE * 3) final position
;   A  = unchanged
;   DE = unchanged
;
; Memory Modified: (HL), (HL+DE), (HL+DE*2), (HL+DE*3)
; Calls: Falls through to CONTINUE_VERTICAL_LINE_DOWN
;==============================================================================
DRAW_VERTICAL_LINE_4_DOWN:
    LD          (HL),A                              ; Draw character at current position
    ADD         HL,DE                               ; Move cursor down one row

;==============================================================================
; CONTINUE_VERTICAL_LINE_DOWN
;==============================================================================
; Continues vertical line drawing for 3 more characters downward.
; Alternative entry point for drawing 3-character vertical line.
;
; Registers:
; --- Start ---
;   HL = position
;   A  = character
;   DE = stride
; ---  End  ---
;   HL = HL + (DE * 2)
;   A  = unchanged
;   DE = unchanged
;
; Memory Modified: (HL), (HL+DE), (HL+DE*2)
; Calls: None
;==============================================================================
CONTINUE_VERTICAL_LINE_DOWN:
    LD          (HL),A                              ; Draw character at new position
    ADD         HL,DE                               ; Move cursor down another row
    LD          (HL),A                              ; Draw character at next position
    ADD         HL,DE                               ; Move cursor down final row
    LD          (HL),A                              ; Draw character at final position
    RET                                             ; Return with cursor 3 rows down

;==============================================================================
; DRAW_DL_3X3_CORNER
;==============================================================================
; Draws bottom-left corner fill pattern (3x3 characters). Draws DOWNWARD using
; ADD HL,DE operations despite visual pattern name.
;
; Pattern (DE=$28/40 standard):  Execution order:
; X . .                          1 . .
; X X .                          2 3 .
; X X X                          6 5 4
;
; Registers:
; --- Start ---
;   HL = top-left position (0,0)
;   A  = fill value
;   DE = row stride
; --- In Process ---
;   HL = moved via ADD/INC/DEC operations
; ---  End  ---
;   HL = bottom-left position (0,2)
;   A  = unchanged
;   DE = unchanged
;
; Memory Modified: 6 positions forming DL corner pattern
; Calls: None
;==============================================================================
DRAW_DL_3X3_CORNER:
    LD          (HL),A                              ; 1: Draw top-left (0,0)
    ADD         HL,DE                               ; Move down one row  
    LD          (HL),A                              ; 2: Draw middle-left (0,1)
    INC         HL                                  ; Move right one position
    LD          (HL),A                              ; 3: Draw middle-center (1,1)
    ADD         HL,DE                               ; Move down another row
    INC         HL                                  ; Move right one more position  
    LD          (HL),A                              ; 4: Draw bottom-right (2,2)
    DEC         HL                                  ; Move back left
    LD          (HL),A                              ; 5: Draw bottom-center (1,2)
    DEC         HL                                  ; Move left again
    LD          (HL),A                              ; 6: Draw bottom-left (0,2)
    RET                                             ; Return with cursor positioned bottom-left

;==============================================================================
; DRAW_DR_3X3_CORNER
;==============================================================================
; Draws bottom-right corner fill pattern (3x3 characters). Draws DOWNWARD using
; ADD HL,DE operations. Supports variable stride for different pattern shifts.
;
; Pattern (DE=$28/40 standard):  Execution order:
; . . X                          . . 1
; . X X                          . 3 2
; X X X                          6 5 4
;
; Pattern (DE=$26/38 strong left-shift - RARELY USED):
; . . . . . . X . .              Creates strong left-shift
; . . . . 3 2 . . .              (may not appear in normal gameplay)
; 6 5 4 . . . . . .
;
; Registers:
; --- Start ---
;   HL = top-right position (2,0)
;   A  = fill value
;   DE = row stride
; --- In Process ---
;   HL = moved via ADD/INC/DEC operations
; ---  End  ---
;   HL = bottom-left position (0,2)
;   A  = unchanged
;   DE = unchanged
;
; Memory Modified: 6 positions forming DR corner pattern
; Calls: None
;==============================================================================
DRAW_DR_3X3_CORNER:
    LD          (HL),A                              ; 1: Draw top-right (2,0)
    ADD         HL,DE                               ; Move down one row
    LD          (HL),A                              ; 2: Draw middle-right (2,1)
    DEC         HL                                  ; Move left one position
    LD          (HL),A                              ; 3: Draw middle-center (1,1)
    ADD         HL,DE                               ; Move down another row
    INC         HL                                  ; Move right one position
    LD          (HL),A                              ; 4: Draw bottom-right (2,2)
    DEC         HL                                  ; Move back left
    LD          (HL),A                              ; 5: Draw bottom-center (1,2)
    DEC         HL                                  ; Move left again
    LD          (HL),A                              ; 6: Draw bottom-left (0,2)
    RET                                             ; Return with cursor positioned bottom-left

;==============================================================================
; DRAW_UL_3X3_CORNER
;==============================================================================
; Draws upper-left corner fill pattern (3x3 characters). Draws DOWNWARD despite
; creating "upper" corner visual pattern.
;
; Pattern (DE=$28/40):  Execution order:
; X X X                 1 2 3
; X X .                 5 4 .
; X . .                 6 . .
;
; Registers:
; --- Start ---
;   HL = top-left position (0,0)
;   A  = fill value
;   DE = row stride
; --- In Process ---
;   HL = moved via ADD/INC operations
; ---  End  ---
;   HL = bottom-left position (0,2)
;   A  = unchanged
;   DE = unchanged
;
; Memory Modified: 6 positions forming UL corner pattern
; Calls: None
;==============================================================================
DRAW_UL_3X3_CORNER:
    LD          (HL),A                              ; 1: Draw top-left (0,0)
    INC         HL                                  ; Move right one position
    LD          (HL),A                              ; 2: Draw top-center (1,0)
    INC         HL                                  ; Move right one position  
    LD          (HL),A                              ; 3: Draw top-right (2,0)
    ADD         HL,DE                               ; Move DOWN one row
    DEC         HL                                  ; Move back left one position
    LD          (HL),A                              ; 4: Draw middle-center (1,1)
    DEC         HL                                  ; Move left one position
    LD          (HL),A                              ; 5: Draw middle-left (0,1)
    ADD         HL,DE                               ; Move DOWN one row
    LD          (HL),A                              ; 6: Draw bottom-left (0,2)
    RET                                             ; Return with cursor at bottom-left

;==============================================================================
; DRAW_UR_3X3_CORNER
;==============================================================================
; Draws upper-right corner fill pattern (3x3 characters). Draws DOWNWARD despite
; creating "upper" corner visual pattern.
;
; Pattern (DE=$28/40):  Execution order:
; X X X                 1 2 3
; . X X                 . 4 5
; . . X                 . . 6
;
; Registers:
; --- Start ---
;   HL = top-left position (0,0)
;   A  = fill value
;   DE = row stride
; --- In Process ---
;   HL = moved via ADD/INC/DEC operations
; ---  End  ---
;   HL = bottom-right position (2,2)
;   A  = unchanged
;   DE = unchanged
;
; Memory Modified: 6 positions forming UR corner pattern
; Calls: None
;==============================================================================
DRAW_UR_3X3_CORNER:
    LD          (HL),A                              ; 1: Draw top-left (0,0)
    INC         HL                                  ; Move right one position
    LD          (HL),A                              ; 2: Draw top-center (1,0)
    INC         HL                                  ; Move right one position
    LD          (HL),A                              ; 3: Draw top-right (2,0)
    ADD         HL,DE                               ; Move DOWN one row
    DEC         HL                                  ; Move back left one position
    LD          (HL),A                              ; 4: Draw middle-center (1,1)
    INC         HL                                  ; Move right one position
    LD          (HL),A                              ; 5: Draw middle-right (2,1)
    ADD         HL,DE                               ; Move DOWN one row
    LD          (HL),A                              ; 6: Draw bottom-right (2,2)
    RET                                             ; Return with cursor at bottom-right

;==============================================================================
; DRAW_ROW
;==============================================================================
; Fills single horizontal row with specified byte value (character or color).
; Helper routine for FILL_CHRCOL_RECT. Recursive implementation.
;
; Pattern:                 Execution Order:
; X X X ... X              1 2 3 ... B
;
; Where X = fill value in A, drawn left-to-right until B reaches 0.
; Note: Actual width depends on B parameter. Example shows conceptual pattern.
;
; Registers:
; --- Start ---
;   HL = start position
;   B  = width
;   A  = fill value
; --- In Process ---
;   HL = incremented each iteration
;   B  = decremented each iteration
; ---  End  ---
;   HL = start + width
;   B  = 0
;   A  = unchanged
;
; Memory Modified: width bytes starting at HL
; Calls: Self (recursive)
;==============================================================================
DRAW_ROW:
    LD          (HL),A                              ; Write character/color to current position
    DEC         B                                   ; Decrement remaining width
    RET         Z                                   ; Return if row completed
    INC         HL                                  ; Move to next position in row
    JP          DRAW_ROW                            ; Continue filling row

;==============================================================================
; DRAW_COLUMN
;==============================================================================
; Fills single vertical column with specified byte value (character or color).
; Moves downward by row stride (DE, typically $28=40). Recursive implementation.
;
; Pattern:    Execution Order:
; X           1
; X           2
; X           3
; .           .
; .           .
; X           C
;
; Where X = fill value in A, drawn top-to-bottom until C reaches 0.
; Note: Actual height depends on C parameter. Example shows conceptual pattern.
;
; Registers:
; --- Start ---
;   HL = start position
;   C  = height
;   A  = fill value
;   DE = row stride
; --- In Process ---
;   HL = incremented by DE each iteration
;   C  = decremented each iteration
; ---  End  ---
;   HL = start + (height * DE)
;   C  = 0
;   A  = unchanged
;   DE = unchanged
;
; Memory Modified: height bytes at HL, HL+DE, HL+2*DE, ...
; Calls: Self (recursive)
;==============================================================================
DRAW_COLUMN:
    LD          (HL),A                              ; Write character/color to current position
    DEC         C                                   ; Decrement remaining height
    RET         Z                                   ; Return if column completed
    ADD         HL,DE								; Move to next row (+40 characters down)
    JP          DRAW_COLUMN                         ; Continue filling column vertically

;==============================================================================
; FILL_CHRCOL_RECT - Fill rectangular area with character or color data
;==============================================================================
; Fills a rectangular region of CHRRAM or COLRAM with a single byte value.
; Used for drawing walls, doors, backgrounds, and UI elements by writing
; the same character or color to multiple screen positions in a rectangle.
;
; Pattern:     _            Execution Order:
; X X X ... X  ^            1    2    3 ... B     (first row)
; X X X ... X  |            B+1         ... 2B    (second row)
; X X X ... X  C            2B+1        ... 3B    (third row)
; . . . ... .  |            ...
; X X X ... X  v            (C-1)B+1    ... C*B   (last row)
; |<-- B -->|  -
;
; Where X = fill value in A. Draws row-by-row, left-to-right, top-to-bottom.
; Note: Actual dimensions depend on B (width) and C (height) parameters.
;
; Registers:
; --- Start ---
;   HL = start address
;   BC = dimensions (B=width, C=height)
;   A  = fill value
; --- In Process ---
;   A  = preserved
;   DE = row stride ($28 / 40)
;   HL = current position
;   BC = counters
; ---  End  ---
;   HL = end position
;   BC = 0
;   A  = unchanged
;   DE = $28 / 40
;
; USES:    Stack for preserving HL/BC during row operations
; CALLS:   DRAW_ROW (internal subroutine)
; NOTES:   Screen is 40x25 characters. Rectangle must fit within memory bounds.
;          No bounds checking performed - caller responsible for valid coordinates.
;==============================================================================
FILL_CHRCOL_RECT:
    LD          DE,$28								; Set row stride to 40 characters (screen width)
DRAW_CHRCOLS:
    PUSH        HL                                  ; Save current row start position
    PUSH        BC                                  ; Save rectangle dimensions (B=width, C=height)
    CALL        DRAW_ROW                            ; Fill current row with character/color in A
    POP         BC                                  ; Restore rectangle dimensions
    POP         HL                                  ; Restore row start position
    DEC         C                                   ; Decrement remaining height
    RET         Z                                   ; Return if all rows completed
    ADD         HL,DE                               ; Move to start of next row (+40 characters)
    JP          DRAW_CHRCOLS                        ; Continue with next row

;==============================================================================
; DRAW_F0_WALL
;==============================================================================
; Draws far distance (F0) wall - large 16x15 solid blue rectangle with bottom
; accent row.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_F0_WALL_IDX, then bottom row position
;   BC = RECT(16,15), then width for bottom row
;   A  = COLOR(BLU,BLU)
; ---  End  ---
;   HL = end of bottom row
;   B  = 0
;   A  = unchanged
;   Jumps to DRAW_ROW
;
; Memory Modified: COLRAM at F0 wall area (16x15 + bottom row)
; Calls: FILL_CHRCOL_RECT, jumps to DRAW_ROW
;==============================================================================
DRAW_F0_WALL:
    LD          HL,COLRAM_F0_WALL_IDX               ; Point to far wall color area
    LD          BC,RECT(16,15)                      ; 16 x 16 rectangle
    LD          A,COLOR(BLU,BLU)                    ; BLU on BLU (solid blue wall)
    CALL        FILL_CHRCOL_RECT                    ; Fill wall area with blue color (WAS JP)
    LD          HL,COLRAM_F0_WALL_IDX + 2 + (40 * 15)
    LD          B,12
    JP          DRAW_ROW

;==============================================================================
; DRAW_F0_WALL_AND_CLOSED_DOOR
;==============================================================================
; Draws F0 wall with closed door overlay - wall background plus green door.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = COLOR(GRN,GRN) after wall drawn
; ---  End  ---
;   Falls through to DRAW_DOOR_F0
;
; Memory Modified: F0 wall and door areas
; Calls: DRAW_F0_WALL, falls through to DRAW_DOOR_F0
;==============================================================================
DRAW_F0_WALL_AND_CLOSED_DOOR:
    CALL        DRAW_F0_WALL                        ; Draw the wall background first
    LD          A,COLOR(GRN,GRN)                    ; GRN on GRN (closed door color)

;==============================================================================
; DRAW_DOOR_F0
;==============================================================================
; Draws F0 door overlay - fills 8x12 door area with color in A register.
; Used for both closed doors (green) and open doors (passage color).
;
; Registers:
; --- Start ---
;   A  = door color
; --- In Process ---
;   HL = COLRAM_F0_DOOR_IDX
;   BC = RECT(8,12)
; ---  End  ---
;   Jumps to FILL_CHRCOL_RECT
;
; Memory Modified: COLRAM at F0 door position (8x12 rectangle)
; Calls: Jumps to FILL_CHRCOL_RECT
;==============================================================================
DRAW_DOOR_F0:
    LD          HL,COLRAM_F0_DOOR_IDX               ; Point to door area within wall
    LD          BC,RECT(8,12)                       ; 8 x 12 rectangle (door size)
    JP          FILL_CHRCOL_RECT                    ; Fill door area with specified color

;==============================================================================
; DRAW_WALL_F0_AND_OPEN_DOOR
;==============================================================================
; Draws F0 wall with open door - wall background plus dark passage opening.
;
; --- Start ---
;   None specific
; --- In Process ---
;   A  = COLOR(DKGRY,BLK)
; ---  End  ---
;   Jumps to DRAW_DOOR_F0
;
; Memory Modified: F0 wall and door areas
; Calls: DRAW_F0_WALL, jumps to DRAW_DOOR_F0
;==============================================================================
DRAW_WALL_F0_AND_OPEN_DOOR:
    CALL        DRAW_F0_WALL                        ; Draw the wall background first
    LD          A,COLOR(DKGRY,BLK)                  ; DKGRY on BLK (open door/passage color)
    JP          DRAW_DOOR_F0                        ; Fill door area showing passage through

;==============================================================================
; DRAW_WALL_F1
;==============================================================================
; Draws mid-distance (F1) wall - 8x8 rectangle with space chars and blue colors.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = CHRRAM_F1_WALL_IDX, then COLRAM_F0_DOOR_IDX
;   BC = RECT(8,8)
;   A  = $20 (SPACE), then COLOR(BLU,DKBLU)
;   C  = 8 (height reset after FILL_CHRCOL_RECT)
; ---  End  ---
;   Jumps to DRAW_CHRCOLS
;
; Memory Modified: CHRRAM and COLRAM at F1 wall position (8x8)
; Calls: FILL_CHRCOL_RECT, jumps to DRAW_CHRCOLS
;==============================================================================
DRAW_WALL_F1:
    LD          HL,CHRRAM_F1_WALL_IDX               ; Point to F1 wall character area
    LD          BC,RECT(8,8)                        ; 8 x 8 rectangle (mid-distance wall size)
    LD          A,$20                               ; SPACE character (clear wall area)
    CALL        FILL_CHRCOL_RECT                    ; Clear wall character area with spaces
    LD          C,0x8                               ; Set height for color fill operation
    LD          HL,COLRAM_F0_DOOR_IDX               ; Point to corresponding color area
    LD          A,COLOR(BLU,DKBLU)                  ; BLU on DKBLU (wall color scheme)
    JP          DRAW_CHRCOLS                        ; Fill color area for wall

;==============================================================================
; DRAW_WALL_F1_AND_CLOSED_DOOR
;==============================================================================
; Draws F1 wall with closed door overlay - wall background plus green door.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = COLOR(GRN,DKGRN) after wall drawn
; ---  End  ---
;   Falls through to DRAW_DOOR_F1
;
; Memory Modified: F1 wall and door areas
; Calls: DRAW_WALL_F1, falls through to DRAW_DOOR_F1
;==============================================================================
DRAW_WALL_F1_AND_CLOSED_DOOR:
    CALL        DRAW_WALL_F1                        ; Draw the F1 wall background first
    LD          A,COLOR(GRN,DKGRN)                  ; GRN on DKGRN (closed door at F1 distance)

;==============================================================================
; DRAW_DOOR_F1
;==============================================================================
; Draws F1 door overlay - fills 4x6 door area with color in A register.
; Smaller door size for mid-distance view.
;
; Registers:
; --- Start ---
;   A  = door color
; --- In Process ---
;   HL = COLRAM_F1_DOOR_IDX
;   BC = RECT(4,6)
; ---  End  ---
;   Jumps to FILL_CHRCOL_RECT
;
; Memory Modified: COLRAM at F1 door position (4x6 rectangle)
; Calls: Jumps to FILL_CHRCOL_RECT
;==============================================================================
DRAW_DOOR_F1:
    LD          HL,COLRAM_F1_DOOR_IDX               ; Point to door area within F1 wall
    LD          BC,RECT(4,6)                        ; 4 x 6 rectangle (smaller door at mid-distance)
    JP          FILL_CHRCOL_RECT                    ; Fill door area with specified color

;==============================================================================
; DRAW_WALL_F1_AND_OPEN_DOOR
;==============================================================================
; Draws F1 wall with open door - wall background plus black passage opening.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = COLOR(BLK,BLK)
; ---  End  ---
;   Jumps to DRAW_DOOR_F1
;
; Memory Modified: F1 wall and door areas
; Calls: DRAW_WALL_F1, jumps to DRAW_DOOR_F1
;==============================================================================
DRAW_WALL_F1_AND_OPEN_DOOR:
    CALL        DRAW_WALL_F1                        ; Draw F1 wall background
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (open door/darkness)
    JP          DRAW_DOOR_F1                        ; Fill door area with black

;==============================================================================
; DRAW_WALL_F2
;==============================================================================
; Draws far distance (F2) wall - small 4x4 rectangle with thin base line.
; Very distant wall appearance.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_F2_WALL_IDX, then $323a (base line)
;   BC = RECT(4,4), then RECT(4,1)
;   A  = COLOR(BLK,DKGRY), then $90 (base line char)
; ---  End  ---
;   Jumps to FILL_CHRCOL_RECT
;
; Memory Modified: COLRAM at F2 wall + CHRRAM base line
; Calls: FILL_CHRCOL_RECT, jumps to FILL_CHRCOL_RECT
;==============================================================================
DRAW_WALL_F2:
    LD          BC,RECT(4,4)                        ; 4 x 4 rectangle
    LD          HL,COLRAM_F2_WALL_IDX               ; Point to F2 wall color area
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (far distance wall)
    CALL        FILL_CHRCOL_RECT                    ; Fill wall area (was JP)
    LD          HL,$323a                            ; Bottom-left CHRRAM IDX of F2
    LD          BC,RECT(4,1)                        ; 4 x 1 rectangle
    LD          A,$90                               ; Thin base line character
    JP          FILL_CHRCOL_RECT                    ; Draw base line

;==============================================================================
; DRAW_WALL_F2_EMPTY
;==============================================================================
; Draws empty F2 area - black 4x4 rectangle for empty/dark corridor.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_F2_WALL_IDX
;   A  = COLOR(BLK,BLK)
; ---  End  ---
;   Falls through to UPDATE_F0_ITEM
;
; Memory Modified: COLRAM at F2 position (4x4)
; Calls: Falls through to UPDATE_F0_ITEM
;==============================================================================
DRAW_WALL_F2_EMPTY:
    LD          HL,COLRAM_F2_WALL_IDX               ; Point to F2 wall color area
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (empty/dark)

;==============================================================================
; WIPE_ITEM_4X4
;==============================================================================
; Generic utility for filling 4x4 color rectangle. Reused by multiple routines
; for item/wall updates at F0 distance.
;
; Registers:
; --- Start ---
;   HL = position
;   A  = character/color
; --- In Process ---
;   BC = RECT(4,4)
; ---  End  ---
;   Jumps to FILL_CHRCOL_RECT
;
; Memory Modified: 4x4 color rectangle at HL
; Calls: Jumps to FILL_CHRCOL_RECT
;==============================================================================
WIPE_ITEM_4X4:
    LD          BC,RECT(4,4)                        ; 4 x 4 rectangle
    JP          FILL_CHRCOL_RECT                    ; Fill area with color in A

;==============================================================================
; DRAW_WALL_L0
;==============================================================================
; Draws left wall at closest distance (L0) - large 4x15 wall with top color
; transition, corner pattern, and left angle bracket characters.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = various positions (COLRAM_L0_WALL_IDX, CHRRAM_L0_WALL_IDX)
;   A  = various colors and CHAR_LT_ANGLE
;   DE = stride adjustments ($28, $29, $27)
;   BC = RECT(4,15)
; ---  End  ---
;   Jumps to DRAW_VERTICAL_LINE_4_DOWN
;   A  = CHAR_LT_ANGLE
;   DE = $29 (stride 41)
;   RET after jump (unreachable)
;
; Memory Modified: COLRAM and CHRRAM at L0 left wall positions
; Calls: DRAW_DOOR_BOTTOM_SETUP, DRAW_DL_3X3_CORNER, DRAW_CHRCOLS,
;        jumps to DRAW_VERTICAL_LINE_4_DOWN
;==============================================================================
DRAW_WALL_L0:
    LD          HL,COLRAM_L0_WALL_IDX               ; Point to L0 wall color area
    LD          A,COLOR(BLU,BLK)                    ; BLU on BLK (wall top color)
    CALL        DRAW_DOOR_BOTTOM_SETUP              ; Set door bottom color and draw
    DEC         DE                                  ; Decrease stride to 40
    ADD         HL,DE                               ; Move to next row
    LD          A,COLOR(BLK,BLU)                    ; BLK on BLU (wall body color)
    CALL        DRAW_DL_3X3_CORNER                  ; Draw corner pattern
    ADD         HL,DE                               ; Move to next row
    LD          BC,RECT(4,15)                       ; 4 x 15 rectangle (was 16)
    CALL        DRAW_CHRCOLS                        ; Fill wall columns
    DEC         DE                                  ; Decrease stride to 39
    LD          HL,CHRRAM_L0_WALL_IDX               ; Point to L0 character area
    LD          A,CHAR_LT_ANGLE                     ; Left angle bracket character
    INC         DE                                  ; Increase stride to 40
    INC         DE                                  ; Increase stride to 41
    JP          DRAW_VERTICAL_LINE_4_DOWN           ; Draw vertical line characters

;==============================================================================
; DRAW_DOOR_L0_HIDDEN
;==============================================================================
; Draws hidden door at L0 position - appears as wall but with subtle coloring.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = COLOR(DKGRY,BLK) saved to AF', then COLOR(BLK,BLU)
; ---  End  ---
;   Jumps to DRAW_DOOR_L0
;
; Memory Modified: L0 wall and door areas
; Calls: DRAW_WALL_L0, jumps to DRAW_DOOR_L0
;==============================================================================
DRAW_DOOR_L0_HIDDEN:
    CALL        DRAW_WALL_L0                        ; Draw L0 wall background
    LD          A,COLOR(DKGRY,BLK)                  ; DKGRY on BLK (hidden door)
    EX          AF,AF'                              ; Save door color to alternate
    LD          A,COLOR(BLK,BLU)                    ; BLK on BLU (wall color)
    JP          DRAW_DOOR_L0                        ; Draw door with saved color

;==============================================================================
; DRAW_DOOR_L0_NORMAL
;==============================================================================
; Draws normal visible door at L0 position - green door on blue wall.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = COLOR(DKGRY,GRN) saved to AF', then COLOR(GRN,BLU)
; ---  End  ---
;   Falls through to DRAW_DOOR_L0
;
; Memory Modified: L0 wall and door areas
; Calls: DRAW_WALL_L0, falls through to DRAW_DOOR_L0
;==============================================================================
DRAW_DOOR_L0_NORMAL:
    CALL        DRAW_WALL_L0                        ; Draw L0 wall background
    LD          A,COLOR(DKGRY,GRN)                  ; DKGRY on GRN (normal door)
    EX          AF,AF'                              ; Save door color to alternate
    LD          A,COLOR(GRN,BLU)                    ; GRN on BLU (door frame color)

;==============================================================================
; DRAW_DOOR_L0
;==============================================================================
; Draws L0 door overlay - 3x11 door with corner pattern, vertical color fill,
; and left angle bracket characters. Uses alternate AF register for door color.
;
; Registers:
; --- Start ---
;   A   = frame color
;   AF' = door body color
; --- In Process ---
;   HL = COLRAM_L0_DOOR_IDX, then CHRRAM_L0_DOOR_IDX
;   DE = stride adjustments ($28, $29)
;   BC = RECT(3,11)
;   A  = swapped via EX AF,AF', then CHAR_LT_ANGLE
; ---  End  ---
;   Jumps to CONTINUE_VERTICAL_LINE_DOWN
;   RET after jump (unreachable)
;
; Memory Modified: COLRAM and CHRRAM at L0 door positions
; Calls: DRAW_VERTICAL_LINE_3_UP, DRAW_DL_3X3_CORNER, DRAW_CHRCOLS,
;        jumps to CONTINUE_VERTICAL_LINE_DOWN
;==============================================================================
DRAW_DOOR_L0:
    LD          HL,COLRAM_L0_DOOR_IDX               ; Point to L0 door color area
    CALL        DRAW_VERTICAL_LINE_3_UP             ; Draw vertical line (stride 41)
    DEC         DE                                  ; Decrease stride to 40
    ADD         HL,DE                               ; Move to next row
    EX          AF,AF'                              ; Restore door color from alternate
    CALL        DRAW_DL_3X3_CORNER                  ; Draw door corner pattern
    ADD         HL,DE                               ; Move to next row
    LD          BC,RECT(3,11)                       ; 3 x 11 rectangle (was 12)
    CALL        DRAW_CHRCOLS                        ; Fill door columns
    DEC         DE                                  ; Decrease stride to 39
    LD          HL,CHRRAM_L0_DOOR_IDX               ; Point to L0 door character area
    LD          A,CHAR_LT_ANGLE                     ; Left angle bracket character
    INC         DE                                  ; Increase stride to 40
    INC         DE                                  ; Increase stride to 41
    JP          CONTINUE_VERTICAL_LINE_DOWN         ; Draw door characters

;==============================================================================
; DRAW_WALL_FL0
;==============================================================================
; Draws front-left wall at closest distance (FL0) - 4x15 blue wall section.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_FL0_WALL_RIGHT_IDX
;   BC = RECT(4,15)
;   A  = COLOR(BLK,BLU)
; ---  End  ---
;   Jumps to FILL_CHRCOL_RECT
;
; Memory Modified: COLRAM at FL0 position (4x15)
; Calls: Jumps to FILL_CHRCOL_RECT
;==============================================================================
DRAW_WALL_FL0:
    LD          HL,COLRAM_FL0_WALL_RIGHT_IDX        ; Point to FL0 wall color area
    LD          A,COLOR(BLK,BLU)                    ; BLK on BLU (wall color)
    LD          BC,RECT(4,15)                       ; 4 x 15 rectangle (was 16)
    JP          FILL_CHRCOL_RECT                    ; Fill wall area

;==============================================================================
; DRAW_WALL_FL1_A
;==============================================================================
; Draws left side of FL1 wall - 4x8 rectangle with space chars and
; blue/dark-blue colors.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = CHRRAM_WALL_FL1_A_IDX, then COLRAM_WALL_FL1_A_IDX
;   BC = RECT(4,8)
;   A  = $20 (SPACE), then COLOR(BLU,DKBLU)
;   C  = 8 (height reset)
; ---  End  ---
;   Jumps to DRAW_CHRCOLS
;
; Memory Modified: CHRRAM and COLRAM at L1 wall positions (4x8)
; Calls: FILL_CHRCOL_RECT, jumps to DRAW_CHRCOLS
;==============================================================================
DRAW_WALL_FL1_A:
    LD          HL,CHRRAM_WALL_FL1_A_IDX            ; Point to L1 character area
    LD          BC,RECT(4,8)                        ; 4 x 8 rectangle
    LD          A,$20                               ; SPACE character (32 / $20)
    CALL        FILL_CHRCOL_RECT                    ; Clear character area
    LD          HL,COLRAM_WALL_FL1_A_IDX            ; Point to L1 color area
    LD          C,0x8                               ; Set height to 8
    LD          A,COLOR(BLU,DKBLU)                  ; BLU on DKBLU (wall color)
    JP          DRAW_CHRCOLS                        ; Fill color columns

;==============================================================================
; DRAW_DOOR_L1_NORMAL
;==============================================================================
; Draws normal visible door at L1 position - dark green door overlay.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = COLOR(DKGRN,DKGRN)
; ---  End  ---
;   Falls through to DRAW_DOOR_L1
;
; Memory Modified: L1 wall and door areas
; Calls: DRAW_WALL_FL1_A, falls through to DRAW_DOOR_L1
;==============================================================================
DRAW_DOOR_L1_NORMAL:
    CALL        DRAW_WALL_FL1_A                     ; Draw L1 wall background
    LD          A,COLOR(DKGRN,DKGRN)                ; DKGRN on DKGRN (normal door)

;==============================================================================
; DRAW_DOOR_L1
;==============================================================================
; Draws L1 door overlay - fills 2x6 door area with color in A register.
;
; Registers:
; --- Start ---
;   A  = door color
; --- In Process ---
;   HL = COLRAM_L1_DOOR_PATTERN_IDX
;   BC = RECT(2,6)
; ---  End  ---
;   Jumps to DRAW_CHRCOLS
;
; Memory Modified: COLRAM at L1 door position (2x6)
; Calls: Jumps to DRAW_CHRCOLS
;==============================================================================
DRAW_DOOR_L1:
    LD          HL,COLRAM_L1_DOOR_PATTERN_IDX       ; Point to L1 door pattern area
    LD          BC,RECT(2,6)                        ; 2 x 6 rectangle
    JP          DRAW_CHRCOLS                        ; Fill door area

;==============================================================================
; DRAW_DOOR_L1_HIDDEN
;==============================================================================
; Draws hidden door at L1 position - appears as wall with black overlay.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = 0 (BLK on BLK)
; ---  End  ---
;   Jumps to DRAW_DOOR_L1
;
; Memory Modified: L1 wall and door areas
; Calls: DRAW_WALL_FL1_A, jumps to DRAW_DOOR_L1
;==============================================================================
DRAW_DOOR_L1_HIDDEN:
    CALL        DRAW_WALL_FL1_A                     ; Draw L1 wall background
    XOR         A                                   ; A = 0 (BLK on BLK - hidden door)
    JP          DRAW_DOOR_L1                        ; Draw door with black color

;==============================================================================
; DRAW_WALL_L1_SIMPLE
;==============================================================================
; Draws L1 wall edge characters and colors with complex pattern of angle brackets
; and color gradients. Creates visible edges and door opening in middle.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = various CHRRAM and COLRAM addresses
;   A  = character codes and color values
;   DE = $28 (row stride)
;   BC = RECT(2,4) for middle section
; ---  End  ---
;   HL = COLRAM_L1_DOOR_PATTERN_IDX
;   C  = 4
;   A  = COLOR(BLK,BLK)
;   Falls through to DRAW_CHRCOLS
;
; Memory Modified: CHRRAM and COLRAM at L1 wall edges and door area
; Calls: DRAW_CHRCOLS (falls through)
;==============================================================================
DRAW_WALL_L1_SIMPLE:
    LD          HL,CHRRAM_L1_WALL_IDX               ; Point to L1 wall character area
    LD          A,CHAR_LT_ANGLE                     ; Left angle bracket character
    LD          (HL),A                              ; Draw left angle at top
    LD          DE,$28                              ; Set stride to 40
    ADD         HL,DE                               ; Move to next row
    INC         HL                                  ; Move to next cell
    LD          (HL),A                              ; Draw left angle again
    LD          HL,CHRRAM_L1_CORNER_TOP_IDX         ; Point to top wall characters
    LD          A,CHAR_RT_ANGLE                     ; Right angle bracket character
    LD          (HL),A                              ; Draw right angle at top
    ADD         HL,DE                               ; Move to next row
    DEC         HL                                  ; Move back one cell (stride 39)
    LD          (HL),A                              ; Draw right angle again
    LD          HL,COLRAM_WALL_FL1_A_IDX            ; Point to FL1 wall color area
    LD          A,COLOR(DKBLU,DKGRY)                ; DKBLU on DKGRY
    LD          (HL),A                              ; Set color at top-left
    ADD         HL,DE                               ; Move to next row
    INC         HL                                  ; Move to next cell
    LD          (HL),A                              ; Set color at next position
    DEC         HL                                  ; Move back one cell
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY
    LD          (HL),A                              ; Set color
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    ADD         HL,DE                               ; Move to next row
    CALL        DRAW_CHRCOLS                        ; Fill middle section
    ADD         HL,DE                               ; Move to next row
    LD          (HL),A                              ; Set color at bottom-left
    INC         HL                                  ; Move to next cell
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY
    LD          (HL),A                              ; Set color at bottom-right
    ADD         HL,DE                               ; Move to next row
    DEC         HL                                  ; Move back one cell
    LD          (HL),A                              ; Set final color
    LD          HL,COLRAM_L1_DOOR_PATTERN_IDX       ; Point to door pattern area
    LD          C,0x4                               ; Set height to 4
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (door opening)
    JP          DRAW_CHRCOLS                        ; Fill door area

;==============================================================================
; DRAW_WALL_L1
;==============================================================================
; Draws left wall at mid-distance (L1) - complex wall with character and color
; layers. Creates 4x8 wall section with corner patterns and edge characters.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = CHRRAM_L1_UR_WALL_IDX, then COLRAM_L1_UR_WALL_IDX
;   BC = RECT(4,8)
;   A  = CHAR_LT_ANGLE, $20, CHAR_RT_ANGLE, then colors
;   DE = stride adjustments ($28, $29, $27)
; ---  End  ---
;   Jumps to DRAW_VERTICAL_LINE_3_UP
;   RET after jump (unreachable)
;
; Memory Modified: CHRRAM and COLRAM at L1 wall positions
; Calls: DRAW_DOOR_BOTTOM_SETUP, DRAW_DL_3X3_CORNER, DRAW_CHRCOLS,
;        DRAW_UL_3X3_CORNER, DRAW_VERTICAL_LINE_3_UP (jump)
;==============================================================================
DRAW_WALL_L1:
    LD          HL,CHRRAM_L1_UR_WALL_IDX            ; Point to L1 upper-right character area
    LD          A,CHAR_LT_ANGLE                     ; Left angle bracket character
    CALL        DRAW_DOOR_BOTTOM_SETUP              ; Set door bottom color
    DEC         DE                                  ; Decrease stride to 40
    ADD         HL,DE                               ; Move to next row
    LD          A,$20                               ; SPACE character (32 / $20)
    CALL        DRAW_DL_3X3_CORNER                  ; Draw upper wall character blocks
    ADD         HL,DE                               ; Move to next row
    LD          BC,RECT(4,8)                        ; 4 x 8 rectangle
    CALL        DRAW_CHRCOLS                        ; Fill middle section
    ADD         HL,DE                               ; Move to next row
    CALL        DRAW_UL_3X3_CORNER                  ; Draw bottom wall character blocks
    INC         HL                                  ; Move to next cell
    LD          A,CHAR_RT_ANGLE                     ; Right angle bracket character
    DEC         DE                                  ; Decrease stride to 39
    CALL        DRAW_VERTICAL_LINE_3_UP             ; Draw bottom wall characters

    LD          HL,COLRAM_L1_UR_WALL_IDX            ; Point to L1 upper-right color area
    LD          A,COLOR(DKBLU,BLK)                  ; DKBLU on BLK (wall top color)
    CALL        DRAW_DOOR_BOTTOM_SETUP              ; Set door bottom color
    DEC         DE                                  ; Decrease stride to 40
    ADD         HL,DE                               ; Move to next row
    LD          A,COLOR(BLU,DKBLU)                  ; BLU on DKBLU (wall body color)
    CALL        DRAW_DL_3X3_CORNER                  ; Draw upper wall color blocks
    ADD         HL,DE                               ; Move to next row
    LD          BC,RECT(4,8)                        ; 4 x 8 rectangle
    CALL        DRAW_CHRCOLS                        ; Fill middle color section
    ADD         HL,DE                               ; Move to next row
    CALL        DRAW_UL_3X3_CORNER                  ; Draw bottom wall color blocks
    INC         HL                                  ; Move to next cell
    LD          A,COLOR(DKGRY,DKBLU)                ; DKGRY on DKBLU (wall edge color)
    DEC         DE                                  ; Decrease stride to 39
    JP          DRAW_VERTICAL_LINE_3_UP             ; Draw bottom wall colors

;==============================================================================
; DRAW_FL1_DOOR
;==============================================================================
; Draws front-left hidden door at L1 distance - wall background with door
; overlay using stacked colors for blending effect.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = COLOR(DKGRY,BLK), COLOR(DKBLU,BLK), COLOR(BLK,DKBLU)
;   Stack = door colors
; ---  End  ---
;   Jumps to DRAW_L1_DOOR
;
; Memory Modified: L1 wall and door areas
; Calls: DRAW_WALL_L1, jumps to DRAW_L1_DOOR
;==============================================================================
DRAW_FL1_DOOR:
    CALL        DRAW_WALL_L1                        ; Draw L1 wall background
    LD          A,COLOR(DKGRY,BLK)                  ; DKGRY on BLK (door edge color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(DKBLU,BLK)                  ; DKBLU on BLK (wall color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(BLK,DKBLU)                  ; BLK on DKBLU (door body color)
    JP          DRAW_L1_DOOR                        ; Draw door with stacked colors

;==============================================================================
; DRAW_L1
;==============================================================================
; Draws normal visible door at L1 distance - wall background with green door
; overlay using stacked colors.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = COLOR(DKGRY,DKGRN), COLOR(GRN,DKGRN), COLOR(DKGRN,DKBLU)
;   Stack = door colors
; ---  End  ---
;   Falls through to DRAW_L1_DOOR
;
; Memory Modified: L1 wall and door areas
; Calls: DRAW_WALL_L1, falls through to DRAW_L1_DOOR
;==============================================================================
DRAW_L1:
    CALL        DRAW_WALL_L1                        ; Draw L1 wall background
    LD          A,COLOR(DKGRY,DKGRN)                ; DKGRY on DKGRN (door edge color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(GRN,DKGRN)                  ; GRN on DKGRN (door frame color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(DKGRN,DKBLU)                ; DKGRN on DKBLU (door body color)

;==============================================================================
; DRAW_L1_DOOR
;==============================================================================
; Draws L1 door overlay - 2x7 door with diagonal fill pattern and left angle
; bracket characters. Uses stack-based color system.
;
; Registers:
; --- Start ---
;   A  = first door color
;   Stack = additional colors from caller
; --- In Process ---
;   HL = COLRAM_L1_DOOR_IDX, then CHRRAM_L1_DOOR_IDX
;   BC = RECT(2,7)
;   DE = $29 (stride 41)
; ---  End  ---
;   Returns to caller
;
; Memory Modified: COLRAM and CHRRAM at L1 door positions
; Calls: DRAW_LEFT_DOOR
;==============================================================================
DRAW_L1_DOOR:
    LD          HL,COLRAM_L1_DOOR_IDX               ; Point to L1 door color area
    LD          BC,RECT(2,7)                        ; 2 x 7 rectangle
    CALL        DRAW_LEFT_DOOR                      ; Draw lefthand door
    LD          HL,CHRRAM_L1_DOOR_IDX               ; Point to L1 door character area
    LD          A,CHAR_LT_ANGLE                     ; Left angle bracket character
    LD          (HL),A                              ; Draw left angle at top
    LD          DE,$29                              ; Set stride to 41
    ADD         HL,DE                               ; Move to next row
    LD          (HL),A                              ; Draw left angle again
    RET                                             ; Return to caller

;==============================================================================
; DRAW_WALL_FL1_B
;==============================================================================
; Draws front-left wall variant B at mid-distance (FL1_B) - 4x8 with colors
; then space chars.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_WALL_FL1_B_IDX, then CHRRAM_WALL_FL1_B_IDX
;   BC = RECT(4,8)
;   A  = COLOR(BLU,DKBLU), then $20 (SPACE)
;   C  = 8 (height reset)
; ---  End  ---
;   Jumps to DRAW_CHRCOLS
;
; Memory Modified: COLRAM and CHRRAM at FL1_B positions (4x8)
; Calls: FILL_CHRCOL_RECT, jumps to DRAW_CHRCOLS
;==============================================================================
DRAW_WALL_FL1_B:
    LD          HL,COLRAM_WALL_FL1_B_IDX            ; Point to FL1_B wall color area
    LD          BC,RECT(4,8)                        ; 4 x 8 rectangle
    LD          A,COLOR(BLU,DKBLU)                  ; BLU on DKBLU (wall color)
    CALL        FILL_CHRCOL_RECT                    ; Fill color area
    LD          HL,CHRRAM_WALL_FL1_B_IDX            ; Point to FL1_B character area
    LD          C,0x8                               ; Set height to 8
    LD          A,$20                               ; SPACE character (32 / $20)
    JP          DRAW_CHRCOLS                        ; Fill character area

;==============================================================================
; DRAW_DOOR_FL1_B_HIDDEN
;==============================================================================
; Draws hidden door at FL1_B position - appears as wall with black overlay.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = 0 (BLK on BLK)
; ---  End  ---
;   Jumps to DRAW_DOOR_FL1_B
;
; Memory Modified: FL1_B wall and door areas
; Calls: DRAW_WALL_FL1_B, jumps to DRAW_DOOR_FL1_B
;==============================================================================
DRAW_DOOR_FL1_B_HIDDEN:
    CALL        DRAW_WALL_FL1_B                     ; Draw FL1_B wall background
    XOR         A                                   ; A = 0 (BLK on BLK - hidden door)
    JP          DRAW_DOOR_FL1_B                     ; Draw door with black

;==============================================================================
; DRAW_DOOR_FL1_B_NORMAL
;==============================================================================
; Draws normal door at FL1_B position - dark green overlay.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = COLOR(DKGRN,DKGRN)
; ---  End  ---
;   Falls through to DRAW_DOOR_FL1_B
;
; Memory Modified: FL1_B wall and door areas
; Calls: DRAW_WALL_FL1_B, falls through to DRAW_DOOR_FL1_B
;==============================================================================
DRAW_DOOR_FL1_B_NORMAL:
    CALL        DRAW_WALL_FL1_B                     ; Draw FL1_B wall background
    LD          A,COLOR(DKGRN,DKGRN)                ; DKGRN on DKGRN (normal door)

;==============================================================================
; DRAW_DOOR_FL1_B
;==============================================================================
; Draws FL1_B door overlay - fills 2x6 door area at FL2 position.
;
; Registers:
; --- Start ---
;   A  = door color
; --- In Process ---
;   HL = COLRAM_FL2_A
;   BC = RECT(2,6)
; ---  End  ---
;   Jumps to DRAW_CHRCOLS
;
; Memory Modified: COLRAM at FL2 position (2x6)
; Calls: Jumps to DRAW_CHRCOLS
;==============================================================================
DRAW_DOOR_FL1_B:
    LD          HL,COLRAM_FL2_A              ; Point to FL2 wall area for door
    LD          BC,RECT(2,6)                        ; 2 x 6 rectangle
    JP          DRAW_CHRCOLS                        ; Fill door area

;==============================================================================
; DRAW_WALL_FL2_EMPTY
;==============================================================================
; Draws empty FL2 area - black 4x4 rectangle for empty/dark corridor.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_FL2_A
;   BC = RECT(4,4)
;   A  = COLOR(BLK,BLK)
; ---  End  ---
;   Jumps to FILL_CHRCOL_RECT
;
; Memory Modified: COLRAM at FL2 position (4x4)
; Calls: Jumps to FILL_CHRCOL_RECT
;==============================================================================
DRAW_WALL_FL2_EMPTY:
    LD          HL,COLRAM_FL2_A              ; Point to FL2 wall color area
    LD          BC,RECT(4,4)                        ; 4 x 4 rectangle
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (empty/dark)
    JP          FILL_CHRCOL_RECT                    ; Fill area with black

;==============================================================================
; DRAW_WALL_L2
;==============================================================================
; Draws left wall at far distance (L2) - uses diagonal pattern with stacked
; characters and colors. Complex multi-layer rendering.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = CHRRAM_F1_WALL_IDX, then COLRAM_F0_DOOR_IDX
;   BC = RECT(2,4)
;   A  = various characters and colors
;   Stack = right slash, space, two color values
; ---  End  ---
;   Returns to caller
;
; Memory Modified: CHRRAM and COLRAM at L2 positions via diagonal pattern
; Calls: DRAW_LEFT_DOOR (twice for chars and colors)
;==============================================================================
DRAW_WALL_L2:
    LD          A,$ca                               ; Right slash character
    PUSH        AF                                  ; Save to stack for later
    LD          A,$20                               ; SPACE character
    PUSH        AF                                  ; Save to stack for later
    LD          HL,CHRRAM_F1_WALL_IDX               ; Point to F1 character area
    LD          A,CHAR_LT_ANGLE                     ; Left angle bracket character
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    CALL        DRAW_LEFT_DOOR                      ; Draw lefthand door
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    PUSH        AF                                  ; Save to stack for later
    LD          HL,COLRAM_F0_DOOR_IDX               ; Point to F0 door color area
    LD          A,COLOR(DKGRY,BLK)                  ; DKGRY on BLK (wall edge color)
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    CALL        DRAW_LEFT_DOOR                      ; Draw lefthand door
    RET                                             ; Return to caller

;==============================================================================
; DRAW_LEFT_DOOR
;==============================================================================
; Stack-based diagonal fill pattern routine. Pops return address to IX, then
; draws diagonal pattern using 3 values from stack. Creates 2x4+ diagonal shape.
;
; Values: P=first (in register A), Q=second (stack), R=third (stack)
;
; Stack Usage (caller pushes in reverse order):
;   R (third value - bottom corners)
;   Q (second value - middle fill via DRAW_CHRCOLS)
;   Return address (moved to IX)
;
; Pattern (2-column width, variable height via BC):
; Row 0:   P .      (Step 1 at column 0)
; Row 1:   Q P      (Step 3 at col 0, Step 2 at col 1)
; Row 2:   Q Q  ┐
; Row 3:   Q Q  │
; Row 4:   Q Q  ├─ DRAW_CHRCOLS fills 2-wide x C-height with Q
; Row 5:   Q Q  │
; Row n:   Q Q  ┘   (last row of DRAW_CHRCOLS)
; Row n+1: . Q      (Step 5 at col 1)
; Row n+2: R Q R    (Step 4 at col 0, Step 6 at col 2)
;
; Note: Actual height depends on C parameter in BC. Example shows C=7.
;
; Registers:
; --- Start ---
;   HL = top-left position
;   A  = first value (P)
;   BC = dimensions
; --- In Process ---
;   IX = return address
;   DE = $29, then $28 (stride adjustments)
;   Stack popped for 2nd (Q) and 3rd (R) values
; ---  End  ---
;   Returns via JP (IX)
;
; Memory Modified: Diagonal pattern at and below HL
; Calls: DRAW_CHRCOLS
;==============================================================================
DRAW_LEFT_DOOR:
    POP         IX                                  ; Save return address to IX
    LD          (HL),A                              ; Draw character at position
    LD          DE,$29                              ; Diagonal DR step (stride 41)
    ADD         HL,DE                               ; Move diagonally down-right
    LD          (HL),A                              ; Draw character at position
    DEC         HL                                  ; Move left one cell
    DEC         DE                                  ; Decrease stride to 40
    POP         AF                                  ; Pop second character from stack
    LD          (HL),A                              ; Draw character at position
    ADD         HL,DE                               ; Move to next row
    CALL        DRAW_CHRCOLS                        ; Fill middle columns
    ADD         HL,DE                               ; Move to next row
    LD          (HL),A                              ; Draw character at position
    ADD         HL,DE                               ; Move to next row
    POP         AF                                  ; Pop third character from stack
    LD          (HL),A                              ; Draw character at position
    SCF                                             ; Set carry flag
    CCF                                             ; Clear carry flag
    SBC         HL,DE                               ; Move back up one row
    INC         HL                                  ; Move right one cell
    LD          (HL),A                              ; Draw character at position
    JP          (IX)                                ; Return to caller

;==============================================================================
; DRAW_WALL_F2_FL2_GAP
;==============================================================================
; Draws FL2_A wall section - 2x4 colored area with bottom edge line.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_F2_FL2_GAP, then $3238 (bottom edge)
;   BC = RECT(2,4), then RECT(2,1)
;   A  = COLOR(BLK,DKGRY), then CHAR_BOTTOM_LINE
; ---  End  ---
;   Jumps to FILL_CHRCOL_RECT
;
; Memory Modified: COLRAM at FL2_A + CHRRAM bottom edge
; Calls: FILL_CHRCOL_RECT, jumps to FILL_CHRCOL_RECT
;==============================================================================
DRAW_WALL_F2_FL2_GAP:
    LD          HL,COLRAM_F2_FL2_GAP                     ; Point to FL2_A wall color area
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    CALL        FILL_CHRCOL_RECT                    ; Fill color area
    LD          HL,$3238                            ; Point to bottom edge area
    LD          BC,RECT(2,1)                        ; 2 x 1 rectangle
    LD          A,CHAR_BOTTOM_LINE                  ; Bottom line character
    JP          FILL_CHRCOL_RECT                    ; Fill bottom edge

;==============================================================================
; DRAW_WALL_F2_FL2_GAP_EMPTY
;==============================================================================
; Draws empty FL2_A section - black 2x4 rectangle for empty corridor.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_F2_FL2_GAP
;   BC = RECT(2,4)
;   A  = COLOR(BLK,BLK)
; ---  End  ---
;   Jumps to FILL_CHRCOL_RECT
;
; Memory Modified: COLRAM at FL2_A position (2x4)
; Calls: Jumps to FILL_CHRCOL_RECT
;==============================================================================
DRAW_WALL_F2_FL2_GAP_EMPTY:
    LD          HL,COLRAM_F2_FL2_GAP                     ; Point to FL2_A wall color area
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (empty/dark)
    JP          FILL_CHRCOL_RECT                    ; Fill area with black

;==============================================================================
; DRAW_WALL_R0
;==============================================================================
; Draws right wall at closest distance (R0) - large 4x15 wall with corner
; pattern and right angle bracket characters. Right side complement of DRAW_WALL_L0.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_R0_WALL_IDX (colors), then CHRRAM_R0_CORNER_TOP_IDX (chars)
;   BC = RECT(4,15)
;   A  = various colors, then CHAR_RT_ANGLE, finally CHAR_LT_ANGLE
;   DE = stride $27 (39), then $28, $29
;   Stack = edge color, wall color
; ---  End  ---
;   A  = CHAR_LT_ANGLE ($c1)
;   DE = $29 (stride 41)
;   Returns to caller
;
; Memory Modified: COLRAM and CHRRAM at R0 right wall positions
; Calls: DRAW_R0_CORNERS, DRAW_VERTICAL_LINE_4_DOWN
;==============================================================================
DRAW_WALL_R0:
    LD          A,COLOR(DKGRY,BLU)                  ; DKGRY on BLU (wall edge color)
    PUSH        AF                                  ; Save to stack for later
    LD          BC,RECT(4,15)                       ; 4 x 15 rectangle (was 16)
    LD          A,COLOR(BLK,BLU)                    ; BLK on BLU (wall color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(BLU,BLK)                    ; BLU on BLK (background color)
    LD          HL,COLRAM_R0_WALL_IDX               ; Point to R0 wall area
    CALL        DRAW_R0_CORNERS                     ; Do corner fills
    LD          HL,CHRRAM_R0_CORNER_TOP_IDX         ; Top right corner of R0
    LD          A,CHAR_RT_ANGLE                     ; Right angle character
    LD          DE,$27                              ; Pitch to 39 / $27
    CALL        DRAW_VERTICAL_LINE_4_DOWN           ; Draw top of R0 wall

    INC         A                                   ; Increment A to CHAR_LT_ANGLE ($c1)
    INC         DE                                  ; Increment pitch to 40 / $28
    INC         DE                                  ; Increment pitch to 41 / $29
    RET                                             ; Return to caller

;==============================================================================
; DRAW_R0_DOOR_HIDDEN
;==============================================================================
; Draws hidden door at R0 position - appears as wall with subtle coloring.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = COLOR(DKGRY,BLK) saved to AF', then COLOR(BLK,BLU)
; ---  End  ---
;   Jumps to DRAW_R0_DOOR
;
; Memory Modified: R0 wall and door areas
; Calls: DRAW_WALL_R0, jumps to DRAW_R0_DOOR
;==============================================================================
DRAW_R0_DOOR_HIDDEN:
    CALL        DRAW_WALL_R0                        ; Draw R0 wall background
    LD          A,COLOR(DKGRY,BLK)                  ; DKGRY on BLK (hidden door edge)
    EX          AF,AF'                              ; Save to alternate AF
    LD          A,COLOR(BLK,BLU)                    ; BLK on BLU (hidden door body)
    JP          DRAW_R0_DOOR                        ; Draw door with hidden colors

;==============================================================================
; DRAW_R0_DOOR_NORMAL
;==============================================================================
; Draws normal visible door at R0 position - green door on blue wall.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = COLOR(DKGRY,GRN) saved to AF', then COLOR(GRN,BLU)
; ---  End  ---
;   Falls through to DRAW_R0_DOOR
;
; Memory Modified: R0 wall and door areas
; Calls: DRAW_WALL_R0, falls through to DRAW_R0_DOOR
;==============================================================================
DRAW_R0_DOOR_NORMAL:
    CALL        DRAW_WALL_R0                        ; Draw R0 wall background
    LD          A,COLOR(DKGRY,GRN)                  ; DKGRY on GRN (normal door edge)
    EX          AF,AF'                              ; Save to alternate AF
    LD          A,COLOR(GRN,BLU)                    ; GRN on BLU (normal door body)

;==============================================================================
; DRAW_R0_DOOR
;==============================================================================
; Draws R0 door overlay - 3x11 door with corner pattern, vertical color fill,
; and right angle bracket characters. Uses alternate AF for door color.
; Right side complement of DRAW_DOOR_L0.
;
; Registers:
; --- Start ---
;   A   = frame color
;   AF' = door body color
;   DE  = $29
; --- In Process ---
;   HL = COLRAM_R0_DOOR_TOP_LEFT_IDX (colors), then CHRRAM_L0_DOOR_ANGLE_IDX (chars)
;   DE = stride adjustments ($27, $28, $29)
;   BC = RECT(3,11)
;   A  = swapped via EX AF,AF', then CHAR_RT_ANGLE
; ---  End  ---
;   Jumps to CONTINUE_VERTICAL_LINE_DOWN
;
; Memory Modified: COLRAM and CHRRAM at R0 door positions
; Calls: DRAW_VERTICAL_LINE_3_UP, DRAW_DR_3X3_CORNER, DRAW_CHRCOLS,
;        jumps to CONTINUE_VERTICAL_LINE_DOWN
;==============================================================================
DRAW_R0_DOOR:
    LD          HL,COLRAM_R0_DOOR_TOP_LEFT_IDX      ; R0 door top left COLRAM IDX
    DEC         DE                                  ; Decrement pitch to 40
    DEC         DE                                  ; Decrement pitch to 39
    CALL        DRAW_VERTICAL_LINE_3_UP             ; Draw door edge
    INC         DE                                  ; Increment pitch to 40
    ADD         HL,DE                               ; Move down a row
    EX          AF,AF'                              ; Get correct door colors
    CALL        DRAW_DR_3X3_CORNER                  ; Draw top door blocks
    ADD         HL,DE                               ; Move down a row
    LD          BC,RECT(3,11)                       ; 3 x 11 rectangle (was 12)
    CALL        DRAW_CHRCOLS                        ; Fill door body

    LD          HL,CHRRAM_L0_DOOR_ANGLE_IDX         ; Point to door angle area
    LD          A,CHAR_RT_ANGLE                     ; Right angle character
    DEC         DE                                  ; Decrement pitch to 39
    JP          CONTINUE_VERTICAL_LINE_DOWN         ; Draw top of door angles

;==============================================================================
; DRAW_WALL_FR0
;==============================================================================
; Draws front-right wall at closest distance (FR0) - 4x15 blue wall section.
; Right side complement of DRAW_WALL_FL0.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_FR0_WALL_IDX
;   BC = RECT(4,15)
;   A  = COLOR(BLK,BLU)
; ---  End  ---
;   Jumps to FILL_CHRCOL_RECT
;
; Memory Modified: COLRAM at FR0 position (4x15)
; Calls: Jumps to FILL_CHRCOL_RECT
;==============================================================================
DRAW_WALL_FR0:
    LD          HL,COLRAM_FR0_WALL_IDX              ; Point to FR0 wall area
    LD          A,COLOR(BLK,BLU)                    ; BLK on BLU (wall color)
    LD          BC,RECT(4,15)                       ; 4 x 15 rectangle (was 16)
    JP          FILL_CHRCOL_RECT                    ; Fill wall area

;==============================================================================
; DRAW_WALL_FR1_B
;==============================================================================
; Draws front-right wall variant B at mid-distance (FR1_B) - 4x8 with space
; chars then colors. Right side complement of DRAW_WALL_FL1_B.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = CHRRAM_FR1_B_WALL_IDX (chars), then COLRAM_FR1_B_WALL_IDX (colors)
;   BC = RECT(4,8)
;   A  = $20 (SPACE), then COLOR(BLU,DKBLU)
;   C  = 8 (height reset)
; ---  End  ---
;   Jumps to DRAW_CHRCOLS
;
; Memory Modified: CHRRAM and COLRAM at FR1_B positions (4x8)
; Calls: FILL_CHRCOL_RECT, jumps to DRAW_CHRCOLS
;==============================================================================
DRAW_WALL_FR1_B:
    LD          HL,CHRRAM_FR1_B_WALL_IDX            ; Point to FR1_B character area
    LD          BC,RECT(4,8)                        ; 4 x 8 rectangle
    LD          A,$20                               ; SPACE character (32 / $20)
    CALL        FILL_CHRCOL_RECT                    ; Fill character area
    LD          HL,COLRAM_FR1_B_WALL_IDX            ; Point to FR1_B color area
    LD          C,0x8                               ; Set height to 8
    LD          A,COLOR(BLU,DKBLU)                  ; BLU on DKBLU (wall color)
    JP          DRAW_CHRCOLS                        ; Fill color area

;==============================================================================
; DRAW_DOOR_FR1_B_HIDDEN
;==============================================================================
; Draws hidden door at FR1_B position - appears as wall with black overlay.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = 0 (BLK on BLK)
; ---  End  ---
;   Jumps to DRAW_DOOR_FR1_B
;
; Memory Modified: FR1_B wall and door areas
; Calls: DRAW_WALL_FR1_B, jumps to DRAW_DOOR_FR1_B
;==============================================================================
DRAW_DOOR_FR1_B_HIDDEN:
    CALL        DRAW_WALL_FR1_B                     ; Draw FR1_B wall background
    XOR         A                                   ; A = 0 (BLK on BLK - hidden door)
    JP          DRAW_DOOR_FR1_B                     ; Draw door with black

;==============================================================================
; DRAW_DOOR_FR1_B_NORMAL
;==============================================================================
; Draws normal door at FR1_B position - dark green overlay.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = COLOR(DKGRN,DKGRN)
; ---  End  ---
;   Falls through to DRAW_DOOR_FR1_B
;
; Memory Modified: FR1_B wall and door areas
; Calls: DRAW_WALL_FR1_B, falls through to DRAW_DOOR_FR1_B
;==============================================================================
DRAW_DOOR_FR1_B_NORMAL:
    CALL        DRAW_WALL_FR1_B                     ; Draw FR1_B wall background
    LD          A,COLOR(DKGRN,DKGRN)                ; DKGRN on DKGRN (normal door)

;==============================================================================
; DRAW_DOOR_FR1_B
;==============================================================================
; Draws FR1_B door overlay - fills 2x6 door area at FR22 position.
;
; Registers:
; --- Start ---
;   A  = door color
; --- In Process ---
;   HL = COLRAM_FR22_WALL_IDX
;   BC = RECT(2,6)
; ---  End  ---
;   Jumps to DRAW_CHRCOLS
;
; Memory Modified: COLRAM at FR22 position (2x6)
; Calls: Jumps to DRAW_CHRCOLS
;==============================================================================
DRAW_DOOR_FR1_B:
    LD          HL,COLRAM_FR22_WALL_IDX             ; Point to FR22 wall area for door
    LD          BC,RECT(2,6)                        ; 2 x 6 rectangle
    JP          DRAW_CHRCOLS                        ; Fill door area

;==============================================================================
; DRAW_WALL_R1_SIMPLE
;==============================================================================
; Draws FR1 wall edge characters and colors with angle brackets and color
; gradients. Creates visible edges and door opening in middle. Right side
; complement of DRAW_WALL_L1_SIMPLE.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = various CHRRAM and COLRAM addresses
;   A  = character codes and color values
;   DE = $28 (row stride)
;   BC = RECT(2,4) for middle section
; ---  End  ---
;   HL = COLRAM_FR22_WALL_IDX
;   C  = 4
;   A  = COLOR(BLK,BLK)
;   Jumps to DRAW_CHRCOLS
;
; Memory Modified: CHRRAM and COLRAM at FR1 wall edges and door area
; Calls: DRAW_CHRCOLS, jumps to DRAW_CHRCOLS
;==============================================================================
DRAW_WALL_R1_SIMPLE:
    LD          HL,CHRRAM_R1_CORNER_TOP_IDX         ; Point to top-right character position
    LD          A,CHAR_RT_ANGLE						; Right angle bracket character
    LD          (HL),A                              ; Draw right angle at top-right
    LD          DE,$28                              ; Set stride to 40
    ADD         HL,DE                               ; Move down one row
    DEC         HL                                  ; Move left one cell (stride 39)
    LD          (HL),A                              ; Draw right angle again
    LD          HL,CHRRAM_L1_CORNER_MID_IDX         ; Point to top-left character position
    LD          A,CHAR_LT_ANGLE						; Left angle bracket character
    LD          (HL),A                              ; Draw left angle at top-left
    ADD         HL,DE                               ; Move down one row
    INC         HL                                  ; Move right one cell (stride 41)
    LD          (HL),A                              ; Draw left angle again
    LD          HL,COLRAM_FL1_A_CORNER_IDX          ; Point to top-right color position
    LD          A,COLOR(DKBLU,DKGRY)			    ; DKBLU on DKGRY
    LD          (HL),A                              ; Set color at top-right
    ADD         HL,DE                               ; Move down one row
    DEC         HL                                  ; Move left one cell
    LD          (HL),A                              ; Set color at next position
    INC         HL                                  ; Move right one cell
    LD          A,COLOR(BLK,DKGRY)			    	; BLK on DKGRY
    LD          (HL),A                              ; Set color
    LD          BC,RECT(2,4)					    ; 2 x 4 rectangle
    ADD         HL,DE                               ; Move to next row
    DEC         HL                                  ; Move left one cell
    CALL        DRAW_CHRCOLS                        ; Fill middle section
    ADD         HL,DE                               ; Move to next row
    INC         HL                                  ; Move right one cell
    LD          (HL),A                              ; Set color at bottom-right
    DEC         HL                                  ; Move left one cell
    LD          A,COLOR(BLK,DKGRY)					; BLK on DKGRY
    LD          (HL),A                              ; Set color at bottom-left
    ADD         HL,DE                               ; Move to next row
    INC         HL                                  ; Move right one cell
    LD          (HL),A                              ; Set final color
    LD          HL,COLRAM_FR22_WALL_IDX             ; Point to FR22 door area
    LD          C,0x4                               ; Set height to 4
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (door opening)
    JP          DRAW_CHRCOLS                        ; Fill door area

;==============================================================================
; DRAW_WALL_FR22_EMPTY
;==============================================================================
; Draws empty FR22 area - black 4x4 rectangle for empty/dark corridor.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_FR22_WALL_IDX
;   BC = RECT(4,4)
;   A  = COLOR(BLK,BLK)
; ---  End  ---
;   Jumps to FILL_CHRCOL_RECT
;
; Memory Modified: COLRAM at FR22 position (4x4)
; Calls: Jumps to FILL_CHRCOL_RECT
;==============================================================================
DRAW_WALL_FR22_EMPTY:
    LD          HL,COLRAM_FR22_WALL_IDX             ; Point to FR22 wall color area
    LD          BC,RECT(4,4)                        ; 4 x 4 rectangle
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (empty/dark)
    JP          FILL_CHRCOL_RECT                    ; Fill area with black

;==============================================================================
; DRAW_WALL_R1
;==============================================================================
; Draws right wall at mid-distance (R1) - uses stack-based corner pattern with
; characters and colors. Right side complement of DRAW_WALL_L1.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = CHRRAM_R1_WALL_IDX, then COLRAM_R1_WALL_IDX
;   BC = RECT(4,8)
;   A  = various characters and colors
;   C  = 8 (height)
;   Stack = left angle, space, edge color, wall color
; ---  End  ---
;   Returns to caller
;
; Memory Modified: CHRRAM and COLRAM at R1 wall positions
; Calls: DRAW_R1_CORNERS (twice for chars and colors)
;==============================================================================
DRAW_WALL_R1:
    LD          A,CHAR_LT_ANGLE                     ; Left angle character
    PUSH        AF                                  ; Save to stack for later
    LD          BC,RECT(4,8)                        ; 4 x 8 rectangle
    LD          A,$20                               ; SPACE character (32 / $20)
    PUSH        AF                                  ; Save to stack for later
    LD          A,CHAR_RT_ANGLE                     ; Right angle character
    LD          HL,CHRRAM_R1_WALL_IDX               ; Point to R1 wall character area
    CALL        DRAW_R1_CORNERS                     ; Draw characters
    LD          A,COLOR(DKGRY,DKBLU)                ; DKGRY on DKBLU (wall edge color)
    PUSH        AF                                  ; Save to stack for later
    LD          C,0x8                               ; Set height to 8
    LD          A,COLOR(BLU,DKBLU)                  ; BLU on DKBLU (wall color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(DKBLU,BLK)                  ; DKBLU on BLK (background color)
    LD          HL,COLRAM_R1_WALL_IDX               ; Point to R1 wall color area
    CALL        DRAW_R1_CORNERS                     ; Draw colors
    RET                                             ; Return to caller

;==============================================================================
; DRAW_R0_CORNERS
;==============================================================================
; Helper routine for drawing R0 wall corner patterns. Uses stack for colors
; and IX for return address. Draws top char, upper corner, middle fill.
;
; Stack Usage (caller pushes in reverse order):
;   [Top] Edge color (for top char)
;   Wall color (for middle fill)
;   [Bottom] Return address (moved to IX)
;
; Registers:
; --- Start ---
;   HL = position
;   A  = value
;   BC = dimensions
; --- In Process ---
;   IX = return address
;   DE = $27, $28, $29 (stride adjustments)
;   Stack popped for colors
; ---  End  ---
;   DE = $29
;   Returns via JP (IX)
;
; Memory Modified: Corner pattern at and below HL
; Calls: DRAW_SINGLE_CHAR_UP, DRAW_DR_3X3_CORNER, DRAW_CHRCOLS
;==============================================================================
DRAW_R0_CORNERS:
    POP         IX                                  ; Save RET address to IX
    LD          DE,$27                              ; Stride is 39 / $27
    CALL        DRAW_SINGLE_CHAR_UP                 ; Draw top character
    INC         DE                                  ; Stride is 40
    ADD         HL,DE                               ; Go to next row
    POP         AF                                  ; Pop color from stack
    CALL        DRAW_DR_3X3_CORNER                  ; Draw upper corner pattern
    ADD         HL,DE                               ; Go to next row
    DEC         HL                                  ; Decrease stride to 39
    CALL        DRAW_CHRCOLS                        ; Fill middle columns
    POP         AF                                  ; Pop next color from stack
    INC         DE                                  ; Increase stride to 41
    JP          (IX)                                ; Return to caller

;==============================================================================
; DRAW_R1_CORNERS
;==============================================================================
; Helper routine for drawing R1 wall corner patterns. Uses stack and IX.
; More complex than R0: draws top, upper corner, middle fill, lower corner,
; and bottom vertical line.
;
; Stack Usage (caller pushes in reverse order):
;   [Top] Value for bottom line
;   Second value (middle fill)
;   [Bottom] Return address (moved to IX)
;
; Registers:
; --- Start ---
;   HL = position
;   A  = value
;   BC = dimensions
; --- In Process ---
;   IX = return address
;   DE = $27, $28, $29 (stride adjustments)
;   Stack popped for values
; ---  End  ---
;   Returns via JP (IX)
;
; Memory Modified: R1 corner pattern at and below HL
; Calls: DRAW_SINGLE_CHAR_UP, DRAW_DR_3X3_CORNER, DRAW_CHRCOLS,
;        DRAW_UR_3X3_CORNER, DRAW_VERTICAL_LINE_3_UP
;==============================================================================
DRAW_R1_CORNERS:
    POP         IX                                  ; Save RET address to IX
    LD          DE,$27                              ; Stride is 39 / $27
    CALL        DRAW_SINGLE_CHAR_UP                 ; Draw top character
    INC         DE                                  ; Increase stride to 40
    ADD         HL,DE                               ; Go to next row
    POP         AF                                  ; Pop character from stack
    CALL        DRAW_DR_3X3_CORNER                  ; Draw upper wall blocks
    ADD         HL,DE                               ; Go to next row
    DEC         HL                                  ; Go back one cell
    CALL        DRAW_CHRCOLS                        ; Fill middle columns
    ADD         HL,DE                               ; Go to next row
    INC         HL                                  ; Go to next cell
    CALL        DRAW_UR_3X3_CORNER                  ; Draw lower corner pattern
    DEC         HL                                  ; Back one cell
    POP         AF                                  ; Pop next character from stack
    INC         DE                                  ; Stride is 41
    CALL        DRAW_VERTICAL_LINE_3_UP             ; Draw vertical line
    JP          (IX)                                ; Return to caller

;==============================================================================
; DRAW_DOOR_R1_HIDDEN
;==============================================================================
; Draws hidden door at R1 position - appears as wall with subtle coloring.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = various colors pushed to stack
;   Stack = edge, body, background colors
; ---  End  ---
;   Jumps to DRAW_DOOR_R1
;
; Memory Modified: R1 wall and door areas
; Calls: DRAW_WALL_R1, jumps to DRAW_DOOR_R1
;==============================================================================
DRAW_DOOR_R1_HIDDEN:
    CALL        DRAW_WALL_R1                        ; Draw R1 wall background
    LD          A,COLOR(DKGRY,BLK)                  ; DKGRY on BLK (hidden door edge)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(DKBLU,BLK)                  ; DKBLU on BLK (hidden door body)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(BLK,DKBLU)                  ; BLK on DKBLU (background)
    JP          DRAW_DOOR_R1                        ; Draw door with hidden colors

;==============================================================================
; DRAW_DOOR_R1_NORMAL
;==============================================================================
; Draws normal visible door at R1 position - green door overlay.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = various colors pushed to stack
;   Stack = edge, frame, body colors
; ---  End  ---
;   Falls through to DRAW_DOOR_R1
;
; Memory Modified: R1 wall and door areas
; Calls: DRAW_WALL_R1, falls through to DRAW_DOOR_R1
;==============================================================================
DRAW_DOOR_R1_NORMAL:
    CALL        DRAW_WALL_R1                        ; Draw R1 wall background
    LD          A,COLOR(DKGRY,DKGRN)                ; DKGRY on DKGRN (normal door edge)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(GRN,DKGRN)                  ; GRN on DKGRN (normal door frame)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(DKGRN,DKBLU)                ; DKGRN on DKBLU (door body)

;==============================================================================
; DRAW_DOOR_R1
;==============================================================================
; Draws R1 door overlay - 2x7 door with diagonal fill pattern using stacked
; colors, plus right angle bracket characters. Right side complement of DRAW_L1_DOOR.
;
; Registers:
; --- Start ---
;   A = first color
;   Stack = [2nd color][3rd color]
; --- In Process ---
;   HL = COLRAM_R1_DOOR_IDX (colors), then CHRRAM_R1_DOOR_ANGLE_IDX (chars)
;   BC = RECT(2,7)
;   DE = $27 (stride 39)
;   A  = CHAR_RT_ANGLE
; ---  End  ---
;   Returns to caller
;
; Memory Modified: COLRAM and CHRRAM at R1 door positions
; Calls: DRAW_RIGHT_DOOR
;==============================================================================
DRAW_DOOR_R1:
    LD          HL,COLRAM_R1_DOOR_IDX               ; Point to R1 door area
    LD          BC,RECT(2,7)                        ; 2 x 7 rectangle
    CALL        DRAW_RIGHT_DOOR                     ; Draw righthand door
    LD          HL,CHRRAM_R1_DOOR_ANGLE_IDX         ; Point to R1 door character area
    LD          A,CHAR_RT_ANGLE                     ; Right angle character
    LD          (HL),A                              ; Draw right angle at top
    LD          DE,$27                              ; Stride is 39 / $27
    ADD         HL,DE                               ; Move to next row
    LD          (HL),A                              ; Draw right angle again
    RET                                             ; Return to caller

;==============================================================================
; DRAW_WALL_FR1_A
;==============================================================================
; Draws front-right wall variant A at mid-distance (FR1_A) - 4x8 with colors
; then space chars.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_WALL_FR1_A_IDX, then CHRRAM_WALL_FR1_A_IDX
;   BC = RECT(4,8)
;   A  = COLOR(BLU,DKBLU), then $20 (SPACE)
;   C  = 8 (height reset)
; ---  End  ---
;   Jumps to DRAW_CHRCOLS
;
; Memory Modified: COLRAM and CHRRAM at FR1_A positions (4x8)
; Calls: FILL_CHRCOL_RECT, jumps to DRAW_CHRCOLS
;==============================================================================
DRAW_WALL_FR1_A:
    LD          HL,COLRAM_WALL_FR1_A_IDX            ; Point to FR1_A wall color area
    LD          BC,RECT(4,8)                        ; 4 x 8 rectangle
    LD          A,COLOR(BLU,DKBLU)                  ; BLU on DKBLU (wall color)
    CALL        FILL_CHRCOL_RECT                    ; Fill color area
    LD          HL,CHRRAM_WALL_FR1_A_IDX            ; Point to FR1_A character area
    LD          C,0x8                               ; Set height to 8
    LD          A,$20                               ; SPACE character (32 / $20)
    JP          DRAW_CHRCOLS                        ; Fill character area

;==============================================================================
; DRAW_DOOR_FR1_A_HIDDEN
;==============================================================================
; Draws hidden door at FR1_A position - appears as wall with black overlay.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = 0 (BLK on BLK)
; ---  End  ---
;   Jumps to DRAW_DOOR_FR1_A
;
; Memory Modified: FR1_A wall and door areas
; Calls: DRAW_WALL_FR1_A, jumps to DRAW_DOOR_FR1_A1_A
;==============================================================================
DRAW_DOOR_FR1_A_HIDDEN:
    CALL        DRAW_WALL_FR1_A                     ; Draw FR1_A wall background
    XOR         A                                   ; A = 0 (BLK on BLK - hidden)
    JP          DRAW_DOOR_FR1_A                     ; Jump to door drawing

;==============================================================================
; DRAW_DOOR_FR1_A_NORMAL
;==============================================================================
; Draws normal door at FR1_A position - dark green overlay.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = COLOR(DKGRN,DKGRN)
; ---  End  ---
;   Falls through to DRAW_DOOR_FR1_A
;
; Memory Modified: FR1_A wall and door areas
; Calls: DRAW_WALL_FR1_A, falls through to DRAW_DOOR_FR1_A1_A
;==============================================================================
DRAW_DOOR_FR1_A_NORMAL:
    CALL        DRAW_WALL_FR1_A                     ; Draw FR1_A wall background
    LD          A,COLOR(DKGRN,DKGRN)                ; DKGRN on DKGRN (normal door)

;==============================================================================
; DRAW_DOOR_FR1_A
;==============================================================================
; Draws FR1_A door overlay - fills 2x6 door area with color in A register.
;
; Registers:
; --- Start ---
;   A  = door color
; --- In Process ---
;   HL = COLRAM_FR1_A_IDX
;   BC = RECT(2,6)
; ---  End  ---
;   Jumps to DRAW_CHRCOLS
;
; Memory Modified: COLRAM at door position (2x6)
; Calls: Jumps to DRAW_CHRCOLS
;==============================================================================
DRAW_DOOR_FR1_A:
    LD          HL,COLRAM_FR1_A_IDX              ; Point to door area
    LD          BC,RECT(2,6)                        ; 2 x 6 rectangle
    JP          DRAW_CHRCOLS                        ; Fill door area

;==============================================================================
; DRAW_WALL_FR2
;==============================================================================
; Draws front-right wall at far distance (FR2) - left and right 2x4 sections
; with bottom edge line.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_FR2_B (right), then COLRAM_FR2_A (left), then bottom chars
;   BC = RECT(2,4), then RECT(4,1)
;   A  = COLOR(BLK,DKGRY), then CHAR_BOTTOM_LINE
;   C  = 4 (height reset)
; ---  End  ---
;   Jumps to DRAW_CHRCOLS
;
; Memory Modified: COLRAM at FR2 positions + CHRRAM bottom edge
; Calls: FILL_CHRCOL_RECT, DRAW_CHRCOLS, jumps to DRAW_CHRCOLS
;==============================================================================
DRAW_WALL_FR2:
    LD          HL,COLRAM_FR2_B            ; Point to FR2 right wall area
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    CALL        FILL_CHRCOL_RECT                    ; Fill right wall
    LD          C,0x4                               ; Set height to 4
    LD          HL,COLRAM_FR2_A             ; FR2 left wall area
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    CALL        DRAW_CHRCOLS                        ; Fill right wall (was JP)
    LD          HL,$31c8 + 120                      ; Bottom row of FR2 right, CHRRAM
    LD          BC,RECT(4,1)                        ; 4 x 1 rectangle
    LD          A,CHAR_BOTTOM_LINE                  ; Bottom line character
    JP          DRAW_CHRCOLS                        ; Fill bottom edge

;==============================================================================
; DRAW_WALL_FR2_EMPTY
;==============================================================================
; Draws empty FR2 right area - black 4x4 rectangle for empty/dark corridor.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_FR2_A
;   BC = RECT(4,4)
;   A  = COLOR(BLK,BLK)
; ---  End  ---
;   Jumps to FILL_CHRCOL_RECT
;
; Memory Modified: COLRAM at FR2 right position (4x4)
; Calls: Jumps to FILL_CHRCOL_RECT
;==============================================================================
DRAW_WALL_FR2_EMPTY:
    LD          HL,COLRAM_FR2_A             ; Point to FR2 left wall area
    LD          BC,RECT(4,4)                        ; 4 x 4 rectangle
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (empty/dark)
    JP          FILL_CHRCOL_RECT                    ; Fill area with black

;==============================================================================
; DRAW_WALL_R2
;==============================================================================
; Draws right wall at far distance (R2) - uses diagonal pattern with stacked
; colors and slash/angle characters. Right side complement of DRAW_WALL_L2.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_R2_WALL_IDX (colors), then character positions
;   BC = RECT(2,4)
;   A  = various colors, then $da (left slash), then CHAR_RT_ANGLE
;   DE = stride from DRAW_RIGHT_DOOR, then decremented
;   Stack = two wall colors
; ---  End  ---
;   Returns to caller
;
; Memory Modified: COLRAM and CHRRAM at R2 positions via diagonal pattern
; Calls: DRAW_RIGHT_DOOR
;==============================================================================
DRAW_WALL_R2:
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(DKGRY,BLK)                  ; DKGRY on BLK (edge color)
    LD          HL,COLRAM_R2_WALL_IDX               ; Point to R2 wall area
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    CALL        DRAW_RIGHT_DOOR                     ; Draw righthand door
    LD          HL,CHRRAM_R2_DOOR_ANGLE_IDX         ; Point to character area
    LD          A,$da                               ; Left slash character
    LD          (HL),A                              ; Draw left slash at position
    ADD         HL,DE                               ; Move to next row
    LD          (HL),A                              ; Draw left slash again
    LD          HL,CHRRAM_FR0_DOOR_ANGLE_IDX        ; Point to next character area
    LD          A,CHAR_RT_ANGLE                     ; Right angle character
    LD          (HL),A                              ; Draw right angle at position
    DEC         DE                                  ; Decrease stride
    DEC         DE                                  ; Decrease stride again
    ADD         HL,DE                               ; Move to next row
    LD          (HL),A                              ; Draw right angle again
    RET                                             ; Return to caller

;==============================================================================
; DRAW_RIGHT_DOOR
;==============================================================================
; Stack-based diagonal fill pattern for right-side angled walls/doors.
; Right side complement of DRAW_LEFT_DOOR - creates down-right diagonal using stride $27 (39).
;
; Values: P=first (in register A), Q=second (stack), R=third (stack)
;
; Stack Usage (caller pushes in reverse order):
;   R (third value - bottom corners)
;   Q (second value - middle fill via DRAW_CHRCOLS)
;   Return address (moved to IX)
;
; Pattern (2-column width, variable height via BC):
; Row 0:   . P      (Step 1 at column 1)
; Row 1:   P Q      (Step 2 at col 0, Step 3 at col 1)
; Row 2:   Q Q  ┐
; Row 3:   Q Q  │
; Row 4:   Q Q  ├─ DRAW_CHRCOLS fills 2-wide x C-height with Q
; Row 5:   Q Q  │
; Row n:   Q Q  ┘   (last row of DRAW_CHRCOLS)
; Row n+1: R Q      (Step 5 at col 0, Step 4 at col 1)
; Row n+2: R .      (Step 6 at col 0)
;
; Note: Actual height depends on C parameter in BC. Example shows C=7.
;
; Registers:
; --- Start ---
;   HL = top-right position (column 1)
;   A  = first value (P)
;   BC = dimensions
; --- In Process ---
;   IX = return address
;   DE = $27, then $28, then $29 (stride progression: 39→40→41)
;   Stack popped for 2nd (Q) and 3rd (R) values
; ---  End  ---
;   DE = $29 (final stride)
;   Returns via JP (IX)
;
; Memory Modified: Diagonal pattern at and below HL
; Calls: DRAW_CHRCOLS
;==============================================================================
DRAW_RIGHT_DOOR:
    POP         IX                                  ; Save return address to IX
    LD          (HL),A                              ; Draw color at position
    LD          DE,$27                              ; Stride is 39 / $27
    ADD         HL,DE                               ; Move to next row
    LD          (HL),A                              ; Draw color at position
    INC         HL                                  ; Move right one cell
    POP         AF                                  ; Pop second color from stack
    LD          (HL),A                              ; Draw color at position
    ADD         HL,DE                               ; Move to next row
    INC         DE                                  ; Increase stride to 40
    CALL        DRAW_CHRCOLS                        ; Fill middle columns
    INC         DE                                  ; Increase stride to 41
    ADD         HL,DE                               ; Move to next row
    LD          (HL),A                              ; Draw color at position
    DEC         HL                                  ; Move left one cell
    POP         AF                                  ; Pop third color from stack
    LD          (HL),A                              ; Draw color at position
    ADD         HL,DE                               ; Move to next row
    LD          (HL),A                              ; Draw color at position
    JP          (IX)                                ; Return to caller

;==============================================================================
; DRAW_WALL_F2_FR2_GAP
;==============================================================================
; Draws FR2 left solid wall section - 2x4 colored area with bottom edge line.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_F2_FR2_GAP, then bottom row chars
;   BC = RECT(2,4), then RECT(4,1)
;   A  = COLOR(BLK,DKGRY), then CHAR_BOTTOM_LINE
; ---  End  ---
;   Jumps to DRAW_CHRCOLS
;
; Memory Modified: COLRAM at FR2 left + CHRRAM bottom edge
; Calls: FILL_CHRCOL_RECT, jumps to DRAW_CHRCOLS
;==============================================================================
DRAW_WALL_F2_FR2_GAP:
    LD          HL,COLRAM_F2_FR2_GAP             ; Gap between F2 and FR2
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    CALL        FILL_CHRCOL_RECT                    ; Fill left wall (was JP)
    LD          HL,$31c6 + 120                      ; Bottom row of FR2_A, CHRRAM
    LD          BC,RECT(4,1)                        ; 4 x 1 rectangle
    LD          A,CHAR_BOTTOM_LINE                  ; Bottom line character
    JP          DRAW_CHRCOLS                        ; Fill bottom edge

;==============================================================================
; DRAW_WALL_F2_FR2_GAP_EMPTY
;==============================================================================
; Draws FR2 left open/empty section - black 2x4 rectangle for empty corridor.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_F2_FR2_GAP
;   BC = RECT(2,4)
;   A  = COLOR(BLK,BLK)
; ---  End  ---
;   Jumps to FILL_CHRCOL_RECT
;
; Memory Modified: COLRAM at FR2 left position (2x4)
; Calls: Jumps to FILL_CHRCOL_RECT
;==============================================================================
DRAW_WALL_F2_FR2_GAP_EMPTY:
    LD          HL,COLRAM_F2_FR2_GAP             ; Gap between F2 and FR2
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (empty/dark)
    JP          FILL_CHRCOL_RECT                    ; Fill with black

;==============================================================================
; PLAY_MONSTER_GROWL
;==============================================================================
; Plays monster growl sound effect. Loops SOUND_04+SOUND_05 10 times to create
; growl character, then jumps to PLAY_PITCH_DOWN_MED for pitch-down tail.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = 10 (sound repeat count and loop counter)
;   B  = 10 (loop counter, decremented to 0)
;   BC = pushed/popped each iteration
; ---  End  ---
;   B  = 0
;   Jumps to PLAY_PITCH_DOWN_MED
;
; Memory Modified: SOUND_REPEAT_COUNT
; Calls: SOUND_04, SOUND_05, jumps to PLAY_PITCH_DOWN_MED
;==============================================================================
PLAY_MONSTER_GROWL:
    LD          A,0xa                               ; Load sound repeat count
    LD          (SOUND_REPEAT_COUNT),A              ; Store repeat count
    LD          B,A                                 ; Set loop counter to 10
MONSTER_GROWL_LOOP:
    PUSH        BC                                  ; Save loop counter
    CALL        SOUND_04                            ; Play sound 4
    CALL        SOUND_05                            ; Play sound 5
    POP         BC                                  ; Restore loop counter
    DJNZ        MONSTER_GROWL_LOOP                  ; Repeat B times
    JP          PLAY_PITCH_DOWN_MED                 ; Jump to pitch-down routine

;==============================================================================
; POOF_SOUND
;==============================================================================
; Plays "poof" disappearance sound effect. Used when items/monsters disappear.
; Short single-iteration doink sound.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = 7 (sound repeat count)
;   B  = 1 (loop counter)
; ---  End  ---
;   Falls through to DOINK_SOUND
;
; Memory Modified: SOUND_REPEAT_COUNT
; Calls: DOINK_SOUND (fall-through)
;==============================================================================
POOF_SOUND:
    LD          A,0x7                               ; Load sound repeat count
    LD          (SOUND_REPEAT_COUNT),A              ; Store repeat count
    LD          B,0x1                               ; Set loop counter to 1
    JP          DOINK_SOUND                         ; Jump to doink sound routine

;==============================================================================
; END_OF_GAME_SOUND
;==============================================================================
; Plays end-of-game sound effect. Multi-iteration doink sound sequence.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = 4 (sound repeat count)
;   B  = 4 (loop counter)
; ---  End  ---
;   Falls through to DOINK_SOUND
;
; Memory Modified: SOUND_REPEAT_COUNT
; Calls: DOINK_SOUND (fall-through)
;==============================================================================
END_OF_GAME_SOUND:
    LD          A,0x4                               ; Load sound repeat count (was 0x7)
    LD          (SOUND_REPEAT_COUNT),A              ; Store repeat count
    LD          B,A                                 ; Set loop counter to 4

;==============================================================================
; DOINK_SOUND
;==============================================================================
; Plays "doink" sound effect with delay. Core sound routine used by POOF_SOUND
; and END_OF_GAME_SOUND. Loops B times playing SOUND_02, delay, then SOUND_03.
;
; Registers:
; --- Start ---
;   B  = loop counter
; --- In Process ---
;   BC = pushed/popped each iteration
; ---  End  ---
;   B  = 0
;
; Memory Modified: None directly (sound routines modify sound registers)
; Calls: SOUND_02, PLAY_PITCH_DOWN_QUICK, SOUND_03
;==============================================================================
DOINK_SOUND:
    PUSH        BC                                  ; Save loop counter
    CALL        SOUND_02                            ; Play sound 2
    CALL        PLAY_PITCH_DOWN_QUICK               ; Quick pitch-down delay
    CALL        SOUND_03                            ; Play sound 3
    POP         BC                                  ; Restore loop counter
    DJNZ        DOINK_SOUND                         ; Repeat B times
    RET                                             ; Return to caller

;==============================================================================
; PLAY_PITCH_DOWN_MED
;==============================================================================
; Sound delay/pitch routine with specific parameters. Sets up pitch change
; parameters and falls through to PLAY_PITCH_CHANGE.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = 0
;   BC = $40 (64 duration)
;   DE = $15 (21 pitch step)
;   HL = $400 (1024 cycle count)
; ---  End  ---
;   PITCH_UP_BOOL = 0 (pitch down)
;   Falls through to PLAY_PITCH_CHANGE
;
; Memory Modified: PITCH_UP_BOOL, stack
; Calls: PLAY_PITCH_CHANGE (fall-through)
;==============================================================================
PLAY_PITCH_DOWN_MED:
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          BC,$40                              ; Set BC to 64
    LD          DE,$15                              ; Set DE to 21
    LD          HL,$400                             ; Set HL to 1024
    LD          A,0x0                               ; Load value 0
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to down
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound

;==============================================================================
; PLAY_PITCH_DOWN_SLOW
;==============================================================================
; Sound delay/pitch routine with alternate parameters. Sets up different pitch
; change characteristics than PLAY_PITCH_DOWN_MED.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = 0
;   BC = $a0 (160 duration)
;   DE = $8 (8 pitch step)
;   HL = $800 (2048 cycle count)
; ---  End  ---
;   PITCH_UP_BOOL = 0 (pitch down)
;   Falls through to PLAY_PITCH_CHANGE
;
; Memory Modified: PITCH_UP_BOOL, stack
; Calls: PLAY_PITCH_CHANGE (fall-through)
;==============================================================================
PLAY_PITCH_DOWN_SLOW:
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          BC,$a0                              ; Set BC to 160
    LD          DE,0x8                              ; Set DE to 8
    LD          HL,$800                             ; Set HL to 2048
    LD          A,0x0                               ; Load value 0
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to down
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound

;==============================================================================
; PLAY_PITCH_DOWN_QUICK
;==============================================================================
; Short delay/pitch routine with minimal parameters. Used for brief sound delays.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = 0
;   BC = $a0 (160 duration)
;   DE = $1 (1 pitch step - minimal change)
;   HL = $2 (2 cycle count - very short)
; ---  End  ---
;   PITCH_UP_BOOL = 0 (pitch down)
;   Falls through to PLAY_PITCH_CHANGE
;
; Memory Modified: PITCH_UP_BOOL, stack
; Calls: PLAY_PITCH_CHANGE (fall-through)
;==============================================================================
PLAY_PITCH_DOWN_QUICK:
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          BC,$a0                              ; Set BC to 160
    LD          DE,0x1                              ; Set DE to 1
    LD          HL,0x2                              ; Set HL to 2
    LD          A,0x0                               ; Load value 0
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to down
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound

;==============================================================================
; SETUP_OPEN_DOOR_SOUND
;==============================================================================
; Sets up parameters for door opening sound - rising pitch effect.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   DE = $f (15 pitch step)
;   HL = $580 (1408 cycle count)
; ---  End  ---
;   Falls through to LO_HI_PITCH_SOUND
;
; Memory Modified: None directly
; Calls: LO_HI_PITCH_SOUND (fall-through)
;==============================================================================
SETUP_OPEN_DOOR_SOUND:
    LD          DE,0xf                              ; Set DE to 15
    LD          HL,$580                             ; Set HL to 1408

;==============================================================================
; LO_HI_PITCH_SOUND
;==============================================================================
; Plays rising pitch sound effect (low to high). Sets pitch direction to up
; and plays pitch change sound.
;
; Registers:
; --- Start ---
;   DE = pitch step
;   HL = cycle count
; --- In Process ---
;   BC = $8 (8 duration)
;   A  = 0, then 1
; ---  End  ---
;   PITCH_UP_BOOL = 1 (pitch up)
;   Jumps to PLAY_PITCH_CHANGE
;
; Memory Modified: PITCH_UP_BOOL, stack
; Calls: Jumps to PLAY_PITCH_CHANGE
;==============================================================================
LO_HI_PITCH_SOUND:
    LD          BC,0x8                              ; Set BC to 8
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          A,0x1                               ; Load value 1
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to up
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound

;==============================================================================
; SETUP_CLOSE_DOOR_SOUND
;==============================================================================
; Sets up parameters for door closing sound - falling pitch effect.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = $5 (5 cycle count)
;   DE = $c (12 pitch step)
; ---  End  ---
;   Falls through to HI_LO_PITCH_SOUND
;
; Memory Modified: None directly
; Calls: HI_LO_PITCH_SOUND (fall-through)
;==============================================================================
SETUP_CLOSE_DOOR_SOUND:
    LD          HL,0x5                              ; Set HL to 5
    LD          DE,0xc                              ; Set DE to 12

;==============================================================================
; HI_LO_PITCH_SOUND
;==============================================================================
; Plays falling pitch sound effect (high to low). Sets pitch direction to down
; and plays pitch change sound.
;
; Registers:
; --- Start ---
;   HL = cycle count
;   DE = pitch step
; --- In Process ---
;   BC = $e (14 duration)
;   A  = 0
; ---  End  ---
;   PITCH_UP_BOOL = 0 (pitch down)
;   Jumps to PLAY_PITCH_CHANGE
;
; Memory Modified: PITCH_UP_BOOL, stack
; Calls: Jumps to PLAY_PITCH_CHANGE
;==============================================================================
HI_LO_PITCH_SOUND:
    LD          BC,0xe                              ; Set BC to 14
    XOR         A                                   ; A = 0
    PUSH        AF                                  ; Save to stack
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to down
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound

;==============================================================================
; SOUND_02
;==============================================================================
; Sound effect 2 - quick rising pitch with higher step.
;
; Parameters: BC=$1a (26), DE=$10 (16), HL=$300 (768), pitch up
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = 0, then 1
;   BC = $1a (26 duration)
;   DE = $10 (16 pitch step)
;   HL = $300 (768 cycles)
; ---  End  ---
;   PITCH_UP_BOOL = 1 (pitch up)
;   Jumps to PLAY_PITCH_CHANGE
;
; Memory Modified: PITCH_UP_BOOL, stack
; Calls: Jumps to PLAY_PITCH_CHANGE
;==============================================================================
SOUND_02:
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          BC,$1a                              ; Set BC to 26
    LD          DE,$10                              ; Set DE to 16
    LD          HL,$300                             ; Set HL to 768
    LD          A,0x1                               ; Load value 1
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to up
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound

;==============================================================================
; SOUND_03
;==============================================================================
; Sound effect 3 - quick falling pitch, very short duration.
;
; Parameters: BC=$2a (42), DE=$a (10), HL=$4 (4), pitch down
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = 0
;   BC = $2a (42 duration)
;   DE = $a (10 pitch step)
;   HL = $4 (4 cycles - very short)
; ---  End  ---
;   PITCH_UP_BOOL = 0 (pitch down)
;   Jumps to PLAY_PITCH_CHANGE
;
; Memory Modified: PITCH_UP_BOOL, stack
; Calls: Jumps to PLAY_PITCH_CHANGE
;==============================================================================
SOUND_03:
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          BC,$2a                              ; Set BC to 42
    LD          DE,0xa                              ; Set DE to 10
    LD          HL,0x4                              ; Set HL to 4
    LD          A,0x0                               ; Load value 0
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to down
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound

;==============================================================================
; SOUND_04
;==============================================================================
; Sound effect 4 - short rising blip, low pitch.
;
; Parameters: BC=$20 (32), DE=$2 (2), HL=$55 (85), pitch up
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = 0, then 1
;   BC = $20 (32 duration)
;   DE = $2 (2 pitch step)
;   HL = $55 (85 cycles)
; ---  End  ---
;   PITCH_UP_BOOL = 1 (pitch up)
;   Jumps to PLAY_PITCH_CHANGE
;
; Memory Modified: PITCH_UP_BOOL, stack
; Calls: Jumps to PLAY_PITCH_CHANGE
;==============================================================================
SOUND_04:
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          BC,$20                              ; Set BC to 32
    LD          DE,0x2                              ; Set DE to 2
    LD          HL,$55                              ; Set HL to 85
    LD          A,0x1                               ; Load value 1
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to up
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound

;==============================================================================
; SOUND_05
;==============================================================================
; Sound effect 5 - minimal tick/click sound, very brief.
;
; Parameters: BC=$30 (48), DE=$1 (1), HL=$1 (1), pitch down
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = 0
;   BC = $30 (48 duration)
;   DE = $1 (1 pitch step - minimal)
;   HL = $1 (1 cycle - instant)
; ---  End  ---
;   PITCH_UP_BOOL = 0 (pitch down)
;   Jumps to PLAY_PITCH_CHANGE
;
; Memory Modified: PITCH_UP_BOOL, stack
; Calls: Jumps to PLAY_PITCH_CHANGE
;==============================================================================
SOUND_05:
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          BC,$30                              ; Set BC to 48
    LD          DE,0x1                              ; Set DE to 1
    LD          HL,0x1                              ; Set HL to 1
    LD          A,0x0                               ; Load value 0
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to down
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound

;==============================================================================
; PLAY_PITCH_CHANGE
;==============================================================================
; Core sound engine - plays tone with dynamic pitch change (rising or falling).
; Uses speaker toggle with variable cycle delays to produce pitch effects.
;
; Registers:
; --- Start ---
;   BC = duration counter
;   DE = pitch step
;   HL = initial cycles
;   Stack = [speaker state]
; --- In Process ---
;   HL = current cycle count (modified each iteration)
;   A  = temp for zero checks and speaker toggle
;   Stack = speaker state (toggled 0/1)
; ---  End  ---
;   BC = 0 (exhausted)
;   HL = original cycle count (restored from SND_CYCLE_HOLDER)
;   F  = set from final OR
;
; Memory Modified: SND_CYCLE_HOLDER, SPEAKER port
; Calls: INCREASE_PITCH or DECREASE_PITCH (internal jumps)
;==============================================================================
PLAY_PITCH_CHANGE:
    LD          (SND_CYCLE_HOLDER),HL               ; Store cycle count
PLAY_PITCH_CHANGE_LOOP:
    DEC         HL                                  ; Decrement cycle counter
    LD          A,H                                 ; Load H into A
    OR          L                                   ; OR with L to check if zero
    JP          NZ,PLAY_PITCH_CHANGE_LOOP           ; Loop if not zero
    POP         AF                                  ; Restore speaker state
    OUT         (SPEAKER),A                         ; Toggle speaker
    XOR         0x1                                 ; Flip bit 0
    PUSH        AF                                  ; Save new speaker state
    DEC         BC                                  ; Decrement duration counter
    LD          A,B                                 ; Load B into A
    OR          C                                   ; OR with C to check if zero
    JP          NZ,INCREASE_PITCH                   ; Continue if more cycles
    POP         AF                                  ; Clean up stack
    LD          HL,(SND_CYCLE_HOLDER)               ; Restore cycle count
    RET                                             ; Return to caller

;==============================================================================
; INCREASE_PITCH
;==============================================================================
; Increases pitch by decreasing cycle count (higher frequency). Only executes
; if PITCH_UP_BOOL is set.
;
; Registers:
; --- Start ---
;   DE = pitch step
; --- In Process ---
;   HL = PITCH_UP_BOOL address, then SND_CYCLE_HOLDER value
;   A  = bit test result (discarded)
;   F  = Z flag from BIT test
; ---  End  ---
;   HL = updated cycle count (decreased by DE)
;   F  = carry from SBC
;   Jumps to PLAY_PITCH_CHANGE or DECREASE_PITCH
;
; Memory Modified: SND_CYCLE_HOLDER (via PLAY_PITCH_CHANGE)
; Calls: Jumps to PLAY_PITCH_CHANGE or DECREASE_PITCH
;==============================================================================
INCREASE_PITCH:
    LD          HL,PITCH_UP_BOOL                    ; Point to pitch direction flag
    BIT         0x0,(HL)                            ; Check if pitch up is set
    JP          Z,DECREASE_PITCH                    ; If zero, decrease pitch instead
    LD          HL,(SND_CYCLE_HOLDER)               ; Load current cycle count
    SBC         HL,DE                               ; Subtract pitch step (increase freq)
    JP          PLAY_PITCH_CHANGE                   ; Continue with new pitch

;==============================================================================
; DECREASE_PITCH
;==============================================================================
; Decreases pitch by increasing cycle count (lower frequency). Default path
; when PITCH_UP_BOOL is not set.
;
; Registers:
; --- Start ---
;   DE = pitch step
; --- In Process ---
;   HL = SND_CYCLE_HOLDER value
; ---  End  ---
;   HL = updated cycle count (increased by DE)
;   F  = carry from ADD
;   Jumps to PLAY_PITCH_CHANGE
;
; Memory Modified: SND_CYCLE_HOLDER (via PLAY_PITCH_CHANGE)
; Calls: Jumps to PLAY_PITCH_CHANGE
;==============================================================================
DECREASE_PITCH:
    LD          HL,(SND_CYCLE_HOLDER)               ; Load current cycle count
    ADD         HL,DE                               ; Add pitch step (decrease freq)
    JP          PLAY_PITCH_CHANGE                   ; Continue with new pitch

; Preamble to HC_JOY_INPUT_COMPARE to handle in-melee only commands
CHK_MONSTER_MELEE_STATE:
    LD          A,(MONSTER_MELEE_STATE)             ; Load MONSTER_MELEE_STATE
    CP          $31                                 ; Compare to "between attacks" mode
    JP          NZ,WAIT_FOR_INPUT                   ; If not in "between attacks" mode, wait for input

;==============================================================================
; HC_JOY_INPUT_COMPARE
;==============================================================================
; Hand controller joystick input handler - maps 8-directional disc positions
; plus button presses to game actions. Checks input mode flag and processes
; joystick values from HC_INPUT_HOLDER.
;
; Direction Mapping:
;   UP (UUL=$f3, UP=$fb, UUR=$eb)    -> Forward movement
;   RIGHT (UR=$e9, RUR=$f9, R=$fd)   -> Turn right
;   LEFT (LUL=$e7, UL=$e3, L=$f7)    -> Turn left
;   DOWN (DDR=$fc, DOWN=$fe, DDL=$ee) -> Jump back
;   DL (LDL=$f6, DL=$e6)             -> Glance left
;   DR (RDR=$ed, DR=$ec)             -> Glance right
;   K4 ($df)                         -> Toggle shift mode
;
; Registers:
; --- Start ---
;   None specific (loads from RAM)
; --- In Process ---
;   A  = mode flag, then joystick comparison values
;   HL = joystick input bytes from HC_INPUT_HOLDER
; ---  End  ---
;   Varies (jumps to action or continues)
;   F  = from final CP/BIT operations
;
; Memory Modified: None directly (action routines modify game state)
; Calls: Jumps to various action routines or continues to game logic
;==============================================================================
HC_JOY_INPUT_COMPARE:
    LD          HL,(HC_INPUT_HOLDER)                ; Load joystick input values
    LD          A,$f3                               ; Compare to JOY disc UUL
    CP          L                                   ; Check L register
    JP          Z,DO_MOVE_FW_CHK_WALLS              ; Move forward if matched
    CP          H                                   ; Check H register
    JP          Z,DO_MOVE_FW_CHK_WALLS              ; Move forward if matched
    LD          A,$fb                               ; Compare to JOY disc UP
    CP          L                                   ; Check L register
    JP          Z,DO_MOVE_FW_CHK_WALLS              ; Move forward if matched
    CP          H                                   ; Check H register
    JP          Z,DO_MOVE_FW_CHK_WALLS              ; Move forward if matched
    LD          A,$eb                               ; Compare to JOY disc UUR
    CP          H                                   ; Check H register
    JP          Z,DO_MOVE_FW_CHK_WALLS              ; Move forward if matched
    CP          L                                   ; Check L register
    JP          Z,DO_MOVE_FW_CHK_WALLS              ; Move forward if matched
    LD          A,$e9                               ; Compare to JOY disc UR
    CP          L                                   ; Check L register
    JP          Z,DO_TURN_RIGHT                     ; Turn right if matched
    CP          H                                   ; Check H register
    JP          Z,DO_TURN_RIGHT                     ; Turn right if matched
    LD          A,$f9                               ; Compare to JOY disc RUR
    CP          L                                   ; Check L register
    JP          Z,DO_TURN_RIGHT                     ; Turn right if matched
    CP          H                                   ; Check H register
    JP          Z,DO_TURN_RIGHT                     ; Turn right if matched
    LD          A,$fd                               ; Compare to JOY disc RIGHT
    CP          L                                   ; Check L register
    JP          Z,DO_TURN_RIGHT                     ; Turn right if matched
    CP          H                                   ; Check H register
    JP          Z,DO_TURN_RIGHT                     ; Turn right if matched
    LD          A,$e7                               ; Compare to JOY disc LUL
    CP          L                                   ; Check L register
    JP          Z,DO_TURN_LEFT                      ; Turn left if matched
    CP          H                                   ; Check H register
    JP          Z,DO_TURN_LEFT                      ; Turn left if matched
    LD          A,$e3                               ; Compare to JOY disc UL
    CP          L                                   ; Check L register
    JP          Z,DO_TURN_LEFT                      ; Turn left if matched
    CP          H                                   ; Check H register
    JP          Z,DO_TURN_LEFT                      ; Turn left if matched
    LD          A,$f7                               ; Compare to JOY disc LEFT
    CP          L                                   ; Check L register
    JP          Z,DO_TURN_LEFT                      ; Turn left if matched
    CP          H                                   ; Check H register
    JP          Z,DO_TURN_LEFT                      ; Turn left if matched
    LD          A,$f6                               ; Compare to JOY disc LDL
    CP          L                                   ; Check L register
    JP          Z,DO_GLANCE_LEFT                    ; Glance left if matched
    CP          H                                   ; Check H register
    JP          Z,DO_GLANCE_LEFT                    ; Glance left if matched
    LD          A,$e6                               ; Compare to JOY disc DL
    CP          L                                   ; Check L register
    JP          Z,DO_GLANCE_LEFT                    ; Glance left if matched
    CP          H                                   ; Check H register
    JP          Z,DO_GLANCE_LEFT                    ; Glance left if matched
    LD          A,$ed                               ; Compare to JOY disc RDR
    CP          L                                   ; Check L register
    JP          Z,DO_GLANCE_RIGHT                   ; Glance right if matched
    CP          H                                   ; Check H register
    JP          Z,DO_GLANCE_RIGHT                   ; Glance right if matched
    LD          A,$ec                               ; Compare to JOY disc DR
    CP          L                                   ; Check L register
    JP          Z,DO_GLANCE_RIGHT                   ; Glance right if matched
    CP          H                                   ; Check H register
    JP          Z,DO_GLANCE_RIGHT                   ; Glance right if matched
    LD          A,$fc                               ; Compare to JOY disc DDR
    CP          L                                   ; Check L register
    JP          Z,DO_JUMP_BACK                      ; Jump back if matched
    CP          H                                   ; Check H register
    JP          Z,DO_JUMP_BACK                      ; Jump back if matched
    LD          A,$fe                               ; Compare to JOY disc DOWN
    CP          L                                   ; Check L register
    JP          Z,DO_JUMP_BACK                      ; Jump back if matched
    CP          H                                   ; Check H register
    JP          Z,DO_JUMP_BACK                      ; Jump back if matched
    LD          A,$ee                               ; Compare to JOY disc DDL
    CP          L                                   ; Check L register
    JP          Z,DO_JUMP_BACK                      ; Jump back if matched
    CP          H                                   ; Check H register
    JP          Z,DO_JUMP_BACK                      ; Jump back if matched
    LD          A,$df                               ; Compare to JOY K4
    CP          L                                   ; Check L register
    JP          Z,TOGGLE_SHIFT_MODE                 ; Toggle shift mode if matched
    CP          H                                   ; Check H register
    JP          Z,TOGGLE_SHIFT_MODE                 ; Toggle shift mode if matched
    LD          A,(GAME_BOOLEANS)                   ; Load game boolean flags
    BIT         0x1,A                               ; Check if shift mode is active
    JP          NZ,DO_HC_SHIFT_ACTIONS              ; If shift active, use shift actions
DO_HC_BUTTON_ACTIONS:
    LD          A,$bf                               ; Compare to JOY K1
    CP          L                                   ; Check L register
    JP          Z,DO_USE_ATTACK                     ; Use/attack if matched
    CP          H                                   ; Check H register
    JP          Z,DO_USE_ATTACK                     ; Use/attack if matched
    LD          A,$7b                               ; Compare to JOY K2
    CP          L                                   ; Check L register
    JP          Z,DO_OPEN_CLOSE                     ; Open/close if matched
    CP          H                                   ; Check H register
    JP          Z,DO_OPEN_CLOSE                     ; Open/close if matched
    LD          A,$5f                               ; Compare to JOY K3
    CP          L                                   ; Check L register
    JP          Z,DO_PICK_UP                        ; Pick up if matched
    CP          H                                   ; Check H register
    JP          Z,DO_PICK_UP                        ; Pick up if matched
    LD          A,$7d                               ; Compare to JOY K5
    CP          L                                   ; Check L register
    JP          Z,DO_SWAP_PACK                      ; Swap pack if matched
    CP          H                                   ; Check H register
    JP          Z,DO_SWAP_PACK                      ; Swap pack if matched
    LD          A,$7e                               ; Compare to JOY K6
    CP          L                                   ; Check L register
    JP          Z,DO_ROTATE_PACK                    ; Rotate pack if matched
    CP          H                                   ; Check H register
    JP          Z,DO_ROTATE_PACK                    ; Rotate pack if matched
    JP          NO_ACTION_TAKEN                     ; No action matched

;==============================================================================
; DO_HC_SHIFT_ACTIONS
;==============================================================================
; Hand controller shift mode action handler - processes button inputs when
; shift mode is active. Maps K1-K6 buttons to alternate game functions.
;
; Shift Mode Button Mapping:
;   K1 ($bf) -> Use ladder
;   K2 ($7b) -> No action
;   K3 ($5f) -> No action
;   K4 + DR chord ($cc) -> Max health/arrows/food (debug/cheat)
;   K4 + DL chord ($c6) -> Teleport
;   K5 ($7d) -> Swap hands
;   K6 ($7e) -> Rest
;
; Registers:
; --- Start ---
;   None specific (loads from HC_INPUT_HOLDER)
; --- In Process ---
;   A  = button comparison values
;   HL = joystick input bytes (from caller context)
; ---  End  ---
;   Varies (jumps to action routines)
;   F  = from final CP operations
;
; Memory Modified: None directly (action routines modify game state)
; Calls: Jumps to action routines (DO_USE_LADDER, DO_SWAP_HANDS, DO_REST, etc.)
;==============================================================================
DO_HC_SHIFT_ACTIONS:
    LD          A,$bf                               ; Compare to JOY K1
    CP          L                                   ; Check L register
    JP          Z,DO_USE_LADDER                     ; Use ladder if matched
    CP          H                                   ; Check H register
    JP          Z,DO_USE_LADDER                     ; Use ladder if matched
    LD          A,$7b                               ; Compare to JOY K2
    CP          L                                   ; Check L register
    JP          Z,USE_KEY                           ; Use key if matched
    CP          H                                   ; Check H register
    JP          Z,USE_KEY                           ; Use key if matched
    LD          A,$5f                               ; Compare to JOY K3
    CP          L                                   ; Check L register
    JP          Z,USE_MAP                           ; Use map if matched
    CP          H                                   ; Check H register
    JP          Z,USE_MAP                           ; Use map if matched
    LD          A,$7d                               ; Compare to JOY K5
    CP          L                                   ; Check L register
    JP          Z,DO_SWAP_HANDS                     ; Swap hands if matched
    CP          H                                   ; Check H register
    JP          Z,DO_SWAP_HANDS                     ; Swap hands if matched
    LD          A,$7e                               ; Compare to JOY K6
    CP          L                                   ; Check L register
    JP          Z,DO_REST                           ; Rest if matched
    CP          H                                   ; Check H register
    JP          Z,DO_REST                           ; Rest if matched
; Chorded HC commands using K4/Shift
    LD          A,$cc                               ; Compare to K4 + DR chord
    CP          L                                   ; Check L register
    JP          Z,MAX_HEALTH_ARROWS_FOOD            ; Max stats if matched
    CP          H                                   ; Check H register
    JP          Z,MAX_HEALTH_ARROWS_FOOD            ; Max stats if matched
    LD          A,$c6                               ; Compare to K4 + DL chord
    CP          L                                   ; Check L register
    JP          Z,DO_TELEPORT                       ; Teleport if matched
    CP          H                                   ; Check H register
    JP          Z,DO_TELEPORT                       ; Teleport if matched
    JP          NO_ACTION_TAKEN                     ; No action matched

;==============================================================================
; DRAW_BKGD
;==============================================================================
; Draws viewport background including ceiling gradient, floor, and checks for
; active battle to display monster health bar.
;
; Background Layers:
; - Clears upper viewport with spaces (24x19 character area)
; - Clears center floor with spaces (12x5 character area)
; - Upper ceiling: 8 rows DKGRY on BLK
; - Lower ceiling: 6 rows BLK on BLK  
; - Upper floor: 5 rows DKGRN on DKGRY
; - Lower floor: 5 rows BLK on DKGRY (12 wide centered)
; - Battle check: If monster active, redraw health bar
; NOTE: Lower-left and lower-right 6x5 corners are NOT cleared (hand item zones)
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = fill values and color codes
;   HL = CHRRAM/COLRAM viewport addresses
;   BC = rectangle dimensions
;   C  = row counts
;   DE = $28 row stride (from DRAW_CHRCOLS)
; ---  End  ---
;   All registers modified
;
; Memory Modified: CHRRAM and COLRAM viewport area
; Calls: FILL_CHRCOL_RECT, DRAW_CHRCOLS, REDRAW_MONSTER_HEALTH (conditional)
;==============================================================================
DRAW_BKGD:
    LD          A,$20                               ; Set VIEWPORT fill chars to SPACE
    LD          HL,CHRRAM_VIEWPORT_IDX              ; Set CHRRAM starting point at the beginning of the VIEWPORT
    LD          BC,RECT(24,19)                      ; 24 x 19 rectangle (top portion, excludes hand zones)
    CALL        FILL_CHRCOL_RECT                    ; Fill upper viewport with spaces
    LD          A,$20                               ; Reload SPACE character (A was modified)
    LD          HL,CHRRAM_VIEWPORT_IDX + (19 * 40) + 6 ; Row 20, Col 6 (center floor CHRRAM)
    LD          BC,RECT(12,5)                       ; 12 x 5 rectangle (center floor area)
    CALL        FILL_CHRCOL_RECT                    ; Fill center floor with spaces
    LD          BC,RECT(24,8)                       ; Set B=24 (width), C=8 (rows of ceiling)
    LD          HL,COLRAM_VIEWPORT_IDX              ; Set COLRAM starting point at the beginning of the VIEWPORT
    LD          A,COLOR(DKGRY,BLK)                  ; DKGRY on BLK (upper ceiling)
    CALL        DRAW_CHRCOLS                        ; Fill upper ceiling rows
    LD          C,0x6                               ; 6 more rows of ceiling
    ADD         HL,DE                               ; Move to next row
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (lower ceiling)
    CALL        DRAW_CHRCOLS                        ; Fill lower ceiling rows
    LD          C,5                                 ; 5 rows of floor (was 10)
    ADD         HL,DE                               ; Move to next row
    LD          A,COLOR(DKGRN,DKGRY)                ; DKGRN on DKGRY (floor)
    CALL        DRAW_CHRCOLS                        ; Fill floor rows
    ADD         HL,DE                               ; Move to next row
    LD          A,L                                 ; Load low byte of HL
    ADD         A,6                                 ; Add 6 to offset
    LD          L,A                                 ; Store back to L
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (lower floor)
    LD          BC,RECT(12,5)                       ; 12 x 5 rectangle
    CALL        FILL_CHRCOL_RECT                    ; Fill lower floor area

; Check if in-battle
    LD          A,(CURR_MONSTER_PHYS)               ; Load current monster physical stats
    CP          0x0                                 ; Check if monster exists
    JP          Z,NOT_IN_BATTLE                     ; If no monster, not in battle
    LD          A,(CURR_MONSTER_SPRT)               ; Load current monster sprite
    CP          0x0                                 ; Check if sprite exists
    JP          Z,NOT_IN_BATTLE                     ; If no sprite, not in battle
    CALL        REDRAW_MONSTER_HEALTH               ; Redraw monster health bar
    RET                                             ; Return to caller
NOT_IN_BATTLE:
    RET                                             ; Return to caller

; DRAW_LEFT_HAND_AREA
;==============================================================================
; Clears the 6x5 lower-left corner of the viewport to black, then draws
; the item graphic specified by the caller.
;
; Registers:
; --- Start ---
;   B  = Color for GFX_DRAW
;   HL = Screen position for GFX_DRAW (CHRRAM_LEFT_HAND_VP_DRAW_IDX)
;   DE = Graphics pointer for GFX_DRAW
; --- In Process ---
;   A  = $20 (SPACE), then COLOR(BLK,BLK)
;   AF, BC, HL, DE (saved/restored)
; ---  End  ---
;   AF, BC, HL, DE restored; then modified by GFX_DRAW
;
; Memory Modified: CHRRAM/COLRAM left-hand area (6x5), then item graphics
; Calls: FILL_CHRCOL_RECT (×2), GFX_DRAW
;==============================================================================
DRAW_LEFT_HAND_AREA:
    PUSH        AF                                  ; Save A register
    PUSH        DE                                  ; Save graphics pointer
    PUSH        BC                                  ; Save color (B)
    PUSH        HL                                  ; Save draw position
    LD          A,$20                               ; SPACE character
    LD          HL,CHRRAM_VIEWPORT_IDX + (19 * 40)  ; Row 20, Col 0 (lower-left CHRRAM)
    LD          BC,RECT(6,5)                        ; 6 x 5 rectangle
    CALL        FILL_CHRCOL_RECT                    ; Fill with spaces
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK
    LD          HL,COLRAM_VIEWPORT_IDX + (19 * 40)  ; Row 20, Col 0 (lower-left COLRAM)
    LD          BC,RECT(6,5)                        ; 6 x 5 rectangle
    CALL        FILL_CHRCOL_RECT                    ; Fill with black
    POP         HL                                  ; Restore draw position
    POP         BC                                  ; Restore color (B)
    POP         DE                                  ; Restore graphics pointer
    POP         AF                                  ; Restore A register
    JP          GFX_DRAW                            ; Draw item and return (tail call)

; DRAW_RIGHT_HAND_AREA
;==============================================================================
; Fills the 6x5 lower-right corner of the viewport with black (SPACE chars,
; BLK on BLK color). Used during initialization and to clear the hand area.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = $20 (SPACE), then COLOR(BLK,BLK)
;   HL = CHRRAM/COLRAM addresses
;   BC = RECT(6,5)
; ---  End  ---
;   A  = COLOR(BLK,BLK)
;   HL = modified by FILL_CHRCOL_RECT
;   BC = modified by FILL_CHRCOL_RECT
;   DE = preserved
;   F  = modified
;
; Memory Modified: CHRRAM $3332-$3357 (6x5), COLRAM $3732-$3757 (6x5)
; Calls: FILL_CHRCOL_RECT (×2)
;==============================================================================
DRAW_RIGHT_HAND_AREA:
    LD          A,$20                               ; SPACE character
    LD          HL,CHRRAM_VIEWPORT_IDX + (19 * 40) + 18 ; Row 20, Col 18 (lower-right CHRRAM)
    LD          BC,RECT(6,5)                        ; 6 x 5 rectangle
    CALL        FILL_CHRCOL_RECT                    ; Fill with spaces
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK
    LD          HL,COLRAM_VIEWPORT_IDX + (19 * 40) + 18 ; Row 20, Col 18 (lower-right COLRAM)
    LD          BC,RECT(6,5)                        ; 6 x 5 rectangle
    JP          FILL_CHRCOL_RECT                    ; Fill with black (tail call)

;==============================================================================
; WIPE_VARIABLE_SPACE
;==============================================================================
; Clears variable storage space in RAM ($3900-$3AFF). Writes zeros to 765 bytes
; (255 iterations \u00d7 3 bytes each), then initializes blink timer.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = 0
;   HL = $3900, incremented through variable space
;   B  = $FF (255), decremented to 0
; ---  End  ---
;   A  = 0
;   HL = $3A62
;   B  = 0
;
; Memory Modified: $3900-$3AFF (variable space), NEXT_BLINK_CHECK
; Calls: Falls through to CLEAR_MAP_SPACE loop
;==============================================================================
WIPE_VARIABLE_SPACE:
    LD          A,0x0                               ; Load value 0
    LD          HL,$3900                            ; Point to start of variable space
    LD          B,$ff                               ; Set loop counter to 255

;==============================================================================
; CLEAR_MAP_SPACE
;==============================================================================
; Loop that clears 3 bytes per iteration. Alternative entry point for map clearing.
;
; Registers:
; --- Start ---
;   A  = 0 (value to write)
;   HL = starting address
;   B  = iteration count
; --- In Process ---
;   HL = incremented by 3 each iteration
;   B  = decremented each iteration
; ---  End  ---
;   HL = start + (3 \u00d7 iterations)
;   B  = 0
;
; Memory Modified: 3\u00d7B bytes starting at HL
; Calls: None
;==============================================================================
CLEAR_MAP_SPACE:
    LD          (HL),A                              ; Clear byte at HL
    INC         HL                                  ; Move to next byte
    LD          (HL),A                              ; Clear byte at HL
    INC         HL                                  ; Move to next byte
    LD          (HL),A                              ; Clear byte at HL
    INC         HL                                  ; Move to next byte
    DJNZ        CLEAR_MAP_SPACE                     ; Repeat B times
    LD          HL,$3a62                            ; Load initial blink check value
    LD          (NEXT_BLINK_CHECK),HL               ; Store blink check timer
    RET                                             ; Return to caller

;==============================================================================
; PLAY_POOF_ANIM
;==============================================================================
; Plays multi-frame "poof" disappearance animation with sound. Draws 6 frames
; of animation at specified screen position with color transitions and delays.
;
; Animation Sequence:
; 1. Frame 1: WHT on BLK (with POOF_SOUND)
; 2. Frame 2: WHT on BLK
; 3. Frame 3: WHT on BLK (position adjusted up by $29)
; 4. Frame 4: BLK on BLK (fadeout)
; 5. Frame 5: BLK on BLK
; 6. Frame 6: DKGRN on BLK (final)
;
; Registers:
; --- Start ---
;   HL = screen position
; --- In Process ---
;   DE = POOF_1 graphics data
;   B  = color values ($70, $80, $d0)
;   HL = pushed/popped, adjusted by $29
;   BC'/DE'/HL' = swapped for sound/delay
; ---  End  ---
;   HL = original position (restored from stack)
;   AF' = swapped
;
; Memory Modified: Screen area around HL
; Calls: POOF_SOUND, GFX_DRAW, TOGGLE_ITEM_POOF_AND_WAIT
;==============================================================================
PLAY_POOF_ANIM:
    PUSH        HL                                  ; Save HL register value
    LD          DE,POOF_1                           ; DE = Start of POOF animation graphic
    LD          B,$70                               ; Set color to WHT on BLK
    EXX                                             ; Swap BC DE HL with BC' DE' HL'
    CALL        POOF_SOUND                          ; Play poof sound effect
    EXX                                             ; Swap BC DE HL with BC' DE' HL'
    CALL        GFX_DRAW                            ; Draw first frame
    POP         HL                                  ; Restore HL register value
    CALL        TOGGLE_ITEM_POOF_AND_WAIT           ; Wait for frame delay
    PUSH        HL                                  ; Save HL again
    CALL        GFX_DRAW                            ; Draw second frame
    POP         HL                                  ; Restore HL
    PUSH        DE                                  ; Save DE
    LD          DE,$29                              ; Load offset value
    SBC         HL,DE                               ; Adjust HL position
    POP         DE                                  ; Restore DE = $D7,$C9,$01
    CALL        TOGGLE_ITEM_POOF_AND_WAIT           ; Wait for frame delay
    PUSH        HL                                  ; Save HL
    CALL        GFX_DRAW                            ; Draw third frame
    POP         HL                                  ; Restore HL
    PUSH        HL                                  ; Save HL again
    LD          B,$80                               ; Set color to BLK on BLK
    CALL        GFX_DRAW                            ; Draw fourth frame
    CALL        TOGGLE_ITEM_POOF_AND_WAIT           ; Wait for frame delay
    POP         HL                                  ; Restore HL
    PUSH        HL                                  ; Save HL again
    CALL        GFX_DRAW                            ; Draw fifth frame
    CALL        TOGGLE_ITEM_POOF_AND_WAIT           ; Wait for frame delay
    LD          B,$d0                               ; Set color to DKGRN on BLK
    POP         HL                                  ; Restore HL
    CALL        GFX_DRAW                            ; Draw final frame
    EX          AF,AF'                              ; Swap AF with AF'
    RET                                             ; Return to caller

;==============================================================================
; TOGGLE_ITEM_POOF_AND_WAIT
;==============================================================================
; Frame delay routine for poof animation. Swaps to alternate register set,
; performs SLEEP delay, then swaps back.
;
; Registers:
; --- Start ---
;   Main registers preserved via EXX
; --- In Process ---
;   BC' = CHRRAM_DELAY_CONST (delay cycle count)
;   Alternate registers used by SLEEP
; ---  End  ---
;   Main registers restored via EXX
;
; Memory Modified: None directly (SLEEP may modify timer state)
; Calls: SLEEP
;==============================================================================
TOGGLE_ITEM_POOF_AND_WAIT:
    EXX                                             ; Swap BC DE HL with BC' DE' HL'
    LD          BC,CHRRAM_DELAY_CONST               ; Load cycle count for delay
    CALL        SLEEP                               ; byte SLEEP(short cycleCount)
    EXX                                             ; Swap BC DE HL with BC' DE' HL'
    RET                                             ; Return to caller

;==============================================================================
; MONSTER_KILLED
;==============================================================================
; Handles monster death sequence. Plays poof animation, removes monster from
; item map, clears monster stats, and updates viewport. Special handling for
; Minotaur death (final boss).
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = CHRRAM_MONSTER_POOF_IDX, then DIR_FACING_HI
;   A  = player position calculations, item number
;   BC = item map RAM location (from ITEM_MAP_CHECK)
; ---  End  ---
;   Jumps to MINOTAUR_DEAD or UPDATE_VIEWPORT
;
; Memory Modified: Item map entry (set to $FE), monster stats cleared
; Calls: PLAY_POOF_ANIM, ITEM_MAP_CHECK, CLEAR_MONSTER_STATS, UPDATE_VIEWPORT (jump)
;==============================================================================
MONSTER_KILLED:
    LD          HL,CHRRAM_MONSTER_POOF_IDX          ; Point to monster poof position
    CALL        PLAY_POOF_ANIM                      ; Play poof animation
    LD          A,(PLAYER_MAP_POS)                  ; A  = Player position in map
    LD          HL,(DIR_FACING_HI)                  ; HL = FW adjustment value
    ADD         A,H                                 ; A  = Player position in map
                                                    ; one step forward
    CALL        ITEM_MAP_CHECK                      ; Upon return,
                                                    ; A  = itemNum one step forward
                                                    ; BC = itemMapRAMLocation
    CP          $9f                                 ; Check to see if it is
                                                    ; the Minotaur ($9f)
    JP          Z,MINOTAUR_DEAD                     ; If Minotaur, handle special death
    LD          A,$fe                               ; A  = $fe (empty item space)
    LD          (BC),A                              ; itemMapLocRAM = $fe (empty)
    CALL        CLEAR_MONSTER_STATS                 ; Clear monster statistics
    POP         HL                                  ; Restore HL
    JP          UPDATE_VIEWPORT                     ; Update viewport display

;==============================================================================
; TOGGLE_SHIFT_MODE
;==============================================================================
; Toggles shift mode on/off and updates shift mode indicator color. If shift
; mode is currently active, resets it; otherwise sets it.
;
; Shift Mode States:
; - Off: Bit 1 of GAME_BOOLEANS = 0, indicator = WHT on BLK ($F0)
; - On:  Bit 1 of GAME_BOOLEANS = 1, indicator = DKGRN on BLK ($D0)
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = GAME_BOOLEANS value, then indicator color
; ---  End  ---
;   Jumps to SET_SHIFT_MODE or RESET_SHIFT_MODE
;
; Memory Modified: GAME_BOOLEANS (bit 1), COLRAM_SHIFT_MODE_IDX
; Calls: SET_SHIFT_MODE or RESET_SHIFT_MODE (fall-through)
;==============================================================================
TOGGLE_SHIFT_MODE:
    LD          A,(GAME_BOOLEANS)                   ; Load game boolean flags
    BIT         0x1,A                               ; NZ if SHIFT MODE active
    JP          NZ,RESET_SHIFT_MODE                 ; If set, reset shift mode

;==============================================================================
; SET_SHIFT_MODE - (Fall-through from above routine)
;==============================================================================
; Activates shift mode by setting bit 1 in GAME_BOOLEANS and updating the
; on-screen indicator to dark green.
;
; Registers:
; --- Start ---
;   A  = GAME_BOOLEANS
; --- In Process ---
;   A  = modified flags, then $D0
; ---  End  ---
;   Jumps to INPUT_DEBOUNCE
;
; Memory Modified: GAME_BOOLEANS (bit 1 set), COLRAM_SHIFT_MODE_IDX
; Calls: INPUT_DEBOUNCE (jump)
;==============================================================================
SET_SHIFT_MODE:
    SET         0x1,A                               ; Set SHIFT MODE boolean
    LD          (GAME_BOOLEANS),A                   ; Store updated flags
    LD          A,$d0                               ; DKGRN on BLK (shift indicator)
    LD          (COLRAM_SHIFT_MODE_IDX),A           ; Update shift mode color
    JP          INPUT_DEBOUNCE                      ; Debounce input

;==============================================================================
; RESET_SHIFT_MODE
;==============================================================================
; Deactivates shift mode by clearing bit 1 in GAME_BOOLEANS and updating the
; on-screen indicator to white.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = GAME_BOOLEANS, modified flags, then $F0
; ---  End  ---
;   Jumps to INPUT_DEBOUNCE
;
; Memory Modified: GAME_BOOLEANS (bit 1 cleared), COLRAM_SHIFT_MODE_IDX
; Calls: INPUT_DEBOUNCE (jump)
;==============================================================================
RESET_SHIFT_MODE:
    LD          A,(GAME_BOOLEANS)                   ; Load game boolean flags
    RES         0x1,A                               ; Reset SHIFT MODE boolean
    LD          (GAME_BOOLEANS),A                   ; Store updated flags
    LD          A,$f0                               ; WHT on BLK (normal indicator)
    LD          (COLRAM_SHIFT_MODE_IDX),A           ; Update shift mode color
    JP          INPUT_DEBOUNCE                      ; Debounce input

;==============================================================================
; SHOW_AUTHOR
;==============================================================================
; Displays author/credits text and waits for input. Shows "Originally programmed
; by Tom L..." message.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = CHRRAM_AUTHORS_IDX
;   DE = AUTHORS text pointer
;   B  = $20 (32 bytes length)
;   A  = $FF
; ---  End  ---
;   Jumps to WAIT_FOR_INPUT
;
; Memory Modified: CHRRAM author text area
; Calls: GFX_DRAW, WAIT_FOR_INPUT (jump)
;==============================================================================
SHOW_AUTHOR:
    LD          HL,CHRRAM_AUTHORS_IDX               ; Point to author text area
    LD          DE,AUTHORS                          ; Authors text
    LD          B,$20                               ; Set length to 32 bytes
    CALL        GFX_DRAW                            ; Draw author text
    LD          A,$ff                               ; Load value 255
    JP          WAIT_FOR_INPUT                      ; Wait for input

;==============================================================================
; TIMER_UPDATE
;==============================================================================
; Increments MASTER_TICK_TIMER by 1. Simple timer maintenance routine.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = MASTER_TICK_TIMER value
;   BC = 1
; ---  End  ---
;   HL = MASTER_TICK_TIMER + 1
;   BC = 1
;
; Memory Modified: MASTER_TICK_TIMER
; Calls: None
;==============================================================================
TIMER_UPDATE:
    LD          HL,(MASTER_TICK_TIMER)              ; Load MASTER_TICK_TIMER value
    LD          BC,0x1                              ; Load increment value 1
    ADD         HL,BC                               ; Increment timer
    LD          (MASTER_TICK_TIMER),HL              ; Store updated timer
    RET                                             ; Return to caller

;==============================================================================
; BLINK_ROUTINE
;==============================================================================
; Title screen eye blink animation handler. Checks if on title screen (game not
; started), then randomly blinks eyes if timer threshold reached.
;
; Registers:
; --- Start ---
;   AF = pushed to stack
; --- In Process ---
;   A  = GAME_BOOLEANS, SECONDARY_TIMER, NEXT_BLINK_CHECK, R (random)
;   BC = pushed (if blinking), $8000 (delay)
;   HL = pushed (if blinking)
;   DE = pushed (if blinking)
; ---  End  ---
;   All registers restored via exit paths
;
; Memory Modified: NEXT_BLINK_CHECK (if blinking), screen eye areas
; Calls: DO_CLOSE_EYES, SLEEP, DO_OPEN_EYES (if blinking)
;==============================================================================
BLINK_ROUTINE:
    PUSH        AF                                  ; Save AF register
    LD          A,(GAME_BOOLEANS)                   ; Load game boolean flags
    BIT         0x0,A                               ; Check if game started
    JP          Z,STILL_ON_TITLE                    ; If on title screen, do blink
    JP          BLINK_EXIT_AF                       ; Otherwise exit
BLINK_EXIT_ALL:
    POP         DE                                  ; Restore DE register
    POP         HL                                  ; Restore HL register
BLINK_EXIT_BCAF:
    POP         BC                                  ; Restore BC register
BLINK_EXIT_AF:
    POP         AF                                  ; Restore AF register
    RET                                             ; Return to caller
STILL_ON_TITLE:
    PUSH        BC                                  ; Save BC register
    LD          A,(SECONDARY_TIMER)                 ; Load SECONDARY_TIMER value
    LD          B,A                                 ; Store in B register
    LD          A,(NEXT_BLINK_CHECK)                ; Load next blink check time
    CP          B                                   ; Compare to current timer
    JP          NZ,BLINK_EXIT_BCAF                  ; If not time yet, exit
    LD          A,R                                 ; Load refresh register (random)
    LD          (NEXT_BLINK_CHECK),A                ; Store next blink check time
    PUSH        HL                                  ; Save HL register
    PUSH        DE                                  ; Save DE register
    CALL        DO_CLOSE_EYES                       ; Close eyes animation
    LD          BC,$8000                            ; Set long delay count
    CALL        SLEEP                               ; byte SLEEP(short cycleCount)
    CALL        DO_OPEN_EYES                        ; Open eyes animation
    JP          BLINK_EXIT_ALL                      ; Exit and restore all registers

;==============================================================================
; DO_OPEN_EYES
;==============================================================================
; Draws open eyes on title screen by copying character and color data from
; TITLE_SCREEN ROM to screen RAM.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   DE = target addresses ($32d6, $36d6)
;   HL = source addresses (TS_EYES_OPEN_CHR, TS_EYES_OPTN_COL)
;   BC = $44 (68 bytes to copy)
; ---  End  ---
;   DE = $36d6 + 68
;   HL = TS_EYES_OPTN_COL + 68
;   BC = 0
;
; Memory Modified: Character area $32d6-$331A, color area $36d6-$371A
; Calls: None (uses LDIR)
;==============================================================================
DO_OPEN_EYES:
    LD          DE,$32d6                            ; Point to eyes character area
    LD          HL,TS_EYES_OPEN_CHR                 ; Pinned to TITLE_SCREEN (0xD800) + 726; WAS 0xdad6
    LD          BC,$44                              ; Set byte count to 68
    LDIR                                            ; Copy open eyes characters
    LD          DE,$36d6                            ; Point to eyes color area
    LD          HL,TS_EYES_OPTN_COL                 ; Pinned to TITLE_SCREEN (0XD800) + 1750; WAS 0xded6
    LD          BC,$44                              ; Set byte count to 68
    LDIR                                            ; Copy open eyes colors
    RET                                             ; Return to caller

;==============================================================================
; DO_CLOSE_EYES
;==============================================================================
; Draws closed eyes on title screen by writing closed eye characters and colors
; directly to screen RAM. Uses BC register pair as character/color source.
;
; BC Values:
; - B = $D1 (closed eye character for most positions)
; - C = $D0 (closed eye character variant)
; - B = $F0, C = $0F (color values for closed eyes)
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = screen positions ($32d6, $32fe, $36d6, $36fe)
;   BC = $D1D0 (characters), then $F00F (colors)
;   DE = $1A (row offset)
; ---  End  ---
;   HL = $36fe area
;   BC = $F00F
;   DE = $1A
;
; Memory Modified: Character areas at $32d6 and $32fe, color areas at $36d6 and $36fe
; Calls: None
;==============================================================================
DO_CLOSE_EYES:
    LD          HL,$32d6                            ; Point to eyes character area
    LD          BC,$d1d0                            ; Value, not an address (closed eye chars)
    LD          (HL),B                              ; Draw closed eye character
    INC         HL                                  ; Move to next position
    LD          (HL),B                              ; Draw closed eye character
    LD          DE,$1a                              ; Set offset to next row
    ADD         HL,DE                               ; Move to next row
    LD          (HL),B                              ; Draw closed eye character
    DEC         HL                                  ; Move back one position
    LD          (HL),B                              ; Draw closed eye character
    LD          HL,$32fe                            ; Point to second eye character area
    LD          (HL),C                              ; Draw closed eye character
    INC         HL                                  ; Move to next position
    LD          (HL),B                              ; Draw closed eye character
    ADD         HL,DE                               ; Move to next row
    LD          (HL),B                              ; Draw closed eye character
    DEC         HL                                  ; Move back one position
    LD          (HL),C                              ; Draw closed eye character
    LD          HL,$36d6                            ; Point to eyes color area
    LD          BC,$f00f                            ; Value, not an address (closed eye colors)
    LD          (HL),B                              ; Set color for closed eye
    INC         HL                                  ; Move to next position
    LD          (HL),C                              ; Set color for closed eye
    ADD         HL,DE                               ; Move to next row
    LD          (HL),C                              ; Set color for closed eye
    DEC         HL                                  ; Move back one position
    LD          (HL),B                              ; Set color for closed eye
    LD          HL,$36fe                            ; Point to second eye color area
    LD          (HL),B                              ; Set color for closed eye
    INC         HL                                  ; Move to next position
    LD          (HL),B                              ; Set color for closed eye
    ADD         HL,DE                               ; Move to next row
    LD          (HL),B                              ; Set color for closed eye
    DEC         HL                                  ; Move back one position
    LD          (HL),B                              ; Set color for closed eye
    RET                                             ; Return to caller

;==============================================================================
; DRAW_ICON_BAR
;==============================================================================
; Draws UI icon bar characters across bottom of screen. Displays level indicator,
; navigation arrow, ladder, item, monster, map, armor, helmet, and ring icons.
;
; Icon Layout (left to right):
; - Halftone borders ($85, $95)
; - Up arrow (8)
; - Ladder ($48 'H')
; - Item ($D3)
; - Monster ($93)
; - Halftone border ($85)
; - Map ($D1)
; - Armor ($9D)
; - Helmet ($0E)
; - Ring ($6F 'o')
;
; Registers:
; --- Start ---
;   AF = pushed to stack
;   HL = pushed to stack
; --- In Process ---
;   HL = CHRRAM_LEVEL_IND_L, incremented through icon positions
; ---  End  ---
;   AF = restored
;   HL = restored
;
; Memory Modified: CHRRAM icon bar area (CHRRAM_LEVEL_IND_L + offsets)
; Calls: None
;==============================================================================
DRAW_ICON_BAR:
    PUSH        AF                                  ; Save AF register
    PUSH        HL                                  ; Save HL register
    LD          HL,CHRRAM_LEVEL_IND_L               ; Point to level indicator area
    LD          (HL),$85                            ; Right side halftone CHR
    INC         HL                                  ; Move to next position
    INC         HL                                  ; Move to next position
    INC         HL                                  ; Move to next position
    LD          (HL),$95                            ; Left side halftone CHR
    INC         HL                                  ; Move to next position
    LD          (HL),0x8                            ; Up arrow CHR
    INC         HL                                  ; Move to next position
    INC         HL                                  ; Move to next position
    LD          (HL),$48                            ; Ladder (H) CHR
    INC         HL                                  ; Move to next position
    INC         HL                                  ; Move to next position
    LD          (HL),$d3                            ; Item CHR
    INC         HL                                  ; Move to next position
    INC         HL                                  ; Move to next position
    LD          (HL),$93                            ; Monster CHR
    INC         HL                                  ; Move to next position
    INC         HL                                  ; Move to next position
    INC         HL                                  ; Move to next position
    LD          (HL),220                            ; Left side of KEY
    INC         HL                                  ; Move to next position
    LD          (HL),5                              ; Right side of KEY
    INC         HL                                  ; Move to next position
    INC         HL                                  ; Map CHR position
    LD          (HL),$d1                            ; Map CHR
    INC         HL                                  ; Move to next position
    INC         HL                                  ; Armor CHR position
    LD          (HL),$9d                            ; Armor CHR
    INC         HL                                  ; Move to next position
    INC         HL                                  ; Helmet CHR position
    LD          (HL),0xe                            ; Helmet CHR
    INC         HL                                  ; Move to next position
    INC         HL                                  ; Ring (o) CHR position
    LD          (HL),$6f                            ; Ring (o) CHR
    POP         HL                                  ; Restore HL register
    POP         AF                                  ; Restore AF register
    RET                                             ; Return to caller

;==============================================================================
; DRAW_COMPASS
;==============================================================================
; Draws compass direction indicator ('n' for north) on screen with DKBLU color.
;
; Registers:
; --- Start ---
;   AF, BC, HL, DE = pushed to stack
; --- In Process ---
;   B  = $B0 (DKBLU on BLK color)
;   HL = CHRRAM_COMPASS_IDX, then COLRAM_COMPASS_IDX
;   DE = COMPASS graphics data
; ---  End  ---
;   All registers restored
;
; Memory Modified: CHRRAM at CHRRAM_COMPASS_IDX, COLRAM at COLRAM_COMPASS_IDX = $10
; Calls: GFX_DRAW
;==============================================================================
DRAW_COMPASS:
    PUSH        AF                                  ; Save AF register (DKBLU on BLK)
    PUSH        BC                                  ; Save BC register
    PUSH        HL                                  ; Save HL register
    PUSH        DE                                  ; Save DE register
    LD          B,COLOR(DKCYN,BLK)                  ; Set color to DKCYN on BLK
    LD          HL,CHRRAM_COMPASS_IDX               ; Point to compass position
    LD          DE,COMPASS                          ; = $D7,"n",$C9,$01
    CALL        GFX_DRAW                            ; Draw compass graphic
    LD          HL,COLRAM_POINTER_IDX               ; Compass pointer color area
    LD          (HL),$10                            ; Set compass pointer color
    POP         DE                                  ; Restore DE register
    POP         HL                                  ; Restore HL register
    POP         BC                                  ; Restore BC register
    POP         AF                                  ; Restore AF register
    RET                                             ; Return to caller

;==============================================================================
; DRAW_PACK_BKGD
;==============================================================================
; Draws background of player's backpack on screen with DKBLU color.
;
; Registers:
; --- Start ---
;   AF, BC, HL, DE = pushed to stack
; --- In Process ---
;   B  = $B0 (DKBLU on BLK color)
;   HL = CHRRAM_PACK_IDX, then COLRAM_PACK_IDX
;   DE = Pack graphics data
; ---  End  ---
;   All registers restored
;
; Memory Modified: CHRRAM at CHRRAM_PACK_IDX
; Calls: GFX_DRAW
;==============================================================================

DRAW_PACK_BKGD:
    PUSH        AF                                  ; Save AF register (DKBLU on BLK)
    PUSH        BC                                  ; Save BC register
    PUSH        HL                                  ; Save HL register
    PUSH        DE                                  ; Save DE register
    LD          B,COLOR(DKBLU,BLK)                  ; Set color to DKBLU on BLK
    LD          HL,CHRRAM_PACK_IDX                  ; Point to pack position
    LD          DE,PACK_BKGD                        ; GFX for pack
    CALL        GFX_DRAW                            ; Draw pack graphic
    POP         DE                                  ; Restore DE register
    POP         HL                                  ; Restore HL register
    POP         BC                                  ; Restore BC register
    POP         AF                                  ; Restore AF register
    RET                                             ; Return to caller

;==============================================================================
; WIPE_WALLS
;==============================================================================
; Clears wall data area ($3800) by writing zeros to 256 bytes, then updates
; viewport display and debounces input.
;
; Registers:
; --- Start ---
;   AF, BC, HL = pushed to stack
; --- In Process ---
;   HL = $3800, incremented to $3900
;   BC = 0 (B used as loop counter: 256 iterations)
;   A  = 0
; ---  End  ---
;   AF, BC, HL = restored
;   Jumps to INPUT_DEBOUNCE
;
; Memory Modified: $3800-$38FF (256 bytes)
; Calls: UPDATE_VIEWPORT, INPUT_DEBOUNCE (jump)
;==============================================================================
WIPE_WALLS:
    PUSH        AF                                  ; Save AF register
    PUSH        BC                                  ; Save BC register
    PUSH        HL                                  ; Save HL register
    LD          HL,$3800                            ; Point to wall data area
    LD          BC,0x0                              ; Set BC to 0 (B=0, C=0)
    LD          A,0x0                               ; Load value 0
WIPE_WALLS_LOOP:
    LD          (HL),A                              ; Clear byte at HL
    INC         HL                                  ; Move to next byte
    DJNZ        WIPE_WALLS_LOOP                     ; Repeat B times (256 iterations)
    POP         HL                                  ; Restore HL register
    POP         BC                                  ; Restore BC register
    POP         AF                                  ; Restore AF register
    CALL        UPDATE_VIEWPORT                     ; Update viewport display
    JP          INPUT_DEBOUNCE                      ; Debounce input

;==============================================================================
; DRAW_WALL_FL22_EMPTY
;==============================================================================
; Draws empty FL22 (front-left level 2-2) area - black 4x4 rectangle for
; empty/dark corridor section.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_FL22_WALL_IDX
;   BC = RECT(4,4)
;   A  = COLOR(BLK,BLK)
; ---  End  ---
;   Jumps to FILL_CHRCOL_RECT
;
; Memory Modified: COLRAM at FL22 position (4x4)
; Calls: Jumps to FILL_CHRCOL_RECT
;==============================================================================
DRAW_WALL_FL22_EMPTY:
    LD          HL,COLRAM_FL22_WALL_IDX             ; Point to FL22 wall color area
    LD          BC,RECT(4,4)                        ; 4 x 4 rectangle
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (empty/dark)
    JP          FILL_CHRCOL_RECT                    ; Fill area with black (Was CALL, followed by the commented section)

;==============================================================================
; DRAW_WALL_FL2
;==============================================================================
; Draws front-left wall at far distance (FL2) - left and right 2x4 sections
; with bottom edge line. Left side complement of DRAW_WALL_FR2.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = $3234 (bottom chars), $35bc (left), $35be (right)
;   BC = RECT(4,1), then RECT(2,4)
;   A  = CHAR_BOTTOM_LINE, then COLOR(BLK,DKGRY)
;   C  = 4 (height reset)
; ---  End  ---
;   Jumps to DRAW_CHRCOLS
;
; Memory Modified: CHRRAM bottom edge + COLRAM at FL2 positions (left/right)
; Calls: FILL_CHRCOL_RECT, jumps to DRAW_CHRCOLS
;==============================================================================
DRAW_WALL_FL2:
    LD          HL,$3234                            ; Bottom CHARRAM IDX of FL2
    LD          BC,RECT(4,1)                        ; 4 x 1 rectangle
    LD          A,CHAR_BOTTOM_LINE                  ; Thin base line character
    CALL        FILL_CHRCOL_RECT                    ; Fill bottom edge
    LD          HL,$35bc                            ; Point to FL2 left wall area
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    CALL        FILL_CHRCOL_RECT                    ; Fill left wall
    LD          C,0x4                               ; Set height to 4
    LD          HL,$35be                            ; Point to FL2 right wall area
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    JP          DRAW_CHRCOLS                        ; Fill right wall

COLOR_LEVEL_INDICATOR:
    LD          HL,COLRAM_LEVEL_IDX_L               ; Point to level indicator color area
    LD          A,(DIFFICULTY_LEVEL)                ; Load DIFFICULTY_LEVEL
    ADD         A,A                                 ; Double the value
    SUB         0x1                                 ; Subtract 1
    LD          (HL),A                              ; Set level indicator color
    INC         L                                   ; Move to next position
    LD          (HL),A                              ; Set level indicator color
    INC         L                                   ; Move to next position
    LD          (HL),A                              ; Set level indicator color
    INC         L                                   ; Move to next position
    LD          (HL),A                              ; Set level indicator color
    RET

;==============================================================================
; INIT_ICONS
;==============================================================================
; Initiates icon row 
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = COLRAM_SHIFT_MODE_IDX
;   A  = $F0 (DKGRY on BLK)
;   BC = $1300 (B=19 loop counter, C=0)
; ---  End  ---
;   HL = end of icon color area
;   B  = 0
;   A  = $F0
;
; Memory Modified: COLRAM icon bar area (19 icon positions)
; Calls: None
;==============================================================================
INIT_ICONS:
    LD          HL,COLRAM_SHIFT_MODE_IDX            ; Point to shift mode color area
    LD          BC,$1300                            ; Set B=19, C=0
    DEC         HL                                  ; Move back one position
ICON_GREY_FILL_LOOP:
    INC         HL                                  ; Move to next position
    LD          (HL),COLOR(DKGRY,BLK)               ; DKGRY on BLK
    DJNZ        ICON_GREY_FILL_LOOP                 ; Repeat B times
    RET                                             ; Return to caller

;==============================================================================
; USE_MAP
;==============================================================================
; Displays the dungeon mini-map overlay when the player uses the map item.
; Checks if the map is owned and available, then draws a 24x24 character area
; showing walls, player position, and optionally ladders/monsters/items based
; on the map's quality level (red=basic, yellow=+ladder, magenta=+monsters,
; white=+items).
;
; Registers:
; --- Start ---
;   A  = GAME_BOOLEANS value for map check
; --- In Process ---
;   BC = Rectangle dimensions and iteration counters
;   HL = CHRRAM/COLRAM pointers for map drawing
;   DE = Map data pointers
;   A  = Map characters, colors, and item/monster codes
;   B  = Map quality level counter
;   D  = Color values for map elements
; ---  End  ---
;   All registers modified by map drawing routines
;   Viewport restored after map closed
;
; Memory Modified: CHRRAM_VIEWPORT_IDX, COLRAM_VIEWPORT_IDX
; Calls: FILL_CHRCOL_RECT, SOUND_03, DRAW_RED/YELLOW/MAGENTA/WHITE_MAP, UPDATE_VIEWPORT
;==============================================================================
USE_MAP:
    LD          A,(GAME_BOOLEANS)                   ; Load game state flags
    BIT         0x2,A                               ; Check bit 2 (map owned flag)
    JP          Z,NO_ACTION_TAKEN                   ; If not owned, exit without action
    LD          A,(MAP_INV_SLOT)                    ; Load map quality level (0-4)
    AND         A                                   ; Test if zero (no map)
    JP          Z,INIT_MN_MELEE_ANIM                ; If no map slot, exit to melee animation
    EXX								                ; Swap to alternate register set

    LD          BC,RECT(24,19)                      ; Set dimensions: 24 wide x 19 high
    LD          HL,CHRRAM_VIEWPORT_IDX              ; Point to viewport character RAM
    LD          A,$20                               ; Load SPACE character ($20)
    CALL        FILL_CHRCOL_RECT                    ; Clear viewport with spaces

    LD          BC,RECT(12,5)                       ; Set dimensions: 12 wide x 5 high
    LD          HL,CHRRAM_VP_MID_BOTTOM_IDX         ; Point to viewport middle bottom character RAM
    CALL        FILL_CHRCOL_RECT                    ; Clear viewport with spaces

    CALL        SOUND_03                            ; Play map open sound

    LD          BC,RECT(24,19)                      ; Set dimensions: 24 wide x 24 high
    LD          HL,COLRAM_VIEWPORT_IDX              ; Point to viewport color RAM
    LD          A,COLOR(DKBLU,BLK)                  ; Set color: dark blue on black
    CALL        FILL_CHRCOL_RECT                    ; Fill viewport with map background color

    LD          BC,RECT(12,5)                       ; Set dimensions: 12 wide x 5 high
    LD          HL,COLRAM_VP_MID_BOTTOM_IDX         ; Point to viewport middle bottom color RAM
    CALL        FILL_CHRCOL_RECT                    ; Fill viewport with map background color

    EXX								                ; Swap back to main register set
    PUSH        AF                                  ; Preserve A register
    LD          A,(MAP_INV_SLOT)                    ; Load map quality level
    LD          B,A                                 ; Copy to B for decrement testing
    POP         AF                                  ; Restore A register
    DEC         B                                   ; Test for level 1 (red map)
    JP          Z,DRAW_RED_MAP                      ; Draw basic walls and player only
    DEC         B                                   ; Test for level 2 (yellow map)
    JP          Z,DRAW_YELLOW_MAP                   ; Draw walls, player, and ladder
    DEC         B                                   ; Test for level 3 (magenta map)
    JP          Z,DRAW_MAGENTA_MAP                  ; Draw walls, player, ladder, and monsters

;==============================================================================
; DRAW_WHITE_MAP
;==============================================================================
; Draws the highest-quality map (level 4), adding item locations on top of
; walls, player position, ladder, and monsters. Iterates over the item list
; and marks each item cell with a distinct color.
;
; Registers:
; --- Start ---
;   HL = $74 (low bound in H, high bound set by loop)
; --- In Process ---
;   BC = List pointer through item entries
;   A  = Position offset for current item
;   D  = Item color value ($b6)
; ---  End  ---
;   BC advanced to end or next phase; Z indicates end-of-list
;
; Memory Modified: COLRAM_VIEWPORT_IDX (item positions)
; Calls: MAP_ITEM_MONSTER, UPDATE_ITEM_CELLS
;==============================================================================
DRAW_WHITE_MAP:
    CALL        DRAW_WHT_MAP_LEGEND                 ; Draw the WHITE map legend
    LD          HL,$74                              ; Set item range lower bound ($74..$78)
    CALL        MAP_ITEM_MONSTER                    ; Prepare list pointer (BC = MAP_LADDER_OFFSET)

;==============================================================================
; UPDATE_ITEM_CELLS
;==============================================================================
; Iterates the item list, coloring each matching item cell in the mini-map.
; Each entry is [position_offset][item_code]; entries outside $74..$78 are
; skipped by FIND_NEXT_ITEM_MONSTER_LOOP. Ends when $FF terminator reached.
;
; Registers:
; --- Start ---
;   BC = Pointer to [offset][code]
; --- In Process ---
;   A  = Position offset; D = item color ($b6)
;   BC = Advanced through list entries
; ---  End  ---
;   Z flag indicates list end; falls through to DRAW_PURPLE_MAP
;
; Memory Modified: COLRAM_VIEWPORT_IDX (item positions)
; Calls: UPDATE_COLRAM_FROM_OFFSET, FIND_NEXT_ITEM_MONSTER_LOOP, DRAW_PURPLE_MAP
;==============================================================================
UPDATE_ITEM_CELLS:
    JP          Z,DRAW_MAGENTA_MAP                  ; If end of list, proceed to monster coloring
    LD          A,(BC)                              ; Load item position offset
    INC         C                                   ; Advance pointer to item code
    INC         C                                   ; Skip past item code byte
    EXX                                             ; Swap to alternate register set for COLRAM
    LD          D,$b6                               ; Set item color (DKBLU on YEL-ish index $b6)
    CALL        UPDATE_COLRAM_FROM_OFFSET           ; Color the cell at offset A with D
    EXX                                             ; Swap back to main register set
    CALL        FIND_NEXT_ITEM_MONSTER_LOOP         ; Find next matching item in range
    JP          UPDATE_ITEM_CELLS                   ; Repeat until list exhausted

;==============================================================================
; DRAW_MAGENTA_MAP
;==============================================================================
; Draws a level-3 quality map showing walls, player position, ladder, and
; monster locations. Iterates through the monster list and marks each monster
; position with red color on the mini-map.
;
; Registers:
; --- Start ---
;   HL = $78a8 (item range filter)
; --- In Process ---
;   BC = Map data pointer (incremented through list)
;   A  = Current item position offset
;   D  = COLOR(DKBLU,RED) for monster cells
; ---  End  ---
;   BC = Advanced past all monster entries
;   Monsters marked on map, control passes to DRAW_YELLOW_MAP
;
; Memory Modified: COLRAM_VIEWPORT_IDX (monster positions)
; Calls: MAP_ITEM_MONSTER, UPDATE_COLRAM_FROM_OFFSET, FIND_NEXT_ITEM_MONSTER_LOOP
;==============================================================================
DRAW_MAGENTA_MAP:
    CALL        DRAW_MAG_MAP_LEGEND                 ; Draw the MAGENTA map legend
    LD          HL,$78a8                            ; Set item range for monsters ($78 to $a8)
    CALL        MAP_ITEM_MONSTER                    ; Initialize monster search (BC = MAP_LADDER_OFFSET)
UPDATE_MONSTER_CELLS_LOOP:
    JP          Z,DRAW_YELLOW_MAP                   ; If no more monsters, continue to yellow map
    LD          A,(BC)                              ; Load monster position offset
    INC         C                                   ; Advance pointer past position
    INC         C                                   ; Advance pointer past monster code
    EXX								                ; Swap to alternate register set (viewport pointers)
    LD          D,COLOR(DKBLU,RED)                  ; Set monster cell color: dark blue on red
    CALL        UPDATE_COLRAM_FROM_OFFSET           ; Update color at monster position
    EXX								                ; Swap back to main register set
    CALL        FIND_NEXT_ITEM_MONSTER_LOOP         ; Find next monster in list
    JP          UPDATE_MONSTER_CELLS_LOOP           ; Repeat for all monsters

;==============================================================================
; DRAW_YELLOW_MAP
;==============================================================================
; Draws a level-2 quality map showing walls, player position, and ladder.
; Marks the ladder position with magenta color, then continues to red map
; to draw walls and player.
;
; Registers:
; --- Start ---
;   D  = COLOR(DKBLU,MAG) set before DRAW_RED_MAP
; --- In Process ---
;   A  = ITEM_HOLDER value (ladder position)
;   D  = Ladder cell color value
; ---  End  ---
;   Ladder marked, control passes to DRAW_RED_MAP
;
; Memory Modified: COLRAM_VIEWPORT_IDX (ladder position)
; Calls: UPDATE_COLRAM_FROM_OFFSET, DRAW_RED_MAP
;==============================================================================
DRAW_YELLOW_MAP:
    CALL        DRAW_YEL_MAP_LEGEND                 ; Draw the YELLOW map legend
    LD          D,COLOR(DKBLU,MAG)                  ; Set ladder cell color: dark blue on magenta
    LD          A,(ITEM_HOLDER)                     ; Load ladder position offset
    CALL        UPDATE_COLRAM_FROM_OFFSET           ; Update color at ladder position

;==============================================================================
; DRAW_RED_MAP
;==============================================================================
; Draws a level-1 (basic) quality map showing only walls and player position.
; Iterates through the dungeon data in HC_LAST_INPUT, drawing wall characters
; in the mini-map viewport based on north/west wall flags in each cell.
;
; Registers:
; --- Start ---
;   BC = RECT(16,24) (width in B, height stored)
;   DE = HC_LAST_INPUT pointer (dungeon data)
;   HL = CHRRAM_MINI_MAP_IDX (mini-map character area)
; --- In Process ---
;   A  = Wall flags and wall characters
;   B  = Column counter (decrements to 0, then resets to $10)
;   D  = Current dungeon data row pointer (high byte)
; ---  End  ---
;   HL = Advanced past all mini-map cells
;   DE = Advanced past all dungeon data
;   Walls drawn, control passes to SET_MINIMAP_PLAYER_LOC
;
; Memory Modified: CHRRAM_MINI_MAP_IDX (wall graphics)
; Calls: SET_MINIMAP_PLAYER_LOC
;==============================================================================
DRAW_RED_MAP:
    LD          BC,RECT(16,24)                      ; Set dimensions: 16 wide, 24 high (B=16, C=24)
    LD          DE,HC_LAST_INPUT                    ; Point to dungeon map data
    LD          HL,CHRRAM_MINI_MAP_IDX              ; Point to mini-map character area
CALC_MINIMAP_WALL:
    INC         DE                                  ; Advance to next dungeon cell
    LD          A,D                                 ; Check high byte of dungeon pointer
    CP          $39                                 ; Compare to end of dungeon data ($39xx)
    JP          Z,SET_MINIMAP_PLAYER_LOC            ; If at end, mark player position
    LD          A,(DE)                              ; Load wall flags from current cell
    OR          A                                   ; Test if any walls present
    JP          Z,SET_MINIMAP_NO_WALLS              ; If no walls, draw empty cell
    AND         0xf                                 ; Mask lower nybble (north wall flag)
    JP          NZ,CHECK_MINIMAP_WEST_WALL          ; If north wall set, check west wall
SET_MINIMAP_N_WALL:
    LD          A,$a3                               ; Load character $a3 (north wall only)
    JP          DRAW_MINIMAP_WALL                   ; Draw wall character
SET_MINIMAP_NO_WALLS:
    LD          A,$a0                               ; Load character $a0 (no walls)
    JP          DRAW_MINIMAP_WALL                   ; Draw empty cell character
SET_MINIMAP_NW_WALLS:
    LD          A,$b7                               ; Load character $b7 (north and west walls)
    JP          DRAW_MINIMAP_WALL                   ; Draw corner wall character
;==============================================================================
; CHECK_MINIMAP_WEST_WALL - Reload wall state and check for west wall
;==============================================================================
; Continuation point after north+west wall check. Reloads wall flags from (DE)
; and masks upper nybble to check west wall bit. If set, draws north+west
; corner, otherwise falls through to west-only wall character.
;
; Registers:
; --- Start ---
;   DE = Wall state pointer
; --- In Process ---
;   A  = Wall state byte, then masked upper nybble
; ---  End  ---
;   A  = Test result or wall character code
;
; Memory Modified: None
; Calls: SET_MINIMAP_NW_WALLS (via JP)
;==============================================================================
CHECK_MINIMAP_WEST_WALL:
    LD          A,(DE)                              ; Reload wall flags
    AND         $f0                                 ; Mask upper nybble (west wall flag)
    JP          NZ,SET_MINIMAP_NW_WALLS             ; If west wall set, draw north+west
SET_MINIMAP_W_WALL:
    LD          A,$b5                               ; Load character $b5 (west wall only)
DRAW_MINIMAP_WALL:
    LD          (HL),A                              ; Write wall character to mini-map
    INC         HL                                  ; Advance to next mini-map cell
    DJNZ        CALC_MINIMAP_WALL                   ; Decrement B (column counter), repeat if not zero
    ADD         HL,BC                               ; Advance HL to next row (skip remainder of 40-char line)
    LD          B,$10                               ; Reset column counter to 16
    JP          CALC_MINIMAP_WALL                   ; Continue to next row

;==============================================================================
; SET_MINIMAP_PLAYER_LOC
;==============================================================================
; Marks the player's current position on the mini-map with white color, then
; waits for a keypress or hand controller input before closing the map and
; returning to the normal viewport.
;
; Registers:
; --- Start ---
;   A  = PLAYER_MAP_POS value
;   D  = COLOR(DKBLU,WHT)
; --- In Process ---
;   BC = $ff (keyboard port), then $f7/$f6 (hand controller ports)
;   A  = Input values from ports (incremented for testing)
;   C  = Port selector ($ff, $f7, $f6)
; ---  End  ---
;   All registers modified by input polling
;   Control passes to UPDATE_VIEWPORT
;
; Memory Modified: COLRAM_VIEWPORT_IDX (player position)
; Calls: UPDATE_COLRAM_FROM_OFFSET, WAIT_A_TICK, UPDATE_VIEWPORT
;==============================================================================
SET_MINIMAP_PLAYER_LOC:
    LD          A,(PLAYER_MAP_POS)                  ; Load player position offset
    LD          D,COLOR(DKBLU,WHT)                  ; Set player cell color: dark blue on white
    CALL        UPDATE_COLRAM_FROM_OFFSET           ; Mark player position on map
    CALL        DRAW_RED_MAP_LEGEND                 ; Draw the RED map legend components (PLAYER & WALLS)
    CALL        WAIT_A_TICK                         ; Wait for display stability

READ_KEY:
    LD          BC,$ff                              ; Set BC to keyboard port ($ff)
    IN          A,(C)                               ; Read keyboard input
    INC         A                                   ; Test for $FF (no key pressed)
    JP          NZ,READ_KEY                         ; If key pressed, wait for release
ENABLE_HC:
    LD          C,$f7                               ; Set port to hand controller 1 ($f7)
    LD          A,0xf                               ; Load hand controller enable value
    OUT         (C),A                               ; Enable hand controller
    DEC         C                                   ; Set port to hand controller 2 ($f6)
READ_HC:
    IN          A,(C)                               ; Read hand controller input
    INC         A                                   ; Test for $FF (no input)
    JP          NZ,READ_KEY                         ; If input detected, wait for release
    INC         C                                   ; Switch back to port $f7
    LD          A,0xe                               ; Load hand controller disable value
DISABLE_HC:
    OUT         (C),A                               ; Disable hand controller
    DEC         C                                   ; Set port back to $f6
    IN          A,(C)                               ; Read hand controller input again
    INC         A                                   ; Test for $FF (no input)
    JP          NZ,READ_KEY                         ; If input detected, keep waiting
    JP          UPDATE_VIEWPORT                     ; Close map and return to normal viewport

DRAW_RED_MAP_LEGEND:
    LD          B,COLOR(GRY,BLK)                    ; GRY on BLK
    LD          HL,CHRRAM_MAP_LGD_PLAYER            ; Draw at MAP LEGEND PLAYER index
    LD          DE,MAP_LEGEND_PLAYER                ; Draw MAP LEGEND PLAYER text
    CALL        GFX_DRAW

    LD          B,COLOR(WHT,BLK)                    ; WHY on BLK
    LD          HL,CHRRAM_MAP_LGD_PLAYER + $400     ; COLRAM for PLAYER square
    LD          (HL),B                              ;

    LD          B,COLOR(GRY,BLK)                    ; GRY on BLK
    LD          HL,CHRRAM_MAP_LGD_WALLS             ; Draw at MAP LEGEND WALLS index
    LD          DE,MAP_LEGEND_WALLS                 ; Draw MAP LEGEND WALLS text
    CALL        GFX_DRAW

    LD          B,COLOR(DKBLU,BLK)                  ; DKBLU on BLK
    LD          HL,CHRRAM_MAP_LGD_WALLS + $400      ; COLRAM for WALLS square
    LD          (HL),B                              ;

    RET                                             ; Done

DRAW_YEL_MAP_LEGEND:
    LD          B,COLOR(GRY,BLK)                    ; GRY on BLK
    LD          HL,CHRRAM_MAP_LGD_LADDER            ; Draw at MAP LEGEND LADDER index
    LD          DE,MAP_LEGEND_LADDER                ; Draw MAP LEGEND LADDER text
    CALL        GFX_DRAW

    LD          B,COLOR(MAG,BLK)                    ; MAG on BLK
    LD          HL,CHRRAM_MAP_LGD_LADDER + $400     ; COLRAM for LADDER square
    LD          (HL),B                              ;

    RET                                             ; Done

DRAW_MAG_MAP_LEGEND:
    LD          B,COLOR(GRY,BLK)                    ; GRY on BLK
    LD          HL,CHRRAM_MAP_LGD_MONSTERS          ; Draw at MAP LEGEND MONSTERS index
    LD          DE,MAP_LEGEND_MONSTERS              ; Draw MAP LEGEND MONSTERS text
    CALL        GFX_DRAW

    LD          B,COLOR(RED,BLK)                    ; RED on BLK
    LD          HL,CHRRAM_MAP_LGD_MONSTERS + $400   ; COLRAM for MONSTERS square
    LD          (HL),B                              ;

    RET                                             ; Done

DRAW_WHT_MAP_LEGEND:
    LD          B,COLOR(GRY,BLK)                    ; GRY on BLK
    LD          HL,CHRRAM_MAP_LGD_ITEMS             ; Draw at MAP LEGEND ITEMS index
    LD          DE,MAP_LEGEND_ITEMS                 ; Draw MAP LEGEND ITEMS text
    CALL        GFX_DRAW

    LD          B,COLOR(CYN,BLK)                    ; CYN on BLK
    LD          HL,CHRRAM_MAP_LGD_ITEMS + $400      ; COLRAM for ITEMS square
    LD          (HL),B                              ;

    RET                                             ; Done


;==============================================================================
; MAP_ITEM_MONSTER
;==============================================================================
; Initializes search for monsters or items in the dungeon map data. Sets BC
; to point to the map item/monster list and falls through to the search loop.
;
; Registers:
; --- Start ---
;   HL = Item range bounds (H=min, L=max)
; --- In Process ---
;   BC = MAP_LADDER_OFFSET (list start pointer)
; ---  End  ---
;   BC = First entry pointer (or end marker)
;   Z flag set if no matching items found
;
; Memory Modified: None
; Calls: FIND_NEXT_ITEM_MONSTER_LOOP (fall-through)
;==============================================================================
MAP_ITEM_MONSTER:
    LD          BC,MAP_LADDER_OFFSET                ; Point to start of map item/monster list

;==============================================================================
; FIND_NEXT_ITEM_MONSTER_LOOP
;==============================================================================
; Searches through the map item/monster list for entries matching the specified
; type range. Each list entry is 2 bytes: [position_offset][item_code]. The
; list is terminated with $FF. Filters entries based on H/L range bounds.
;
; Registers:
; --- Start ---
;   BC = List pointer (entry position offset)
;   HL = Range bounds (H=min, L=max)
; --- In Process ---
;   A  = Position offset, then item code
;   BC = Incremented through list entries
; ---  End  ---
;   BC = Match position (BC-2) or end of list
;   A  = Last item code compared
;   Z flag = match status
;
; Memory Modified: None
; Calls: None (returns to caller)
;==============================================================================
FIND_NEXT_ITEM_MONSTER_LOOP:
    LD          A,(BC)                              ; Load position offset byte
    INC         BC                                  ; Advance to item code byte
    INC         A                                   ; Test for $FF terminator (becomes $00)
    RET         Z                                   ; Return with Z flag if end of list
    LD          A,(BC)                              ; Load item code
    CP          H                                   ; Compare to low bound (H)
    INC         BC                                  ; Advance to next entry
    JP          C,FIND_NEXT_ITEM_MONSTER_LOOP       ; If code < low bound, continue search
    CP          L                                   ; Compare to high bound (L)
    JP          NC,FIND_NEXT_ITEM_MONSTER_LOOP      ; If code >= high bound, continue search
    DEC         C                                   ; Back up to item code byte
    DEC         BC                                  ; Back up to position offset byte
    RET                                             ; Return with Z clear (match found)

;==============================================================================
; UPDATE_COLRAM_FROM_OFFSET
;==============================================================================
; Updates a color RAM cell in the viewport based on a linear offset (0-383).
; Converts the offset to a 2D coordinate in the 24x16 viewport grid and sets
; the color at that position to the value in D register.
;
; Registers:
; --- Start ---
;   A  = Linear offset value
;   D  = Color value to set
; --- In Process ---
;   A  = X coordinate, then row calculations
;   BC = Offset accumulators for row/column math
;   HL = COLRAM_F0_WALL_IDX base, then final COLRAM address
;   B  = Row multiplier carry bit
; ---  End  ---
;   HL = Final COLRAM address
;   (HL) = Color value from D
;   A, BC modified
;
; Memory Modified: COLRAM_VIEWPORT_IDX (one cell at calculated offset)
; Calls: None
;==============================================================================
UPDATE_COLRAM_FROM_OFFSET:
    PUSH        AF                                  ; Preserve original offset
    AND         0xf                                 ; Mask lower nybble (X coordinate 0-15)
    LD          HL,COLRAM_MINI_MAP_IDX              ; Point to viewport COLRAM base
    LD          C,A                                 ; Copy X coordinate to C
    LD          B,0x0                               ; Clear B for 16-bit addition
    ADD         HL,BC                               ; Add X offset to base address
    POP         AF                                  ; Restore original offset
    AND         $f0                                 ; Mask upper nybble (row number * 16)
    RRA                                             ; Divide by 2 (row * 8)
    LD          C,A                                 ; Copy to C
    ADD         HL,BC                               ; Add (row * 8) to address
    RLA                                             ; Multiply by 2 (row * 16)
    RLA                                             ; Multiply by 2 (row * 32)
    RL          B                                   ; Capture carry bit into B
    LD          C,A                                 ; Copy (row * 32) to C
    ADD         HL,BC                               ; Add (row * 32), total = row * 40
    LD          (HL),D                              ; Write color value D to COLRAM
    RET                                             ; Return to caller

;==============================================================================
; RANDOMIZE_BCD_NYBBLES — Randomize BCD nybbles in L
;==============================================================================
; Takes the value in L, extracts and randomizes each BCD nybble independently,
; then recombines them back into L. Uses modulo arithmetic to constrain the
; random value to valid BCD ranges (0-9 for each nybble).
;
; Registers:
; --- Start ---
;   L = Input BCD value
; --- In Process ---
;   A = Extracted nybbles and calculations
;   B = Range parameter for modulo
;   C = Randomized lower nybble (temporary)
; ---  End  ---
;   L = Randomized output
;   A = Combined result
;
; Memory Modified: None directly; screen saver timer via RANDOM_MOD_B
; Calls: RANDOM_MOD_B (twice)
;==============================================================================
RANDOMIZE_BCD_NYBBLES:
    LD          A,L                                 ; Load BCD value
    AND         0xf                                 ; Mask lower nybble (0-15)
    LD          B,A                                 ; Copy to B
    INC         B                                   ; B = nybble + 1 (range 1-16)
    CALL        RANDOM_MOD_B                        ; Get random A mod B
    LD          C,A                                 ; Save randomized lower nybble in C
    LD          A,L                                 ; Reload BCD value
    AND         $f0                                 ; Mask upper nybble
    RLCA                                            ; Shift right 4 bits (nybble to lower position)
    RLCA
    RLCA
    RLCA
    LD          B,A                                 ; Copy to B
    INC         B                                   ; B = nybble + 1 (range 1-16)
    CALL        RANDOM_MOD_B                        ; Get random A mod B
    RLCA                                            ; Shift left 4 bits (nybble to upper position)
    RLCA
    RLCA
    RLCA
    ADD         A,C                                 ; Combine upper nybble with lower (from C)
    LD          L,A                                 ; Store combined result in L
    RET
;==============================================================================
; RANDOM_MOD_B — Random Modulo
;==============================================================================
; Returns a pseudo-random value modulo B. Uses UPDATE_SCR_SAVER_TIMER as a
; random source, then repeatedly subtracts B until result is in range [0,B-1].
;
; Registers:
; --- Start ---
;   B = Divisor
; --- In Process ---
;   A = Random byte, then modulo result
; ---  End  ---
;   A = Result in range [0, B-1]
;
; Memory Modified: Screen saver timer via UPDATE_SCR_SAVER_TIMER
; Calls: UPDATE_SCR_SAVER_TIMER
;==============================================================================
RANDOM_MOD_B:
    CALL        UPDATE_SCR_SAVER_TIMER              ; Get pseudo-random byte in A
    AND         0xf                                 ; Mask to lower nybble (0-15)
RAND_MOD_LOOP:                                      ; Modulo loop
    SUB         B                                   ; A = A - B
    JP          NC,RAND_MOD_LOOP                    ; If no borrow (A >= B), repeat
    ADD         A,B                                 ; A went negative; add B back
    RET                                             ; Return A in range [0, B-1]

;==============================================================================
; ADD_BCD_HL_DE — Add BCD Values (HL += DE)
;==============================================================================
; Adds two 16-bit BCD (Binary Coded Decimal) values. Uses DAA (Decimal Adjust
; Accumulator) after each byte addition to keep result in valid BCD format.
;
; Registers:
; --- Start ---
;   HL = BCD addend 1
;   DE = BCD addend 2
; --- In Process ---
;   A = Intermediate sums with carry
; ---  End  ---
;   HL = BCD result
;   A = Final high byte result
;
; Memory Modified: None
; Calls: None
;==============================================================================
ADD_BCD_HL_DE:
    LD          A,L                                 ; Load low byte of HL
    ADD         A,E                                 ; Add low byte of DE
    DAA                                             ; Decimal adjust for BCD
    LD          L,A                                 ; Store BCD result in L
    LD          A,D                                 ; Load high byte of DE
    ADC         A,H                                 ; Add high byte of HL with carry
    DAA                                             ; Decimal adjust for BCD
    LD          H,A                                 ; Store BCD result in H
    RET

;==============================================================================
; RECALC_PHYS_HEALTH — Subtract BCD Values (HL -= DE)
;==============================================================================
; Subtracts two 16-bit BCD values, typically used to recalculate physical
; health after damage. Uses DAA after each byte subtraction to maintain BCD.
;
; Registers:
; --- Start ---
;   HL = BCD minuend
;   DE = BCD subtrahend
; --- In Process ---
;   A = Intermediate differences with borrow
; ---  End  ---
;   HL = BCD result
;   A = Final high byte result
;
; Memory Modified: None
; Calls: None
;==============================================================================
RECALC_PHYS_HEALTH:
    LD          A,L                                 ; Load low byte of HL
    SUB         E                                   ; Subtract low byte of DE
    DAA                                             ; Decimal adjust for BCD
    LD          L,A                                 ; Store BCD result in L
    LD          A,H                                 ; Load high byte of HL
    SBC         A,D                                 ; Subtract high byte of DE with borrow
    DAA                                             ; Decimal adjust for BCD
    LD          H,A                                 ; Store BCD result in H
    RET

;==============================================================================
; DIVIDE_BCD_HL_BY_2 — Divide BCD HL by 2 with Rounding
;==============================================================================
; Divides a 16-bit BCD value in HL by 2 using right shifts. Applies BCD
; correction when shifting across nybble boundaries and rounds down if the
; lower nybble of L has bit 3 set.
;
; Registers:
; --- Start ---
;   HL = BCD dividend
; --- In Process ---
;   A = Correction values ($30, 3)
; ---  End  ---
;   HL = BCD quotient
;   Flags reflect final state
;
; Memory Modified: None
; Calls: None
;==============================================================================
DIVIDE_BCD_HL_BY_2:
    XOR         A                                   ; Clear A and carry flag
    RR          H                                   ; Rotate H right (divide high byte by 2)
    JP          NC,DIVIDE_NO_CARRY                  ; If no carry, skip BCD correction
    RR          L                                   ; Rotate L right with carry from H
    LD          A,L                                 ; Load L
    SUB         $30                                 ; BCD correction: subtract $30
    LD          L,A                                 ; Store corrected value
    JP          DIVIDE_ROUND_CHECK                  ; Continue to rounding check
DIVIDE_NO_CARRY:                                    ; No carry from H
    RR          L                                   ; Rotate L right (divide by 2)
DIVIDE_ROUND_CHECK:                                 ; Rounding adjustment
    BIT         0x3,L                               ; Test bit 3 of L
    RET         Z                                   ; If clear, no rounding needed
    LD          A,L                                 ; Load L
    SUB         0x3                                 ; Subtract 3 for rounding
    LD          L,A                                 ; Store adjusted value
    RET

;==============================================================================
; COPY_GFX_2_BUFFER
;==============================================================================
; Copies a 4x4 character block from source to destination address. Source
; pointer (HL) advances through screen rows while destination (DE) remains
; a contiguous buffer. Automatically handles both CHRRAM and COLRAM addressing
; by detecting the memory page and recursively copying color data.
;
; Memory Layout:
; - Screen is 40 characters wide, so next row = current + 40 ($28)
; - After copying 4 characters in a row, skip 36 positions to next row
; - If crossing from CHRRAM to COLRAM ($3400+), add $384 offset
;
; Registers:
; --- Start ---
;   HL = Source address for 4x4 block (screen memory)
;   DE = Destination address for 4x4 block (buffer)
;   A  = Row counter (will be set to 4)
; --- In Process ---
;   A  = Row counter (4→3→2→1→0)
;   BC = Copy length (4 chars) and row skip offset ($24 = 36)
;   HL = Current source position advancing through screen rows
;   DE = Current destination position (auto-increments contiguously via LDIR)
;   H  = Used for source memory page detection ($30-$33 vs $34+)
; ---  End  ---
;   A  = 0 (exhausted row counter) or memory page value for COLRAM handling
;   BC = $384 (COLRAM offset) if memory page transition occurred
;   HL = Final source position after all copying and potential page adjustment
;   DE = Final destination position (16 bytes past start)
;
; Memory Modified: 16 memory locations in 4x4 destination area
; Calls: None (uses LDIR instruction for block copying)
;==============================================================================
COPY_GFX_2_BUFFER:
    LD          A,0x4                               ; Set row counter to 4 (copy 4 rows)
COPY_GFX_2_BUFF_LOOP:
    LD          BC,0x4                              ; Set BC to 4 (copy 4 characters per row)
    LDIR                                            ; Copy 4 bytes from (HL) to (DE), auto-increment both
    DEC         A                                   ; Decrement row counter
    JP          Z,COPY_GFX_2_BUF_MEMCHK             ; If all 4 rows copied, jump to memory page check
    LD          BC,$24                              ; BC = 36 (skip to next row: 40 - 4 = 36)
    ADD         HL,BC                               ; Advance HL to start of next source row
    JP          COPY_GFX_2_BUFF_LOOP                ; Loop back to copy next row
COPY_GFX_2_BUF_MEMCHK:
    LD          A,H                                 ; Load high byte of HL for memory page detection
    CP          $34                                 ; Compare with $34 (COLRAM start page)
    RET         NC                                  ; If HL >= $34xx (in COLRAM range), return
    LD          BC,$384                             ; BC = $384 (offset from CHRRAM to corresponding COLRAM)
    ADD         HL,BC                               ; Adjust HL from CHRRAM ($30xx) to COLRAM ($34xx)
    JP          COPY_GFX_2_BUFFER                   ; Recursive call to copy corresponding COLRAM area

;==============================================================================
; COPY_GFX_FROM_BUFFER
;==============================================================================
; Copies a 4x4 character block from source buffer to destination screen memory.
; Source pointer (HL) remains contiguous while destination (DE) advances through
; screen rows. Inverse of COPY_GFX_2_BUFFER. Includes COLRAM page transition
; detection for the destination pointer.
;
; Registers:
; --- Start ---
;   HL = Source address for 4x4 block (buffer)
;   DE = Destination address for 4x4 block (screen memory)
;   A  = Row counter (will be set to 4)
; --- In Process ---
;   A  = Row counter (4→3→2→1→0)
;   BC = Copy length (4 chars) and row skip offset ($24 = 36)
;   HL = Current source position (auto-increments contiguously via LDIR)
;   DE = Current destination position advancing through screen rows
;   D  = Used for destination memory page detection ($30-$33 vs $34+)
; ---  End  ---
;   A  = Final row counter value or memory page value
;   BC = $384 (COLRAM offset) if destination page transition occurred
;   HL = Final source position (16 bytes past start)
;   DE = Final destination position after copying and potential page adjustment
;
; Memory Modified: 16 memory locations in 4x4 destination area
; Calls: None (uses LDIR instruction for block copying)
;==============================================================================
COPY_GFX_FROM_BUFFER:
    LD          A,0x4                               ; Set row counter to 4 (copy 4 rows)
COPY_GFX_FROM_BUFF_LOOP:
    LD          BC,0x4                              ; Set BC to 4 (copy 4 characters per row)
    LDIR                                            ; Copy 4 bytes from (HL) to (DE), auto-increment both
    DEC         A                                   ; Decrement row counter
    JP          Z,COPY_GFX_FROM_BUFF_MEMCHK         ; If all 4 rows copied, jump to memory page check
    EX          DE,HL                               ; Swap HL and DE for destination pointer advancement
    LD          BC,$24                              ; BC = 36 (skip to next row: 40 - 4 = 36)
    ADD         HL,BC                               ; Advance destination pointer to next row
    EX          DE,HL                               ; Restore HL as source, DE as destination
    JP          COPY_GFX_FROM_BUFF_LOOP             ; Loop back to copy next row
COPY_GFX_FROM_BUFF_MEMCHK:
    LD          A,D                                 ; Load high byte of DE for destination memory page detection
    CP          $34                                 ; Compare with $34 (COLRAM start page)
    RET         NC                                  ; If DE >= $34xx (in COLRAM range), return
    LD          BC,$384                             ; BC = $384 (offset from CHRRAM to corresponding COLRAM)
    EX          DE,HL                               ; Swap to adjust destination pointer
    ADD         HL,BC                               ; Adjust DE from CHRRAM ($30xx) to COLRAM ($34xx)
    EX          DE,HL                               ; Restore HL as source, DE as adjusted destination
    JP          COPY_GFX_FROM_BUFFER                ; Recursive call to copy corresponding COLRAM area

;==============================================================================
; COPY_GFX_SCRN_2_SCRN  
;==============================================================================
; Copies a 4x4 character block from source to destination with synchronized
; row advancement for both pointers. Both source and destination advance by
; the row stride, and both are checked for COLRAM page transitions. This
; function handles cases where both source and destination areas need to
; maintain proper screen memory alignment.
;
; Registers:
; --- Start ---
;   HL = Source address for 4x4 block
;   DE = Destination address for 4x4 block
;   A  = Row counter (will be set to 4)
; --- In Process ---
;   A  = Row counter (4→3→2→1→0)  
;   BC = Copy length (4 chars) and row skip offset ($24 = 36)
;   HL = Current source position advancing through 4x4 area
;   DE = Current destination position advancing through 4x4 area
;   H  = Used for source memory page detection ($30-$33 vs $34+)
; ---  End  ---
;   A  = Final row counter or memory page value
;   BC = $384 (COLRAM offset) if page transitions occurred
;   HL = Final source position after copying and potential page adjustment
;   DE = Final destination position after copying and potential page adjustment
;
; Memory Modified: 16 memory locations in 4x4 destination area
; Calls: None (uses LDIR instruction for block copying)
;==============================================================================
COPY_GFX_SCRN_2_SCRN:
    LD          A,0x4                               ; Set row counter to 4 (copy 4 rows)
COPY_GFX_SCRN_2_SCRN_LOOP:
    LD          BC,0x4                              ; Set BC to 4 (copy 4 characters per row)
    LDIR                                            ; Copy 4 bytes from (HL) to (DE), auto-increment both
    DEC         A                                   ; Decrement row counter  
    JP          Z,COPY_GFX_SCRN_2_SCRN_MEMCHK       ; If all 4 rows copied, jump to memory page check
    LD          BC,$24                              ; BC = 36 (skip to next row: 40 - 4 = 36)
    ADD         HL,BC                               ; Advance source pointer to next row
    EX          DE,HL                               ; Swap to advance destination pointer
    ADD         HL,BC                               ; Advance destination pointer to next row
    EX          DE,HL                               ; Restore HL as source, DE as destination
    JP          COPY_GFX_SCRN_2_SCRN_LOOP           ; Loop back to copy next row
COPY_GFX_SCRN_2_SCRN_MEMCHK:
    LD          A,H                                 ; Load high byte of HL for source memory page detection
    CP          $34                                 ; Compare with $34 (COLRAM start page)
    RET         NC                                  ; If HL >= $34xx (in COLRAM range), return
    LD          BC,$384                             ; BC = $384 (offset from CHRRAM to corresponding COLRAM)
    ADD         HL,BC                               ; Adjust source from CHRRAM ($30xx) to COLRAM ($34xx)
    EX          DE,HL                               ; Swap to adjust destination pointer
    ADD         HL,BC                               ; Adjust destination from CHRRAM ($30xx) to COLRAM ($34xx)
    EX          DE,HL                               ; Restore HL as source, DE as destination
    JP          COPY_GFX_SCRN_2_SCRN                ; Recursive call to copy corresponding COLRAM areas

;==============================================================================
; RHA_REDRAW - Redraw Ring/Helmet/Armor icons and return to input
;==============================================================================
; Updates the color attributes for all three equipment icons (Ring, Helmet,
; Armor) based on their current inventory levels, then returns to the input
; debounce loop. Typically called after equipment changes.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A = Modified by CHECK_* routines
; ---  End  ---
;   Control transfers to INPUT_DEBOUNCE (no return)
;
; Memory Modified: COLRAM_RING_IDX, COLRAM_HELMET_IDX, COLRAM_ARMOR_IDX
; Calls: CHECK_RING, CHECK_HELMET, CHECK_ARMOR, INPUT_DEBOUNCE
;==============================================================================
RHA_REDRAW:
    CALL        CHECK_RING                          ; Update ring icon color
    CALL        CHECK_HELMET                        ; Update helmet icon color
    CALL        CHECK_ARMOR                         ; Update armor icon color
    JP          INPUT_DEBOUNCE                      ; Return to input loop

;==============================================================================
; CHECK_RING - Update ring icon color based on inventory level
;==============================================================================
; Reads the ring inventory slot level, converts it to a color value using
; LEVEL_TO_COLRAM_FIX, and updates the ring icon color in COLRAM. Preserves
; the A register across the operation.
;
; Registers:
; --- Start ---
;   A = Preserved (pushed/popped)
; --- In Process ---
;   A = RING_INV_SLOT value, then color value from LEVEL_TO_COLRAM_FIX
; ---  End  ---
;   A = Original value (restored)
;
; Memory Modified: COLRAM_RING_IDX
; Calls: LEVEL_TO_COLRAM_FIX
;==============================================================================
CHECK_RING:
    PUSH        AF                                  ; Preserve A register
    LD          A,(RING_INV_SLOT)                   ; A = ring level (0-3)
    CALL        LEVEL_TO_COLRAM_FIX                 ; Convert level to color value
    LD          (COLRAM_RING_IDX),A                 ; Update ring icon color
    POP         AF                                  ; Restore A register
    RET                                             ; Return to caller

;==============================================================================
; CHECK_HELMET - Update helmet icon color based on inventory level
;==============================================================================
; Reads the helmet inventory slot level, converts it to a color value using
; LEVEL_TO_COLRAM_FIX, and updates the helmet icon color in COLRAM. Preserves
; the A register across the operation. Mirrors CHECK_RING logic for helmet.
;
; Registers:
; --- Start ---
;   A = Preserved (pushed/popped)
; --- In Process ---
;   A = HELMET_INV_SLOT value, then color value from LEVEL_TO_COLRAM_FIX
; ---  End  ---
;   A = Original value (restored)
;
; Memory Modified: COLRAM_HELMET_IDX
; Calls: LEVEL_TO_COLRAM_FIX
;==============================================================================
CHECK_HELMET:
    PUSH        AF                                  ; Preserve A register
    LD          A,(HELMET_INV_SLOT)                 ; A = helmet level (0-3)
    CALL        LEVEL_TO_COLRAM_FIX                 ; Convert level to color value
    LD          (COLRAM_HELMET_IDX),A               ; Update helmet icon color
    POP         AF                                  ; Restore A register
    RET                                             ; Return to caller

;==============================================================================
; CHECK_ARMOR - Update armor icon color based on inventory level
;==============================================================================
; Reads the armor inventory slot level, converts it to a color value using
; LEVEL_TO_COLRAM_FIX, and updates the armor icon color in COLRAM. Preserves
; the A register across the operation.
;
; Registers:
; --- Start ---
;   A = Preserved (pushed/popped)
; --- In Process ---
;   A = ARMOR_INV_SLOT value, then color value from LEVEL_TO_COLRAM_FIX
; ---  End  ---
;   A = Original value (restored)
;
; Memory Modified: COLRAM_ARMOR_IDX
; Calls: LEVEL_TO_COLRAM_FIX
;==============================================================================
CHECK_ARMOR:
    PUSH        AF                                  ; Preserve A register
    LD          A,(ARMOR_INV_SLOT)                  ; A = armor level (0-3)
    CALL        LEVEL_TO_COLRAM_FIX                 ; Convert level to color value
    LD          (COLRAM_ARMOR_IDX),A                ; Update armor icon color
    POP         AF                                  ; Restore A register
    RET                                             ; Return to caller

;==============================================================================
; LEVEL_TO_COLRAM_FIX - Convert equipment level to color attribute value
;==============================================================================
; Converts an equipment level (0-3) to a COLRAM color attribute value using
; the formula: ((level * 2) - 1) * 16. This maps levels to color palette
; indices: 0→$F0 (wraps from -16), 1→$10, 2→$30, 3→$50. Uses RRCA rotation
; to efficiently shift the value into the upper nybble (multiply by 16).
;
; Registers:
; --- Start ---
;   A = Level (0-3)
; --- In Process ---
;   A = Intermediate calculations, rotated values
; ---  End  ---
;   A = Color value (palette index * 16, lower nybble cleared)
;
; Memory Modified: None
; Calls: None
;==============================================================================
LEVEL_TO_COLRAM_FIX:
    ADD         A,A                                 ; A = level * 2
    DEC         A                                   ; A = (level * 2) - 1
    RRCA                                            ; Rotate right (shift to upper nybble)
    RRCA                                            ; Rotate right
    RRCA                                            ; Rotate right
    RRCA                                            ; Rotate right (total: * 16)
    AND         $F0                                 ; Mask lower nybble (clean result)
    RET                                             ; Return color value in A

;==============================================================================
; VP_LH_GAP_REDRAW - Redraw Viewport Left Hand Filler
;==============================================================================
; Draws the ornaments to the right of the left hand item in the viewport
;
;==============================================================================
VP_LH_GAP_REDRAW:
    LD          DE,VP_LH_GAP                        ; DE = viewport left hand gap graphic
    LD          HL,CHRRAM_VP_LH_GAP_IDX             ; HL = Viewport Left hand gap index
    LD          B,COLOR(DKGRY,BLK)                  ; BLK on DKGRY
    JP          GFX_DRAW                            ; Draw filler

;==============================================================================
; VP_RH_GAP_REDRAW - Redraw Viewport Right Hand Filler
;==============================================================================
; Draws the ornaments to the right of the right hand item in the viewport
;
;==============================================================================
VP_RH_GAP_REDRAW:
    LD          DE,VP_RH_GAP                        ; DE = viewport left hand gap graphic
    LD          HL,CHRRAM_VP_RH_GAP_IDX             ; HL = Viewport Left hand gap index
    LD          B,COLOR(DKGRY,BLK)                  ; DKGRY on BLK
    JP          GFX_DRAW                            ; Draw filler

;==============================================================================
; PLAY_TELEPORT_SOUND - Play descending teleport sound effect
;==============================================================================
; Plays a four-tone descending sound sequence to indicate teleportation.
; Each tone is played at progressively lower frequency (higher BC value)
; for a short duration (DE=$18).
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   BC = Duration values ($220, $110, $88, $44)
;   DE = Pitch value ($18 for all tones)
;   All registers modified by PLAY_SOUND_LOOP
; ---  End  ---
;   All registers modified
;
; Memory Modified: None
; Calls: PLAY_SOUND_LOOP (4 times)
;==============================================================================
PLAY_TELEPORT_SOUND:
    LD          BC,$220                             ; BC = duration for first tone
    LD          DE,$18                              ; DE = pitch/frequency
    CALL        PLAY_SOUND_LOOP                     ; Play first (highest) tone
    LD          BC,$110                             ; BC = duration for second tone
    LD          DE,$18                              ; DE = pitch/frequency
    CALL        PLAY_SOUND_LOOP                     ; Play second tone
    LD          BC,$88                              ; BC = duration for third tone
    LD          DE,$18                              ; DE = pitch/frequency
    CALL        PLAY_SOUND_LOOP                     ; Play third tone
    LD          BC,$44                              ; BC = duration for fourth tone
    LD          DE,$18                              ; DE = pitch/frequency
    CALL        PLAY_SOUND_LOOP                     ; Play fourth (lowest) tone
    RET                                             ; Return to caller

;==============================================================================
; PLAY_POWER_UP_SOUND - Play ascending power-up sound effect
;==============================================================================
; Plays a four-tone ascending sound sequence to indicate power-up or stat
; maximization. Each tone is played at progressively higher frequency (lower
; BC value). The final tone has extended duration (DE=$60).
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   BC = Duration values ($220, $200, $1e0, $1c0)
;   DE = Pitch values ($18 for first 3, $60 for last)
;   All registers modified by PLAY_SOUND_LOOP
; ---  End  ---
;   All registers modified
;
; Memory Modified: None
; Calls: PLAY_SOUND_LOOP (4 times)
;==============================================================================
PLAY_POWER_UP_SOUND:
    LD          BC,$220                             ; BC = duration for first tone
    LD          DE,$18                              ; DE = pitch/frequency (short)
    CALL        PLAY_SOUND_LOOP                     ; Play first tone
    LD          BC,$200                             ; BC = duration for second tone
    LD          DE,$18                              ; DE = pitch/frequency (short)
    CALL        PLAY_SOUND_LOOP                     ; Play second tone
    LD          BC,$1e0                             ; BC = duration for third tone
    LD          DE,$18                              ; DE = pitch/frequency (short)
    CALL        PLAY_SOUND_LOOP                     ; Play third tone
    LD          BC,$1c0                             ; BC = duration for fourth tone
    LD          DE,$60                              ; DE = pitch/frequency (long final tone)
    CALL        PLAY_SOUND_LOOP                     ; Play fourth tone (extended)
    RET                                             ; Return to caller
