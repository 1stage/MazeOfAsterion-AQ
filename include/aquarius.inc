; ==============================================================================
; Mattel Aquarius Hardware Definitions
; ==============================================================================
; Memory map and I/O port definitions for the Mattel Aquarius computer
; This file contains the system constants needed for ROM cartridge development

; ==============================================================================
; MEMORY MAP
; ==============================================================================

; System memory areas
CARTRIDGE_ROM_START     EQU $0000   ; Cartridge ROM starts at 0000h
CARTRIDGE_ROM_END       EQU $3FFF   ; Cartridge ROM can be up to 16KB
SYSTEM_RAM_START        EQU $4000   ; System RAM starts at 4000h  
SYSTEM_RAM_END          EQU $7FFF   ; System RAM up to 7FFFh (16KB)
CHARACTER_RAM_START     EQU $3000   ; Character RAM (part of cartridge space)
CHARACTER_RAM_SIZE      EQU $0800   ; 2KB character RAM
VIDEO_RAM_START         EQU $3400   ; Video RAM
VIDEO_RAM_SIZE          EQU $0400   ; 1KB video RAM
COLOR_RAM_START         EQU $3800   ; Color RAM
COLOR_RAM_SIZE          EQU $0400   ; 1KB color RAM

; Screen dimensions
SCREEN_WIDTH            EQU 40      ; Screen width in characters
SCREEN_HEIGHT           EQU 25      ; Screen height in characters
SCREEN_SIZE             EQU SCREEN_WIDTH * SCREEN_HEIGHT

; ==============================================================================
; I/O PORTS
; ==============================================================================

; Sound chip (AY-3-8910)
SOUND_LATCH             EQU $F6     ; Sound chip latch register
SOUND_DATA              EQU $F7     ; Sound chip data register

; Keyboard
KEYBOARD_PORT           EQU $FF     ; Keyboard input port

; Printer port
PRINTER_PORT            EQU $FE     ; Printer control port

; ==============================================================================
; KEYBOARD SCAN CODES
; ==============================================================================

; Keyboard matrix scan codes
KEY_ESC                 EQU $01
KEY_1                   EQU $02
KEY_2                   EQU $03
KEY_3                   EQU $04
KEY_4                   EQU $05
KEY_5                   EQU $06
KEY_6                   EQU $07
KEY_7                   EQU $08
KEY_8                   EQU $09
KEY_9                   EQU $0A
KEY_0                   EQU $0B
KEY_MINUS               EQU $0C
KEY_EQUALS              EQU $0D
KEY_BACKSPACE           EQU $0E

KEY_Q                   EQU $10
KEY_W                   EQU $11
KEY_E                   EQU $12
KEY_R                   EQU $13
KEY_T                   EQU $14
KEY_Y                   EQU $15
KEY_U                   EQU $16
KEY_I                   EQU $17
KEY_O                   EQU $18
KEY_P                   EQU $19

KEY_A                   EQU $1E
KEY_S                   EQU $1F
KEY_D                   EQU $20
KEY_F                   EQU $21
KEY_G                   EQU $22
KEY_H                   EQU $23
KEY_J                   EQU $24
KEY_K                   EQU $25
KEY_L                   EQU $26

KEY_Z                   EQU $2C
KEY_X                   EQU $2D
KEY_C                   EQU $2E
KEY_V                   EQU $2F
KEY_B                   EQU $30
KEY_N                   EQU $31
KEY_M                   EQU $32

KEY_SPACE               EQU $39
KEY_ENTER               EQU $1C

; Arrow keys (if available)
KEY_UP                  EQU $48
KEY_DOWN                EQU $50
KEY_LEFT                EQU $4B
KEY_RIGHT               EQU $4D

; ==============================================================================
; CHARACTER CODES
; ==============================================================================

; Special characters for dungeon graphics
CHAR_WALL_HORIZONTAL    EQU $96     ; Horizontal wall character
CHAR_WALL_VERTICAL      EQU $95     ; Vertical wall character
CHAR_CORNER_TL          EQU $97     ; Top-left corner
CHAR_CORNER_TR          EQU $98     ; Top-right corner  
CHAR_CORNER_BL          EQU $99     ; Bottom-left corner
CHAR_CORNER_BR          EQU $9A     ; Bottom-right corner
CHAR_DOOR_OPEN          EQU $9B     ; Open door
CHAR_DOOR_CLOSED        EQU $9C     ; Closed door
CHAR_STAIRS_UP          EQU $9D     ; Stairs going up
CHAR_STAIRS_DOWN        EQU $9E     ; Stairs going down
CHAR_TREASURE           EQU $9F     ; Treasure chest
CHAR_MONSTER            EQU $A0     ; Generic monster
CHAR_PLAYER             EQU $A1     ; Player character

; Standard ASCII characters
CHAR_SPACE              EQU $20
CHAR_0                  EQU $30
CHAR_9                  EQU $39
CHAR_A                  EQU $41
CHAR_Z                  EQU $5A

; ==============================================================================
; COLOR DEFINITIONS
; ==============================================================================

; Color values for Aquarius (4-bit color)
COLOR_BLACK             EQU $00
COLOR_RED               EQU $01
COLOR_GREEN             EQU $02
COLOR_YELLOW            EQU $03
COLOR_BLUE              EQU $04
COLOR_MAGENTA           EQU $05
COLOR_CYAN              EQU $06
COLOR_WHITE             EQU $07
COLOR_GRAY              EQU $08
COLOR_BRIGHT_RED        EQU $09
COLOR_BRIGHT_GREEN      EQU $0A
COLOR_BRIGHT_YELLOW     EQU $0B
COLOR_BRIGHT_BLUE       EQU $0C
COLOR_BRIGHT_MAGENTA    EQU $0D
COLOR_BRIGHT_CYAN       EQU $0E
COLOR_BRIGHT_WHITE      EQU $0F

; Default colors for different game elements
COLOR_WALL              EQU COLOR_WHITE
COLOR_FLOOR             EQU COLOR_BLACK
COLOR_DOOR              EQU COLOR_YELLOW
COLOR_TREASURE          EQU COLOR_BRIGHT_YELLOW
COLOR_MONSTER           EQU COLOR_RED
COLOR_PLAYER            EQU COLOR_BRIGHT_GREEN
COLOR_TEXT              EQU COLOR_WHITE

; ==============================================================================
; CARTRIDGE ROM HEADER
; ==============================================================================

; Cartridge identification bytes (Aquarius ROM format)
CARTRIDGE_ID1           EQU $AA     ; First ID byte
CARTRIDGE_ID2           EQU $55     ; Second ID byte