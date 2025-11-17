;==============================================================================
; ASTERION GRAPHICS FUNCTIONS - COMPLETE CORNER FUNCTION SET ANALYSIS
;==============================================================================
; ARCHITECTURAL DISCOVERY: COMPLETE 3X3 CORNER FUNCTION FAMILY
; All functions draw DOWNWARD using ADD HL,DE operations, despite visual pattern names:
;
; COMPLETE CORNER FUNCTION SET:
; - DRAW_DL_3X3_CORNER: Bottom-left corner (start top-left, draw down-left)
; - DRAW_DR_3X3_CORNER: Bottom-right corner (start top-right, draw down-right)  
; - DRAW_UR_3X3_CORNER: Upper-left corner (start top-left, draw down-right)
; - DRAW_UL_3X3_CORNER: Upper-right corner (start top-left, draw down-left)
;
; DE REGISTER USAGE - VARIABLE STRIDE VALUES FOR PRECISION POSITIONING:
; - DE=$27 (40-1): Precision left-aligned positioning
; - DE=$28 (40):   Standard row stride 
; - DE=$26 (40-2): Specialized corner positioning
;
; NOTE: Previously misnamed as "HORIZONTAL_LINE" functions - these create L-shaped
; corner patterns, not simple horizontal lines. Function renaming reveals elegant
; complete corner drawing system with variable stride support for precise graphics.
;==============================================================================

;==============================================================================
; DRAW_DOOR_BOTTOM_SETUP - Set up color for door bottom drawing
;==============================================================================
; PURPOSE: Prepares door bottom color and falls through to
;          DRAW_SINGLE_CHAR_UP to draw door frame elements
; INPUT:   HL = screen position, A = character to draw
; OUTPUT:  DE = door bottom color, character drawn, HL modified
;==============================================================================
DRAW_DOOR_BOTTOM_SETUP:
    LD          DE,COLOR(GRN,DKCYN)					; GRN on DKCYN (door bottom/frame color)
								                    ; (bottom of closed door)

;------------------------------------------------------------------------------
; DRAW_SINGLE_CHAR_UP - Draw single character moving cursor up
;------------------------------------------------------------------------------
; INPUT:  HL = position, A = character, DE = color or row stride
; OUTPUT: HL = position moved up by DE, character drawn
; PATTERN: X    Execution order: 1
; REGISTERS MODIFIED: HL (moved up by DE amount)
;------------------------------------------------------------------------------
DRAW_SINGLE_CHAR_UP:
    LD          (HL),A                              ; Draw character at current position
    SCF                                             ; Set carry flag 
    CCF                                             ; Clear carry flag (prepare for SBC)
    SBC         HL,DE                               ; Move cursor up by DE amount

;------------------------------------------------------------------------------
; DRAW_VERTICAL_LINE_3_UP - Draw 3-character vertical line moving upward
;------------------------------------------------------------------------------
; INPUT:  HL = starting position, A = character, DE = row stride
; OUTPUT: HL = position 3 rows up, 3 characters drawn vertically
; PATTERN: X    Execution order: 3
;          X                     2  
;          X                     1
; REGISTERS MODIFIED: HL (moved up 3 rows)
;------------------------------------------------------------------------------
DRAW_VERTICAL_LINE_3_UP:
    LD          (HL),A                              ; Draw character at current position
    SCF                                             ; Set carry flag
    CCF                                             ; Clear carry flag (prepare for SBC)
    SBC         HL,DE                               ; Move cursor up one row
    LD          (HL),A                              ; Draw character at new position
    SBC         HL,DE                               ; Move cursor up another row
    LD          (HL),A                              ; Draw character at final position
    RET                                             ; Return with cursor 3 rows up

; Dead Code?    
;    LD          DE,COLOR(GRN,DKCYN)					; GRN on DKCYN (door frame setup)
								                    ; (bottom of closed door)

;------------------------------------------------------------------------------
; DRAW_VERTICAL_LINE_4_DOWN - Draw 4-character vertical line moving downward
;------------------------------------------------------------------------------
; INPUT:  HL = starting position, A = character, DE = row stride  
; OUTPUT: HL = position 3 rows down, 4 characters drawn vertically
; PATTERN: X    Execution order: 1
;          X                     2
;          X                     3  
;          X                     4
; REGISTERS MODIFIED: HL (moved down 3 rows)
;------------------------------------------------------------------------------
DRAW_VERTICAL_LINE_4_DOWN:
    LD          (HL),A                              ; Draw character at current position
    ADD         HL,DE                               ; Move cursor down one row
CONTINUE_VERTICAL_LINE_DOWN:
    LD          (HL),A                              ; Draw character at new position
    ADD         HL,DE                               ; Move cursor down another row
    LD          (HL),A                              ; Draw character at next position
    ADD         HL,DE                               ; Move cursor down final row
    LD          (HL),A                              ; Draw character at final position
    RET                                             ; Return with cursor 3 rows down

;------------------------------------------------------------------------------
; DRAW_DL_3X3_CORNER - Draw bottom-left corner fill pattern
;------------------------------------------------------------------------------
; INPUT:  HL = top-left position, A = char/color, DE = row stride (VARIABLE!)
; OUTPUT: HL = bottom-left position of filled area
; 
; DE=$28 (40): Standard DL corner pattern (normal screen row width)
; X . .    Execution order: 1 . .
; X X .                     2 3 . 
; X X X                     6 5 4
;
; NOTE: All corner functions draw downward using ADD HL,DE operations.
; Different DE values enable precise positioning for various screen contexts.
;
; REGISTERS MODIFIED: HL (points to bottom-left when done)
;------------------------------------------------------------------------------
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

