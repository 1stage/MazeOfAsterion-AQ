INCLUDE "aquarius.inc"
INCLUDE "asterion.inc"

org $c000

include "asterion_low_rom.asm"

TITLE_SCREEN:
INCBIN "asterion_title.scr"

TS_EYES_OPEN_CHR EQU TITLE_SCREEN + 726
TITLE_SCREEN_COL EQU TITLE_SCREEN + 1024
TS_EYES_OPTN_COL EQU TITLE_SCREEN + 1750

include "scramblecode.asm"

include "asterion_high_rom.asm"