; Aquarius SYSROM Routines
SLEEP_ZERO EQU $1d48        
SLEEP EQU $1d4b        
FILL_FULL_1024 EQU $1e59        

; CHRRAM - Character RAM
CHRRAM EQU $3000 

; COLRAM: Color RAM
COLRAM EQU $3400 

; Aquarius IO ports
MODEM_A EQU $7E
MODEM_B EQU $7F
CONTROL_PADS EQU $F6
PSG EQU $F7
SPEAKER EQU $FC
VSYNC EQU $FD
PRINTER EQU $FE
KEYBOARD EQU $FF

; Aquarius Graphics Macros

; AQUASCII Character descriptions, shorthand 
CHAR_RT_ANGLE   EQU $C0
CHAR_LT_ANGLE   EQU $C1
CHAR_BOTTOM_LINE    EQU $90

; Color values for Aquarius system
; Background and Foreground colors (4-bit each)
BLK     EQU 0      ; Black
RED     EQU 1      ; Red  
GRN     EQU 2      ; Green
YEL     EQU 3      ; Yellow
BLU     EQU 4      ; Blue
MAG     EQU 5      ; Magenta
CYN     EQU 6      ; Cyan
WHT     EQU 7      ; White
GRY     EQU 8      ; Light Gray
DKCYN   EQU 9      ; Dark Cyan
DKMAG   EQU 10     ; Dark Magenta
DKBLU   EQU 11     ; Dark Blue
LTYEL   EQU 12     ; Light Yellow
DKGRN   EQU 13     ; Dark Green
DKRED   EQU 14     ; Dark Red
DKGRY   EQU 15     ; Dark Grey

#define COLOR(fg,bg) (fg * 16) + bg

#define RECT(width,height) (width * 256) + height