;------------------------------------------------------------------------------
; DRAW_DR_3X3_CORNER - Draw bottom-right corner fill pattern
;------------------------------------------------------------------------------
; INPUT:  HL = top-right position, A = char/color, DE = row stride (VARIABLE!)  
; OUTPUT: HL = bottom-left position of filled area
; 
; DE=$28 (40): Standard DR corner pattern (normal screen row width)
; . . X . .    Execution order: . . 1 . .  
; . X X . .                     . 3 2 . .    
; X X X . .                     6 5 4 . .    
;
; DE=$26 (38): Creates STRONG LEFT-SHIFT pattern (stride -2) - RARELY USED
; . . . . . . X . .    Execution order: . . . . . . 1 . .
; . . . . 3 2 . . .                     . . . . 3 2 . . .
; 6 5 4 . . . . . .                     6 5 4 . . . . . .
; (Note: This pattern exists in code but may not be visually rendered in normal gameplay)
;
; NOTE: All corner functions draw downward using ADD HL,DE operations.
; Different DE values enable creating multiple pattern variants from same function.
;
; REGISTERS MODIFIED: HL (points to bottom-left when done)
;------------------------------------------------------------------------------
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

;------------------------------------------------------------------------------
; DRAW_UL_3X3_CORNER - Draw upper-left corner fill pattern
;------------------------------------------------------------------------------
; INPUT:  HL = top-left starting position, A = character, DE = row stride (VARIABLE!)
; OUTPUT: HL = final position after drawing pattern
; PATTERN: X X X    Execution order: 1 2 3
;          X X .                     5 4 .
;          X . .                     6 . .
; 
; Creates upper-leftt corner pattern by starting at top-left and drawing:
; 1. Full horizontal line (3 chars right)
; 2. Moving DOWN one row, draw 2 chars from center-left  
; 3. Moving DOWN another row, draw 1 char at left
;
; NOTE: This draws DOWNWARD despite creating "upper" corner visual pattern.
; Part of complete corner function set with variable DE stride support.
;
; REGISTERS MODIFIED: HL (moved to final drawn position)
;------------------------------------------------------------------------------
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

;------------------------------------------------------------------------------
; DRAW_UR_3X3_CORNER - Draw upper-right corner fill pattern
;------------------------------------------------------------------------------
; INPUT:  HL = top-left starting position, A = character, DE = row stride (VARIABLE!)
; OUTPUT: HL = final position after drawing pattern  
; PATTERN: X X X    Execution order: 1 2 3
;          . X X                     . 4 5
;          . . X                     . . 6
;
; Creates upper-left corner pattern by starting at top-left and drawing:
; 1. Full horizontal line (3 chars right)
; 2. Moving DOWN one row, draw 2 chars from center-right
; 3. Moving DOWN another row, draw 1 char at right
;
; NOTE: This draws DOWNWARD despite creating "upper" corner visual pattern.
; Part of complete corner function set with variable DE stride support.
;
; REGISTERS MODIFIED: HL (moved to final drawn position)
;------------------------------------------------------------------------------
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

;------------------------------------------------------------------------------
; DRAW_ROW - Fill single row with byte value (helper for FILL_CHRCOL_RECT)
;------------------------------------------------------------------------------
; INPUT:  HL = starting position, B = width, A = fill value
; OUTPUT: HL = position after last byte, B = 0, A = unchanged
; PATTERN: Horizontal line (width B)
; X X ... X    Execution order: 1 2 ... B
; REGISTERS MODIFIED: HL (advanced by B positions), B (decremented to 0)
;------------------------------------------------------------------------------
DRAW_ROW:
    LD          (HL),A                              ; Write character/color to current position
    DEC         B                                   ; Decrement remaining width
    RET         Z                                   ; Return if row completed
    INC         HL                                  ; Move to next position in row
    JP          DRAW_ROW                            ; Continue filling row

;------------------------------------------------------------------------------
; DRAW_COLUMN - Fill single column with byte value (vertical line drawing)
;------------------------------------------------------------------------------
; INPUT:  HL = starting position, C = height, A = fill value, DE = $28 (row stride)
; OUTPUT: HL = position after last byte, C = 0, A = unchanged
; PATTERN: Vertical line (height C)
; X    Execution order: 1
; X                     2
; .                     .
; .                     .
; X                     C
; REGISTERS MODIFIED: HL (advanced by C*DE positions), C (decremented to 0)
;------------------------------------------------------------------------------
DRAW_COLUMN:
    LD          (HL),A                              ; Write character/color to current position
    DEC         C                                   ; Decrement remaining height
    RET         Z                                   ; Return if column completed
    ADD         HL,DE								; Move to next row (+40 characters down)
    JP          DRAW_COLUMN                         ; Continue filling column vertically

;==============================================================================
; FILL_CHRCOL_RECT - Fill rectangular area with character or color data
;==============================================================================
; PURPOSE: Fills a rectangular region of CHRRAM or COLRAM with a single byte value.
;          Used for drawing walls, doors, backgrounds, and UI elements by writing
;          the same character or color to multiple screen positions in a rectangle.
;
; INPUT:   HL = starting memory address (CHRRAM $3000+ or COLRAM $3400+)
;          BC = rectangle dimensions (B=width in characters, C=height in rows)
;          A  = byte value to fill (character code for CHRRAM, color for COLRAM)
;
; PROCESS: 1. Set row stride to 40 (screen width in characters)
;          2. For each row: fill B positions with value A
;          3. Move to next row (+40 characters) and repeat
;          4. Continue until C rows completed
;
; OUTPUT:  Rectangle filled with specified byte, HL points past last written byte
;
; REGISTERS MODIFIED:
;   INPUT:  HL (start address), BC (dimensions), A (fill value)
;   DURING: DE (row stride=$28), HL (current position), BC (counters), A (preserved)
;   OUTPUT: HL (end position), BC (both zero), DE ($28), A (unchanged)
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

