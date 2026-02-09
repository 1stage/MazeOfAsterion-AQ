

;==============================================================================
; KEY_BUFFER - Scan all keyboard columns and buffer results
;==============================================================================
; Scans all 8 keyboard columns and stores results in buffer.
;
; Registers:
; --- Start ---
;   none
; --- In Process ---
;   A  = Accumulator
;   B  = Column mask (rotated left each iteration)
;   C  = Keyboard port ($FF)
;   D  = Decremented counter
;   HL = Key input Buffer column address
; ---  End  ---
;   none
;
; Memory Modified: KEY_INPUT_COL0...7
;==============================================================================

KEY_BUFFER:
    LD          HL,KEY_INPUT_COL0                   ; Point to key input buffer start
    LD          BC,0xfeff                           ; C=$FF (port), B=$FE (column 0 mask)
    LD          D,0x8                               ; Set counter to 8 (8 columns to scan)
KEY_BUFFER_SCAN_LOOP:
    IN          A,(C)                               ; Read current keyboard column
    LD          (HL),A                              ; Store column data to key column buffer
    INC         HL                                  ; Advance to next buffer position
    RLC         B                                   ; Rotate column mask left (next column)
    DEC         D                                   ; Decrement column counter
    JP          NZ,KEY_BUFFER_SCAN_LOOP             ; Loop if more columns to scan
    RET                                             ; Done with KEYSCAN

;==============================================================================
; KEY_BUFFER_MASK_CHECK - Check key buffer mask (Z/NZ)
;==============================================================================
; Checks a mask against a single key column and returns with Z/NZ from AND.
; For single-bit masks, Z=pressed, NZ=not pressed (active-low buffer).
;
; Registers:
; --- Start ---
;   B  = Column index (0-7)
;   E  = Bit mask
; --- In Process ---
;   A  = Mask temp
;   C  = Column data (pressed=0)
;   D  = 0 (index high byte)
;   HL = Key buffer address
; ---  End  ---
;   F  = Z/NZ from AND
;
; Memory Modified: None
; Calls: None
;==============================================================================

KEY_BUFFER_MASK_CHECK:
    LD          A,E                                 ; A = mask (preserve for AND)
    LD          HL,KEY_INPUT_COL0                   ; Base of key buffer
    LD          E,B                                 ; E = column index (0-7)
    LD          D,0                                 ; D = 0 (index high byte)
    ADD         HL,DE                               ; HL = buffer + column index
    LD          C,(HL)                              ; C = column data (pressed=0)
    AND         C                                   ; Test selected key mask
    RET                                             ; Done

;==============================================================================
; KEY_BUFFER_CHECK - Process key buffer (single key, first match)
;==============================================================================
; Processes all 8 key column buffers and jumps to first match. No other actions
; after it are processed, so this is a ONE KEY per cycle handler.
;
; KEY_BUFFER_DONE inserted for each key as temporary "no action" jump.
;
; Registers:
; --- Start ---
;   none
; --- In Process ---
;   A  = Accumulator
;   HL = Key input Buffer column address
; ---  End  ---
;   none
;
; Memory Modified: none
;==============================================================================

KEY_BUFFER_CHECK:
KEY_BUFFER_COL0:
    LD          HL,KEY_INPUT_COL0                   ; HL = keyboard column 0 address
    LD          A,(HL)                              ; A = key column 0 scan value
    CP          $fe                                 ; Test row 0 "="
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fd                                 ; Test row 1 "BKSP"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fb                                 ; Test row 2 ":"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $f7                                 ; Test row 3 "RET"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $ef                                 ; Test row 4 ";"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $df                                 ; Test row 5 "."
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
KEY_BUFFER_COL1:
    INC         HL                                  ; Move to column 1
    LD          A,(HL)                              ; A = key column 1 scan value
    CP          $fe                                 ; Test row 0 "-"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fd                                 ; Test row 1 "/"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fb                                 ; Test row 2 "0"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $f7                                 ; Test row 3 "P"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $ef                                 ; Test row 4 "L"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $df                                 ; Test row 5 ","
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
KEY_BUFFER_COL2:
    INC         HL                                  ; Move to column 2
    LD          A,(HL)                              ; A = key column 2 scan value
    CP          $fe                                 ; Test row 0 "9"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fd                                 ; Test row 1 "O"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fb                                 ; Test row 2 "K"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $f7                                 ; Test row 3 "M"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $ef                                 ; Test row 4 "N"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $df                                 ; Test row 5 "J"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
KEY_BUFFER_COL3:
    INC         HL                                  ; Move to column 3
    LD          A,(HL)                              ; A = key column 3 scan value
    CP          $fe                                 ; Test row 0 "8"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fd                                 ; Test row 1 "I"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fb                                 ; Test row 2 "7"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $f7                                 ; Test row 3 "U"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $ef                                 ; Test row 4 "H"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $df                                 ; Test row 5 "B"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
KEY_BUFFER_COL4:
    INC         HL                                  ; Move to column 4
    LD          A,(HL)                              ; A = key column 4 scan value
    CP          $fe                                 ; Test row 0 "6"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fd                                 ; Test row 1 "Y"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fb                                 ; Test row 2 "G"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $f7                                 ; Test row 3 "V"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $ef                                 ; Test row 4 "C"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $df                                 ; Test row 5 "F"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
KEY_BUFFER_COL5:
    INC         HL                                  ; Move to column 5
    LD          A,(HL)                              ; A = key column 5 scan value
    CP          $fe                                 ; Test row 0 "5"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fd                                 ; Test row 1 "T"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fb                                 ; Test row 2 "4"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $f7                                 ; Test row 3 "R"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $ef                                 ; Test row 4 "D"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $df                                 ; Test row 5 "X"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore

KEY_BUFFER_COL6:
    INC         HL                                  ; Move to column 6
    LD          A,(HL)                              ; A = key column 6 scan value
    CP          $fe                                 ; Test row 0 "3"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fd                                 ; Test row 1 "E"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fb                                 ; Test row 2 "S"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $f7                                 ; Test row 3 "Z"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $ef                                 ; Test row 4 "SPC"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $df                                 ; Test row 5 "A"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
KEY_BUFFER_COL7:
    INC         HL                                  ; Move to column 7
    LD          A,(HL)                              ; A = key column 7 scan value
    CP          $fe                                 ; Test row 0 "2"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fd                                 ; Test row 1 "W"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $fb                                 ; Test row 2 "1"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $f7                                 ; Test row 3 "Q"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $ef                                 ; Test row 4 "SHFT"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    CP          $df                                 ; Test row 5 "CTRL"
    JP          Z,KEY_BUFFER_DONE                   ; If pressed, ignore
    JP          KEY_BUFFER_DONE                        ; No valid key, ignore

KEY_BUFFER_DONE:
    RET

;==============================================================================
; KEY_BUFFER_INV - Scan all keyboard columns (inverted) to $3C00-$3C07
;==============================================================================
; Scans all 8 keyboard columns and stores results in $3C00-$3C07 with
; inverted logic (pressed keys = 1).
;
; Registers:
; --- Start ---
;   none
; --- In Process ---
;   A  = Accumulator
;   B  = Column mask (rotated left each iteration)
;   C  = Keyboard port ($FF)
;   D  = Decremented counter
;   HL = ...COLx_BITS buffer address
; ---  End  ---
;   none
;   F  = Z/NZ from last DEC
;
; Memory Modified: KEYBOARD_COL0_INV_BITS ... KEYBOARD_COL7_INV_BITS
; Calls: None
;==============================================================================

KEY_BUFFER_INV:
    LD          HL,KEYBOARD_COL0_INV_BITS           ; Point to inverted key buffer start
    LD          BC,0xfeff                           ; C=$FF (port), B=$FE (column 0 mask)
    LD          D,0x8                               ; Set counter to 8 (8 columns to scan)
KEY_BUFFER_INV_LOOP:
    IN          A,(C)                               ; Read current keyboard column
    CPL                                             ; A = !A ; Invert so pressed keys = 1
    LD          (HL),A                              ; Store inverted column data
    INC         HL                                  ; Advance to next buffer position
    RLC         B                                   ; Rotate column mask left (next column)
    DEC         D                                   ; Decrement column counter
    JP          NZ,KEY_BUFFER_INV_LOOP              ; Loop if more columns to scan
    RET                                             ; Done with scan

;==============================================================================
; KEY_BUFFER_INV_BIT_CHECK - Check inverted key buffer bit (Z/NZ)
;==============================================================================
; Checks a single bit in the inverted key buffer and returns with Z/NZ from BIT
; (Z=not pressed, NZ=pressed).
;
; Registers:
; --- Start ---
;   B  = Column index (0-7)
;   E  = Bit index (0-5)
; --- In Process ---
;   A  = Bit index temp
;   C  = Column data (pressed=1)
;   D  = 0 (index high byte)
;   HL = Inverted key buffer address
; ---  End  ---
;   F  = Z/NZ from BIT (Z=not pressed, NZ=pressed)
;
; Memory Modified: None
; Calls: None
;==============================================================================

KEY_BUFFER_INV_BIT_CHECK:
    LD          A,E                                 ; A = bit index (preserve for later)
    LD          HL,KEYBOARD_COL0_INV_BITS           ; Base of inverted key buffer
    LD          E,B                                 ; E = column index (0-7)
    LD          D,0                                 ; D = 0 (index high byte)
    ADD         HL,DE                               ; HL = buffer + column index
    LD          C,(HL)                              ; C = column data (pressed=1)
    LD          HL,KEY_BIT_MASK_TABLE               ; Base of bit mask table
    LD          E,A                                 ; E = bit index (0-7)
    LD          D,0                                 ; D = 0 (index high byte)
    ADD         HL,DE                               ; HL = mask table + bit index
    LD          A,(HL)                              ; A = mask
    AND         C                                   ; Test selected key bit
    RET                                             ; Done

;==============================================================================
; KEY_BIT_MASK_TABLE - Masks for bit tests (0-7)
;==============================================================================

KEY_BIT_MASK_TABLE:
    DB          $01,$02,$04,$08,$10,$20,$40,$80


;==============================================================================
; KEY_BUFFER_INV_MASK_CHECK - Check inverted key buffer mask (Z/NZ)
;==============================================================================
; Checks a mask against a single inverted key column and returns with Z/NZ
; from AND (Z=no masked keys pressed, NZ=at least one pressed).
;
; Registers:
; --- Start ---
;   B  = Column index (0-7)
;   E  = Bit mask
; --- In Process ---
;   A  = Mask temp
;   C  = Column data (pressed=1)
;   D  = 0 (index high byte)
;   HL = Inverted key buffer address
; ---  End  ---
;   F  = Z/NZ from AND
;
; Memory Modified: None
; Calls: None
;==============================================================================

KEY_BUFFER_INV_MASK_CHECK:
    LD          A,E                                 ; A = mask (preserve for AND)
    LD          HL,KEYBOARD_COL0_INV_BITS           ; Base of inverted key buffer
    LD          E,B                                 ; E = column index (0-7)
    LD          D,0                                 ; D = 0 (index high byte)
    ADD         HL,DE                               ; HL = buffer + column index
    LD          C,(HL)                              ; C = column data (pressed=1)
    AND         C                                   ; Test selected key mask
    RET                                             ; Done

