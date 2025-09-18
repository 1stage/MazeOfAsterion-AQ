; ==============================================================================
; Custom Character Set for Maze of Asterion
; ==============================================================================
; Character definitions for dungeon graphics
; Each character is 8x8 pixels, 8 bytes per character

; Character definitions (to be loaded into Character RAM)
; Format: 8 bytes per character, each byte represents one row of pixels

; Character $96 - Horizontal Wall
char_wall_horizontal:
        DEFB %11111111          ; ████████
        DEFB %10000001          ; █      █
        DEFB %10000001          ; █      █
        DEFB %11111111          ; ████████
        DEFB %11111111          ; ████████
        DEFB %10000001          ; █      █
        DEFB %10000001          ; █      █
        DEFB %11111111          ; ████████

; Character $95 - Vertical Wall
char_wall_vertical:
        DEFB %11001100          ; ██  ██  
        DEFB %11001100          ; ██  ██  
        DEFB %11001100          ; ██  ██  
        DEFB %11001100          ; ██  ██  
        DEFB %11001100          ; ██  ██  
        DEFB %11001100          ; ██  ██  
        DEFB %11001100          ; ██  ██  
        DEFB %11001100          ; ██  ██  

; Character $97 - Top-Left Corner
char_corner_tl:
        DEFB %11111111          ; ████████
        DEFB %10000000          ; █       
        DEFB %10000000          ; █       
        DEFB %10000000          ; █       
        DEFB %10000000          ; █       
        DEFB %10000000          ; █       
        DEFB %10000000          ; █       
        DEFB %11111111          ; ████████

; Character $98 - Top-Right Corner
char_corner_tr:
        DEFB %11111111          ; ████████
        DEFB %00000001          ;       █
        DEFB %00000001          ;       █
        DEFB %00000001          ;       █
        DEFB %00000001          ;       █
        DEFB %00000001          ;       █
        DEFB %00000001          ;       █
        DEFB %11111111          ; ████████

; Character $99 - Bottom-Left Corner
char_corner_bl:
        DEFB %11111111          ; ████████
        DEFB %10000000          ; █       
        DEFB %10000000          ; █       
        DEFB %10000000          ; █       
        DEFB %10000000          ; █       
        DEFB %10000000          ; █       
        DEFB %10000000          ; █       
        DEFB %11111111          ; ████████

; Character $9A - Bottom-Right Corner
char_corner_br:
        DEFB %11111111          ; ████████
        DEFB %00000001          ;       █
        DEFB %00000001          ;       █
        DEFB %00000001          ;       █
        DEFB %00000001          ;       █
        DEFB %00000001          ;       █
        DEFB %00000001          ;       █
        DEFB %11111111          ; ████████

; Character $9B - Open Door
char_door_open:
        DEFB %11100000          ; ███     
        DEFB %10100000          ; █ █     
        DEFB %10100000          ; █ █     
        DEFB %10100000          ; █ █     
        DEFB %10100000          ; █ █     
        DEFB %10100000          ; █ █     
        DEFB %10100000          ; █ █     
        DEFB %11100000          ; ███     

; Character $9C - Closed Door
char_door_closed:
        DEFB %11111111          ; ████████
        DEFB %10000001          ; █      █
        DEFB %10111001          ; █ ███  █
        DEFB %10100001          ; █ █    █
        DEFB %10100001          ; █ █    █
        DEFB %10111001          ; █ ███  █
        DEFB %10000001          ; █      █
        DEFB %11111111          ; ████████

; Character $9D - Stairs Up
char_stairs_up:
        DEFB %00000001          ;       █
        DEFB %00000011          ;      ██
        DEFB %00000111          ;     ███
        DEFB %00001111          ;    ████
        DEFB %00011111          ;   █████
        DEFB %00111111          ;  ██████
        DEFB %01111111          ; ███████
        DEFB %11111111          ; ████████

; Character $9E - Stairs Down
char_stairs_down:
        DEFB %11111111          ; ████████
        DEFB %01111111          ; ███████
        DEFB %00111111          ;  ██████
        DEFB %00011111          ;   █████
        DEFB %00001111          ;    ████
        DEFB %00000111          ;     ███
        DEFB %00000011          ;      ██
        DEFB %00000001          ;       █

; Character $9F - Treasure Chest
char_treasure:
        DEFB %01111110          ;  ██████ 
        DEFB %11111111          ; ████████
        DEFB %11000011          ; ██    ██
        DEFB %11111111          ; ████████
        DEFB %11111111          ; ████████
        DEFB %11111111          ; ████████
        DEFB %11111111          ; ████████
        DEFB %01111110          ;  ██████ 

; Character $A0 - Monster (Generic)
char_monster:
        DEFB %00111100          ;   ████  
        DEFB %01100110          ;  ██  ██ 
        DEFB %11100111          ; ███  ███
        DEFB %11111111          ; ████████
        DEFB %01111110          ;  ██████ 
        DEFB %00111100          ;   ████  
        DEFB %01011010          ;  █ ██ █ 
        DEFB %10000001          ; █      █

; Character $A1 - Player Character
char_player:
        DEFB %00111100          ;   ████  
        DEFB %01111110          ;  ██████ 
        DEFB %01111110          ;  ██████ 
        DEFB %00111100          ;   ████  
        DEFB %01111110          ;  ██████ 
        DEFB %00111100          ;   ████  
        DEFB %01000010          ;  █    █ 
        DEFB %11000011          ; ██    ██

; Character set table for easy loading
character_set_data:
        ; Include all character definitions
        INCLUDE "char_wall_horizontal"
        INCLUDE "char_wall_vertical"
        INCLUDE "char_corner_tl"
        INCLUDE "char_corner_tr"
        INCLUDE "char_corner_bl"
        INCLUDE "char_corner_br"
        INCLUDE "char_door_open"
        INCLUDE "char_door_closed"
        INCLUDE "char_stairs_up"
        INCLUDE "char_stairs_down"
        INCLUDE "char_treasure"
        INCLUDE "char_monster"
        INCLUDE "char_player"

character_set_end: