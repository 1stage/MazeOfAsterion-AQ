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
    LD          DE,COLOR(GRN,DKCYN)                 ; GRN on DKCYN (door bottom/frame color)
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
    SBC         HL,DE                               ; Move cursor up by DE amount;------------------------------------------------------------------------------
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
    LD          HL,COLRAM_F0_WALL_IDX               ; Point to far wall color area
    LD          BC,RECT(16,15)                      ; 16 x 16 rectangle
    LD          A,COLOR(BLU,BLU)                    ; BLU on BLU (solid blue wall)
    CALL        FILL_CHRCOL_RECT                    ; Fill wall area with blue color (WAS JP)
    LD          HL,COLRAM_F0_WALL_IDX + 2 + (40 * 15)
    LD          B,12
    JP          DRAW_ROW

DRAW_F0_WALL_AND_CLOSED_DOOR:
    CALL        DRAW_F0_WALL                        ; Draw the wall background first
    LD          A,COLOR(GRN,GRN)                    ; GRN on GRN (closed door color)

DRAW_DOOR_F0:
    LD          HL,COLRAM_F0_DOOR_IDX               ; Point to door area within wall
    LD          BC,RECT(8,12)                       ; 8 x 12 rectangle (door size)
    JP          FILL_CHRCOL_RECT                    ; Fill door area with specified color

DRAW_WALL_F0_AND_OPEN_DOOR:
    CALL        DRAW_F0_WALL                        ; Draw the wall background first
    LD          A,COLOR(DKGRY,BLK)                  ; DKGRY on BLK (open door/passage color)
    JP          DRAW_DOOR_F0                        ; Fill door area showing passage through

DRAW_WALL_F1:
    LD          HL,CHRRAM_F1_WALL_IDX               ; Point to F1 wall character area
    LD          BC,RECT(8,8)                        ; 8 x 8 rectangle (mid-distance wall size)
    LD          A,$20                               ; SPACE character (clear wall area)
    CALL        FILL_CHRCOL_RECT                    ; Clear wall character area with spaces
    LD          C,0x8                               ; Set height for color fill operation
    LD          HL,COLRAM_F0_DOOR_IDX               ; Point to corresponding color area
    LD          A,COLOR(BLU,DKBLU)                  ; BLU on DKBLU (wall color scheme)
    JP          DRAW_CHRCOLS                        ; Fill color area for wall

DRAW_WALL_F1_AND_CLOSED_DOOR:
    CALL        DRAW_WALL_F1                        ; Draw the F1 wall background first
    LD          A,COLOR(GRN,DKGRN)                  ; GRN on DKGRN (closed door at F1 distance)

DRAW_DOOR_F1:
    LD          HL,COLRAM_F1_DOOR_IDX               ; Point to door area within F1 wall
    LD          BC,RECT(4,6)                        ; 4 x 6 rectangle (smaller door at mid-distance)
    JP          FILL_CHRCOL_RECT                    ; Fill door area with specified color

DRAW_WALL_F1_AND_OPEN_DOOR:
    CALL        DRAW_WALL_F1                        ; Draw F1 wall background
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (open door/darkness)
    JP          DRAW_DOOR_F1                        ; Fill door area with black

DRAW_WALL_F2:
    LD          BC,RECT(4,4)                        ; 4 x 4 rectangle
    LD          HL,COLRAM_F2_WALL_IDX               ; Point to F2 wall color area
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (far distance wall)
    CALL        FILL_CHRCOL_RECT                    ; Fill wall area (was JP)
    LD          HL,$323a                            ; Bottom-left CHRRAM IDX of F2
    LD          BC,RECT(4,1)                        ; 4 x 1 rectangle
    LD          A,$90                               ; Thin base line character
    JP          FILL_CHRCOL_RECT                    ; Draw base line

DRAW_WALL_F2_EMPTY:
    LD          HL,COLRAM_F2_WALL_IDX               ; Point to F2 wall color area
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (empty/dark)

UPDATE_F0_ITEM:
    LD          BC,RECT(4,4)                        ; 4 x 4 rectangle
    JP          FILL_CHRCOL_RECT                    ; Fill area with color in A

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
    RET                                             ; (Unreachable - dead code)
DRAW_DOOR_L0_HIDDEN:
    CALL        DRAW_WALL_L0                        ; Draw L0 wall background
    LD          A,COLOR(DKGRY,BLK)                  ; DKGRY on BLK (hidden door)
    EX          AF,AF'                              ; Save door color to alternate
    LD          A,COLOR(BLK,BLU)                    ; BLK on BLU (wall color)
    JP          DRAW_DOOR_L0                        ; Draw door with saved color
DRAW_DOOR_L0_NORMAL:
    CALL        DRAW_WALL_L0                        ; Draw L0 wall background
    LD          A,COLOR(DKGRY,GRN)                  ; DKGRY on GRN (normal door)
    EX          AF,AF'                              ; Save door color to alternate
    LD          A,COLOR(GRN,BLU)                    ; GRN on BLU (door frame color)

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
    RET                                             ; (Unreachable - dead code)

DRAW_WALL_FL0:
    LD          HL,DAT_ram_34c8                     ; Point to FL0 wall color area
    LD          A,COLOR(BLK,BLU)                    ; BLK on BLU (wall color)
    LD          BC,RECT(4,15)                       ; 4 x 15 rectangle (was 16)
    JP          FILL_CHRCOL_RECT                    ; Fill wall area

DRAW_WALL_L1:
    LD          HL,CHRRAM_WALL_FL1_A_IDX            ; Point to L1 character area
    LD          BC,RECT(4,8)                        ; 4 x 8 rectangle
    LD          A,$20                               ; SPACE character (32 / $20)
    CALL        FILL_CHRCOL_RECT                    ; Clear character area
    LD          HL,COLRAM_WALL_FL1_A_IDX            ; Point to L1 color area
    LD          C,0x8                               ; Set height to 8
    LD          A,COLOR(BLU,DKBLU)                  ; BLU on DKBLU (wall color)
    JP          DRAW_CHRCOLS                        ; Fill color columns
DRAW_DOOR_L1_NORMAL:
    CALL        DRAW_WALL_L1                        ; Draw L1 wall background
    LD          A,COLOR(DKGRN,DKGRN)                ; DKGRN on DKGRN (normal door)
DRAW_DOOR_L1:
    LD          HL,COLRAM_L1_DOOR_PATTERN_IDX       ; Point to L1 door pattern area
    LD          BC,RECT(2,6)                        ; 2 x 6 rectangle
    JP          DRAW_CHRCOLS                        ; Fill door area
DRAW_DOOR_L1_HIDDEN:
    CALL        DRAW_WALL_L1                        ; Draw L1 wall background
    XOR         A                                   ; A = 0 (BLK on BLK - hidden door)
    JP          DRAW_DOOR_L1                        ; Draw door with black color
SUB_ram_c9f9:
    LD          HL,CHRRAM_L1_WALL_IDX               ; Point to L1 wall character area
    LD          A,CHAR_LT_ANGLE                     ; Left angle bracket character
    LD          (HL),A                              ; Draw left angle at top
    LD          DE,$28                              ; Set stride to 40
    ADD         HL,DE                               ; Move to next row
    INC         HL                                  ; Move to next cell
    LD          (HL),A                              ; Draw left angle again
    LD          HL,DAT_ram_3259                     ; Point to top wall characters
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

DRAW_WALL_FL22:
    LD          HL,COLRAM_FL22_WALL_IDX             ; Point to FL22 wall color area
    LD          BC,RECT(4,4)                        ; 4 x 4 rectangle
    LD          A,COLOR(DKGRY,DKGRY)                ; DKGRY on DKGRY (far wall)
    JP          FILL_CHRCOL_RECT                    ; Fill wall area
DRAW_L1_WALL:
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
    RET                                             ; (Unreachable - dead code)
DRAW_FL1_DOOR:
    CALL        DRAW_L1_WALL                        ; Draw L1 wall background
    LD          A,COLOR(DKGRY,BLK)                  ; DKGRY on BLK (door edge color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(DKBLU,BLK)                  ; DKBLU on BLK (wall color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(BLK,DKBLU)                  ; BLK on DKBLU (door body color)
    JP          DRAW_L1_DOOR                        ; Draw door with stacked colors
DRAW_L1:
    CALL        DRAW_L1_WALL                        ; Draw L1 wall background
    LD          A,COLOR(DKGRY,DKGRN)                ; DKGRY on DKGRN (door edge color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(GRN,DKGRN)                  ; GRN on DKGRN (door frame color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(DKGRN,DKBLU)                ; DKGRN on DKBLU (door body color)
DRAW_L1_DOOR:
    LD          HL,COLRAM_L1_DOOR_IDX               ; Point to L1 door color area
    LD          BC,RECT(2,7)                        ; 2 x 7 rectangle
    CALL        SUB_ram_cb1c                        ; Fill door with stacked colors
    LD          HL,CHRRAM_L1_DOOR_IDX               ; Point to L1 door character area
    LD          A,CHAR_LT_ANGLE                     ; Left angle bracket character
    LD          (HL),A                              ; Draw left angle at top
    LD          DE,$29                              ; Set stride to 41
    ADD         HL,DE                               ; Move to next row
    LD          (HL),A                              ; Draw left angle again
    RET                                             ; Return to caller
DRAW_WALL_FL1_B:
    LD          HL,COLRAM_WALL_FL1_B_IDX            ; Point to FL1_B wall color area
    LD          BC,RECT(4,8)                        ; 4 x 8 rectangle
    LD          A,COLOR(BLU,DKBLU)                  ; BLU on DKBLU (wall color)
    CALL        FILL_CHRCOL_RECT                    ; Fill color area
    LD          HL,CHRRAM_WALL_FL1_B_IDX            ; Point to FL1_B character area
    LD          C,0x8                               ; Set height to 8
    LD          A,$20                               ; SPACE character (32 / $20)
    JP          DRAW_CHRCOLS                        ; Fill character area
DRAW_DOOR_FL1_B_HIDDEN:
    CALL        DRAW_WALL_FL1_B                     ; Draw FL1_B wall background
    XOR         A                                   ; A = 0 (BLK on BLK - hidden door)
    JP          DRAW_DOOR_FL1_B                     ; Draw door with black
DRAW_DOOR_FL1_B_NORMAL:
    CALL        DRAW_WALL_FL1_B                     ; Draw FL1_B wall background
    LD          A,COLOR(DKGRN,DKGRN)                ; DKGRN on DKGRN (normal door)
DRAW_DOOR_FL1_B:
    LD          HL,COLRAM_FL2_WALL_IDX              ; Point to FL2 wall area for door
    LD          BC,RECT(2,6)                        ; 2 x 6 rectangle
    JP          DRAW_CHRCOLS                        ; Fill door area

DRAW_WALL_FL2_EMPTY:
    LD          HL,COLRAM_FL2_WALL_IDX              ; Point to FL2 wall color area
    LD          BC,RECT(4,4)                        ; 4 x 4 rectangle
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (empty/dark)
    JP          FILL_CHRCOL_RECT                    ; Fill area with black
DRAW_WALL_L2:
    LD          A,$ca                               ; Right slash character
    PUSH        AF                                  ; Save to stack for later
    LD          A,$20                               ; SPACE character
    PUSH        AF                                  ; Save to stack for later
    LD          HL,CHRRAM_F1_WALL_IDX               ; Point to F1 character area
    LD          A,CHAR_LT_ANGLE                     ; Left angle bracket character
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    CALL        SUB_ram_cb1c                        ; Fill with stacked characters
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    PUSH        AF                                  ; Save to stack for later
    LD          HL,COLRAM_F0_DOOR_IDX               ; Point to F0 door color area
    LD          A,COLOR(DKGRY,BLK)                  ; DKGRY on BLK (wall edge color)
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    CALL        SUB_ram_cb1c                        ; Fill with stacked colors
    RET                                             ; Return to caller
SUB_ram_cb1c:
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
DRAW_WALL_L2_LEFT:
    LD          HL,COLRAM_L2_LEFT                   ; Point to L2 left wall color area
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    CALL        FILL_CHRCOL_RECT                    ; Fill color area
    LD          HL,$3238                            ; Point to bottom edge area
    LD          BC,RECT(2,1)                        ; 2 x 1 rectangle
    LD          A,CHAR_BOTTOM_LINE                  ; Bottom line character
    JP          FILL_CHRCOL_RECT                    ; Fill bottom edge
DRAW_WALL_L2_LEFT_EMPTY:
    LD          HL,COLRAM_L2_LEFT                   ; Point to L2 left wall color area
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (empty/dark)
    JP          FILL_CHRCOL_RECT                    ; Fill area with black
DRAW_WALL_R0:
    LD          A,COLOR(DKGRY,BLU)                  ; DKGRY on BLU (wall edge color)
    PUSH        AF                                  ; Save to stack for later
    LD          BC,RECT(4,15)                       ; 4 x 15 rectangle (was 16)
    LD          A,COLOR(BLK,BLU)                    ; BLK on BLU (wall color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(BLU,BLK)                    ; BLU on BLK (background color)
    LD          HL,DAT_ram_34b4                     ; Point to R0 wall area
    CALL        DRAW_R0_CORNERS                     ; Do corner fills
    LD          HL,DAT_ram_303f                     ; Top right corner of R0
    LD          A,CHAR_RT_ANGLE                     ; Right angle character
    LD          DE,$27                              ; Pitch to 39 / $27
    CALL        DRAW_VERTICAL_LINE_4_DOWN           ; Draw top of R0 wall

    INC         A                                   ; Increment A to CHAR_LT_ANGLE ($c1)
    INC         DE                                  ; Increment pitch to 40 / $28
    INC         DE                                  ; Increment pitch to 41 / $29
    RET                                             ; Return to caller
DRAW_R0_DOOR_HIDDEN:
    CALL        DRAW_WALL_R0                        ; Draw R0 wall background
    LD          A,COLOR(DKGRY,BLK)                  ; DKGRY on BLK (hidden door edge)
    EX          AF,AF'                              ; Save to alternate AF
    LD          A,COLOR(BLK,BLU)                    ; BLK on BLU (hidden door body)
    JP          DRAW_R0_DOOR                        ; Draw door with hidden colors
DRAW_R0_DOOR_NORMAL:
    CALL        DRAW_WALL_R0                        ; Draw R0 wall background
    LD          A,COLOR(DKGRY,GRN)                  ; DKGRY on GRN (normal door edge)
    EX          AF,AF'                              ; Save to alternate AF
    LD          A,COLOR(GRN,BLU)                    ; GRN on BLU (normal door body)
DRAW_R0_DOOR:
    LD          HL,DAT_ram_352d                     ; R0 door top left COLRAM IDX
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

    LD          HL,DAT_ram_30df                     ; Point to door angle area
    LD          A,CHAR_RT_ANGLE                     ; Right angle character
    DEC         DE                                  ; Decrement pitch to 39
    JP          CONTINUE_VERTICAL_LINE_DOWN         ; Draw top of door angles

DRAW_WALL_FR0:
    LD          HL,DAT_ram_34dc                     ; Point to FR0 wall area
    LD          A,COLOR(BLK,BLU)                    ; BLK on BLU (wall color)
    LD          BC,RECT(4,15)                       ; 4 x 15 rectangle (was 16)
    JP          FILL_CHRCOL_RECT                    ; Fill wall area
DRAW_WALL_FR1_B:
    LD          HL,DAT_ram_317c                     ; Point to FR1_B character area
    LD          BC,RECT(4,8)                        ; 4 x 8 rectangle
    LD          A,$20                               ; SPACE character (32 / $20)
    CALL        FILL_CHRCOL_RECT                    ; Fill character area
    LD          HL,DAT_ram_357c                     ; Point to FR1_B color area
    LD          C,0x8                               ; Set height to 8
    LD          A,COLOR(BLU,DKBLU)                  ; BLU on DKBLU (wall color)
    JP          DRAW_CHRCOLS                        ; Fill color area

DRAW_DOOR_FR1_B_HIDDEN:
    CALL        DRAW_WALL_FR1_B                     ; Draw FR1_B wall background
    XOR         A                                   ; A = 0 (BLK on BLK - hidden door)
    JP          DRAW_DOOR_FR1_B                     ; Draw door with black
DRAW_DOOR_FR1_B_NORMAL:
    CALL        DRAW_WALL_FR1_B                     ; Draw FR1_B wall background
    LD          A,COLOR(DKGRN,DKGRN)                ; DKGRN on DKGRN (normal door)
DRAW_DOOR_FR1_B:
    LD          HL,COLRAM_FR22_WALL_IDX             ; Point to FR22 wall area for door
    LD          BC,RECT(2,6)                        ; 2 x 6 rectangle
    JP          DRAW_CHRCOLS                        ; Fill door area
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
    LD          HL,COLRAM_FR22_WALL_IDX             ; Point to FR22 wall color area
    LD          BC,RECT(4,4)                        ; 4 x 4 rectangle
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (empty/dark)
    JP          FILL_CHRCOL_RECT                    ; Fill area with black
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

DRAW_DOOR_R1_HIDDEN:
    CALL        DRAW_WALL_R1                        ; Draw R1 wall background
    LD          A,COLOR(DKGRY,BLK)                  ; DKGRY on BLK (hidden door edge)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(DKBLU,BLK)                  ; DKBLU on BLK (hidden door body)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(BLK,DKBLU)                  ; BLK on DKBLU (background)
    JP          DRAW_DOOR_R1                        ; Draw door with hidden colors
DRAW_DOOR_R1_NORMAL:
    CALL        DRAW_WALL_R1                        ; Draw R1 wall background
    LD          A,COLOR(DKGRY,DKGRN)                ; DKGRY on DKGRN (normal door edge)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(GRN,DKGRN)                  ; GRN on DKGRN (normal door frame)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(DKGRN,DKBLU)                ; DKGRN on DKBLU (door body)
DRAW_DOOR_R1:
    LD          HL,DAT_ram_357a                     ; Point to R1 door area
    LD          BC,RECT(2,7)                        ; 2 x 7 rectangle
    CALL        SUB_ram_cd07                        ; Fill door with stacked colors
    LD          HL,DAT_ram_317a                     ; Point to R1 door character area
    LD          A,CHAR_RT_ANGLE                     ; Right angle character
    LD          (HL),A                              ; Draw right angle at top
    LD          DE,$27                              ; Stride is 39 / $27
    ADD         HL,DE                               ; Move to next row
    LD          (HL),A                              ; Draw right angle again
    RET                                             ; Return to caller
DRAW_WALL_FR1_A:
    LD          HL,COLRAM_WALL_FR1_A_IDX            ; Point to FR1_A wall color area
    LD          BC,RECT(4,8)                        ; 4 x 8 rectangle
    LD          A,COLOR(BLU,DKBLU)                  ; BLU on DKBLU (wall color)
    CALL        FILL_CHRCOL_RECT                    ; Fill color area
    LD          HL,CHRRAM_WALL_FR1_A_IDX            ; Point to FR1_A character area
    LD          C,0x8                               ; Set height to 8
    LD          A,$20                               ; SPACE character (32 / $20)
    JP          DRAW_CHRCOLS                        ; Fill character area
SUB_ram_ccaf:
    CALL        DRAW_WALL_FR1_A                     ; Draw FR1_A wall background
    XOR         A                                   ; A = 0 (BLK on BLK - hidden)
    JP          LAB_ram_ccba                        ; Jump to door drawing
SUB_ram_ccb5:
    CALL        DRAW_WALL_FR1_A                     ; Draw FR1_A wall background
    LD          A,COLOR(DKGRN,DKGRN)                ; DKGRN on DKGRN (normal door)
LAB_ram_ccba:
    LD          HL,DAT_ram_35ca                     ; Point to door area
    LD          BC,RECT(2,6)                        ; 2 x 6 rectangle
    JP          DRAW_CHRCOLS                        ; Fill door area
DRAW_WALL_FR2:
    LD          HL,DAT_ram_35ca                     ; Point to FR2 left wall area
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    CALL        FILL_CHRCOL_RECT                    ; Fill left wall
    LD          C,0x4                               ; Set height to 4
    LD          HL,COLRAM_FR2_RIGHT                 ; FR2 Right wall area
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    CALL        DRAW_CHRCOLS                        ; Fill right wall (was JP)
    LD          HL,$31c8 + 120                      ; Bottom row of FR2 right, CHRRAM
    LD          BC,RECT(4,1)                        ; 4 x 1 rectangle
    LD          A,CHAR_BOTTOM_LINE                  ; Bottom line character
    JP          DRAW_CHRCOLS                        ; Fill bottom edge

DRAW_WALL_FR2_EMPTY:
    LD          HL,COLRAM_FR2_RIGHT                 ; Point to FR2 right wall area
    LD          BC,RECT(4,4)                        ; 4 x 4 rectangle
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (empty/dark)
    JP          FILL_CHRCOL_RECT                    ; Fill area with black
DRAW_WALL_R2:
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    PUSH        AF                                  ; Save to stack for later
    LD          A,COLOR(DKGRY,BLK)                  ; DKGRY on BLK (edge color)
    LD          HL,DAT_ram_3577                     ; Point to R2 wall area
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    CALL        SUB_ram_cd07                        ; Fill with stacked colors
    LD          HL,DAT_ram_3266                     ; Point to character area
    LD          A,$da                               ; Left slash character
    LD          (HL),A                              ; Draw left slash at position
    ADD         HL,DE                               ; Move to next row
    LD          (HL),A                              ; Draw left slash again
    LD          HL,DAT_ram_3177                     ; Point to next character area
    LD          A,CHAR_RT_ANGLE                     ; Right angle character
    LD          (HL),A                              ; Draw right angle at position
    DEC         DE                                  ; Decrease stride
    DEC         DE                                  ; Decrease stride again
    ADD         HL,DE                               ; Move to next row
    LD          (HL),A                              ; Draw right angle again
    RET                                             ; Return to caller

SUB_ram_cd07:
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
SUB_ram_cd21:
    LD          HL,COLRAM_FR2_LEFT                  ; FR2_LEFT_SOLID area
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    LD          A,COLOR(BLK,DKGRY)                  ; BLK on DKGRY (wall color)
    CALL        FILL_CHRCOL_RECT                    ; Fill left wall (was JP)
    LD          HL,$31c6 + 120                      ; Bottom row of FR2 left, CHRRAM
    LD          BC,RECT(4,1)                        ; 4 x 1 rectangle
    LD          A,CHAR_BOTTOM_LINE                  ; Bottom line character
    JP          DRAW_CHRCOLS                        ; Fill bottom edge

SUB_ram_cd2c:
    LD          HL,COLRAM_FR2_LEFT                  ; FR2_LEFT_OPEN area
    LD          BC,RECT(2,4)                        ; 2 x 4 rectangle
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (empty/dark)
    JP          FILL_CHRCOL_RECT                    ; Fill with black


    LD          A,0x8                               ; Load sound repeat count
    LD          (SOUND_REPEAT_COUNT),A              ; Store repeat count
    LD          B,A                                 ; Set loop counter to 8
LAB_ram_cd3d:
    PUSH        BC                                  ; Save loop counter
    CALL        SOUND_04                            ; Play sound 4
    CALL        SUB_ram_cde7                        ; Call delay routine
    CALL        SOUND_02                            ; Play sound 2
    CALL        SOUND_01                            ; Play sound 1
    POP         BC                                  ; Restore loop counter
    DJNZ        LAB_ram_cd3d                        ; Repeat B times
    RET                                             ; Return to caller
    LD          A,0x7                               ; Load sound repeat count
    LD          (SOUND_REPEAT_COUNT),A              ; Store repeat count
    LD          B,A                                 ; Set loop counter to 7
LAB_ram_cd54:
    PUSH        BC                                  ; Save loop counter
    CALL        SOUND_02                            ; Play sound 2
    CALL        SOUND_03                            ; Play sound 3
    POP         BC                                  ; Restore loop counter
    DJNZ        LAB_ram_cd54                        ; Repeat B times
    RET                                             ; Return to caller
SUB_ram_cd5f:
    LD          A,0xa                               ; Load sound repeat count
    LD          (SOUND_REPEAT_COUNT),A              ; Store repeat count
    LD          B,A                                 ; Set loop counter to 10
LAB_ram_cd65:
    PUSH        BC                                  ; Save loop counter
    CALL        SOUND_04                            ; Play sound 4
    CALL        SOUND_05                            ; Play sound 5
    POP         BC                                  ; Restore loop counter
    DJNZ        LAB_ram_cd65                        ; Repeat B times
    JP          SUB_ram_cdbf                        ; Jump to next routine
POOF_SOUND:
    LD          A,0x7                               ; Load sound repeat count
    LD          (SOUND_REPEAT_COUNT),A              ; Store repeat count
    LD          B,0x1                               ; Set loop counter to 1
    JP          DOINK_SOUND                         ; Jump to doink sound routine
END_OF_GAME_SOUND:
    LD          A,0x4                               ; Load sound repeat count (was 0x7)
    LD          (SOUND_REPEAT_COUNT),A              ; Store repeat count
    LD          B,A                                 ; Set loop counter to 4
DOINK_SOUND:
    PUSH        BC                                  ; Save loop counter
    CALL        SOUND_02                            ; Play sound 2
    CALL        SUB_ram_cde7                        ; Call delay routine
    CALL        SOUND_03                            ; Play sound 3
    POP         BC                                  ; Restore loop counter
    DJNZ        DOINK_SOUND                         ; Repeat B times
    RET                                             ; Return to caller
    CALL        SUB_ram_cde7                        ; Call delay routine
    CALL        SUB_ram_cde7                        ; Call delay routine
    CALL        SUB_ram_cde7                        ; Call delay routine
    CALL        SUB_ram_cde7                        ; Call delay routine
    CALL        SUB_ram_cde7                        ; Call delay routine
    CALL        SUB_ram_cde7                        ; Call delay routine
    CALL        SUB_ram_cde7                        ; Call delay routine
    CALL        SUB_ram_cde7                        ; Call delay routine
    CALL        SUB_ram_cde7                        ; Call delay routine
    CALL        SUB_ram_cde7                        ; Call delay routine
    CALL        SUB_ram_cde7                        ; Call delay routine
    CALL        SOUND_05                            ; Play sound 5
    CALL        SOUND_05                            ; Play sound 5
    CALL        SOUND_05                            ; Play sound 5
    CALL        SOUND_05                            ; Play sound 5
    JP          SOUND_05                            ; Play sound 5 and return
SUB_ram_cdbf:
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          BC,$40                              ; Set BC to 64
    LD          DE,$15                              ; Set DE to 21
    LD          HL,$400                             ; Set HL to 1024
    LD          A,0x0                               ; Load value 0
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to down
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound
SUB_ram_cdd3:
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          BC,$a0                              ; Set BC to 160
    LD          DE,0x8                              ; Set DE to 8
    LD          HL,$800                             ; Set HL to 2048
    LD          A,0x0                               ; Load value 0
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to down
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound
SUB_ram_cde7:
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          BC,$a0                              ; Set BC to 160
    LD          DE,0x1                              ; Set DE to 1
    LD          HL,0x2                              ; Set HL to 2
    LD          A,0x0                               ; Load value 0
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to down
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound
SETUP_OPEN_DOOR_SOUND:
    LD          DE,0xf                              ; Set DE to 15
    LD          HL,$580                             ; Set HL to 1408
LO_HI_PITCH_SOUND:
    LD          BC,0x8                              ; Set BC to 8
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          A,0x1                               ; Load value 1
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to up
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound
SETUP_CLOSE_DOOR_SOUND:
    LD          HL,0x5                              ; Set HL to 5
    LD          DE,0xc                              ; Set DE to 12
HI_LO_PITCH_SOUND:
    LD          BC,0xe                              ; Set BC to 14
    XOR         A                                   ; A = 0
    PUSH        AF                                  ; Save to stack
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to down
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound
SOUND_01:
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          BC,$30                              ; Set BC to 48
    LD          DE,0x2                              ; Set DE to 2
    LD          HL,$100                             ; Set HL to 256
    LD          A,0x1                               ; Load value 1
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to up
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound
SOUND_02:
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          BC,$1a                              ; Set BC to 26
    LD          DE,$10                              ; Set DE to 16
    LD          HL,$300                             ; Set HL to 768
    LD          A,0x1                               ; Load value 1
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to up
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound
SOUND_03:
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          BC,$2a                              ; Set BC to 42
    LD          DE,0xa                              ; Set DE to 10
    LD          HL,0x4                              ; Set HL to 4
    LD          A,0x0                               ; Load value 0
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to down
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound
SOUND_04:
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          BC,$20                              ; Set BC to 32
    LD          DE,0x2                              ; Set DE to 2
    LD          HL,$55                              ; Set HL to 85
    LD          A,0x1                               ; Load value 1
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to up
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound
SOUND_05:
    LD          A,0x0                               ; Load value 0
    PUSH        AF                                  ; Save to stack
    LD          BC,$30                              ; Set BC to 48
    LD          DE,0x1                              ; Set DE to 1
    LD          HL,0x1                              ; Set HL to 1
    LD          A,0x0                               ; Load value 0
    LD          (PITCH_UP_BOOL),A                   ; Set pitch direction to down
    JP          PLAY_PITCH_CHANGE                   ; Play pitch change sound
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
INCREASE_PITCH:
    LD          HL,PITCH_UP_BOOL                    ; Point to pitch direction flag
    BIT         0x0,(HL)                            ; Check if pitch up is set
    JP          Z,DECREASE_PITCH                    ; If zero, decrease pitch instead
    LD          HL,(SND_CYCLE_HOLDER)               ; Load current cycle count
    SBC         HL,DE                               ; Subtract pitch step (increase freq)
    JP          PLAY_PITCH_CHANGE                   ; Continue with new pitch
DECREASE_PITCH:
    LD          HL,(SND_CYCLE_HOLDER)               ; Load current cycle count
    ADD         HL,DE                               ; Add pitch step (decrease freq)
    JP          PLAY_PITCH_CHANGE                   ; Continue with new pitch
HC_JOY_INPUT_COMPARE:
    LD          A,(RAM_AE)                          ; Load input mode flag
    CP          $31                                 ; Compare to "1" (handcontroller mode)
    JP          NZ,WAIT_FOR_INPUT                   ; If not HC mode, wait for input
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
DO_HC_SHIFT_ACTIONS:
    LD          A,$bf                               ; Compare to JOY K1
    CP          L                                   ; Check L register
    JP          Z,DO_USE_LADDER                     ; Use ladder if matched
    CP          H                                   ; Check H register
    JP          Z,DO_USE_LADDER                     ; Use ladder if matched
    LD          A,$7b                               ; Compare to JOY K2
    CP          L                                   ; Check L register
    JP          Z,NO_ACTION_TAKEN                   ; No action for K2 in shift mode
    CP          H                                   ; Check H register
    JP          Z,NO_ACTION_TAKEN                   ; No action for K2 in shift mode
    LD          A,$5f                               ; Compare to JOY K3
    CP          L                                   ; Check L register
    JP          Z,NO_ACTION_TAKEN                   ; No action for K3 in shift mode
    CP          H                                   ; Check H register
    JP          Z,NO_ACTION_TAKEN                   ; No action for K3 in shift mode
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

DRAW_BKGD:
    LD          A,$20                               ; Set VIEWPORT fill chars to SPACE
    LD          HL,CHRRAM_VIEWPORT_IDX              ; Set CHRRAM starting point at the beginning of the VIEWPORT
    LD          BC,RECT(24,24)                      ; 24 x 24 rectangle
    CALL        FILL_CHRCOL_RECT                    ; Fill viewport with spaces
    LD          C,0x8                               ; 8 rows of ceiling
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
; NEW STUFF
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
WIPE_VARIABLE_SPACE:
    LD          A,0x0                               ; Load value 0
    LD          HL,$3900                            ; Point to start of variable space
    LD          B,$ff                               ; Set loop counter to 255
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
TOGGLE_ITEM_POOF_AND_WAIT:
    EXX                                             ; Swap BC DE HL with BC' DE' HL'
    LD          BC,DAT_ram_3200                     ; Load cycle count for delay
    CALL        SLEEP                               ; byte SLEEP(short cycleCount)
    EXX                                             ; Swap BC DE HL with BC' DE' HL'
    RET                                             ; Return to caller
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
TOGGLE_SHIFT_MODE:
    LD          A,(GAME_BOOLEANS)                   ; Load game boolean flags
    BIT         0x1,A                               ; NZ if SHIFT MODE active
    JP          NZ,RESET_SHIFT_MODE                 ; If set, reset shift mode
SET_SHIFT_MODE:
    SET         0x1,A                               ; Set SHIFT MODE boolean
    LD          (GAME_BOOLEANS),A                   ; Store updated flags
    LD          A,$d0                               ; DKGRN on BLK (shift indicator)
    LD          (COLRAM_SHIFT_MODE_IDX),A           ; Update shift mode color
    JP          INPUT_DEBOUNCE                      ; Debounce input
RESET_SHIFT_MODE:
    LD          A,(GAME_BOOLEANS)                   ; Load game boolean flags
    RES         0x1,A                               ; Reset SHIFT MODE boolean
    LD          (GAME_BOOLEANS),A                   ; Store updated flags
    LD          A,$f0                               ; WHT on BLK (normal indicator)
    LD          (COLRAM_SHIFT_MODE_IDX),A           ; Update shift mode color
    JP          INPUT_DEBOUNCE                      ; Debounce input
SHOW_AUTHOR:
    LD          HL,CHRRAM_AUTHORS_IDX               ; Point to author text area
    LD          DE,AUTHORS                          ; = "   Originally programmed by Tom L...
    LD          B,$20                               ; Set length to 32 bytes
    CALL        GFX_DRAW                            ; Draw author text
    LD          A,$ff                               ; Load value 255
    JP          WAIT_FOR_INPUT                      ; Wait for input
TIMER_UPDATE:
    LD          HL,(TIMER_A)                        ; Load TIMER_A value
    LD          BC,0x1                              ; Load increment value 1
    ADD         HL,BC                               ; Increment timer
    LD          (TIMER_A),HL                        ; Store updated timer
    RET                                             ; Return to caller
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
    LD          A,(TIMER_B)                         ; Load TIMER_B value
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
    LD          (HL),$85                            ; Right side halftone CHR
    INC         HL                                  ; Move to next position
    INC         HL                                  ; Move to next position
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
DRAW_COMPASS:
    PUSH        AF                                  ; Save AF register (DKBLU on BLK)
    PUSH        BC                                  ; Save BC register
    PUSH        HL                                  ; Save HL register
    PUSH        DE                                  ; Save DE register
    LD          B,$b0                               ; Set color to DKBLU on BLK
    LD          HL,DAT_ram_31af                     ; Point to compass position
    LD          DE,COMPASS                          ; = $D7,"n",$C9,$01
    CALL        GFX_DRAW                            ; Draw compass graphic
    LD          HL,DAT_ram_35d8                     ; Point to compass color area
    LD          (HL),$10                            ; Set compass color
    POP         DE                                  ; Restore DE register
    POP         HL                                  ; Restore HL register
    POP         BC                                  ; Restore BC register
    POP         AF                                  ; Restore AF register
    RET                                             ; Return to caller
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
DRAW_WALL_FL22_EMPTY:
    LD          HL,COLRAM_FL22_WALL_IDX             ; Point to FL22 wall color area
    LD          BC,RECT(4,4)                        ; 4 x 4 rectangle
    LD          A,COLOR(BLK,BLK)                    ; BLK on BLK (empty/dark)
    JP          FILL_CHRCOL_RECT                    ; Fill area with black (Was CALL, followed by the commented section)

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

FIX_ICON_COLORS:
    LD          HL,COLRAM_LEVEL_IDX_L               ; Point to level indicator color area
    LD          A,(INPUT_HOLDER)                    ; Load input holder value
    ADD         A,A                                 ; Double the value
    SUB         0x1                                 ; Subtract 1
    LD          (HL),A                              ; Set level indicator color
    INC         L                                   ; Move to next position
    LD          (HL),A                              ; Set level indicator color
    INC         L                                   ; Move to next position
    LD          (HL),A                              ; Set level indicator color
    INC         L                                   ; Move to next position
    LD          (HL),A                              ; Set level indicator color
    LD          HL,COLRAM_SHIFT_MODE_IDX            ; Point to shift mode color area
    LD          BC,$1300                            ; Set B=19, C=0
    DEC         HL                                  ; Move back one position
ICON_GREY_FILL_LOOP:
    INC         HL                                  ; Move to next position
    LD          (HL),$f0                            ; Set color to WHT on BLK
    DJNZ        ICON_GREY_FILL_LOOP                 ; Repeat B times
    RET                                             ; Return to caller
