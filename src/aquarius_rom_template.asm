; Aquarius ROM Cartridge Template for z88dk
; SCRAMBLECODE at $e000, entry at $e010
; CHRRAM/Screen RAM: $3000-$33ff
; COLRAM/Color RAM: $3400-$37ff
; RAM: $3800-$3fff

; --- SCRAMBLECODE (16 bytes) ---
    INCLUDE "aquarius_rom_scramblecode.inc"

    ORG $e010

; --- Entry Point ---
START:
    JP MAIN

; --- Main Program ---
MAIN:
    ; Example: Clear screen
    LD HL, $3000        ; CHRRAM start
    LD DE, $3001
    LD BC, 0x03FF       ; 1024 bytes
    LD (HL), 0x20       ; Space character
    LDIR

    LD HL, $3400        ; COLRAM start
    LD DE, $3401
    LD BC, 0x03FF
    LD (HL), 0x01       ; Color index 1
    LDIR

    ; Example: Set border
    LD A, 0x20           ; Space
    LD ($3000), A
    LD A, 0x01           ; Color index 1
    LD ($3400), A

    ; Infinite loop
    JP $

; --- End of ROM ---