DRAW_F0_WALL:
; OLD STUFF
    LD          HL,COLRAM_F0_WALL_IDX               ; Point to far wall color area
    LD          BC,RECT(16,15)						; 16 x 16 rectangle
    LD          A,COLOR(BLU,BLU)					; BLU on BLU (solid blue wall)
    CALL        FILL_CHRCOL_RECT                    ; Fill wall area with blue color (WAS JP)
; NEW STUFF
    LD          HL,COLRAM_F0_WALL_IDX + 2 + (40 * 15)
    LD          B,12
    JP          DRAW_ROW

DRAW_F0_WALL_AND_CLOSED_DOOR:
    CALL        DRAW_F0_WALL                        ; Draw the wall background first
    LD          A,COLOR(GRN,GRN)					; GRN on GRN (closed door color)

DRAW_DOOR_F0:
    LD          HL,COLRAM_F0_DOOR_IDX               ; Point to door area within wall
    LD          BC,RECT(8,12)						; 8 x 12 rectangle (door size)
    JP          FILL_CHRCOL_RECT                    ; Fill door area with specified color

DRAW_WALL_F0_AND_OPEN_DOOR:
    CALL        DRAW_F0_WALL                        ; Draw the wall background first
    LD          A,COLOR(DKGRY,BLK)					; DKGRY on BLK (open door/passage color)
    JP          DRAW_DOOR_F0                        ; Fill door area showing passage through

DRAW_WALL_F1:
    LD          HL,CHRRAM_F1_WALL_IDX               ; Point to F1 wall character area
    LD          BC,RECT(8,8)						; 8 x 8 rectangle (mid-distance wall size)
    LD          A,$20								; SPACE character (clear wall area)
    CALL        FILL_CHRCOL_RECT                    ; Clear wall character area with spaces
    LD          C,0x8                               ; Set height for color fill operation
    LD          HL,COLRAM_F0_DOOR_IDX               ; Point to corresponding color area
    LD          A,COLOR(BLU,DKBLU)					; BLU on DKBLU (wall color scheme)
    JP          DRAW_CHRCOLS                        ; Fill color area for wall

DRAW_WALL_F1_AND_CLOSED_DOOR:
    CALL        DRAW_WALL_F1                        ; Draw the F1 wall background first
    LD          A,COLOR(GRN,DKGRN)					; GRN on DKGRN (closed door at F1 distance)

DRAW_DOOR_F1:
    LD          HL,COLRAM_F1_DOOR_IDX               ; Point to door area within F1 wall
    LD          BC,RECT(4,6)						; 4 x 6 rectangle (smaller door at mid-distance)
    JP          FILL_CHRCOL_RECT                    ; Fill door area with specified color

DRAW_WALL_F1_AND_OPEN_DOOR:
    CALL        DRAW_WALL_F1
    LD          A,COLOR(BLK,BLK)					; BLK on BLK
    JP          DRAW_DOOR_F1

DRAW_WALL_F2:
    LD          BC,RECT(4,4)						; 4 x 4 rectangle
    LD          HL,COLRAM_F2_WALL_IDX
    LD          A,COLOR(BLK,DKGRY)				    ; BLK on DKGRY
    CALL        FILL_CHRCOL_RECT                    ; Was JP FILL_CHRCOL_RECT
    LD          HL,$323a						    ; Bottom-left CHARRAM IDX of F2
    LD          BC,RECT(4,1)						; 4 x 1 rectangle
    LD          A,$90								; Thin base line char
    JP          FILL_CHRCOL_RECT

DRAW_WALL_F2_EMPTY:
    LD          HL,COLRAM_F2_WALL_IDX
    LD          A,COLOR(BLK,BLK)					; BLK on BLK

UPDATE_F0_ITEM:
    LD          BC,RECT(4,4)						; 4 x 4 rectangle
    JP          FILL_CHRCOL_RECT

DRAW_WALL_L0:
    LD          HL,COLRAM_L0_WALL_IDX
    LD          A,COLOR(BLU,BLK)					; BLU on BLK
    CALL        DRAW_DOOR_BOTTOM_SETUP
    DEC         DE                                  ; Decrease stride to 40
    ADD         HL,DE                               ; Go to next row
    LD          A,COLOR(BLK,BLU)    				; BLK on BLU
    CALL        DRAW_DL_3X3_CORNER                  ; Draw door top blocks
    ADD         HL,DE                               ; Go to next row
    LD          BC,RECT(4,15)						; 4 x 15 rectangle (was 16)
    CALL        DRAW_CHRCOLS
    ; ADD         HL,DE                               ; Go to next row
    ; CALL        DRAW_UL_3X3_CORNER                  ; Draw door bottom blocks
    ; ADD         HL,DE                               ; Go to next row
    ; LD          A,COLOR(DKGRY,BLU)					; DKGRY on BLU
    DEC         DE                                  ; Decrease stride to 39
    ; CALL        DRAW_SINGLE_CHAR_UP                 ; Draw bottom of wall colors
    ; LD          A,CHAR_RT_ANGLE                     ;
    ; LD          HL,DAT_ram_33c0                     ; Move to CHRRAM LO wall bottom IDX
    ; CALL        DRAW_SINGLE_CHAR_UP                 ; Draw bottom of wall chars
    LD          HL,CHRRAM_L0_WALL_IDX
    LD          A,CHAR_LT_ANGLE
    INC         DE                                  ; Increase stride to 40
    INC         DE                                  ; Increase stride to 41
    JP          DRAW_VERTICAL_LINE_4_DOWN           ; Draw door top chars
    RET
