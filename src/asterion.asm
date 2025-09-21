INCLUDE "aquarius.inc"
INCLUDE "asterion.inc"

org $c000

include "asterion_low_rom.asm"

TITLE_SCREEN:
INCBIN "asterion_title.scr"

include "scramblecode.asm"

include "asterion_high_rom.asm"