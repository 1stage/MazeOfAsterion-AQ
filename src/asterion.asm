INCLUDE "aquarius.inc"
INCLUDE "asterion.inc"

org $c000

include "asterion_gfx.asm"
include "asterion_func_low.asm"
   defs         $1800 - $, $00

TITLE_SCREEN:
INCBIN "asterion_title.scr"

TS_EYES_OPEN_CHR EQU TITLE_SCREEN + 726
TITLE_SCREEN_COL EQU TITLE_SCREEN + 1024
TS_EYES_OPTN_COL EQU TITLE_SCREEN + 1750

include "scramblecode.asm"

include "asterion_high_rom.asm"
    defs         $3EFF - $, $00
    
include "asterion_gfx_pointers.asm"
    defs         $4000 - $, $00