DRAW_DOOR_L0_HIDDEN:
    CALL        DRAW_WALL_L0
    LD          A,COLOR(DKGRY,BLK)					; DKGRY on BLK
    EX          AF,AF'
    LD          A,COLOR(BLK,BLU)					; BLK on BLU
    JP          DRAW_DOOR_L0
DRAW_DOOR_L0_NORMAL:
    CALL        DRAW_WALL_L0
    LD          A,COLOR(DKGRY,GRN)					; DKGRY on GRN
    EX          AF,AF'
    LD          A,COLOR(GRN,BLU)					; GRN on BLU

DRAW_DOOR_L0:
    LD          HL,COLRAM_L0_DOOR_IDX
    CALL        DRAW_VERTICAL_LINE_3_UP             ; Stride is 41
    DEC         DE                                  ; Decrease stride to 40
    ADD         HL,DE                               ; Go to next row
    EX          AF,AF'                              ; Get proper door color
    CALL        DRAW_DL_3X3_CORNER                  ; Draw top of door color blocks
    ADD         HL,DE                               ; Go to next row
    LD          BC,RECT(3,11)                       ; 3 x 11 rectangle (was 12)
    CALL        DRAW_CHRCOLS
    ; ADD         HL,DE                               ; Go to next row
    ; CALL        DRAW_UL_3X3_CORNER                  ; Draw bottom of door color blocks
    ; ADD         HL,DE                               ; Go to next row
    DEC         DE                                  ; Decrease stride to 39
    ; CALL        DRAW_VERTICAL_LINE_3_UP           ; Draw bottom of door colors
    LD          HL,CHRRAM_L0_DOOR_IDX
    LD          A,CHAR_LT_ANGLE
    INC         DE                                  ; Increase stride to 40
    INC         DE                                  ; Increase stride to 41
    JP          CONTINUE_VERTICAL_LINE_DOWN         ; Draw top of door characters
    RET

DRAW_WALL_FL0:
    LD          HL,DAT_ram_34c8
    LD          A,COLOR(BLK,BLU)					; BLK on BLU
    LD          BC,RECT(4,15)						; 4 x 15 rectangle (was 16)
    JP          FILL_CHRCOL_RECT

DRAW_WALL_L1:
    LD          HL,CHRRAM_L1_WALL_IDX
    LD          BC,RECT(4,8)						; 4 x 8 rectangle
    LD          A,$20								; Change to SPACE 32 / $20
    CALL        FILL_CHRCOL_RECT
    LD          HL,COLRAM_L1_WALL_IDX
    LD          C,0x8
    LD          A,COLOR(BLU,DKBLU)					; BLU on DKBLU
    JP          DRAW_CHRCOLS
DRAW_DOOR_L1_NORMAL:
    CALL        DRAW_WALL_L1
    LD          A,COLOR(DKGRN,DKGRN)				; DKGRN on DKGRN
DRAW_DOOR_L1:
    LD          HL,COLRAM_L1_DOOR_PATTERN_IDX
    LD          BC,RECT(2,6)						; 2 x 6 rectangle
    JP          DRAW_CHRCOLS
DRAW_DOOR_L1_HIDDEN:
    CALL        DRAW_WALL_L1
    XOR         A
    JP          DRAW_DOOR_L1
SUB_ram_c9f9:
    LD          HL,CHRRAM_L1_WALL_IDX
    LD          A,CHAR_LT_ANGLE                     ; Left angle char
    LD          (HL),A
    LD          DE,$28                              ; Set stride to 40
    ADD         HL,DE                               ; Go to next row
    INC         HL                                  ; Go to next cell
    LD          (HL),A
    LD          HL,DAT_ram_3259                     ; Draw top of wall characters
    LD          A,CHAR_RT_ANGLE                     ; Right angle char
    LD          (HL),A
    ADD         HL,DE
    DEC         HL                                  ; Set stride to 39
    LD          (HL),A
    LD          HL,COLRAM_L1_WALL_IDX
    LD          A,COLOR(DKBLU,DKGRY)				; DKBLU on DKGRY
    LD          (HL),A
    ADD         HL,DE                               ; Go to next row
    INC         HL                                  ; Go to next cell
    LD          (HL),A
    DEC         HL                                  ; Go to previous cell
    LD          A,COLOR(BLK,DKGRY)					; BLK on DKGRY
    LD          (HL),A
    LD          BC,RECT(2,4)						; 2 x 4 rectangle
    ADD         HL,DE                               ; Go to next row
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    LD          (HL),A
    INC         HL
    LD          A,COLOR(BLK,DKGRY)					; BLK on DKGRY
    LD          (HL),A
    ADD         HL,DE
    DEC         HL
    LD          (HL),A
    LD          HL,COLRAM_L1_DOOR_PATTERN_IDX
    LD          C,0x4
    LD          A,COLOR(BLK,BLK)
    JP          DRAW_CHRCOLS                        ; DRAW

DRAW_WALL_FL22:
    LD          HL,COLRAM_FL22_WALL_IDX
    LD          BC,RECT(4,4)						; 4 x 4 rectangle
    LD          A,COLOR(DKGRY,DKGRY)				; DKGRY on DKGRY
    JP          FILL_CHRCOL_RECT
