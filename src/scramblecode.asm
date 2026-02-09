; Aquarius SCRAMBLECODE include file
; Bytes map to the cartridge header at $E000-$E00F.
; ROM check constants at $E005,$E007,$E009,$E00B,$E00D,$E00F: 9C,B0,6C,64,A8,70.
; Scramble code: (sum $E003-$E00E + 78) mod 256 XOR $E00F.
;
; MAKE NO CHANGES TO THE CODE BELOW! Edit scramble seeds in the asterion.inc file instead!
;
SCRAMBLECODE:
    DB $3e,$5b,$5e,SCRAMBLE_SEED_0
    DB SCRAMBLE_SEED_1,$9c,SCRAMBLE_SEED_2,$b0
    DB SCRAMBLE_SEED_3,$6c,SCRAMBLE_SEED_4,$64
    DB SCRAMBLE_SEED_5,$a8,SCRAMBLE_SEED_6,$70
    
; Original hard-coded bytes (reference)
;     DB 0x3e,0x5b,0x5e,0x00    ; $E000-$E003
;     DB 0x00,0x9c,0x00,0xb0    ; $E004-$E007 (L,E constants)
;     DB 0x00,0x6c,0x00,0x64    ; $E008-$E00B (T,T constants)
;     DB 0x00,0xa8,0x5e,0x70    ; $E00C-$E00F (A, extra, M)
