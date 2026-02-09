;==============================================================================
; MUSICSCAN.ASM
;==============================================================================
; Intellivision ECS Music Synthesizer keyboard scan routines.
;
; Requires: aquarius.inc, asterion.inc
;==============================================================================

;==============================================================================
; MUSIC_SCAN_MATRIX
;==============================================================================
; Set PSG to keyboard-matrix mode (Port B = output, Port A = input), scan
; 8 columns x 8 rows, store inverted results in KEYBOARD_COL0_INV_BITS..7,
; then restore PSG to its prior mode.
;
; Assumptions:
; - AY-3-8910 register 7 bits 6/7 control Port A/B direction (0=input, 1=output)
; - Port B drives column mask, Port A reads row bits
; - Active-low keyboard matrix (pressed = 0), inverted on store
;
; Registers:
; --- Start ---
;   none
; --- In Process ---
;   A  = PSG register select, data, scan values
;   B  = Column mask
;   C  = PSG port selector
;   D  = Column counter
;   HL = KEYBOARD_COLx_INV_BITS buffer address
; ---  End  ---
;   none
;
; Memory Modified: KEYBOARD_COL0_INV_BITS..KEYBOARD_COL7_INV_BITS
; Calls: None
;==============================================================================

MUSIC_SCAN_MATRIX:
    LD          C,PSG_REGS                          ; C = PSG register select port ($F7)
    LD          A,7                                 ; A = register 7 (mixer / I/O enable)
    OUT         (C),A                               ; Select register 7
    DEC         C                                   ; C = PSG data port ($F6)
    IN          A,(C)                               ; Read current register 7 value
    LD          B,A                                 ; B = original register 7 value
    PUSH        AF                                  ; Save original register 7

    INC         C                                   ; C = PSG register select port
    LD          A,7                                 ; A = register 7
    OUT         (C),A                               ; Select register 7
    DEC         C                                   ; C = PSG data port
    LD          A,B                                 ; A = original register 7 value
    AND         $3F                                 ; Clear I/O direction bits
    OR          $80                                 ; Port B = output, Port A = input
    OUT         (C),A                               ; Set keyboard-matrix mode

    INC         C                                   ; C = PSG register select port
    LD          A,15                                ; A = register 15 (Port B data)
    OUT         (C),A                               ; Select register 14
    DEC         C                                   ; C = PSG data port
    IN          A,(C)                               ; Read current Port B output
    PUSH        AF                                  ; Save original Port B output

    LD          HL,KEYBOARD_COL0_INV_BITS           ; HL = output buffer base
    LD          B,$FE                               ; B = initial column mask (active low)
    LD          D,8                                 ; D = column counter
MUSIC_SCAN_LOOP:
    LD          C,PSG_REGS                          ; C = PSG register select port
    LD          A,15                                ; A = register 15 (Port B data)
    OUT         (C),A                               ; Select register 14
    DEC         C                                   ; C = PSG data port
    LD          A,B                                 ; A = column mask
    OUT         (C),A                               ; Drive current column

    INC         C                                   ; C = PSG register select port
    LD          A,14                                ; A = register 14 (Port A data)
    OUT         (C),A                               ; Select register 15
    DEC         C                                   ; C = PSG data port
    IN          A,(C)                               ; Read row inputs
    CPL                                             ; Invert so pressed keys = 1
    LD          (HL),A                              ; Store inverted row bits

    INC         HL                                  ; Advance buffer pointer
    RLC         B                                   ; Next column mask
    DEC         D                                   ; Decrement column counter
    JP          NZ,MUSIC_SCAN_LOOP                  ; Continue scanning columns

    LD          C,PSG_REGS                          ; C = PSG register select port
    LD          A,15                                ; A = register 15
    OUT         (C),A                               ; Select register 14
    DEC         C                                   ; C = PSG data port
    POP         AF                                  ; Restore original Port B output
    OUT         (C),A                               ; Write Port B output

    INC         C                                   ; C = PSG register select port
    LD          A,7                                 ; A = register 7
    OUT         (C),A                               ; Select register 7
    DEC         C                                   ; C = PSG data port
    POP         AF                                  ; Restore original register 7 value
    OUT         (C),A                               ; Restore PSG mode

    RET                                             ; Done