DRAW_L1_WALL:
    LD          HL,CHRRAM_FL1_WALL_IDX
    LD          A,CHAR_LT_ANGLE						; LEFT angle CHR
    CALL        DRAW_DOOR_BOTTOM_SETUP
    DEC         DE                                  ; Decrease stride to 40
    ADD         HL,DE                               ; Go to next row
    LD          A,$20								; Change to SPACE 32 / $20
    CALL        DRAW_DL_3X3_CORNER                  ; Draw upper wall char blocks
    ADD         HL,DE                               ; Go to next row
    LD          BC,RECT(4,8)						; 4 x 8 rectangle
    CALL        DRAW_CHRCOLS
    ADD         HL,DE                               ; Go to next row
    CALL        DRAW_UL_3X3_CORNER                  ; Draw bottom wall char blocks
    ; ADD         HL,DE                               ; Go to next row
    INC         HL                                  ; NEW
    LD          A,CHAR_RT_ANGLE						; RIGHT angle CHR
    DEC         DE                                  ; Decrease stride to 39
    ; CALL        DRAW_SINGLE_CHAR_UP
    CALL        DRAW_VERTICAL_LINE_3_UP             ; Draw bottom wall char block

    LD          HL,DAT_ram_3547
    LD          A,COLOR(DKBLU,BLK)					; DKBLU on BLK
    CALL        DRAW_DOOR_BOTTOM_SETUP
    DEC         DE                                  ; Decrease stride to 40
    ADD         HL,DE                               ; Go to next row
    LD          A,COLOR(BLU,DKBLU)					; BLU on DKBLU
    CALL        DRAW_DL_3X3_CORNER                  ; Draw upper wall color blocks
    ADD         HL,DE                               ; Go to next row
    LD          BC,RECT(4,8)						; 4 x 8 rectangle
    CALL        DRAW_CHRCOLS
    ADD         HL,DE                               ; Go to next row
    CALL        DRAW_UL_3X3_CORNER                  ; Draw bottom wall color blocks
    ; ADD         HL,DE                               ; Go to next row
    INC         HL                                  ; NEW
    LD          A,COLOR(DKGRY,DKBLU)   			    ; DKGRY on DKBLU
    DEC         DE                                  ; Decrease stride to 39
    ; JP          DRAW_SINGLE_CHAR_UP                 ; Draw bottom wall color blocks
    JP          DRAW_VERTICAL_LINE_3_UP             ; Draw bottom wall color blocks
    RET
DRAW_FL1_DOOR:
    CALL        DRAW_L1_WALL
    LD          A,COLOR(DKGRY,BLK)					; DKGRY on BLK
    PUSH        AF
    LD          A,COLOR(DKBLU,BLK)					; DKBLU on BLK
    PUSH        AF
    LD          A,COLOR(BLK,DKBLU)  				; BLK on DKGRY
    JP          DRAW_L1_DOOR
DRAW_L1:
    CALL        DRAW_L1_WALL
    LD          A,COLOR(DKGRY,DKGRN)				; DKGRY on DKGRN
    PUSH        AF
    LD          A,COLOR(GRN,DKGRN)					; GRN on DKGRN
    PUSH        AF
    LD          A,COLOR(DKGRN,DKBLU)				; DKGRN on DKBLU
DRAW_L1_DOOR:
    LD          HL,COLRAM_L1_DOOR_IDX
    LD          BC,RECT(2,7)						; 2 x 7 rectangle
    CALL        SUB_ram_cb1c
    LD          HL,CHRRAM_L1_DOOR_IDX
    LD          A,CHAR_LT_ANGLE						; LEFT ANGLE CHR
    LD          (HL),A
    LD          DE,$29                              ; Set stride to 41
    ADD         HL,DE                               ; Go to next row
    LD          (HL),A
    RET
SUB_ram_cab0:
    LD          HL,DAT_ram_356c
    LD          BC,RECT(4,8)						; 4 x 8 rectangle
    LD          A,COLOR(BLU,DKBLU)					; BLU on DKBLU
    CALL        FILL_CHRCOL_RECT
    LD          HL,DAT_ram_316c
    LD          C,0x8
    LD          A,$20								; Change to SPACE 32 / $20
    JP          DRAW_CHRCOLS
SUB_ram_cac5:
    CALL        SUB_ram_cab0
    XOR         A
    JP          DRAW_L1_DOOR_2
DRAW_L1_DOOR_CLOSED:
    CALL        SUB_ram_cab0
    LD          A,COLOR(DKGRN,DKGRN)				; DKGRN on DKGRN
DRAW_L1_DOOR_2:
    LD          HL,COLRAM_FL2_WALL_IDX
    LD          BC,RECT(2,6)						; 2 x 6 rectangle
    JP          DRAW_CHRCOLS

DRAW_WALL_FL2_EMPTY:
    LD          HL,COLRAM_FL2_WALL_IDX
    LD          BC,RECT(4,4)						; 4 x 4 rectangle
    LD          A,COLOR(BLK,BLK)					; BLK on BLK
    JP          FILL_CHRCOL_RECT
DRAW_WALL_L2:
    LD          A,$ca								; Right slash char
    PUSH        AF
    LD          A,$20								; SPACE char
    PUSH        AF
    LD          HL,CHRRAM_F1_WALL_IDX
    LD          A,CHAR_LT_ANGLE						; Left angle char
    LD          BC,RECT(2,4)						; 2 x 4 rectangle
    CALL        SUB_ram_cb1c
    LD          A,COLOR(BLK,DKGRY)					; BLK on CKGRY
    PUSH        AF
    LD          A,COLOR(BLK,DKGRY)					; BLK on CKGRY
    PUSH        AF
    LD          HL,COLRAM_F0_DOOR_IDX
    LD          A,COLOR(DKGRY,BLK)					; DKGRY on BLK
    LD          BC,RECT(2,4)						; 2 x 4 rectangle
    CALL        SUB_ram_cb1c
    RET
