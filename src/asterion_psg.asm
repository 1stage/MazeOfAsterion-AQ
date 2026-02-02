;==============================================================================
; ASTERION_PSG.ASM
;==============================================================================
; PSG (AY-3-8910) Detection and Control Routines
; 
; This module provides runtime detection of the optional AY-3-8910 sound chip
; (Mattel Aquarius Mini-Expander) and initialization routines for enhanced
; sound capabilities when available.
;
; NOTE: This file is not yet integrated into the build. It will be included
; when ROM space optimization allows. Reference in build process when ready.
;
; Requires: asterion.inc, aquarius.inc
;==============================================================================

;==============================================================================
; PSG_DETECT
;==============================================================================
; Detect AY-3-8910 PSG chip presence via read-back test on register 6.
; Safely tests if PSG is available without corrupting game state.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   BC = PSG port addressing ($F7 latch, $F6 data)
;   A  = Register select, test value, read-back value
; --- End ---
;   PSG_AVAILABLE = $00 if PSG absent, $01 if present
;   All PSG registers restored to original state
;
; Memory Modified: PSG_AVAILABLE ($3abc)
; Calls: None
;==============================================================================
PSG_DETECT:
    LD          C,PSG_REGS                          ; C = PSG latch port ($F7)
    LD          A,6                                 ; A = register 6 (noise period)
    OUT         (C),A                               ; Select register 6
    DEC         C                                   ; C = PSG data port ($F6)
    IN          A,(C)                               ; Read current noise period value
    PUSH        AF                                  ; Save original value on stack
    
    LD          A,$15                               ; A = test pattern ($15 = 0001 0101)
    OUT         (C),A                               ; Write test pattern to register 6
    NOP                                             ; Small delay for chip response
    NOP
    
    LD          C,PSG_REGS                          ; C = PSG latch port
    LD          A,6                                 ; A = register 6
    OUT         (C),A                               ; Re-select register 6
    DEC         C                                   ; C = PSG data port
    IN          A,(C)                               ; Read back test value
    
    CP          $15                                 ; Compare read-back to test pattern
    LD          A,0                                 ; A = 0 (assume PSG absent)
    JR          NZ,PSG_DETECT_RESTORE               ; If mismatch, PSG is absent
    LD          A,1                                 ; A = 1 (PSG is present)
    
PSG_DETECT_RESTORE:
    LD          B,A                                 ; B = PSG presence result (0 or 1)
    
    POP         AF                                  ; Restore original R6 value
    LD          C,PSG_REGS                          ; C = PSG latch port
    LD          H,6                                 ; H = register 6
    OUT         (C),H                               ; Select register 6
    DEC         C                                   ; C = PSG data port
    OUT         (C),A                               ; Restore original R6 value
    
    LD          A,B                                 ; A = PSG presence (0 or 1)
    LD          (PSG_AVAILABLE),A                   ; Store result in memory
    
    RET                                             ; Return to caller

;==============================================================================
; Integration Notes
;==============================================================================
;
; 1. PSG_AVAILABLE is already defined in asterion.inc at $3abc
;    PSG_AVAILABLE EQU $3abc    ; PSG chip presence flag (0=absent, 1=present)
;
; 2. Include in build file after asterion_high_rom.asm:
;      INCLUDE "asterion_psg.asm"
;
; 3. Call PSG_DETECT in GAMEINIT, before PSG_MIXER_RESET:
;      CALL        PSG_DETECT
;      CALL        PSG_MIXER_RESET
;
; 4. Later in code, check PSG availability:
;      LD          A,(PSG_AVAILABLE)
;      OR          A
;      JP          NZ,USE_PSG_SOUND    ; Branch if PSG present
;
;==============================================================================