SUB_ram_cb1c:
    POP         IX
    LD          (HL),A
    LD          DE,$29								; Diagonal DR step
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
DRAW_WALL_L2_LEFT:
    LD          HL,COLRAM_L2_LEFT
    LD          BC,RECT(2,4)						; 2 x 4 rectangle
    LD          A,COLOR(BLK,DKGRY)					; BLK on DKGRY
    CALL        FILL_CHRCOL_RECT
    LD          HL,$3238
    LD          BC,RECT(2,1)
    LD          A,CHAR_BOTTOM_LINE
    JP          FILL_CHRCOL_RECT
DRAW_WALL_L2_LEFT_EMPTY:
    LD          HL,COLRAM_L2_LEFT
    LD          BC,RECT(2,4)    					; 2 x 4 rectangle
    LD          A,COLOR(BLK,BLK)					; BLK on BLK
    JP          FILL_CHRCOL_RECT
DRAW_WALL_R0:
    LD          A,COLOR(DKGRY,BLU)					; DKGRY on BLU
    PUSH        AF
    LD          BC,RECT(4,15)                       ; 4 x 15 rectangle (was 16)
    LD          A,COLOR(BLK,BLU)					; BLK on BLU
    PUSH        AF
    LD          A,COLOR(BLU,BLK)					; BLU on BLK
    LD          HL,DAT_ram_34b4
    CALL        DRAW_R0_CORNERS                     ; Do corner fills
    LD          HL,DAT_ram_303f                     ; Top right corner of R0
    LD          A,CHAR_RT_ANGLE						; Right angle char
    LD          DE,$27                              ; Pitch to 39 / $27
    CALL        DRAW_VERTICAL_LINE_4_DOWN           ; Draw top of RO wall

; Old bottom of wall stuff
    ; LD          HL,DAT_ram_335c
    INC         A                                   ; Increment A to CHAR_LT_ANGLE ($c1)
    INC         DE                                  ; Increment pitch to 40 / $28
    INC         DE                                  ; Increment pitch to 41 / $29
    ; JP          DRAW_VERTICAL_LINE_4_DOWN           ; Draw bottom of R0 wall
    RET
DRAW_R0_DOOR_HIDDEN:
    CALL        DRAW_WALL_R0
    LD          A,COLOR(DKGRY,BLK)					; DKGRY on BLK
    EX          AF,AF'
    LD          A,COLOR(BLK,BLU)					; BLK on BLU
    JP          DRAW_R0_DOOR
DRAW_R0_DOOR_NORMAL:
    CALL        DRAW_WALL_R0
    LD          A,COLOR(DKGRY,GRN)					; DKGRY on GRN
    EX          AF,AF'
    LD          A,COLOR(GRN,BLU)					; GRN on BLU
DRAW_R0_DOOR:
    LD          HL,DAT_ram_352d                     ; RO door top left COLRAM IDX
    DEC         DE                                  ; Decrement pitch to 40
    DEC         DE                                  ; Decrement pitch to 39
    CALL        DRAW_VERTICAL_LINE_3_UP
    INC         DE                                  ; Increment pitch to 40
    ADD         HL,DE                               ; Move down a row
    EX          AF,AF'                              ; Get correct door colors
    CALL        DRAW_DR_3X3_CORNER                  ; Draw top door blocks
    ADD         HL,DE                               ; Move down a row
    LD          BC,RECT(3,11)                       ; 3 x 11 rectangle (was 12)
    CALL        DRAW_CHRCOLS

    ; ADD         HL,DE                               ; Move down a row
    ; CALL        DRAW_UR_3X3_CORNER                  ; Draw bottom door blocks
    ; ADD         HL,DE                               ; Move down a row
    ; INC         DE                                  ; Increment pitch to 41
    ; CALL        DRAW_VERTICAL_LINE_3_UP
    LD          HL,DAT_ram_30df
    LD          A,CHAR_RT_ANGLE						; Right angle char
    ; DEC         DE                                  ; Decrement pitch to 40
    DEC         DE                                  ; Decrement pitch to 39
    JP          CONTINUE_VERTICAL_LINE_DOWN         ; Draw top of door angles

DRAW_WALL_FR0:
    LD          HL,DAT_ram_34dc
    LD          A,COLOR(BLK,BLU)					; BLK on BLU
    LD          BC,RECT(4,15)						; 4 x 15 rectangle (was 16)
    JP          FILL_CHRCOL_RECT
DRAW_WALL_FR1_B:
    LD          HL,DAT_ram_317c
    LD          BC,RECT(4,8)                        ; 4 x 8 rectangle
    LD          A,$20								; Change to SPACE 32 / $20
    CALL        FILL_CHRCOL_RECT
    LD          HL,DAT_ram_357c
    LD          C,0x8
    LD          A,COLOR(BLU,DKBLU)					; BLU on DKBLU ****
    JP          DRAW_CHRCOLS

DRAW_DOOR_FR1_B_HIDDEN:
    CALL        DRAW_WALL_FR1_B
    XOR         A
    JP          DRAW_DOOR_FR1_B
DRAW_DOOR_FR1_B_NORMAL:
    CALL        DRAW_WALL_FR1_B
    LD          A,COLOR(DKGRN,DKGRN)				; DKGRN on DKGRNd
DRAW_DOOR_FR1_B:
    LD          HL,COLRAM_FR22_WALL_IDX
    LD          BC,RECT(2,6)						; 2 x 6 rectangle
    JP          DRAW_CHRCOLS
SUB_ram_cbe2:
    LD          HL,DAT_ram_317f
    LD          A,CHAR_RT_ANGLE						; Right angle char
    LD          (HL),A
    LD          DE,$28                              ; Stride is 40
    ADD         HL,DE
    DEC         HL
    LD          (HL),A
    LD          HL,DAT_ram_326e
    LD          A,CHAR_LT_ANGLE						; Left angle char
    LD          (HL),A
    ADD         HL,DE
    INC         HL
    LD          (HL),A
    LD          HL,DAT_ram_357f
    LD          A,COLOR(DKBLU,DKGRY)			    ; DKBLU on DKGRY
    LD          (HL),A
    ADD         HL,DE
    DEC         HL
    LD          (HL),A
    INC         HL
    LD          A,COLOR(BLK,DKGRY)			    	; BLK on DKGRY
    LD          (HL),A
    LD          BC,RECT(2,4)					    ; 2 x 4 rectangle
    ADD         HL,DE
    DEC         HL
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    INC         HL
    LD          (HL),A
    DEC         HL
    LD          A,COLOR(BLK,DKGRY)					; BLK on DKGRY
    LD          (HL),A
    ADD         HL,DE
    INC         HL
    LD          (HL),A
    LD          HL,COLRAM_FR22_WALL_IDX
    LD          C,0x4
    LD          A,COLOR(BLK,BLK)
    JP          DRAW_CHRCOLS
DRAW_WALL_FR22_EMPTY:
    LD          HL,COLRAM_FR22_WALL_IDX
    LD          BC,RECT(4,4)						; 4 x 4 rectangle
    LD          A,COLOR(BLK,BLK)					; BLK on BLK
    JP          FILL_CHRCOL_RECT
DRAW_WALL_FR1:
    LD          A,CHAR_LT_ANGLE
    PUSH        AF
    LD          BC,RECT(4,8)						; 4 x 8 rectangle
    LD          A,$20								; Change to SPACE 32 / $20
    PUSH        AF
    LD          A,CHAR_RT_ANGLE						; Right angle char
    LD          HL,DAT_ram_3150
    CALL        SUB_ram_cc4d
    LD          A,COLOR(DKGRY,DKBLU)		    	; DKGRY on DKBLU
    PUSH        AF
    LD          C,0x8
    LD          A,COLOR(BLU,DKBLU)			    	; BLU on DKBLU
    PUSH        AF
    LD          A,COLOR(DKBLU,BLK)			    	; DKBLU on BLK
    LD          HL,DAT_ram_3550
    CALL        SUB_ram_cc4d
    RET
DRAW_R0_CORNERS:
    POP         IX                                  ; Save RET address to IX
    LD          DE,$27                              ; Stride is 39 / $27
    CALL        DRAW_SINGLE_CHAR_UP
    INC         DE                                  ; Stride is 40
    ADD         HL,DE
    POP         AF
    CALL        DRAW_DR_3X3_CORNER
    ADD         HL,DE
    DEC         HL
    CALL        DRAW_CHRCOLS
    ; ADD         HL,DE
    ; INC         HL
    ; CALL        DRAW_UR_3X3_CORNER
    ; ADD         HL,DE
    POP         AF
    INC         DE                                  ; Stride is 41
    ; CALL        DRAW_SINGLE_CHAR_UP
    JP          (IX)

SUB_ram_cc4d:
    POP         IX                                  ; Save RET address to IX
    LD          DE,$27                              ; Stride is 39 / $27
    CALL        DRAW_SINGLE_CHAR_UP
    INC         DE                                  ; Stride is 40
    ADD         HL,DE
    POP         AF
    CALL        DRAW_DR_3X3_CORNER
    ADD         HL,DE
    DEC         HL
    CALL        DRAW_CHRCOLS
    ADD         HL,DE
    INC         HL
    CALL        DRAW_UR_3X3_CORNER
    ADD         HL,DE
    POP         AF
    INC         DE                                  ; Stride is 41
    CALL        DRAW_SINGLE_CHAR_UP
    JP          (IX)
SUB_ram_cc6d:
    CALL        DRAW_WALL_FR1
    LD          A,COLOR(DKGRY,BLK)					; DKGRY on BLK
    PUSH        AF
    LD          A,COLOR(DKBLU,BLK)  				; DKBLU on BLK
    PUSH        AF
    LD          A,COLOR(BLK,DKBLU)					; BLK on DKBLU
    JP          LAB_ram_cc85
SUB_ram_cc7a:
    CALL        DRAW_WALL_FR1
    LD          A,$fd								; DKGRY on DKGRN
    PUSH        AF
    LD          A,$2d								; GRN on DKGRN
    PUSH        AF
    LD          A,$db								; DKGRN on DKBLU
LAB_ram_cc85:
    LD          HL,DAT_ram_357a
    LD          BC,RECT(2,7)						; 2 x 7 rectangle
    CALL        SUB_ram_cd07
    LD          HL,DAT_ram_317a
    LD          A,CHAR_RT_ANGLE						; Right angle char
    LD          (HL),A
    LD          DE,$27                              ; Stride is 39 / $27
    ADD         HL,DE
    LD          (HL),A
    RET
SUB_ram_cc9a:
    LD          HL,DAT_ram_3578
    LD          BC,RECT(4,8)						; 4 x 8 rectangle
    LD          A,COLOR(BLU,DKBLU)					; BLU on DKBLU
    CALL        FILL_CHRCOL_RECT
    LD          HL,DAT_ram_3178
    LD          C,0x8
    LD          A,$20								; Change to SPACE 32 / $20
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
    LD          BC,RECT(2,6)						; 2 x 6 rectangle
    JP          DRAW_CHRCOLS
DRAW_WALL_FR2:
    LD          HL,DAT_ram_35ca                     ; ???
    LD          BC,RECT(2,4)						; 2 x 4 rectangle
    LD          A,COLOR(BLK,DKGRY)					; BLK on DKGRY
    CALL        FILL_CHRCOL_RECT
    LD          C,0x4
    LD          HL,COLRAM_FR2_RIGHT                 ; FR2 Right
    LD          A,COLOR(BLK,DKGRY)					; BLK on DKGRY
    CALL        DRAW_CHRCOLS                        ; Was JP
    LD          HL,$31c8 + 120                      ; Bottom row of FR2 right, CHRRAM
    LD          BC,RECT(4,1)                        ; 4 x 1 rectangle
    LD          A,CHAR_BOTTOM_LINE
    JP          DRAW_CHRCOLS                        ; *****

DRAW_WALL_FR2_EMPTY:
    LD          HL,COLRAM_FR2_RIGHT
    LD          BC,RECT(4,4)						; 4 x 4 rectangle
    LD          A,COLOR(BLK,BLK)					; BLK on BLK
    JP          FILL_CHRCOL_RECT
DRAW_WALL_R2:
    LD          A,COLOR(BLK,DKGRY)					; BLK on DKGRY
    PUSH        AF
    LD          A,COLOR(BLK,DKGRY)					; BLK on DKGRY
    PUSH        AF
    LD          A,COLOR(DKGRY,BLK)					; DKGRY on BLK
    LD          HL,DAT_ram_3577
    LD          BC,RECT(2,4)						; 2 x 4 rectangle
    CALL        SUB_ram_cd07
    LD          HL,DAT_ram_3266
    LD          A,$da								; Left slash char
    LD          (HL),A
    ADD         HL,DE
    LD          (HL),A
    LD          HL,DAT_ram_3177
    LD          A,CHAR_RT_ANGLE						; Right angle char
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
    LD          HL,COLRAM_FR2_LEFT                  ; FR2_LEFT_SOLID
    LD          BC,RECT(2,4)						; 2 x 4 rectangle
    LD          A,COLOR(BLK,DKGRY)					; BLK on DKGRY
    CALL        FILL_CHRCOL_RECT                    ; Was JP
    LD          HL,$31c6 + 120                      ; Bottom row of FR2 left, CHRRAM
    LD          BC,RECT(4,1)                        ; 4 x 1 rectangle
    LD          A,CHAR_BOTTOM_LINE
    JP          DRAW_CHRCOLS                        ; 

SUB_ram_cd2c:
    LD          HL,COLRAM_FR2_LEFT                  ; FR2_LEFT_OPEN
    LD          BC,RECT(2,4)						; 2 x 4 rectangle
    LD          A,COLOR(BLK,BLK)					; BLK on BLK
    JP          FILL_CHRCOL_RECT                    ; *****


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
    LD          A,$20								; Set VIEWPORT fill chars to SPACE
    LD          HL,CHRRAM_VIEWPORT_IDX				; Set CHRRAM starting point at the beginning of the VIEWPORT
    LD          BC,RECT(24,24)						; 24 x 24 rectangle
    CALL        FILL_CHRCOL_RECT
    LD          C,0x8								; 8 rows of ceiling
    LD          HL,COLRAM_VIEWPORT_IDX				; Set COLRAM starting point at the beginning of the VIEWPORT
    LD          A,COLOR(DKGRY,BLK)					; DKGRY on BLK
    CALL        DRAW_CHRCOLS
    LD          C,0x6								; 6 more rows of ceiling
    ADD         HL,DE
    LD          A,COLOR(BLK,BLK)					; BLK on BLK
    CALL        DRAW_CHRCOLS
    LD          C,5 								; 5 rows of floor (was 10)
    ADD         HL,DE
    LD          A,COLOR(DKGRN,DKGRY)				; DKGRN on DKGRY
    CALL        DRAW_CHRCOLS
; NEW STUFF
    ADD         HL,DE                               
    LD          A,L
    ADD         A,6
    LD          L,A
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY
    LD          BC,RECT(12,5)                       ; 12 x 5 rectangle
    CALL        FILL_CHRCOL_RECT

; Check if in-battle
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
    LD          HL,(DIR_FACING_HI)								; HL = FW adjustment value
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
    LD          BC,RECT(4,4)						; 4 x 4 rectangle
    LD          A,COLOR(BLK,BLK)					; BLK on BLK
    JP          FILL_CHRCOL_RECT                    ; Was CALL, followed by the commented section

DRAW_WALL_FL2:
    LD          HL,$3234							; Bottom CHARRAM IDX of FL2
    LD          BC,RECT(4,1)						; 4 x 1 rectangle
    LD          A,CHAR_BOTTOM_LINE					; Thin base line char
    CALL        FILL_CHRCOL_RECT
    LD          HL,$35bc
    LD          BC,RECT(2,4)						; 2 x 4 rectangle
    LD          A,COLOR(BLK,DKGRY)					; BLK on DKGRY
    CALL        FILL_CHRCOL_RECT
    LD          C,0x4
    LD          HL,$35be
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY
    JP          DRAW_CHRCOLS                        ; *****

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
