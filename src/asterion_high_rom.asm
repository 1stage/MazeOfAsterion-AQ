;==============================================================================
; GAMEINIT - Initialize game state and display title screen
;==============================================================================
;   - Resets stack pointer and clears all game variables
;   - Initializes game state values in memory ($3A62-$3A8B)
;   - Clears screen memory (CHRRAM and COLRAM)
;   - Configures PSG (Programmable Sound Generator)
;   - Displays title screen and transfers to input handling
; Registers:
; --- Start ---
;   None (system entry point)
; --- In Process ---
;   SP = $3FFF (stack pointer reset)
;   A  = Variable initialization values, I/O operations, R register read
;   BC = PSG port addressing ($7E/$7F), fill values for FILL_FULL_1024
;   DE = Variable space clearing (via WIPE_VARIABLE_SPACE)
;   HL = Memory addressing for variable init, CHRRAM/COLRAM fills, timer/RNG setup
; ---  End  ---
;   Does not return - jumps to INPUT_DEBOUNCE
;   CHRRAM filled with SPACE characters
;   COLRAM filled with BLK on CYN
;   Title screen displayed
;   All game variables initialized
;
GAMEINIT:
    LD          SP,$3fff                            ; Reset stack pointer (top of BANK0 RAM)
RESET_POST_SP:
    CALL        WIPE_VARIABLE_SPACE                 ; Clear variable region; HL now at start of init block ($3A62)
    LD          (HL),0x2                            ; Store constant 02 at $3A62 (game/state flag)
    INC         L                                   ; Advance to $3A63
    LD          A,$32                               ; A = 32 (ASCII '2' or preset timer/item value)
    LD          (HL),A                              ; Store 32 at $3A63
    INC         L                                   ; Advance to $3A64
    LD          (HL),A                              ; Store 32 at $3A64
    INC         L                                   ; Advance to $3A65
    LD          (HL),A                              ; Store 32 at $3A65
    INC         L                                   ; Advance to $3A66
    DEC         A                                   ; A = 31 (adjust constant for next slots)
    LD          (HL),A                              ; Store 31 at $3A66
    INC         L                                   ; Advance to $3A67
    LD          (HL),A                              ; Store 31 at $3A67
    INC         L                                   ; Advance to $3A68 (start of zero block)
    LD          B,$12                               ; Loop counter: 18 bytes to zero ($12)
    XOR         A                                   ; A = 00 (zero fill value)
INIT_ZERO_VAR_BLOCK_LOOP:
    LD          (HL),A                              ; Zero current byte
    INC         L                                   ; Advance to next byte in zero region
    DJNZ        INIT_ZERO_VAR_BLOCK_LOOP            ; Continue until B exhausted
    LD          A,$18                               ; A = 18 (preset value for next slot)
    LD          (HL),A                              ; Store 18 at current address ($3A7A)
    INC         HL                                  ; Move to $3A7B (start of $FE fill block)
    LD          A,$fe                               ; A = FE (empty/sentinel marker value)
    LD          B,$10                               ; Loop counter: 16 bytes to fill with FE
RESET_ITEM_ANIM_VARS_LOOP:
    LD          (HL),A                              ; Store FE in current slot
    INC         HL                                  ; Advance to next slot
    DJNZ        RESET_ITEM_ANIM_VARS_LOOP           ; Repeat until 16 bytes filled with FE
    LD          B,$20                               ; B = 20 (SPACE char for screen clear)
    LD          HL,CHRRAM                           ; HL = start of character RAM ($3000)
    CALL        FILL_FULL_1024                      ; Clear CHRRAM with SPACE
    LD          HL,$5e                              ; HL = initial timer seed value ($005E)
    LD          (RND_SEED_POLY),HL                  ; Store timer seed
    LD          A,R                                 ; Read R register (pseudo-random)
    LD          H,A                                 ; Copy random byte to H
    LD          (RND_SEED_LFSR),HL                  ; Seed random hold variable
    
;==============================================================================
; PSG_MIXER_RESET
;==============================================================================
; Silence all PSG (AY-3-8910) channels via mixer register configuration.
; Sets register 7 (mixer control) with all bits = 1, disabling tone and noise
; outputs on all three channels (A, B, C).
;
; Register 7 Bit Layout (write $3F to disable all):
;   Bit 0-2: Tone enable for channels A/B/C (0=on, 1=off)
;   Bit 3-5: Noise enable for channels A/B/C (0=on, 1=off)
;   Bit 6-7: I/O port direction (not used here)
;
; Registers:
; --- Start ---
;   BC = $007F (PSG latch port), A = $07 (register select)
; --- In Process ---
;   C transitions $7F -> $7E (PSG data port), A = $3F (disable all mixer)
; --- End ---
;   PSG register 7 = $3F (all channels silenced)
;   Falls through to COLRAM clear and title setup
;
; Memory Modified: PSG register 7 via ports $7F/$7E
; Calls: None (falls through to subsequent code)
;==============================================================================
PSG_MIXER_RESET:
    LD          BC,$7f                              ; BC = PSG ports ($7F latch, $7E data)
    LD          A,0x7                               ; A = register 7 (mixer control)
    OUT         (C),A                               ; Write register select to $7F
    DEC         C                                   ; C = $7E (data write port)
    LD          A,$3f                               ; A = $3F (all bits=1 disables all channels)
    OUT         (C),A                               ; Write $3F to register 7, silencing PSG

    LD          B,0x6                               ; B = color fill value for COLRAM (palette constant)

;==============================================================================
; CLEAR_COLRAM_DEFAULT - Initialize color RAM and draw title screen
;==============================================================================
; Clears entire color RAM to default cyan background, prepares item graphics
; state, draws the title screen, and transfers control to input debounce.
; This is typically called during game initialization after PSG setup.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   B  = COLOR(BLK,CYN) fill value
;   HL = COLRAM base ($3400)
;   Used by FILL_FULL_1024, CHK_ITEM, DRAW_TITLE, INPUT_DEBOUNCE
; ---  End  ---
;   Does not return (jumps to INPUT_DEBOUNCE)
;
; Memory Modified: COLRAM ($3400-$37FF), CHRRAM via DRAW_TITLE
; Calls: FILL_FULL_1024, CHK_ITEM, DRAW_TITLE, INPUT_DEBOUNCE (jump)
;==============================================================================
CLEAR_COLRAM_DEFAULT:
    LD          B,COLOR(BLK,CYN)                    ; B = BLK on CYN (0x06) uniform background color
    LD          HL,COLRAM                           ; HL = start of color RAM ($3400)
    CALL        FILL_FULL_1024                      ; Clear COLRAM with uniform color
    CALL        CHK_ITEM                            ; Prepare item graphics state (side-effects only)
    CALL        DRAW_TITLE                          ; Draw title screen (CHR + COLRAM)
    JP          INPUT_DEBOUNCE                      ; Transfer to input debounce handler (no return)

;==============================================================================
; DRAW_TITLE
;==============================================================================
; Copy title screen graphics to display memory
;   - Copies 1000 bytes of character data from TITLE_SCREEN to CHRRAM
;   - Copies 1000 bytes of color data from TITLE_SCREEN_COL to COLRAM
;   - Uses Z80 LDIR instruction for fast block memory transfer
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   BC = $03E8 (1000 bytes transfer count for LDIR)
;   DE = Destination pointer (CHRRAM $3000, then COLRAM $3400)
;   HL = Source pointer (TITLE_SCREEN, then TITLE_SCREEN_COL)
; ---  End  ---
;   BC = $0000 (decremented to zero by LDIR)
;   DE = $33E8 (CHRRAM end), then $37E8 (COLRAM end)
;   HL = End of source data (TITLE_SCREEN + 1000, TITLE_SCREEN_COL + 1000)
;
; Memory Modified: CHRRAM, COLRAM (1000 bytes each)
; Calls: None (uses LDIR instruction)
;==============================================================================
DRAW_TITLE:
    LD          DE,CHRRAM                           ; DE = destination (CHR screen base)
    LD          HL,TITLE_SCREEN                     ; HL = source character data
    LD          BC,1000                             ; Copy length = 1000 bytes
    LDIR								            ; Bulk copy characters
    LD          DE,COLRAM                           ; DE = destination (color RAM base)
    LD          HL,TITLE_SCREEN_COL                 ; HL = source color data
    LD          BC,1000                             ; Copy length = 1000 bytes
    LDIR								            ; Bulk copy colors
    RET								                ; Return to caller

;==============================================================================
; BLANK_SCRN
;==============================================================================
; Clear screen and initialize game UI elements
;   - Clears CHRRAM with SPACE characters and COLRAM with DKGRY on BLK
;   - Draws stats panel with DKGRN on BLK color scheme
;   - Initializes player health (PHYS=48/$30, SPRT=21/$15)
;   - Sets starting inventory (FOOD=20, ARROWS=20)
;   - Draws starting equipment (BOW left hand, BUCKLER right hand)
;   - Generates dungeon map and renders initial viewport
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = Color values, health values, inventory counts
;   BC = Rectangle dimensions for FILL_CHRCOL_RECT, calculation temps
;   DE = Graphics data pointers (STATS_TXT, BOW, BUCKLER)
;   HL = Memory addresses for screen positioning and health storage
;   B  = Color parameter for GFX_DRAW calls
;   E  = SPRT health temporary storage
; ---  End  ---
;   Screen cleared and game UI rendered
;   Player stats initialized and displayed
;   Starting equipment drawn
;   Dungeon map generated
;   Initial viewport rendered
;   Control transfers to DO_SWAP_HANDS
;
; Memory Modified: CHRRAM, COLRAM, PLAYER_*_HEALTH, FOOD_INV, ARROW_INV, MAPSPACE_WALLS
; Calls: FILL_FULL_1024, FILL_CHRCOL_RECT, GFX_DRAW, REDRAW_STATS, FIX_ICON_COLORS, DRAW_COMPASS, BUILD_MAP, UPDATE_VIEWPORT, DO_SWAP_HANDS
;==============================================================================
BLANK_SCRN:
    LD          HL,CHRRAM                           ; HL = CHR screen start
    LD          B,$20                               ; B = SPACE character value
    CALL        FILL_FULL_1024                      ; Clear character RAM
    LD          HL,COLRAM                           ; HL = color RAM start
    LD          B,COLOR(DKGRY,BLK)                  ; B = dark grey on black
    CALL        FILL_FULL_1024                      ; Clear color RAM

    LD          A,COLOR(DKGRN,BLK)                  ; A = dark green on black (panel color)
    LD          HL,COLRAM_PHYS_STATS_1000           ; HL = top-left of stats panel color area
    LD          BC,RECT(9,3)                        ; 9 x 3 rectangle
    CALL        FILL_CHRCOL_RECT                    ; Paint stats panel background
    LD          DE,STATS_TXT                        ; DE = stats label graphics
    LD          HL,CHRRAM_STATS_TOP                 ; HL = position to draw stats label
    LD          B,COLOR(DKGRN,BLK)                  ; B = panel text color
    CALL        GFX_DRAW                            ; Draw stats text
    LD          HL,CHRRAM_HEALTH_SPACER_IDX         ; HL = spacer graphics location
    CALL        GFX_DRAW                            ; Draw spacer
    LD          HL,$30                              ; HL = 0030 (initial PHYS health BCD)
    LD          E,$15                               ; E = 15 (initial SPRT health BCD)
    LD          (PLAYER_PHYS_HEALTH),HL             ; Set current physical health
    LD          (PLAYER_PHYS_HEALTH_MAX),HL         ; Set max physical health
    LD          A,E                                 ; A = spirit health BCD
    LD          (PLAYER_SPRT_HEALTH),A              ; Set current spirit health
    LD          (PLAYER_SPRT_HEALTH_MAX),A          ; Set max spirit health
    CALL        REDRAW_STATS                        ; Render initial stats values
    LD          HL,$20                              ; HL = 0020 (misc counter / timer init)
    LD          (REST_FOOD_COUNTER),HL              ; Store counter value

    LD          A,$14                               ; A = 14 (starting food/arrows BCD)
    LD          (FOOD_INV),A                        ; Initialize food inventory
    LD          (ARROW_INV),A                       ; Initialize arrow inventory
    CALL        REFRESH_FOOD_ARROWS                 ; Refresh arrow and food graphs

    LD          B,COLOR(RED,BLK)                    ; B = red on black (left hand item color)
    LD          HL,CHRRAM_LEFT_HAND_VP_DRAW_IDX     ; HL = left hand viewport draw position
    LD          DE,BOW                              ; DE = BOW graphics pointer
    CALL        DRAW_LEFT_HAND_AREA                 ; Clear area and draw BOW
    CALL        INIT_ICONS                          ; Setup icons
    CALL        COLOR_LEVEL_INDICATOR               ; Color the level indicator
    CALL        DRAW_COMPASS                        ; Draw initial compass
    CALL        DRAW_PACK_BKGD                      ; Draw pack background
    DEC         A                                   ; A = 13 (used in shield calc temp)
    LD          B,A                                 ; B = 13 (temp store)
    LD          A,0x3                               ; A = 3 (base for shield computation)
    SUB         B                                   ; A = 3 - 13 = wrap/underflow (used to derive right-hand item code)
    LD          (RIGHT_HAND_ITEM),A                 ; Store computed right-hand item code
    RRCA							                ; Rotate for flag-based shield path decision
    JP          C,SET_ALT_SHIELD_BASE               ; If carry set, use alternate shield base
    LD          B,$10                               ; B = $10 (standard shield base level)
    JP          ADJUST_SHIELD_LEVEL                 ; Continue shield setup

;==============================================================================
; SET_ALT_SHIELD_BASE
;==============================================================================
; Set base shield level for alternative path
;   - Entry point for shield initialization when carry flag is set
;   - Sets B register to $30 as base shield level
;   - Falls through to ADJUST_SHIELD_LEVEL for final configuration
;
; Registers:
; --- Start ---
;   A = Carry flag set from previous RRCA
; --- In Process ---
;   B = $30 (base shield level)
; ---  End  ---
;   Falls through to ADJUST_SHIELD_LEVEL
;
; Memory Modified: None
; Calls: None (falls through)
;==============================================================================
SET_ALT_SHIELD_BASE:
    LD          B,$30                               ; B = $30 (alternate shield base level)

;==============================================================================
; ADJUST_SHIELD_LEVEL
;==============================================================================
; Calculate final shield level based on flags
;   - Tests carry flag from RRCA to determine shield upgrade level
;   - If carry set: adds $40 to base shield value in B
;   - If carry clear: uses base shield value unchanged
;   - Falls through to FINALIZE_STARTUP_STATE for equipment finalization
;
; Registers:
; --- Start ---
;   A = Value from RIGHT_HAND_ITEM calculation (rotated)
;   B = Base shield level ($10 or $30)
; --- In Process ---
;   A = Rotated right again (RRCA), then $40 if carry set
;   B = Final shield level (base or base + $40)
; ---  End  ---
;   A = Modified ($40 + base if carry, otherwise rotated value)
;   B = Final shield level for equipment setup
;   Falls through to FINALIZE_STARTUP_STATE
;
; Memory Modified: None (register calculations only)
; Calls: None (falls through to FINALIZE_STARTUP_STATE)
;==============================================================================
ADJUST_SHIELD_LEVEL:
    RRCA								            ; Rotate again; carry indicates upgrade path
    JP          NC,FINALIZE_STARTUP_STATE           ; If no carry, skip upgrade addition
    LD          A,$40                               ; A = $40 (upgrade increment)
    ADD         A,B                                 ; A = base + $40
    LD          B,A                                 ; B = final shield level

;==============================================================================
; FINALIZE_STARTUP_STATE
;==============================================================================
; Finalize starting equipment and initialize game world
;   - Sets left hand item to BOW ($18)
;   - Draws BUCKLER graphic to right hand equipment slot
;   - Builds initial dungeon map layout
;   - Initializes sound/viewport systems
;   - Renders starting game screen
;   - Transfers control to DO_SWAP_HANDS
;
; Registers:
; --- Start ---
;   B = Final shield level from ADJUST_SHIELD_LEVEL
; --- In Process ---
;   A  = $18 (BOW item code)
;   BC = Used by called subroutines (BUILD_MAP, etc.)
;   DE = BUCKLER graphics pointer
;   HL = CHRRAM_RIGHT_HAND_ITEM_IDX screen position
; ---  End  ---
;   LEFT_HAND_ITEM = $18 (BOW)
;   Right hand equipment drawn
;   Dungeon map generated
;   Viewport rendered
;   Control transfers to DO_SWAP_HANDS (does not return)
;
; Memory Modified: LEFT_HAND_ITEM, CHRRAM (right hand slot), MAPSPACE_WALLS, ITEM_TABLE
; Calls: GFX_DRAW, BUILD_MAP, PLAY_PITCH_DOWN_MED, INC_DUNGEON_LEVEL, UPDATE_VIEWPORT, DO_SWAP_HANDS
;==============================================================================
FINALIZE_STARTUP_STATE:
    LD          A,RED_BOW_ITEM                      ; A = $18 (BOW item code)
    LD          (LEFT_HAND_ITEM),A                  ; Set left hand item to BOW
    LD          HL,CHRRAM_RIGHT_HAND_VP_DRAW_IDX    ; HL = right hand item screen pos
    LD          DE,BUCKLER                          ; DE = BUCKLER graphics pointer
    CALL        GFX_DRAW                            ; Draw BUCKLER in right hand slot
    CALL        BUILD_MAP                           ; Generate dungeon walls/items
    CALL        PLAY_PITCH_DOWN_MED                 ; Init sound / system routine
    CALL        INC_DUNGEON_LEVEL                   ; Additional startup (timer/UI) routine
    CALL        REDRAW_START                        ; Draw initial non-viewport UI elements
    CALL        REDRAW_VIEWPORT                     ; Render initial 3D maze view
    
    CALL        VP_LH_GAP_REDRAW                    ; Fill in space to right of left hand item
    CALL        VP_RH_GAP_REDRAW                    ; Fill in space to left of right hand item

    JP          DO_SWAP_HANDS                       ; Enter main input loop (no return)

;==============================================================================
; DO_MOVE_FW_CHK_WALLS - Attempt forward movement with wall and monster checks
;==============================================================================
;   - Checks F0 position for walls or closed doors
;   - Checks F1 position for blocking monsters
;   - If clear, updates player position and saves previous state
;   - Falls through to viewport redraw if movement succeeds
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = Wall state bits, item/monster codes, position calculations
;   BC = Direction vector from DIR_FACING_HI
; ---  End  ---
;   Position updated if movement valid, else NO_ACTION_TAKEN
;
DO_MOVE_FW_CHK_WALLS:
    LD          A,(WALL_F0_STATE)                   ; Load F0 wall state
    CP          0x0                                 ; Check if no wall present
    JP          Z,FW_WALLS_CLEAR_CHK_MONSTER        ; If clear, check for monster
    BIT         0x2,A                               ; Test bit 2 (closed door flag)
    JP          Z,NO_ACTION_TAKEN                   ; If wall/closed door, block movement
;==============================================================================
; FW_WALLS_CLEAR_CHK_MONSTER - Validate monster not blocking F1 position
;==============================================================================
; Entry point when F0 wall check passes. Tests F1 position for monster presence
; ($7A and above indicates monster). If clear, updates player position with
; direction vector and saves previous state for potential backtracking.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = ITEM_S1 + 2, then comparisons, then position calculations
;   BC = DIR_FACING_HI (direction vector)
; ---  End  ---
;   Control transfers (no return)
;
; Memory Modified: PREV_DIR_VECTOR, PREV_DIR_FACING, PLAYER_PREV_MAP_LOC, PLAYER_MAP_POS
; Calls: UPDATE_VIEWPORT, NO_ACTION_TAKEN (via JP)
;==============================================================================
FW_WALLS_CLEAR_CHK_MONSTER:
    LD          A,(ITEM_S1)                         ; Load S1 sprite/monster code
    INC         A                                   ; Adjust for offset
    INC         A                                   ; (FE -> 00, monster codes shift)
    CP          $7a                                 ; Compare against monster threshold
    JP          NC,NO_ACTION_TAKEN                  ; If monster blocking, abort movement
    LD          BC,(DIR_FACING_HI)                  ; Load direction vector (BC = offset)
    LD          (PREV_DIR_VECTOR),BC                ; Save previous direction for backtrack
    LD          A,(DIR_FACING_SHORT)                ; Load facing byte (1-4)
    LD          (PREV_DIR_FACING),A                 ; Save previous facing
    LD          A,(PLAYER_MAP_POS)                  ; Load current map position
    LD          (PLAYER_PREV_MAP_LOC),A             ; Save previous position for backtrack
    ADD         A,B                                 ; Add direction offset to position
    LD          (PLAYER_MAP_POS),A                  ; Store new player position
    CALL        PLAY_FOOTSTEP                       ; Play hi/lo pip sound for walking
    JP          UPDATE_VIEWPORT                     ; Redraw viewport at new position

;==============================================================================
; DO_JUMP_BACK - Jump back to previous position (backtrack)
;==============================================================================
;   - Restores previous player position and facing direction
;   - Validates backtrack is possible (not already at previous pos)
;   - Validates direction reversal is valid
;   - Clears combat if in melee and re-enters combat animation
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = Position comparisons, direction validation
;   AF'= Preserved previous position during direction checks
;   HL = PLAYER_MAP_POS pointer, then PREV_DIR_VECTOR
; ---  End  ---
;   Position restored, viewport updated, or combat re-initialized
;
DO_JUMP_BACK:
    LD          HL,PLAYER_MAP_POS                   ; HL = current position address
    LD          A,(PLAYER_PREV_MAP_LOC)             ; A = saved previous position
    CP          (HL)                                ; Compare: already at previous location?
    JP          Z,CANNOT_JUMP_BACK                  ; If same position, play error sound
    EX          AF,AF'                              ; Save position in AF' for later restore
    LD          HL,(PREV_DIR_VECTOR)                ; HL = previous direction vector
    LD          A,(DIR_FACING_LO)                   ; A = current low direction byte
    NEG											    ; Negate to get reverse direction
    CP          H                                   ; Compare with previous direction high byte
    JP          Z,NO_ACTION_TAKEN                   ; If directions don't allow backtrack, block
    EX          AF,AF'                              ; Restore saved position to A
    LD          (PLAYER_MAP_POS),A                  ; Write previous position as new position
    LD          (DIR_FACING_HI),HL                  ; Restore previous direction vector
    LD          A,(PREV_DIR_FACING)                 ; A = previous facing byte (1-4)
    LD          (DIR_FACING_SHORT),A                ; Restore facing direction
    LD          A,(COMBAT_BUSY_FLAG)                ; Check if in combat
    AND         A                                   ; Test zero
    JP          Z,UPDATE_VIEWPORT                   ; If not in combat, just redraw
    CALL        CLEAR_MONSTER_STATS                 ; Clear combat UI/state
    JP          INIT_MN_MELEE_ANIM                  ; Re-enter combat animation

;==============================================================================
; CANNOT_JUMP_BACK
;==============================================================================
; Play error sound when backtrack invalid
;   - Called when player at same position as previous (can't backtrack)
;   - Plays error tone then checks combat state
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   BC = $500 (sound frequency)
;   DE = $20 (sound duration)
;   A  = COMBAT_BUSY_FLAG value
; ---  End  ---
;   Control transferred to WAIT_FOR_INPUT or INIT_MELEE_ANIM
;
; Memory Modified: None (sound only)
; Calls: PLAY_SOUND_LOOP, WAIT_FOR_INPUT or INIT_MELEE_ANIM
;==============================================================================
CANNOT_JUMP_BACK:
    LD          BC,$500                             ; BC = sound frequency parameter
    LD          DE,$20                              ; DE = sound duration parameter
    CALL        PLAY_SOUND_LOOP                     ; Play error beep
    LD          A,(COMBAT_BUSY_FLAG)                ; Check combat state
    AND         A                                   ; Test if in combat
    JP          Z,WAIT_FOR_INPUT                    ; If not in combat, wait for next input
    JP          INIT_MN_MELEE_ANIM                  ; If in combat, re-enter melee

;==============================================================================
; NO_ACTION_TAKEN
;==============================================================================
; Plays a low-pitched "blocked" sound effect and returns to the input wait
; loop. Called when the player attempts an invalid action (moving into a wall,
; using an item they don't have, etc.).
;
; Registers:
; --- Start ---
;   BC = $500 (delay duration)
;   DE = $20 (pitch/frequency)
; --- In Process ---
;   All registers modified by PLAY_SOUND_LOOP
; ---  End  ---
;   Control passes to WAIT_FOR_INPUT
;
; Memory Modified: None
; Calls: PLAY_SOUND_LOOP, WAIT_FOR_INPUT
;==============================================================================
NO_ACTION_TAKEN:
    LD          BC,$500                             ; Set delay duration ($500)
    LD          DE,$20                              ; Set sound pitch/frequency ($20)
    CALL        PLAY_SOUND_LOOP                     ; Play the blocked action sound
    JP          WAIT_FOR_INPUT                      ; Return to input polling loop

;==============================================================================
; PLAY_SOUND_LOOP
;==============================================================================
;
; Registers:
; --- Start ---
;   A  = PLAYER_MAP_POS
; --- In Process ---
;   All registers modified by PLAY_SOUND_LOOP
; ---  End  ---
;   Control passes to WAIT_FOR_INPUT
;
; Memory Modified: None
; Calls: PLAY_SOUND_LOOP, WAIT_FOR_INPUT
;
;==============================================================================
; PLAY_FOOTSTEP
;==============================================================================
; Plays a footstep sound based on checkerboard pattern of player position.
; Determines "odd" vs "even" square by XORing bit 0 (X coord LSB) with bit 4
; (Y coord LSB) of the map position byte. Odd squares play HI pip, even
; squares play LO pip, creating an alternating audio pattern as player moves.
;
; Position encoding: Low nybble = X coordinate, High nybble = Y coordinate
; Checkerboard logic: (X[0] XOR Y[0]) determines square parity
;
; Registers:
; --- Start ---
;   A  = Player map position (YYYYXXXX format)
; --- In Process ---
;   B  = Saved position value
;   A  = Isolated bit 4, then XOR result, then final parity
; ---  End  ---
;   Jumps to PLAY_INPUT_PIP_HI or PLAY_INPUT_PIP_LO (does not return here)
;
; Memory Modified: None directly (pip routines modify timers)
; Calls: PLAY_INPUT_PIP_HI or PLAY_INPUT_PIP_LO (via JP)
;==============================================================================
PLAY_FOOTSTEP:
    LD          B,A                                 ; Save position in B
    AND         $10                                 ; Isolate bit 4 (Y coordinate LSB)
    XOR         B                                   ; XOR with full position (brings bit 0 into result)
    AND         $01                                 ; Isolate final parity bit (0=even, 1=odd)
    JP          NZ,PLAY_INPUT_PIP_HI                ; Odd square → play HI pip
    JP          PLAY_INPUT_PIP_LO                   ; Even square → play LO pip

;==============================================================================
; PLAY_SOUND_LOOP
;==============================================================================
; Generates a repeating tone by toggling the speaker output at a specified
; pitch (DE) for a specified number of cycles (BC). Creates a simple square
; wave audio effect through direct speaker port manipulation.
;
; Registers:
; --- Start ---
;   BC = Delay duration value
;   DE = Pitch cycle count
; --- In Process ---
;   A  = Speaker toggle value (0 or non-zero)
;   HL = Delay counter (copy of BC)
;   DE = Decremented each cycle
; ---  End  ---
;   DE = 0 (pitch counter exhausted)
;   BC = Original delay value (preserved)
;   HL, A modified
;
; Memory Modified: None
; Calls: SOUND_DELAY_LOOP (fall-through delay loop)
;==============================================================================
PLAY_SOUND_LOOP:
    DEC         DE                                  ; Decrement pitch counter
    LD          A,E                                 ; Load E into A
    OR          D                                   ; OR with D to test for zero
    RET         Z                                   ; If DE=0, sound complete, return
    OUT         (SPEAKER),A                         ; Send toggle value to speaker port
    LD          H,B                                 ; Copy BC to HL for delay
    LD          L,C                                 ; HL = BC (delay duration)

;==============================================================================
; SOUND_DELAY_LOOP
;==============================================================================
; Delay loop that counts down HL to zero, creating a timed pause to control
; the pitch of the sound wave. Falls through from PLAY_SOUND_LOOP.
;
; Registers:
; --- Start ---
;   HL = Delay count
; --- In Process ---
;   HL = Decremented each iteration
;   A  = L OR H (zero test)
; ---  End  ---
;   HL = 0
;   A  = 0
;
; Memory Modified: None
; Calls: PLAY_SOUND_LOOP (loops back)
;==============================================================================
SOUND_DELAY_LOOP:
    DEC         HL                                  ; Decrement delay counter
    LD          A,L                                 ; Load L into A
    OR          H                                   ; OR with H to test for zero
    JP          NZ,SOUND_DELAY_LOOP                 ; If HL≠0, continue delay loop
    JP          PLAY_SOUND_LOOP                     ; Return to next sound cycle

;==============================================================================
; CHK_ITEM_BREAK
;==============================================================================
; Determines whether a right-hand (RH) item breaks after use based on the
; item level and a random roll. Higher item levels increase break chance.
; If the item breaks, triggers a poof animation and resets RH colors.
;
; Registers:
; --- Start ---
;   B = itemLevel
; --- In Process ---
;   A = scaled level and random calculations
;   C = scaled level (level*8)
; ---  End  ---
;   Flags reflect break outcome (C set on break)
;
; Memory Modified: CHRRAM_RH_ITEM_IDX, COLRAM_RH_ITEM_IDX via FIX_RH_COLORS
; Calls: MAKE_RANDOM_BYTE, ITEM_POOFS_RH, FIX_RH_COLORS
;==============================================================================
CHK_ITEM_BREAK:
    LD          A,B                                 ; Load item level (0-3)
    RLCA                                            ; Scale: level * 2
    RLCA                                            ; Scale: level * 4
    RLCA                                            ; Scale: level * 8 (break factor)
    LD          C,A                                 ; Save factor in C
    CALL        MAKE_RANDOM_BYTE                    ; A = random byte
    ADD         A,C                                 ; Add factor; test for carry (overflow)
    JP          C,ITEM_POOFS_RH                     ; If overflow, item breaks immediately
    ADD         A,0x5                               ; Add small constant to increase chance
    RET         NC                                  ; If still no carry, item survives
    
ITEM_POOFS_RH:
    SCF                                             ; Set carry to indicate break
    EX          AF,AF'                              ; Preserve flags/state in alternate set
    LD          HL,CHRRAM_RH_VP_POOF_IDX            ; CHRRAM pointer for poof animation
    CALL        PLAY_POOF_ANIM                      ; Execute poof animation frames

FIX_RH_COLORS:
    CALL        CLEAR_RIGHT_HAND_GFX                ; Clear graphics in right hand
    SCF                                             ; Keep carry set indicating break
    RET

CLEAR_RIGHT_HAND_GFX:
    PUSH        AF                                  ; Preserve registers during color fix
    PUSH        BC
    PUSH        HL

; Clear Chars
    LD          A,' '                               ; Set RH item area to SPACE fill
    LD          BC,RECT(4,4)                        ; 4x4 rectangle (RH item viewport)
    LD          HL,CHRRAM_RIGHT_HAND_VP_IDX         ; Chara RAM base for RH item block
    CALL        FILL_CHRCOL_RECT                    ; Clear/neutralize RH item colors
    
; Fix Colors
    LD          A,COLOR(DKGRY,BLK)                  ; Set RH item area to dark gray on black
    LD          BC,RECT(4,4)                        ; 4x4 rectangle (RH item viewport)
    LD          HL,COLRAM_RIGHT_HAND_VP_IDX         ; Color RAM base for RH item block
    CALL        FILL_CHRCOL_RECT                    ; Clear/neutralize RH item colors

    POP         HL
    POP         BC
    POP         AF
    RET

;==============================================================================
; PLAYER_ANIM_ADVANCE — Advance Player Weapon Animation Loop
;==============================================================================
; Advances the right-hand item animation, manages loop counters, updates the
; CHRRAM pointer for sprite frames, and copies character graphics into a
; movement buffer. Also updates monster frame state and caches a timer copy.
;
; Registers:
; --- Start ---
;   A = ITEM_ANIM_STATE
;   HL = ITEM_ANIM_LOOP_COUNT
; --- In Process ---
;   HL = CHRRAM pointer arithmetic; BC used as delta ($29/$c8)
;   DE = ITEM_MOVE_CHR_BUFFER
;   A = PL_WPN_CHRRAM_ADDR_HI, ITEM_SPRITE_INDEX, MASTER_TICK_TIMER
; ---  End  ---
;   State/loop/pointers updated; flags used by SBC/ADD operations
;
; Memory Modified: ITEM_ANIM_STATE, ITEM_ANIM_LOOP_COUNT, ITEM_ANIM_CHRRAM_PTR,
;                  ITEM_MOVE_CHR_BUFFER, WEAPON_SPRITE_CHRRAM_ADDR_HI, ITEM_ANIM_TIMER_COPY
; Calls: SOUND_05, COPY_GFX_2_BUFFER, CHK_ITEM, ADVANCE_RH_ANIM_FRAME, COPY_RH_ITEM_FRAME_GFX
;==============================================================================
PLAYER_ANIM_ADVANCE:
    CALL        SOUND_05                            ; Play animation sound 05
    LD          A,(PLAYER_ANIM_STATE)               ; Load item animation state
    LD          HL,(PLAYER_ANIM_LOOP_COUNT)         ; Load loop counter (HL)
    DEC         A                                   ; Decrement state
    JP          NZ,SKIP_PLAYER_WEAPON_FRAME         ; If still non-zero, branch to frame step
    DEC         L                                   ; Decrement inner loop count
    JP          NZ,RESET_PLAYER_ANIM_STATE          ; If not zero, refresh state and continue
    DEC         H                                   ; Decrement outer loop count
    JP          Z,FINISH_APPLY_MONSTER_DAMAGE       ; If zero, animation complete
    LD          A,$31                               ; Player weapon CHRRAM high byte
    LD          (PL_WPN_CHRRAM_HI),A                ; Store into CPL_WPN_CHRRAM_LO
    LD          L,0x4                               ; Reset inner loop count to 4
RESET_PLAYER_ANIM_STATE:
    LD          A,0x4                               ; Set player animation state to 4
    LD          (PLAYER_ANIM_STATE),A               ; Write back state
    LD          (PLAYER_ANIM_LOOP_COUNT),HL         ; Write back loop counters
    LD          HL,(PLAYER_WEAPON_CHRRAM_PTR)       ; Load CHRRAM pointer for frame
    LD          BC,41                               ; Row stride 41
    XOR         A                                   ; Clear Flags for SBC
    SBC         HL,BC                               ; Move pointer backwards by 41 (UL)
    LD          (PLAYER_WEAPON_CHRRAM_PTR),HL       ; Save updated pointer
    JP          DRAW_PLAYER_WEAPON_FRAME            ; Continue to graphics copy/update

SKIP_PLAYER_WEAPON_FRAME:
    LD          (PLAYER_ANIM_STATE),A               ; Persist new animation state
;    LD          HL,(PLAYER_WEAPON_CHRRAM_PTR)       ; Load CHRRAM pointer
;    DEC         HL                                  ; Move to previous byte   **** CHANGE ME ****
;    LD          (PLAYER_WEAPON_CHRRAM_PTR),HL       ; Save updated pointer
    JP          ADVANCE_PLAYER_WEAPON_FRAME         ; Jump past DRAW FRAME section

;==============================================================================
; DRAW_PLAYER_WEAPON_FRAME — Draw Player's Weapon Sprite Frame
;==============================================================================
; Copies character graphics for the current item frame into the movement
; buffer, updates weapon sprite CHRRAM address high byte (WEAPON_SPRITE_CHRRAM_ADDR_HI), runs item check logic, and
; caches the item animation timer value.
;
; Registers: HL/BC/DE used for copy; A for state updates
; Memory Modified: ITEM_MOVE_CHR_BUFFER, WEAPON_SPRITE_CHRRAM_ADDR_HI, ITEM_ANIM_TIMER_COPY
; Calls: COPY_GFX_2_BUFFER, CHK_ITEM
;==============================================================================
DRAW_PLAYER_WEAPON_FRAME:
    LD          BC,200                              ; BC = 200 (40 * 5), offset for start of ITEM graphics
    XOR         A                                   ; A = 0 (clear for subtraction)
    SBC         HL,BC                               ; HL = HL - 200 (40 * 5)
    PUSH        HL                                  ; Save source pointer

    ; SBC         HL,BC                               ; HL = HL - 200 (40 * 5)
    ; **** CHANGE ME ****
    ; Adjusted to match DRAW_MONSTER_WEAPON_FRAME

    ADD         HL,BC                               ; HL = HL + 200 (40 * 5)
    LD          DE,PL_BG_CHRRAM_BUFFER              ; Destination buffer for movement CHR
    CALL        COPY_GFX_2_BUFFER                   ; Copy frame graphics to buffer

    ; POP         HL                                  ; Restore source pointer
    ; LD          C,L                                 ; Save low byte of pointer into C
    ; **** CHANGE ME **** 
    ; Adjusted to match DRAW_MONSTER_WEAPON_FRAME

    POP         BC                                  ; BC = adjusted screen address (from stack)
    LD          B,0x0                               ; B = 0 (clear high byte for CHK_ITEM parameter)

    LD          A,(PL_WPN_CHRRAM_HI)                ; Load PL_WPN_CHRRAM_HI byte
    LD          (ITEM_CHRRAM_HI),A                  ; Update ITEM_CHRRAM_HI from PL_WPN_CHRRAM_HI
    LD          A,(PLAYER_WEAPON_SPRITE)            ; Load item sprite index
    CALL        CHK_ITEM                            ; Draw player weapon sprite (first of two draws this tick)

ADVANCE_PLAYER_WEAPON_FRAME:
    LD          A,$32                               ; Player weapon CHRRAM row base
    LD          (ITEM_CHRRAM_HI),A                  ; Update ITEM_CHRRAM_HI
    LD          A,(MASTER_TICK_TIMER)               ; Load timer A
    ADD         A,$ff                               ; Decrement by 1
    LD          (PLAYER_TIMER_COMPARE),A            ; Cache copy for animation timing
    RET                                             ; Return to animation loop

 
;==============================================================================
; COPY_PL_BUFF_TO_SCRN  
;==============================================================================
; Copy 4x4 item graphic from `ITEM_MOVE_CHR_BUFFER` into CHRRAM at
; `(ITEM_ANIM_CHRRAM_PTR)`. Used to finalize the RH item animation frame.
;
; Registers:
; --- Start ---
;   DE = dest CHRRAM ptr, HL = src buffer
; --- In Process ---
;   A/B/C used by copy helper; DE/HL advanced
; ---  End  ---
;   DE/HL at post-copy positions
;   F  = per last operation
;
; Memory Modified: CHRRAM at `(ITEM_ANIM_CHRRAM_PTR)`
; Calls: COPY_GFX_FROM_BUFFER
;==============================================================================
COPY_PL_BUFF_TO_SCRN:
    LD          DE,(PLAYER_WEAPON_CHRRAM_PTR)       ; DE = screen position where weapon is drawn
    LD          HL,PL_BG_CHRRAM_BUFFER              ; HL = buffer with saved background
    JP          COPY_GFX_FROM_BUFFER                ; Copy buffer graphics to CHRRAM at DE
    
 
;==============================================================================
; FINISH_APPLY_MONSTER_DAMAGE  
;==============================================================================
; Finalize RH item after animation graphic copy; set status bytes, decode
; weapon type (physical vs spiritual), and branch into the matching damage
; pipeline.
;
; Registers:
; --- Start ---
;   A/E/D used for weapon type and DE load
; --- In Process ---
;   EXX around NEW_RIGHT_HAND_ITEM; HL used for player max health
; ---  End  ---
;   Branch to physical pipeline or spiritual path
;
; Memory Modified: CHRRAM via COPY_ITEM_GFX_TO_CHRRAM; PL_WPN_CHRRAM_ADDR_HI/SCREENSAVER_STATE
; Calls: COPY_ITEM_GFX_TO_CHRRAM, NEW_RIGHT_HAND_ITEM
;==============================================================================
FINISH_APPLY_MONSTER_DAMAGE:
    CALL        COPY_PL_BUFF_TO_SCRN                ; Copy RH item gfx into CHRRAM
    LD          A,$32                               ; Monster weapon CHRRAM row base
    LD          (PL_WPN_CHRRAM_HI),A                ; Store status into PL_WPN_CHRRAM_HI
    LD          (PLAYER_MELEE_STATE),A              ; Store status into PLAYER_MELEE_STATE
    LD          A,(WEAPON_SPRT)                     ; Load weapon SPRT value
    LD          E,A                                 ; Move flag into E for math
    LD          D,0x0                               ; Clear D to form DE
    CP          0x0                                 ; Compare: physical (0) vs spiritual (≠0)
    JP          NZ,CALC_SPRT_DAMAGE                 ; If spiritual, branch to spiritual path
    LD          DE,(WEAPON_PHYS)                    ; Load weapon PHYS value
    EXX                                             ; Switch to alt regs for item setup
    CALL        NEW_RIGHT_HAND_ITEM                 ; Finalize right-hand item state
    EXX                                             ; Restore primary regs
    LD          HL,(PLAYER_PHYS_HEALTH_MAX)         ; Load player max physical health (BCD)
    CALL        DIVIDE_BCD_HL_BY_2                  ; Compute half of max health
    CALL        RECALC_PHYS_HEALTH                  ; Normalize/check health math state
    JP          NC,APPLY_PHYS_DAMAGE                ; If no carry, proceed with physical mix/damage
    LD          HL,0x0                              ; Else seed zero to proceed with fallback
    
 
;==============================================================================
; APPLY_PHYS_DAMAGE  
;==============================================================================
; Physical damage seed build and application.
; Mixes halves and weapon value via RANDOMIZE_BCD_NYBBLES and DIVIDE/ADD
; helpers, computes NEW_DAMAGE, then applies to monster physical HP.
;
; Inputs:
;   HL = half of player max physical health (pre-normalized)
;   DE = working seed/weapon pair during mixing
;
; Outputs:
;   NEW_DAMAGE updated; CURR_MONSTER_PHYS reduced and HUD redrawn if alive
;   F  = flags per math/compare
;
; Registers:
; --- Start ---
;   HL = half-health seed
; --- In Process ---
;   A swaps with H; DE/HL exchanged; multiple calls to SUB_ram_e401/e439/e427
; ---  End  ---
;   HL/DE updated; branch to heavy-damage or death paths as needed
;
; Memory Modified: CURR_MONSTER_PHYS, NEW_DAMAGE
; Calls: RANDOMIZE_BCD_NYBBLES (SUB_ram_e401), DIVIDE_BCD_HL_BY_2 (SUB_ram_e439), ADD_BCD_HL_DE (SUB_ram_e427), REDRAW_MONSTER_HEALTH
;==============================================================================
APPLY_PHYS_DAMAGE:
    CALL        RANDOMIZE_BCD_NYBBLES               ; Randomize BCD nybbles (seed mix)
    LD          L,H                                 ; Move H into L for mixing
    LD          H,A                                 ; Move random A into H
    CALL        RANDOMIZE_BCD_NYBBLES               ; Randomize again for variability
    LD          L,H                                 ; Shuffle H→L
    LD          H,A                                 ; Shuffle A→H
    EX          DE,HL                               ; Swap seed with weapon value
    CALL        DIVIDE_BCD_HL_BY_2                  ; Halve the seed (normalize)
    EX          DE,HL                               ; Restore HL=seed, DE=weapon
    CALL        ADD_BCD_HL_DE                       ; HL += DE (seed + weapon)
    EX          DE,HL                               ; Swap again for further mix
    CALL        RANDOMIZE_BCD_NYBBLES               ; Randomize to perturb mix
    CALL        ADD_BCD_HL_DE                       ; HL += DE (final mix value)
    LD          DE,(NEW_DAMAGE)                     ; Point DE to NEW_DAMAGE storage
    CALL        RECALC_PHYS_HEALTH                  ; Compute resulting damage value
    JP          C,PHYS_FALLBACK_SEED                ; If carry, use heavy fallback path
MONSTER_TAKES_PHYS_DAMAGE:
    EX          DE,HL                               ; HL=NEW_DAMAGE, DE=monster phys
    LD          HL,(CURR_MONSTER_PHYS)              ; Load monster physical HP (BCD)
    CALL        RECALC_PHYS_HEALTH                  ; Apply damage calculation to HL vs DE
    JP          C,MONSTER_PHYS_DEATH                ; If carry/underflow, treat as death
    OR          L                                   ; Check if low byte is zero
    JP          Z,MONSTER_PHYS_DEATH                ; If zero, monster dead
    LD          (CURR_MONSTER_PHYS),HL              ; Store updated monster physical HP
    JP          REDRAW_MONSTER_HEALTH               ; Refresh HUD with new HP

 
;==============================================================================
; PHYS_FALLBACK_SEED  
;==============================================================================
; Heavy physical damage fallback; randomize using constant 6 to ensure
; non-trivial hit before resuming normal apply path.
;
; Registers:
; --- Start ---
;   HL = $0006
; --- In Process ---
;   A/B/C used by randomize
; ---  End  ---
;   Seed prepared; flow continues
;
; Memory Modified: None
; Calls: RANDOMIZE_BCD_NYBBLES
;==============================================================================
PHYS_FALLBACK_SEED:
    LD          HL,0x6                              ; Seed HL with constant 6
    CALL        RANDOMIZE_BCD_NYBBLES               ; Randomize seed for non-trivial hit
    JP          MONSTER_TAKES_PHYS_DAMAGE           ; Continue with standard apply path
    
 
;==============================================================================
; MONSTER_PHYS_DEATH  
;==============================================================================
; Monster physical death and stat threshold checks. Clears monster HP,
; redraws HUD, then evaluates thresholds to decide on max physical health
; increases or immediate kill conclusion.
;
; Registers:
; --- Start ---
;   Alt set via EXX; HL used for clears and threshold halves
; --- In Process ---
;   A/B for compares; HL updated; calls EXPAND_STAT_THRESHOLDS for thresholds
; ---  End  ---
;   Branch per threshold outcomes
;
; Memory Modified: CURR_MONSTER_PHYS
; Calls: REDRAW_MONSTER_HEALTH, EXPAND_STAT_THRESHOLDS, SUB_ram_e439, UPDATE_SCR_SAVER_TIMER
;==============================================================================
MONSTER_PHYS_DEATH:
    EXX                                             ; Use alt regs for clear/HUD
    LD          HL,0x0                              ; HL = 0
    LD          (CURR_MONSTER_PHYS),HL              ; Clear monster physical HP
    CALL        REDRAW_MONSTER_HEALTH               ; Redraw HUD after death
    EXX                                             ; Restore primary regs
    INC         L                                   ; Increment local threshold counter
    LD          A,$99                               ; Load high threshold constant
    CP          H                                   ; Compare against H
    JP          NZ,MONSTER_KILLED                   ; If mismatch, conclude kill
    LD          A,$61                               ; Load low threshold constant
    CP          L                                   ; Compare against L
    JP          NC,MONSTER_KILLED                   ; If <=, conclude kill
    LD          A,(COLRAM_PHYS_STATS_1000)          ; Read phys stats color/threshold byte
    CALL        EXPAND_STAT_THRESHOLDS              ; Expand thresholds into B/C
    LD          HL,(PLAYER_PHYS_HEALTH_MAX)         ; Load player max physical health
    CALL        DIVIDE_BCD_HL_BY_2                  ; Half the max health
    LD          A,L                                 ; A = low byte half
    CP          B                                   ; Compare with scaled threshold B
    JP          NC,MONSTER_KILLED                   ; If not above, conclude kill
PHYS_THRESHOLD_LOOP:
    CALL        UPDATE_SCR_SAVER_TIMER              ; Tick screen saver timer
    SUB         $40                                 ; Reduce local counter by 0x40
    JP          C,INCREASE_MAX_PHYS_HEALTH          ; If underflow, increase max phys
    CP          C                                   ; Compare remaining against C threshold
    JP          NC,MONSTER_KILLED                   ; If <=, conclude kill
INCREASE_MAX_PHYS_HEALTH:
    LD          HL,(PLAYER_PHYS_HEALTH_MAX)         ; Load current max phys health
    LD          A,L                                 ; A = low byte
    ADD         A,0x1                               ; Increment by 1
    DAA                                             ; Adjust to valid BCD
    LD          L,A                                 ; Store back to L
    LD          A,H                                 ; A = high byte
    ADC         A,0x0                               ; Propagate carry into H
    LD          H,A                                 ; Store back to H
    LD          (PLAYER_PHYS_HEALTH_MAX),HL         ; Save updated max phys health
    LD          A,C                                 ; A = C threshold
    SUB         $10                                 ; Reduce threshold step by 0x10
    JP          C,MONSTER_KILLED                    ; If underflow, conclude kill
    LD          C,A                                 ; Update C with reduced threshold
    JP          PHYS_THRESHOLD_LOOP                 ; Loop threshold processing
CALC_SPRT_DAMAGE:
    LD          A,(PLAYER_SPRT_HEALTH_MAX)          ; Load player max spiritual health
    LD          H,0x0                               ; Clear high byte
    LD          L,A                                 ; HL = max sprt as BCD
    EXX                                             ; Use alt regs for item setup
    CALL        NEW_RIGHT_HAND_ITEM                 ; Finalize right-hand item state
    EXX                                             ; Restore primary regs
    CALL        DIVIDE_BCD_HL_BY_2                  ; Half the spiritual max
    LD          A,L                                 ; A = half value
    SUB         E                                   ; Subtract weapon sprt component
    DAA                                             ; Normalize to BCD
    LD          L,A                                 ; L = adjusted half
    JP          NC,SPRT_SEED_MIX                    ; If no borrow, continue
    LD          L,0x0                               ; If negative, clamp to 0
SPRT_SEED_MIX:
    CALL        RANDOMIZE_BCD_NYBBLES               ; Randomize seed
    EX          DE,HL                               ; Swap seed with DE
    CALL        DIVIDE_BCD_HL_BY_2                  ; Halve seed
    LD          A,L                                 ; A = low byte seed
    ADD         A,E                                 ; Add weapon sprt value
    DAA                                             ; Normalize to BCD
    LD          E,A                                 ; E = mixed value
    CALL        RANDOMIZE_BCD_NYBBLES               ; Randomize again
    ADD         A,E                                 ; Add mixed value
    DAA                                             ; Normalize to BCD
    LD          L,A                                 ; L = final seed
    LD          A,(MONSTER_PHYS_HP_BASE)            ; Load environment/bonus modifier
    LD          E,A                                 ; E = modifier
    LD          A,L                                 ; A = seed
    SUB         E                                   ; Subtract modifier to adjust
    DAA                                             ; Normalize to BCD
    JP          C,SPRT_FALLBACK_SEED                ; If negative, use fallback seed
    LD          L,A                                 ; L = adjusted seed
MONSTER_TAKES_SPRT_DAMAGE:
    LD          A,(CURR_MONSTER_SPRT)               ; Load monster spiritual HP
    SUB         L                                   ; Apply damage L to A
    DAA                                             ; Normalize to BCD
    JP          C,MONSTER_SPRT_DEATH                ; If underflow, kill path
    JP          Z,MONSTER_SPRT_DEATH                ; If zero, kill path
    LD          (CURR_MONSTER_SPRT),A               ; Store updated spiritual HP
    JP          REDRAW_MONSTER_HEALTH               ; Refresh HUD
 
;==============================================================================
; SPRT_FALLBACK_SEED  
;==============================================================================
; Spiritual damage fallback seed. Randomizes a small 3-value seed then
; continues to apply spiritual damage to the monster.
;
; Registers:
; --- Start ---
;   HL = $0003
; --- In Process ---
;   A/B/C used by RANDOMIZE_BCD_NYBBLES; HL walked
; ---  End  ---
;   Seed state prepared; flow continues to MONSTER_TAKES_SPRT_DAMAGE
;
; Memory Modified: None
; Calls: RANDOMIZE_BCD_NYBBLES, MONSTER_TAKES_SPRT_DAMAGE
;==============================================================================
SPRT_FALLBACK_SEED:
    LD          HL,0x3                              ; Seed HL with small constant 3
    CALL        RANDOMIZE_BCD_NYBBLES               ; Randomize seed for variability
    JP          MONSTER_TAKES_SPRT_DAMAGE           ; Continue to apply spiritual damage
 
;==============================================================================
; MONSTER_SPRT_DEATH  
;==============================================================================
; Spiritual kill and max-SPRT handling. Clears monster spiritual HP,
; redraws HUD, then checks thresholds to optionally increase player's
; max spiritual health (in 0x10 steps) while reducing local counter by $30.
;
; Inputs:
;   A  = last accumulator used for SPRT damage path
;
; Outputs:
;   CURR_MONSTER_SPRT = 0 on kill; may update PLAYER_SPRT_HEALTH_MAX
;   F  = flags per arithmetic and comparisons
;
; Registers:
; --- Start ---
;   A = recent SPRT accumulator
; --- In Process ---
;   A/B/C used for threshold math; HL/DE not used here
; ---  End  ---
;   A/B/C reflect final threshold state; flags set accordingly
;
; Memory Modified: CURR_MONSTER_SPRT, PLAYER_SPRT_HEALTH_MAX
; Calls: REDRAW_MONSTER_HEALTH, EXPAND_STAT_THRESHOLDS, UPDATE_SCR_SAVER_TIMER
;==============================================================================
MONSTER_SPRT_DEATH:
    PUSH        AF                                  ; Preserve recent accumulator
    XOR         A                                   ; A = 0
    LD          (CURR_MONSTER_SPRT),A               ; Clear monster spiritual HP
    CALL        REDRAW_MONSTER_HEALTH               ; Update HUD
    POP         AF                                  ; Restore accumulator
    DEC         A                                   ; Decrement for threshold start
    CP          $86                                 ; Compare against constant $86
    JP          C,ITEM_USED_UP                      ; If below, item is used up
    LD          A,(COLRAM_SPRT_STATS_10)            ; Load spiritual stats threshold byte
    CALL        EXPAND_STAT_THRESHOLDS              ; Expand into B/C thresholds
    LD          A,(PLAYER_SPRT_HEALTH_MAX)          ; Load player max spiritual health
    CP          B                                   ; Compare to threshold B
    JP          NC,ITEM_USED_UP                     ; If not greater, item used up
 
;==============================================================================
; REDUCE_ITEM_BY_30  
REDUCE_ITEM_BY_30:
    CALL        UPDATE_SCR_SAVER_TIMER              ; Tick screen saver timer
    SUB         $30                                 ; Reduce local counter by 0x30
    JP          C,INCREASE_MAX_SPRT_HEALTH          ; Underflow triggers max sprt increase
    CP          C                                   ; Compare remaining against C threshold
    JP          NC,ITEM_USED_UP                     ; If <=, item used up
 
;==============================================================================
; INCREASE_MAX_SPRT_HEALTH  
INCREASE_MAX_SPRT_HEALTH:
    LD          A,(PLAYER_SPRT_HEALTH_MAX)          ; Load current max spiritual health
    ADD         A,0x1                               ; Increment by 1
    DAA                                             ; Adjust to valid BCD
    LD          (PLAYER_SPRT_HEALTH_MAX),A          ; Store updated max sprt health
    LD          A,C                                 ; A = C threshold
    SUB         $10                                 ; Reduce threshold by 0x10 step
    JP          C,ITEM_USED_UP                      ; If underflow, end
    LD          C,A                                 ; Update C threshold
    JP          REDUCE_ITEM_BY_30                   ; Loop reduction/increase sequence
 
;==============================================================================
; ITEM_USED_UP  
ITEM_USED_UP:
    JP          MONSTER_KILLED                      ; Conclude: monster killed, item consumed
 
;==============================================================================
; CLEAR_MONSTER_STATS  
CLEAR_MONSTER_STATS:
    XOR         A                                   ; A=0
    LD          (COMBAT_BUSY_FLAG),A                ; Clear combat busy flag
    LD          BC,RECT(14,2)                       ; 14 x 2 rectangle
    LD          HL,CHRRAM_MONSTER_STATS_IDX         ; HL = Monster stats CHRRAM
    LD          A,$20                               ; A = fill color/code
    ; JP          FILL_CHRCOL_RECT                    ; Fill screen region to clear stats
    CALL        FILL_CHRCOL_RECT                    ; Fill screen region to clear stats
    RET
;==============================================================================
; EXPAND_STAT_THRESHOLDS  
;==============================================================================
; Expand a 4-bit value in A into weighted B/C thresholds for stat checks.
; Maps low nybble (A&0xF) into:
;   B = scaled BCD (A*2 four times with DAA), C = A rotated by 4 (high nybble)
; Used to evaluate whether to increase player max SPRT health.
;
; Registers:
; --- Start ---
;   A = input value (low nybble significant)
; --- In Process ---
;   A rotated; A doubled repeatedly with DAA; B/C loaded
; ---  End  ---
;   B = A doubled×4 (BCD normalized)
;   C = A rotated left by 4
;   F = set per last operation
;
; Memory Modified: None
; Calls: None
;==============================================================================
EXPAND_STAT_THRESHOLDS:
    AND         0xf                                 ; Mask to low nybble
    INC         A                                   ; Increment seed (x2 total)
    INC         A                                   ; Increment again
    LD          B,A                                 ; B = base seed
    RLCA                                            ; Rotate left 4 times (×16)
    RLCA
    RLCA
    RLCA
    LD          C,A                                 ; C = rotated high-nybble value
    LD          A,B                                 ; A = base seed
    ADD         A,A                                 ; ×2 scale in BCD
    DAA                                             ; Normalize BCD
    ADD         A,A                                 ; ×4
    DAA                                             ; Normalize
    ADD         A,A                                 ; ×8
    DAA                                             ; Normalize
    ADD         A,A                                 ; ×16
    DAA                                             ; Normalize
    LD          B,A                                 ; B = scaled threshold
    RET                                             ; Return with B/C prepared

;==============================================================================
; MONSTER_ANIM_ADVANCE - Advance Monster Weapon Animation Loop
;==============================================================================
; Advances the monster weapon animation by one frame, managing state machine,
; position counters, and triggers weapon sprite drawing. Called once per frame,
; this is NOT an internal loop but a single animation step.
;
; Animation States (MELEE_ANIM_STATE):
;   1 = Monster attacking (weapon flying from center to down-right)
;   3 = Player attacking (weapon flying from down-right to center)
;
; Registers:
; --- Start ---
;   (Reads from memory: MELEE_ANIM_STATE, MONSTER_ATT_POS_COUNT, WEAPON_SPRITE_POS_OFFSET)
; --- In Process ---
;   A  = Animation state values, flags, and temporary calculations
;   HL = Position frame counters and screen position offsets
;   BC = Position delta for weapon movement : 39 bytes (was 41)
;   DE = Buffer address (MONSTER_BG_SAVE_BUFFER) for background save
; ---  End  ---
;   All registers modified by called functions
;   Animation state, position, and timer updated in memory
;
; Memory Modified: MELEE_ANIM_STATE, MONSTER_ATT_POS_COUNT, WEAPON_SPRITE_POS_OFFSET,
;                  WEAPON_SPRITE_CHRRAM_ADDR_HI, MONSTER_ANIM_TIMER_COPY, MONSTER_BG_SAVE_BUFFER (buffer)
; Calls: SOUND_05, DRAW_MONSTER_WEAPON_FRAME, COPY_GFX_2_BUFFER, CHK_ITEM
;==============================================================================
MONSTER_ANIM_ADVANCE:
    CALL        SOUND_05                            ; Play attack sound blip
    LD          A,(MONSTER_ANIM_STATE)              ; Load current animation state (1 or 3)
    LD          HL,(MONSTER_ANIM_LOOP_COUNT)        ; Load position frame counter
    DEC         A                                   ; Decrement state: 1→0 or 3→2
    JP          NZ,SKIP_MONSTER_WEAPON_FRAME        ; If state≠1, jump to increment position
    DEC         L                                   ; State=1: decrement low byte of counter
    JP          NZ,RESET_MONSTER_ANIM_STATE         ; If L≠0, continue animation
    DEC         H                                   ; L reached 0: decrement high byte
    JP          Z,FINISH_APPLY_PLAYER_DAMAGE        ; If both bytes=0, animation done, apply damage
    LD          A,$32                               ; Monster weapon CHRRAM high byte
    LD          (MN_WPN_CHRRAM_HI),A                ; Store high byte for melee weapon positioning
    LD          L,0x2                               ; Reset low counter to 2

RESET_MONSTER_ANIM_STATE:
    LD          A,0x3                               ; Set monster animation state to 3

    LD          (MONSTER_ANIM_STATE),A              ; Store new state
    LD          (MONSTER_ANIM_LOOP_COUNT),HL        ; Save updated frame counter
    LD          HL,(MONSTER_WEAPON_CHRRAM_PTR)      ; Load current weapon screen position
;    LD          BC,41                              ; Row stride 41
    LD          BC,39                               ; Row stride 39      **** CHANGE ME ****
    ADD         HL,BC                               ; Advance weapon position by 39 bytes
    LD          (MONSTER_WEAPON_CHRRAM_PTR),HL      ; Store new weapon position
    JP          DRAW_MONSTER_WEAPON_FRAME           ; Draw weapon at new position

SKIP_MONSTER_WEAPON_FRAME:
    LD          (MONSTER_ANIM_STATE),A              ; Store current state (decremented)
;    LD          HL,(MONSTER_WEAPON_CHRRAM_PTR)      ; Load current weapon screen position
;    INC         HL                                  ; Move weapon forward by 1 byte    **** CHANGE ME ****
;    LD          (MONSTER_WEAPON_CHRRAM_PTR),HL      ; Store new position
    JP          ADVANCE_MONSTER_WEAPON_FRAME        ; Advance monster weapon screen position

;==============================================================================
; DRAW_MONSTER_WEAPON_FRAME
;==============================================================================
; Draws the monster weapon sprite at the current animation position. Saves the screen
; background to a buffer before drawing, allowing the weapon to be erased later
; by restoring the saved background.
;
; Registers:
; --- Start ---
;   HL = Screen position offset
; --- In Process ---
;   BC = 20 (40 * 5) offset for start of ITEM graphics
;   A  = Various temp values and flags
;   DE = Buffer address (MONSTER_BG_SAVE_BUFFER)
; ---  End  ---
;   All registers modified
;
; Memory Modified: MONSTER_BG_SAVE_BUFFER, WEAPON_SPRITE_CHRRAM_ADDR_HI, MONSTER_ANIM_TIMER_COPY
; Calls: COPY_GFX_2_BUFFER, CHK_ITEM
;==============================================================================
DRAW_MONSTER_WEAPON_FRAME:
    LD          BC,200                              ; BC = 200 (40 * 5), offset for start of ITEM graphics
    XOR         A                                   ; A = 0 (clear for subtraction)
    SBC         HL,BC                               ; HL = HL - 200 (40 * 5)
    PUSH        HL                                  ; Save adjusted screen address
    ADD         HL,BC                               ; Restore original position offset
    LD          DE,MN_BG_CHRRAM_BUFFER              ; DE = background buffer address
    CALL        COPY_GFX_2_BUFFER                   ; Save 4x4 screen area to buffer

    POP         BC                                  ; BC = saved MONSTER CHRRAM address (from stack)
    LD          B,0x0                               ; B = 0 (clear high byte for CHK_ITEM parameter)
    LD          A,(MN_WPN_CHRRAM_HI)                ; Load monster weapon CHRRAM high byte
    LD          (ITEM_CHRRAM_HI),A                  ; Store as sprite address high byte
    LD          A,(MONSTER_WEAPON_SPRITE)           ; Load weapon sprite ID
    CALL        CHK_ITEM                            ; Draw melee weapon sprite (second draw this tick)

ADVANCE_MONSTER_WEAPON_FRAME:
    LD          A,$32                               ; Reset to default CHRRAM row
;    LD          A,(MN_WPN_CHRRAM_HI)                ; Load monster weapon CHRRAM high byte **** CHANGE ME ****
    LD          (ITEM_CHRRAM_HI),A                  ; Store as sprite address high byte
    LD          A,(MASTER_TICK_TIMER)               ; Load system timer
    ADD         A,$ff                               ; Decrement by 1
    LD          (MONSTER_TIMER_COMPARE),A           ; Store updated animation timer
    RET                                             ; Return to animation loop

;==============================================================================
; COPY_MN_BUFF_TO_SCRN
;==============================================================================
; Restores the screen background from buffer, erasing the weapon sprite.
; Called to clear the weapon from its previous position before drawing at
; the next position, or after animation completes.
;
; Registers:
; --- Start ---
;   (None)
; --- In Process ---
;   HL = Buffer address (MONSTER_BG_SAVE_BUFFER)
;   DE = Screen position from MONSTER_ATT_POS_OFFSET
; ---  End  ---
;   Modified by COPY_GFX_FROM_BUFFER
;
; Memory Modified: None
; Calls: COPY_GFX_FROM_BUFFER
;==============================================================================
COPY_MN_BUFF_TO_SCRN:
    LD          DE,(MONSTER_WEAPON_CHRRAM_PTR)      ; DE = screen position where weapon is drawn
    LD          HL,MN_BG_CHRRAM_BUFFER              ; HL = buffer with saved background
    JP          COPY_GFX_FROM_BUFFER                ; Restore background, erasing the melee sprite only (RH item not erased here)

;==============================================================================
; FINISH_APPLY_PLAYER_DAMAGE
;==============================================================================
; Animation complete handler. Restores final background, then calculates and
; applies damage from the completed attack. Determines if monster or player
; took damage based on MELEE_WEAPON_SPRITE, then updates health and redraws.
;
; Registers:
; --- Start ---
;   (Reads from memory: MELEE_WEAPON_SPRITE, WEAPON_VALUE_HOLDER, MULTIPURPOSE_BYTE)
; --- In Process ---
;   A  = Flags, damage values, health calculations (BCD arithmetic)
;   B  = Loop counter for damage multiplication
;   HL = Damage accumulator (BCD), health values
;   DE = Shield/defense values, damage amounts
; ---  End  ---
;   All registers modified through multiple function calls
;   Health values updated, viewport redrawn
;
; Calls: MELEE_RESTORE_BG_FROM_BUFFER, SUB_ram_e439, SUB_ram_e401, RECALC_PHYS_HEALTH,
;        REDRAW_STATS, PLAYER_DIES, REDRAW_START, REDRAW_VIEWPORT
;==============================================================================
FINISH_APPLY_PLAYER_DAMAGE:
    CALL        COPY_MN_BUFF_TO_SCRN                ; Restore background, erase weapon sprite
    LD          A,$31                               ; Player weapon CHRRAM high byte
    LD          (MN_WPN_CHRRAM_HI),A                ; Store high byte (also signals damage calc phase)
    LD          (MONSTER_MELEE_STATE),A             ; Store MONSTER_MELEE_STATE
    LD          A,(DIFFICULTY_LEVEL)                ; Load DIFFICULTY_LEVEL
    LD          B,A                                 ; B = iteration counter
    LD          H,0x0                               ; H = 0 (high byte of damage accumulator)
    LD          A,(WEAPON_VALUE_HOLDER)             ; Load base weapon damage value
    LD          L,A                                 ; L = base damage (low byte)
    JP          ACCUM_DAMAGE_LOOP                   ; Jump into damage calculation loop

;==============================================================================
; ACCUM_DAMAGE_STEP — BCD Damage Accumulation Loop Body
;==============================================================================
; Inner loop step that accumulates damage using BCD arithmetic. Multiplies
; base weapon damage by the iteration count through repeated addition.
;
; Registers:
; --- Start ---
;   A  = Accumulated damage so far
;   L  = Base damage value (constant)
;   B  = Loop counter
; --- In Process ---
;   A  = A + L with DAA correction
; ---  End  ---
;   A  = Updated accumulator
;   F  = Flags from DAA
;
; Memory Modified: None
; Calls: None (called by ACCUM_DAMAGE_LOOP)
;==============================================================================
ACCUM_DAMAGE_STEP:
    ADD         A,L                                 ; A = A + L (accumulate damage)
    DAA                                             ; Decimal adjust for BCD arithmetic

;==============================================================================
; ACCUM_DAMAGE_LOOP — Damage Multiplication Entry Point
;==============================================================================
; Entry point for damage accumulation loop. Multiplies base damage by count
; through repeated BCD addition. Enters mid-loop to handle B iterations.
;
; Registers:
; --- Start ---
;   B  = Iteration count
;   A  = Initial accumulator
;   L  = Base damage
; --- In Process ---
;   B  = Decremented each iteration
;   A  = Accumulated via ADD/DAA
; ---  End  ---
;   B  = 0
;   A  = Total damage
;   F  = Flags from last operation
;
; Memory Modified: None
; Calls: ACCUM_DAMAGE_STEP (loops back)
;==============================================================================
ACCUM_DAMAGE_LOOP:
    DJNZ        ACCUM_DAMAGE_STEP                   ; Loop B times: B--, if B != 0 jump to step
    LD          L,A                                 ; L = total calculated damage
    LD          A,(MONSTER_WEAPON_SPRITE)           ; Load target identifier (sprite frame code)
    AND         $fc                                 ; Mask to sprite family ($24-$27 → $24)
    CP          $24                                 ; Check if player is target ($24-$27 range)
    JP          NZ,MONSTER_PHYS_BRANCH              ; If not player target, jump to monster damage
    
    ; Player is target - calculate spiritual shield effectiveness
    LD          A,(SHIELD_SPRT)                     ; Load player's spiritual shield value
    LD          E,A                                 ; E = shield defense value (saved for later)
    CALL        DIVIDE_BCD_HL_BY_2                  ; HL = damage / 2; result in L (shield effectiveness roll)
    LD          D,L                                 ; D = shield roll result (half damage)
    CALL        RANDOMIZE_BCD_NYBBLES               ; Randomize L nybbles for variance
    LD          A,L                                 ; A = random variance value
    ADD         A,D                                 ; A = shield roll + variance
    DAA                                             ; Decimal adjust for BCD
    SUB         E                                   ; A = (shield roll + variance) - shield value
    DAA                                             ; Decimal adjust for BCD
    JP          C,SHIELD_BLOCKS_DAMAGE              ; If negative (shield blocked), reduce damage
    LD          E,A                                 ; E = final damage to apply (penetrated shield) (penetrated shield)

;==============================================================================
; PLAYER_TAKES_SPRT_DAMAGE — Apply Spiritual Damage to Player
;==============================================================================
; Applies spiritual damage to the player's health. Checks for death conditions
; (health <= 0) and updates the stats display if player survives.
;
; Registers:
; --- Start ---
;   E  = Damage value
; --- In Process ---
;   A  = Health calculations
; ---  End  ---
;   A  = New health value (if alive)
;   F  = Flags from SUB/DAA
;
; Memory Modified: PLAYER_SPRT_HEALTH (if alive)
; Calls: PLAYER_DIES, REDRAW_STATS, REDRAW_SCREEN_AFTER_DAMAGE
;==============================================================================
PLAYER_TAKES_SPRT_DAMAGE:
    LD          A,(PLAYER_SPRT_HEALTH)              ; Load player's current spiritual health
    SUB         E                                   ; A = health - damage (BCD subtraction)
    DAA                                             ; Decimal adjust for BCD
    JP          C,PLAYER_DIES                       ; If negative (carry set), player dies
    JP          Z,PLAYER_DIES                       ; If zero health, player dies
    LD          (PLAYER_SPRT_HEALTH),A              ; Store new health value
    CALL        REDRAW_STATS                        ; Update stats display on screen
    JP          REDRAW_SCREEN_AFTER_DAMAGE          ; Jump to finish animation and redraw and redraw

;==============================================================================
; SHIELD_BLOCKS_DAMAGE — Shield Block Damage Reduction
;==============================================================================
; Handles case where player's spiritual shield successfully blocks most damage.
; Reduces incoming damage to a small random value (0-2) and applies it.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = Base value (2)
;   L  = Randomized result
; ---  End  ---
;   E  = Reduced damage
;   L  = Randomized value
;
; Memory Modified: None directly (via PLAYER_TAKES_SPRT_DAMAGE)
; Calls: RANDOMIZE_BCD_NYBBLES, PLAYER_TAKES_SPRT_DAMAGE
;==============================================================================
SHIELD_BLOCKS_DAMAGE:
    LD          HL,0x2                              ; Base reduced damage = 2
    CALL        RANDOMIZE_BCD_NYBBLES               ; Randomize to 0-2 range
    LD          E,L                                 ; E = reduced damage value
    JP          PLAYER_TAKES_SPRT_DAMAGE            ; Apply minimal damage to player

;==============================================================================
; MONSTER_PHYS_BRANCH — Monster Takes Physical Damage
;==============================================================================
; Handles physical damage application to monsters. Calculates final damage
; by adding weapon value to accumulated damage with variance, then tests
; against monster's physical defense.
;
; Registers:
; --- Start ---
;   HL = Accumulated damage
; --- In Process ---
;   A  = Calculations for low/high bytes
;   L  = Damage low byte with variance
;   H  = Damage high byte with carry
;   DE = Defense value
; ---  End  ---
;   HL = Final damage value
;   DE = Defense value
;   F  = Flags from RECALC_PHYS_HEALTH
;
; Memory Modified: None directly
; Calls: RANDOMIZE_BCD_NYBBLES, RECALC_PHYS_HEALTH, PLAYER_CALC_PHYS_DAMAGE or BOOST_MIN_DAMAGE
;==============================================================================
MONSTER_PHYS_BRANCH:
    CALL        RANDOMIZE_BCD_NYBBLES               ; Randomize L nybbles for damage variance
    LD          A,(WEAPON_VALUE_HOLDER)             ; Load base weapon damage value
    ADD         A,L                                 ; A = base damage + variance
    DAA                                             ; Decimal adjust for BCD
    LD          L,A                                 ; L = damage low byte
    LD          A,H                                 ; A = damage high byte (was 0)
    ADC         A,0x0                               ; Add carry from low byte addition
    DAA                                             ; Decimal adjust for BCD
    LD          H,A                                 ; H = damage high byte
    LD          DE,(SHIELD_PHYS)                    ; DE = monster's physical defense (16-bit BCD)
    CALL        RECALC_PHYS_HEALTH                  ; HL = HL - DE; carry if HL < DE
    JP          C,BOOST_MIN_DAMAGE                  ; If HL < DE (defense too strong), boost damage boost damage

;==============================================================================
; PLAYER_CALC_PHYS_DAMAGE — Apply Physical Damage to Player
;==============================================================================
; Applies calculated physical damage to player health. Checks for
; player death conditions and updates display.
;
; Registers:
; --- Start ---
;   HL = Damage value
; --- In Process ---
;   DE = Damage (after swap)
;   HL = Player health, then result
;   A  = Health check
; ---  End  ---
;   HL = New health (if alive)
;   F  = Flags from health calculation
;
; Memory Modified: PLAYER_PHYS_HEALTH (if alive)
; Calls: RECALC_PHYS_HEALTH, PLAYER_DIES, REDRAW_STATS, REDRAW_SCREEN_AFTER_DAMAGE
;==============================================================================
PLAYER_CALC_PHYS_DAMAGE:
    EX          DE,HL                               ; Swap: DE = damage, HL = unused
    LD          HL,(PLAYER_PHYS_HEALTH)             ; Load player's health
    CALL        RECALC_PHYS_HEALTH                  ; HL = HL - DE; carry if HL < DE
    JP          C,PLAYER_DIES                       ; If underflow (health < 0), player dies
    OR          L                                   ; A = A | L; check if low byte is zero
    JP          Z,PLAYER_DIES                       ; If health = 0, player dies
    LD          (PLAYER_PHYS_HEALTH),HL             ; Store player's new health value
    CALL        REDRAW_STATS                        ; Update stats display on screen on screen

;==============================================================================
; REDRAW_SCREEN_AFTER_DAMAGE — Finalize Combat Round Visual Update
;==============================================================================
; Completes a combat round by preparing and executing a full viewport redraw.
; This ensures any visual changes from the damage application are reflected.
;
; Registers:
; --- Start ---
;   All per REDRAW_START requirements
; --- In Process ---
;   All modified by redraw routines
; ---  End  ---
;   All per REDRAW_VIEWPORT completion
;
; Memory Modified: CHRRAM/COLRAM via viewport redraw
; Calls: REDRAW_START, REDRAW_VIEWPORT
;==============================================================================
REDRAW_SCREEN_AFTER_DAMAGE:
    CALL        REDRAW_START                        ; Prepare for viewport redraw
                                                    ; Viewport redraw occurs after damage is applied
                                                    ; to reflect any visual changes from the combat round.
    JP          REDRAW_VIEWPORT                     ; Redraw viewport and return to game loop

;==============================================================================
; BOOST_MIN_DAMAGE — Boost Damage When Defense Too Low
;==============================================================================
; Handles case where monster's physical defense is insufficient to reduce
; damage meaningfully. Applies a minimum damage boost with variance.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = Base damage (3)
;   L  = Randomized result
; ---  End  ---
;   HL = Final boosted damage
;
; Memory Modified: None directly
; Calls: RANDOMIZE_BCD_NYBBLES, MONSTER_CALC_PHYS_DAMAGE
;==============================================================================
BOOST_MIN_DAMAGE:
    LD          HL,0x3                              ; Base boosted damage = 3
    CALL        RANDOMIZE_BCD_NYBBLES               ; Randomize to 0-3 range
    JP          PLAYER_CALC_PHYS_DAMAGE             ; Apply boosted damage to player

;==============================================================================
; DO_SWAP_HANDS — Swap Left and Right Hand Items
;==============================================================================
; Exchanges items between left and right hands, updating both the item codes
; and their visual representations. Also recalculates shield values based on
; the new equipment configuration.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = Various pointers (item codes, graphics)
;   DE = Graphics destination pointers
;   BC = Item code pointers, then shield adjustment values
;   A  = Item codes and shield calculations
; ---  End  ---
;   BC = Shield bonuses from new left-hand item
;   All registers modified
;
; Memory Modified: RIGHT_HAND_ITEM, LEFT_HAND_ITEM, CHRRAM graphics areas,
;                  SHIELD_SPRT, SHIELD_PHYS
; Calls: SWAP_BYTES_AT_HL_BC, COPY_GFX_2_BUFFER, COPY_GFX_SCRN_2_SCRN,
;        COPY_GFX_FROM_BUFFER, NEW_RIGHT_HAND_ITEM, GET_ITEM_SHIELD_BONUS, UPDATE_SHIELD_STATS
;==============================================================================
DO_SWAP_HANDS:
    LD          HL,RIGHT_HAND_ITEM                  ; HL points to right-hand item code
    LD          BC,LEFT_HAND_ITEM                   ; BC points to left-hand item code
    CALL        SWAP_BYTES_AT_HL_BC                 ; Swap the two item codes
    LD          HL,CHRRAM_RIGHT_HAND_VP_IDX         ; HL = right-hand graphics source
    LD          DE,PL_BG_CHRRAM_BUFFER              ; DE = temporary buffer destination
    CALL        COPY_GFX_2_BUFFER                   ; Save right-hand graphics to buffer
    LD          HL,CHRRAM_LEFT_HAND_VP_IDX          ; HL = left-hand viewport graphics source
    LD          DE,CHRRAM_RIGHT_HAND_VP_IDX         ; DE = right-hand graphics destination
    CALL        COPY_GFX_SCRN_2_SCRN                ; Copy left-hand graphics to right-hand slot
    LD          HL,PL_BG_CHRRAM_BUFFER              ; HL = buffered graphics source
    LD          DE,CHRRAM_LEFT_HAND_VP_IDX          ; DE = left-hand viewport graphics destination
    CALL        COPY_GFX_FROM_BUFFER                ; Copy buffered graphics to left-hand slot
    CALL        NEW_RIGHT_HAND_ITEM                 ; Update right-hand item attributes
    LD          BC,0x0                              ; Clear BC (will hold shield bonuses)
    LD          HL,RIGHT_HAND_ITEM                  ; HL points to new right-hand item
    CALL        GET_ITEM_SHIELD_BONUS               ; Get old right-hand item's shield bonuses into BC
    LD          A,(SHIELD_SPRT)                     ; Load current spiritual shield
    SUB         C                                   ; Subtract old right-hand SPRT bonus
    DAA                                             ; Decimal adjust for BCD
    LD          (SHIELD_SPRT),A                     ; Store updated spiritual shield
    LD          A,(SHIELD_PHYS)                     ; Load physical shield low byte
    SUB         B                                   ; Subtract old right-hand PHYS bonus
    DAA                                             ; Decimal adjust for BCD
    LD          (SHIELD_PHYS),A                     ; Store updated physical shield low byte
    LD          A,(SHIELD_PHYS+1)                   ; Load physical shield high byte
    SBC         A,0x0                               ; Subtract borrow from high byte
    LD          (SHIELD_PHYS+1),A                   ; Store updated physical shield high byte
    LD          BC,0x0                              ; Clear BC for next item's bonuses
    LD          HL,LEFT_HAND_ITEM                   ; HL points to new left-hand item
    CALL        GET_ITEM_SHIELD_BONUS               ; Get old left-hand item's shield bonuses into BC
    JP          UPDATE_SHIELD_STATS                 ; Jump to add new shield bonuses

;==============================================================================
; GET_ITEM_SHIELD_BONUS — Get Item Shield Bonuses
;==============================================================================
; Retrieves shield bonuses (physical and spiritual) from an item based on its
; code. Only processes shield items ($00-$03, $10-$13) and returns halved
; attribute values in BC.
;
; Item ranges:
;   $00-$03: Basic shields (BUCKLER variants)
;   $04-$0F: Non-shield items (skip)
;   $10-$13: Advanced shields (SHIELD variants)
;   $14+:    Non-shield items (skip)
;
; Registers:
; --- Start ---
;   HL = Item code pointer
; --- In Process ---
;   A  = Item code, level, attribute checks
;   HL = Attribute pointer, then calculation temp
;   B/C = Attribute values
; ---  End  ---
;   B  = PHYS bonus (or unchanged if not shield)
;   C  = SPRT bonus (or unchanged if not shield)
;   HL = Modified by calculations
;
; Memory Modified: None
; Calls: ITEM_ATTR_LOOKUP, DIVIDE_BCD_HL_BY_2 (twice)
;==============================================================================
GET_ITEM_SHIELD_BONUS:
    LD          A,(HL)                              ; Load item code from (HL)
    CP          $14                                 ; Compare to $14 (first non-shield advanced item)
    RET         NC                                  ; If >= $14, not a shield, return
    CP          $10                                 ; Compare to $10 (advanced shield start)
    JP          NC,CALC_SHIELD_ATTRS                ; If >= $10, process as advanced shield
    CP          0x4                                 ; Compare to $04 (first non-shield basic item)
    RET         NC                                  ; If >= $04 and < $10, not a shield, return
    ; Falls through for $00-$03 (basic shields)

;==============================================================================
; CALC_SHIELD_ATTRS — Extract and Halve Shield Attributes
;==============================================================================
; Processes shield items to extract attribute bonuses. Masks item code to get
; level (0-3), looks up attributes, validates them, and returns halved values.
;
; Registers:
; --- Start ---
;   A  = Item code
;   B/C = Attribute values from lookup
; --- In Process ---
;   A  = Level (0-3), then attribute validation
;   HL = Used for division calculations
;   L  = Temporary for halving operations
; ---  End  ---
;   B  = Halved physical bonus
;   C  = Halved spiritual bonus
;   HL/A modified
;
; Memory Modified: None
; Calls: ITEM_ATTR_LOOKUP, DIVIDE_BCD_HL_BY_2 (twice)
;==============================================================================
CALC_SHIELD_ATTRS:
    AND         0x3                                 ; Mask to level bits (0-3)
    INC         A                                   ; Increment to 1-4 for lookup
    CALL        ITEM_ATTR_LOOKUP                    ; Get item attributes; returns HL = attr ptr, B/C set
    LD          A,(HL)                              ; Load attribute byte
    AND         $fc                                 ; Mask upper 6 bits (check if attributes exist)
    RET         NZ                                  ; If non-zero, attributes invalid or special, return
    LD          H,0x0                               ; Clear H for 16-bit division
    LD          L,B                                 ; L = physical attribute value
    CALL        DIVIDE_BCD_HL_BY_2                  ; Halve physical attribute
    LD          B,L                                 ; B = halved physical bonus
    LD          L,C                                 ; L = spiritual attribute value
    CALL        DIVIDE_BCD_HL_BY_2                  ; Halve spiritual attribute
    LD          C,L                                 ; C = halved spiritual bonus
    RET                                             ; Return with B/C containing halved bonuses
 
;==============================================================================
; NEW_RIGHT_HAND_ITEM — Recalculate Right-Hand Weapon Stats
;==============================================================================
; Derives weapon stats for the current right-hand item. For bow/crossbow
; range ($18..$33), computes physical or spiritual weapon values depending
; on subtype, then updates HUD counters for PHYS and SPRT weapons.
;
; Registers:
; --- Start ---
;   A = RIGHT_HAND_ITEM
; --- In Process ---
;   D = damage scale selector; B/E used by rotates
;   HL = temporary/result for PHYS value
; ---  End  ---
;   HL/A modified; flags set by DAA/CP
;
; Memory Modified: WEAPON_PHYS, WEAPON_SPRT
; Calls: CALC_WEAPON_VALUE, RECALC_AND_REDRAW_BCD
;==============================================================================
NEW_RIGHT_HAND_ITEM:
    LD          A,(RIGHT_HAND_ITEM)                 ; Load current right-hand item code into A
    CP          $18                                 ; Compare to $18 (RED Bow start)
    JP          C,CLEAR_WEAPON_VALUES               ; If below range, clear weapon values
    CP          $34                                 ; Compare to $34 (one past WHITE Crossbow)
    JP          NC,CLEAR_WEAPON_VALUES              ; If at/above, clear weapon values
    LD          BC,0x0                              ; Clear BC (B/C used during bit rotations)
    LD          E,0x0                               ; E = 0 (used by spiritual path later)
    SRL         A                                   ; Logical shift right: begin subtype decode
    RR          B                                   ; Rotate through carry into B (collect bits)
    RRA                                             ; Rotate A right through carry (continue decode)
    RL          B                                   ; Rotate B left: accumulate subtype bits
    RL          B                                   ; Rotate B left again: finalize subtype accumulation
    SUB         0x6                                 ; Normalize subtype to tier base
    JP          NZ,WEAPON_TIER_SPRT_1               ; If not zero, branch to tier handlers
    LD          D,0x6                               ; D = base tier value for physical path
    JP          CALC_PHYS_WEAPON                    ; Compute physical weapon value
 
;==============================================================================
; WEAPON_TIER_SPRT_1 — Tier Branch (Spiritual Path Selector)
;==============================================================================
; Branch for decoded subtype tier. Selects base tier value in D and
; jumps to spiritual weapon computation path when A decrements to zero.
;
; Registers:
; --- Start ---
;   A = tier counter
; --- In Process ---
;   A decremented for decision; D loaded
; ---  End  ---
;   D set; branch taken
;
; Memory Modified: None
; Calls: None
;==============================================================================
WEAPON_TIER_SPRT_1:
    DEC         A                                   ; Decrement tier counter
    JP          NZ,WEAPON_TIER_PHYS_1               ; If not zero, continue to next branch
    LD          D,0x6                               ; D = spiritual tier value
    JP          CALC_SPRT_WEAPON                    ; Compute spiritual weapon value
 
;==============================================================================
; WEAPON_TIER_PHYS_1 — Tier Branch (Physical Path Selector)
;==============================================================================
; Selects higher physical tier for weapon calculation and branches to
; physical computation path when A reaches zero.
;
; Inputs:
;   A = subtype tier counter
;
; Outputs:
;   D = physical tier value
;   Flow to CALC_PHYS_WEAPON
;
; Registers:
; --- Start ---
;   A = tier counter
; --- In Process ---
;   A decremented; D assigned
; ---  End  ---
;   D set; branch taken
;
; Memory Modified: None
; Calls: None
;==============================================================================
WEAPON_TIER_PHYS_1:
    DEC         A                                   ; Decrement tier counter
    JP          NZ,WEAPON_TIER_SPRT_2               ; If not zero, check next branch
    LD          D,$16                               ; D = higher physical tier value
    JP          CALC_PHYS_WEAPON                    ; Compute physical weapon value
 
;==============================================================================
; WEAPON_TIER_SPRT_2 — Tier Branch (Spiritual Path Selector)
;==============================================================================
; Selects higher spiritual tier for weapon calculation and branches to
; spiritual computation path when A reaches zero.
;
; Inputs:
;   A = subtype tier counter
;
; Outputs:
;   D = spiritual tier value
;   Flow to CALC_SPRT_WEAPON
;
; Registers:
; --- Start ---
;   A = tier counter
; --- In Process ---
;   A decremented; D assigned
; ---  End  ---
;   D set; branch taken
;
; Memory Modified: None
; Calls: None
;==============================================================================
WEAPON_TIER_SPRT_2:
    DEC         A                                   ; Decrement tier counter
    JP          NZ,WEAPON_TIER_PHYS_2               ; If not zero, check next branch
    LD          D,$20                               ; D = higher spiritual tier value
    JP          CALC_SPRT_WEAPON                    ; Compute spiritual weapon value
 
;==============================================================================
; WEAPON_TIER_PHYS_2 — Tier Branch (Physical Path Selector)
;==============================================================================
; Selects higher physical tier for weapon calculation and branches to
; physical computation path when A reaches zero.
;
; Inputs:
;   A = subtype tier counter
;
; Outputs:
;   D = physical tier value
;   Flow to CALC_PHYS_WEAPON
;
; Registers:
; --- Start ---
;   A = tier counter
; --- In Process ---
;   A decremented; D assigned
; ---  End  ---
;   D set; branch taken
;
; Memory Modified: None
; Calls: None
;==============================================================================
WEAPON_TIER_PHYS_2:
    DEC         A                                   ; Decrement tier counter
    JP          NZ,WEAPON_TIER_SPRT_3               ; If not zero, check next branch
    LD          D,$24                               ; D = higher physical tier value
    JP          CALC_PHYS_WEAPON                    ; Compute physical weapon value
 
;==============================================================================
; WEAPON_TIER_SPRT_3 — Tier Branch (Spiritual Path Selector)
;==============================================================================
; Selects spiritual tier for weapon calculation and branches to
; spiritual computation path when A reaches zero.
;
; Inputs:
;   A = subtype tier counter
;
; Outputs:
;   D = spiritual tier value
;   Flow to CALC_SPRT_WEAPON
;
; Registers:
; --- Start ---
;   A = tier counter
; --- In Process ---
;   A decremented; D assigned
; ---  End  ---
;   D set; branch taken
;
; Memory Modified: None
; Calls: None
;==============================================================================
WEAPON_TIER_SPRT_3:
    DEC         A                                   ; Decrement tier counter
    JP          NZ,WEAPON_TIER_PHYS_FINAL           ; If not zero, go to final physical tier
    LD          D,$15                               ; D = spiritual tier value
    JP          CALC_SPRT_WEAPON                    ; Compute spiritual weapon value
 
;==============================================================================
; WEAPON_TIER_PHYS_FINAL — Final Tier (Physical Path)
;==============================================================================
; Final tier selection for physical weapon path. Sets D to last tier
; value and falls through to physical weapon value computation.
;
; Inputs:
;   A = final tier counter
;
; Outputs:
;   D = physical tier value
;   Flow to CALC_PHYS_WEAPON
;
; Registers:
; --- Start ---
;   A = counter
; --- In Process ---
;   A decremented
; ---  End  ---
;   D set
;
; Memory Modified: None
; Calls: None
;==============================================================================
WEAPON_TIER_PHYS_FINAL:
    DEC         A                                   ; Final decrement on tier counter
    LD          D,$18                               ; D = final physical tier value
 
;==============================================================================
; CALC_PHYS_WEAPON — Compute Physical Weapon Value
;==============================================================================
; Computes 16-bit BCD physical weapon value from tier D via CALC_WEAPON_VALUE,
; doubles it, normalizes with DAA, stores into WEAPON_PHYS, and clears WEAPON_SPRT.
;
; Inputs:
;   D = physical tier value
;
; Outputs:
;   WEAPON_PHYS updated; WEAPON_SPRT cleared
;   Flow to REDRAW_WEAPON_HUD (HUD redraw)
;
; Registers:
; --- Start ---
;   D = tier
; --- In Process ---
;   A = base value and doubled result; H/L = stored value
; ---  End  ---
;   HL/A updated; flags set by DAA
;
; Memory Modified: WEAPON_PHYS, WEAPON_SPRT
; Calls: CALC_WEAPON_VALUE
;==============================================================================
CALC_PHYS_WEAPON:
    CALL        CALC_WEAPON_VALUE                   ; A = base weapon value from tier D
    ADD         A,A                                 ; Double A for physical weighting
    DAA                                             ; Decimal adjust to maintain BCD
    LD          L,A                                 ; L = low byte of PHYS value
    LD          A,0x0                               ; Prepare zero for high byte computation
    RLA                                             ; Rotate left: move carry into high nybble
    LD          H,A                                 ; H = high byte of PHYS value
    LD          (WEAPON_PHYS),HL                    ; Store 16-bit PHYS value
    XOR         A                                   ; A = 0
    LD          (WEAPON_SPRT),A                     ; Clear SPRT value
    JP          REDRAW_WEAPON_HUD                   ; Redraw HUD weapon counters
 
;==============================================================================
; CALC_SPRT_WEAPON — Compute Spiritual Weapon Value
;==============================================================================
; Computes 8-bit BCD spiritual weapon value from tier D via CALC_WEAPON_VALUE,
; stores into WEAPON_SPRT, and clears WEAPON_PHYS.
;
; Inputs:
;   D = spiritual tier value
;
; Outputs:
;   WEAPON_SPRT updated; WEAPON_PHYS cleared
;   Flow to REDRAW_WEAPON_HUD (HUD redraw)
;
; Registers:
; --- Start ---
;   D = tier
; --- In Process ---
;   A = computed value; HL cleared
; ---  End  ---
;   A/HL updated
;
; Memory Modified: WEAPON_SPRT, WEAPON_PHYS
; Calls: CALC_WEAPON_VALUE
;==============================================================================
CALC_SPRT_WEAPON:
    CALL        CALC_WEAPON_VALUE                   ; A = spiritual weapon value from tier D
    LD          (WEAPON_SPRT),A                     ; Store SPRT value (8-bit BCD)
    LD          HL,0x0                              ; HL = 0
    LD          (WEAPON_PHYS),HL                    ; Clear PHYS value
 
;==============================================================================
; REDRAW_WEAPON_HUD — Redraw Weapon Values on HUD
;==============================================================================
; Recalculates and redraws HUD counters for PHYS and SPRT weapon values.
; Writes PHYS (2 digits) and SPRT (1 digit) to their CHRRAM positions.
;
; Inputs:
;   WEAPON_PHYS, WEAPON_SPRT
;
; Outputs:
;   HUD counters updated
;
; Registers:
; --- Start ---
;   HL = value pointers; DE = CHRRAM indices; B = digit count
; --- In Process ---
;   Modified by RECALC_AND_REDRAW_BCD
; ---  End  ---
;   Updated HUD
;
; Memory Modified: CHRRAM_PHYS_WEAPON_IDX, CHRRAM_SPRT_WEAPON_IDX
; Calls: RECALC_AND_REDRAW_BCD
;==============================================================================
REDRAW_WEAPON_HUD:
    LD          DE,CHRRAM_PHYS_WEAPON_IDX           ; DE = PHYS HUD counter CHRRAM address
    LD          HL,WEAPON_PHYS                      ; HL = pointer to PHYS value
    LD          B,0x2                               ; B = number of digits (2)
    CALL        RECALC_AND_REDRAW_BCD               ; Recalculate and draw PHYS digits
    LD          DE,CHRRAM_SPRT_WEAPON_IDX           ; DE = SPRT HUD counter CHRRAM address
    LD          HL,WEAPON_SPRT                      ; HL = pointer to SPRT value
    LD          B,0x1                               ; B = number of digits (1)
    JP          RECALC_AND_REDRAW_BCD               ; Recalculate and draw SPRT digit
 
;==============================================================================
; CLEAR_WEAPON_VALUES — Clear Weapon Values Outside Range
;==============================================================================
; Handles items outside bow/crossbow range. Clears PHYS and SPRT weapon
; values and triggers HUD redraw.
;
; Inputs:
;   RIGHT_HAND_ITEM outside $18..$33
;
; Outputs:
;   WEAPON_PHYS = 0; WEAPON_SPRT = 0
;   Flow to REDRAW_WEAPON_HUD
;
; Registers:
; --- Start ---
;   HL cleared; A = 0
; --- In Process ---
;   Stores zeros
; ---  End  ---
;   Values cleared
;
; Memory Modified: WEAPON_PHYS, WEAPON_SPRT
; Calls: RECALC_AND_REDRAW_BCD (via REDRAW_WEAPON_HUD)
;==============================================================================
CLEAR_WEAPON_VALUES:
    LD          HL,0x0                              ; Load HL with 0
    XOR         A                                   ; Clear A (A = 0)
    LD          (WEAPON_PHYS),HL                    ; Store 0 to WEAPON_PHYS (2 bytes)
    LD          (WEAPON_SPRT),A                     ; Store 0 to WEAPON_SPRT
    JP          REDRAW_WEAPON_HUD                   ; Jump to recalc/redraw weapon stats

;==============================================================================
; DO_PICK_UP - Handle item pickup from dungeon floor
;==============================================================================
; Validates that player is adjacent to (not on) an item, then routes to
; appropriate pickup handler based on item type. Distinguishes between
; equipment (Ring/Helmet/Armor), consumables (Food/Arrows), and Map.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = Player position, item position comparisons, item type code
;   B  = Item position temp storage
;   HL = Inventory slot pointers
; ---  End  ---
;   Varies by item type handler
;
; Memory Modified: Inventory slots, equipment stats (varies by item type)
; Calls: ITEM_MAP_CHECK, PICK_UP_S0_ITEM, CHECK_FOOD_ARROWS, PROCESS_RHA
;==============================================================================
DO_PICK_UP:
    LD          A,(ITEM_HOLDER)                     ; Load item's map position
    LD          B,A                                 ; Store item position in B
    LD          A,(PLAYER_MAP_POS)                  ; Load player's map position
    CP          B                                   ; Compare player position to item position
                                                    ; (check if player is on same square as item)
    JP          Z,NO_ACTION_TAKEN                   ; If player on item square, no pickup
    INC         A                                   ; Increment player position
    JP          Z,NO_ACTION_TAKEN                   ; If result is 0 (was $FF), no pickup
    DEC         A                                   ; Restore original player position
    CALL        ITEM_MAP_CHECK                      ; Check item type and validity
    JP          Z,CHECK_CHEST_PICKUP                ; If Z flag set, handle special case
    CP          RED_RING_ITEM                       ; Compare item to RED RING (item code 4)
    JP          C,CHECK_FOOD_ARROWS                 ; If < RING (items 0-3), check food/arrows
    CP          RED_PAVISE_ITEM                     ; Compare to RED PAVISE (item code $10)
    JP          NC,CHECK_FOOD_ARROWS                ; If >= PAVISE, check food/arrows

;==============================================================================
; PROCESS_RHA - Process Ring/Helmet/Armor pickup
;==============================================================================
; Handles pickup of equipment items (Ring, Helmet, Armor). Determines which
; inventory slot to update based on item code, then calls equipment stat
; recalculation routines.
;
; Registers:
; --- Start ---
;   A  = Equipment item code
; --- In Process ---
;   HL = Inventory slot pointer (ARMOR_INV_SLOT, HELMET_INV_SLOT, or RING_INV_SLOT)
;   A  = Decremented for item type testing
; ---  End  ---
;   Varies by equipment handler
;
; Memory Modified: ARMOR_INV_SLOT, HELMET_INV_SLOT, or RING_INV_SLOT
; Calls: PICK_UP_S0_ITEM, equipment stat handlers
;==============================================================================
PROCESS_RHA:
    CALL        PICK_UP_S0_ITEM                     ; Remove item from map, increment D
    LD          HL,ARMOR_INV_SLOT                   ; Point HL to armor inventory slot
    DEC         A                                   ; Decrement item code (test if armor, code 4)
                                                    ; After DEC: 4->3, 5->4, 6->5, etc.
    JP          NZ,NOT_ARMOR                        ; If not zero, not armor
    INC         HL                                  ; Point to helmet slot (armor was code 4)
    INC         HL                                  ; Point to ring slot
NOT_ARMOR:
    DEC         A                                   ; Decrement again (test if helmet, code 5)
    JP          NZ,NOT_HELMET                       ; If not zero, not helmet
    INC         HL                                  ; Point to next slot (helmet was code 5)
NOT_HELMET:
    LD          A,(HL)                              ; Load current item code from inv slot
    INC         D                                   ; Increment D (new item tier/level)
    CP          D                                   ; Compare current item to new item
    JP          NC,ITEM_NOT_WORTHY                  ; If current >= new, don't swap (keep better)
    CALL        PLAY_POWER_UP_SOUND                 ; Upgrading! Play powerup sound.
    EX          AF,AF'                              ; Save A and flags (old item code)
    LD          A,D                                 ; Load new item code
    LD          (HL),A                              ; Store new item in inventory slot
    CALL        ITEM_ATTR_LOOKUP                    ; Get new item attributes (BC = phys/sprt)
    LD          E,C                                 ; Save new SPRT in E
    LD          D,B                                 ; Save new PHYS in D
    EX          AF,AF'                              ; Restore old item code
    CALL        ITEM_ATTR_LOOKUP                    ; Get old item attributes (BC = phys/sprt)
    LD          A,E                                 ; Load new item SPRT
    SUB         C                                   ; Subtract old item SPRT
    DAA                                             ; BCD correction for subtraction
    LD          C,A                                 ; Store SPRT delta in C
    LD          A,D                                 ; Load new item PHYS
    SUB         B                                   ; Subtract old item PHYS
    DAA                                             ; BCD correction for subtraction
    LD          B,A                                 ; Store PHYS delta in B
UPDATE_SHIELD_STATS:
    LD          A,(SHIELD_SPRT)                     ; Load current shield SPRT stat
    ADD         A,C                                 ; Add SPRT delta from item swap
    DAA                                             ; BCD correction for addition
    LD          (SHIELD_SPRT),A                     ; Store updated shield SPRT
    LD          A,(SHIELD_PHYS)                     ; Load shield PHYS low byte
    ADD         A,B                                 ; Add PHYS delta from item swap
    DAA                                             ; BCD correction for addition
    LD          (SHIELD_PHYS),A                     ; Store updated shield PHYS low byte
    LD          A,(SHIELD_PHYS+1)                   ; Load shield PHYS high byte
    ADC         A,0x0                               ; Add carry from previous addition
    DAA                                             ; BCD correction for addition
    LD          (SHIELD_PHYS+1),A                   ; Store updated shield PHYS high byte
    LD          HL,SHIELD_PHYS                      ; Point to shield PHYS value
    LD          DE,CHRRAM_PHYS_SHIELD_IDX           ; Point to screen location for PHYS
    LD          B,0x2                               ; 2 bytes to display
    CALL        RECALC_AND_REDRAW_BCD               ; Recalculate and redraw PHYS stat
    LD          HL,SHIELD_SPRT                      ; Point to shield SPRT value
    LD          DE,CHRRAM_SPRT_SHIELD_IDX           ; Point to screen location for SPRT
    LD          B,0x1                               ; 1 byte to display
    CALL        RECALC_AND_REDRAW_BCD               ; Recalculate and redraw SPRT stat
    JP          RHA_REDRAW                          ; Jump to redraw ring/helmet/armor

ITEM_NOT_WORTHY:
    CALL        WHITE_NOISE_BURST                   ; Not worth keeping sound
    JP          INPUT_DEBOUNCE                      ; Done

CHECK_CHEST_PICKUP:
    CALL        Z,VALIDATE_RH_ITEM_PRESENT          ; If Z flag set, call special handler
CHECK_FOOD_ARROWS:
    CP          RED_FOOD_ITEM                       ; Compare to RED FOOD (item code $48)
    JP          C,CHECK_MAPS                        ; If < $48, check map/amulet/charms
    CP          RED_LOCKED_CHEST_ITEM               ; Compare to LOCKED_CHEST (item code $50)
    JP          NC,CHECK_MAPS                       ; If >= $50, check map/amulet/charms
    CALL        PICK_UP_S0_ITEM                     ; Remove item from map, increment D
    INC         D                                   ; Increment D (item quantity/tier)
    RL          D                                   ; Rotate left (multiply by 2, with carry)
    INC         D                                   ; Increment D again
    CP          FOOD_ITEM_CP                        ; Compare to FOOD item code ($12)
    JP          NZ,PICK_UP_ARROWS                   ; If not food, handle as arrows
    PUSH        DE                                  ; Save DE (item data)
    CALL        PICK_UP_FOOD                        ; Add food to inventory (first portion)
    POP         DE                                  ; Restore DE
    CALL        PICK_UP_FOOD                        ; Add food to inventory (second portion)
    JP          INPUT_DEBOUNCE                      ; Jump to input debounce routine

;==============================================================================
; PICK_UP_FOOD - Add food to player inventory with overflow handling
;==============================================================================
; Adds the quantity in D register to the food inventory count. Handles BCD
; overflow (max 99) by recursively reducing the amount added until it fits.
; Also updates a cumulative food statistics counter using BCD arithmetic.
;
; Registers:
; --- Start ---
;   D = Quantity to add
; --- In Process ---
;   A  = FOOD_INV value, arithmetic operations
;   C  = Overflow amount (if needed)
;   HL = REST_FOOD_COUNTER statistics counter
;   D  = May be reduced during overflow handling
; ---  End  ---
;   A  = H after final DAA (high byte of counter)
;   HL = Updated REST_FOOD_COUNTER value
;
; Memory Modified: FOOD_INV, REST_FOOD_COUNTER
; Calls: Self (recursive on overflow)
;==============================================================================
PICK_UP_FOOD:
    LD          A,(FOOD_INV)                        ; Load current food inventory count
    CP          MAX_FOOD                            ; Compare to MAX_FOOD
    JP          NC,STORE_FOOD_NO_OVERFLOW           ; If already at max, jump ahead
    ADD         A,D                                 ; Add food quantity from D
    JP          NC,STORE_FOOD_NO_OVERFLOW           ; If no carry (no overflow), store result
    INC         A                                   ; Increment A (handle overflow)
    LD          C,A                                 ; Store overflow amount in C
    LD          A,D                                 ; Load original food quantity
    SUB         C                                   ; Subtract overflow from quantity
    LD          D,A                                 ; Store reduced quantity back to D
    JP          PICK_UP_FOOD                        ; Try again with reduced quantity
STORE_FOOD_NO_OVERFLOW:
    CP          MAX_FOOD                            ; Compare to MAX_FOOD
    JP          C,BELOW_MAX_FOOD                    ; Below MAX_FOOD level
    LD          A,MAX_FOOD                          ; Set A to food max
BELOW_MAX_FOOD:
    LD          (FOOD_INV),A                        ; Store updated food inventory count
    LD          HL,(REST_FOOD_COUNTER)              ; Load food statistics counter (BCD)
    LD          A,D                                 ; Load food quantity added
    ADD         A,L                                 ; Add to low byte of counter
    LD          L,A                                 ; Store updated low byte
    LD          A,H                                 ; Load high byte of counter
    ADC         A,0x0                               ; Add carry from previous addition
    LD          H,A                                 ; Store updated high byte
    LD          (REST_FOOD_COUNTER),HL              ; Save updated food statistics counter

    CALL        REDRAW_FOOD_GRAPH                   ; Redraw food inv graphic

    RET                                             ; Return to caller

;==============================================================================
; PICK_UP_ARROWS - Add arrows to player inventory with max cap
;==============================================================================
; Adds the quantity in D register to the arrow inventory count. Enforces a
; maximum arrow count of 64. If the addition would exceed 64,
; clamps the result to exactly 64.
;
; Registers:
; --- Start ---
;   D = Quantity to add
; --- In Process ---
;   A = ARROW_INV value, comparison result, possibly clamped to $32
; ---  End  ---
;   A = Final arrow count stored
;   Jumps to CHECK_MAPS (does not return)
;
; Memory Modified: ARROW_INV
; Calls: CHECK_MAPS (jump)
;==============================================================================
PICK_UP_ARROWS:
    LD          A,(ARROW_INV)                       ; Load current arrow inventory count
    CP          MAX_ARROWS                          ; Compare to MAX_ARROWS
    JP          NC,ADD_ARROWS_TO_INV                ; If more than MAX_ARROWS, jump ahead
    ADD         A,D                                 ; Add arrow quantity from D
    CP          MAX_ARROWS                          ; Compare to MAX_ARROWS
    JP          C,ADD_ARROWS_TO_INV                 ; If less than MAX_ARROWS, add arrows to inventory
    LD          A,MAX_ARROWS                        ; Load max arrow count ($64 BCD)

ADD_ARROWS_TO_INV:
    LD          (ARROW_INV),A                       ; Store updated arrow inventory count
    CALL        REDRAW_ARROWS_GRAPH                 ; Refresh arrows graphic
    JP          INPUT_DEBOUNCE                      ; Jump to input debounce routine
CHECK_MAPS:
    CP          RED_MAP_ITEM                        ; Is it >= $6C (RED_MAP)?
    JP          C,CHECK_CHALICES                    ; If < $6C, not a map, skip to chalices
    CP          WHT_MAP_ITEM+1                      ; Is it < $70 (one past WHT_MAP)?
    JP          NC,CHECK_CHALICES                   ; If >= $70, not a map, skip to chalices
    JP          PROCESS_MAP                         ; In range $6C-$6F, process as map
CHECK_CHALICES:
    CP          RED_CHALICE_ITEM                    ; Compare to RED CHALICE (item code $60)
    JP          Z,PROCESS_RED_CHALICE               ; Make all doors visible on level
    CP          YEL_CHALICE_ITEM                    ; Compare to YEL CHALICE (item code $61)
    JP          Z,PROCESS_YEL_CHALICE               ; Enable Teleport to Ladder option
    CP          MAG_CHALICE_ITEM                    ; Compare to MAG CHALICE (item code $62)
    JP          Z,PROCESS_MAG_CHALICE               ; Wipe all walls on this level
    CP          WHT_CHALICE_ITEM                    ; Compare to WHT CHALICE (item code $63)
    JP          Z,PROCESS_WHT_CHALICE               ; Remove all monsters on this level

CHECK_AMULETS:
    CP          RED_AMULET_ITEM                     ; Compare to RED KEY (item code $5C)
    JP          C,CHECK_KEYS                        ; If < $5C, not an amulet
    CP          WHT_AMULET_ITEM+1                   ; Compare to $60 (one past WHT AMULET)
    JP          NC,CHECK_KEYS                       ; If >= $60, not an amulet
    JP          PICK_UP_NON_TREASURE                ; Pick up amulet (for later use)

CHECK_KEYS:
    CP          RED_KEY_ITEM                        ; Compare to RED KEY (item code $58)
    JP          C,HANDLE_NON_TREASURES              ; If < $58, not a key
    CP          WHT_KEY_ITEM+1                      ; Compare to $5C (one past WHT KEY)
    JP          NC,HANDLE_NON_TREASURES             ; If >= $5C, not a key
    JP          PROCESS_KEY                         ; Item is in key range $58-$5B

HANDLE_NON_TREASURES:
    JP          C,PICK_UP_NON_TREASURE              ; If < $5C, handle as non-treasure item
    CP          RED_WARRIOR_POTION_ITEM             ; Compare to RED WARRIOR POTION (item code $64)
    JP          NC,PICK_UP_NON_TREASURE             ; If >= $64, handle as non-treasure item
    CALL        PICK_UP_S0_ITEM                     ; Remove item from map, increment D
    JP          INPUT_DEBOUNCE                      ; Jump to input debounce routine
PROCESS_MAP:
    PUSH        AF                                  ; Save A (map item code)
    LD          A,(GAME_BOOLEANS)                   ; Load game boolean flags
    SET         0x2,A                               ; Set bit 2 (map acquired flag)
    LD          (GAME_BOOLEANS),A                   ; Store updated boolean flags
    POP         AF                                  ; Restore A (map item code)
    CALL        PICK_UP_S0_ITEM                     ; Remove map from floor, level (0-3) in D
    LD          A,D                                 ; Get map level from D register
    LD          HL,MAP_INV_SLOT                     ; Get MAP_INV_SLOT address
    CP          (HL)                                ; Compare to current value
    JP          C,ITEM_NOT_WORTHY                   ; If less than current value, exit (technically <= due to 0-3 value range)
    INC         A                                   ; Convert to 1-4 range for USE_MAP checks
    LD          (HL),A                              ; Store map level (1=RED, 2=YEL, 3=MAG, 4=WHT)
    CALL        LEVEL_TO_COLRAM_FIX                 ; Convert level to color RAM value
    LD          (COLRAM_MAP_IDX),A                  ; Store color value for map display
    CALL        PLAY_POWER_UP_SOUND                 ; Play power up music
    JP          INPUT_DEBOUNCE                      ; Jump to input debounce routine

PROCESS_KEY:
    PUSH        AF                                  ; Save A (key item code)
    LD          A,(GAME_BOOLEANS)                   ; Load game boolean flags
    SET         0x3,A                               ; Set bit 3 (key acquired flag)
    LD          (GAME_BOOLEANS),A                   ; Store updated boolean flags
    POP         AF                                  ; Restore A (key item code)
    CALL        PICK_UP_S0_ITEM                     ; Remove key from floor, level (0-3) in D
    LD          A,D                                 ; Get key level from D register
    LD          HL,KEY_INV_SLOT                     ; Get KEY_INV_SLOT address
    CP          (HL)                                ; Compare to current value
    JP          C,ITEM_NOT_WORTHY                   ; If less than current value, exit (technically <= due to 0-3 value range)
    INC         A                                   ; Convert to 1-4 range for USE_KEY checks
    LD          (KEY_INV_SLOT),A                    ; Store key level (1=RED, 2=YEL, 3=MAG, 4=WHT)
    CALL        LEVEL_TO_COLRAM_FIX                 ; Convert level to color RAM value
    LD          (COLRAM_KEY_IDX),A                  ; Store color value for key display left
    LD          (COLRAM_KEY_IDX + 1),A              ; Store color value for key display right
    CALL        PLAY_POWER_UP_SOUND                 ; Play power up music
    JP          INPUT_DEBOUNCE                      ; Jump to input debounce routine

;==============================================================================
; PROCESS_RED_CHALICE - Make all doors visible for this level
;==============================================================================
PROCESS_RED_CHALICE:
    CALL        PICK_UP_S0_ITEM                     ; Remove red chalice from floor
    ; Clear all hidden door flags (bits 0 and 5) in 256-byte map space
    LD          HL,MAPSPACE_WALLS                   ; HL = Start of map space ($3800)
    LD          B,0                                 ; B = 0 (256 iteration counter in B)
REVEAL_DOORS_LOOP:
    LD          A,(HL)                              ; Load map byte
    LD          C,A                                 ; Preserve original map byte
    ; Upper nybble (N/S walls): only clear bit 5 when upper nybble != %0010
    LD          A,C                                 ; A = map byte
    AND         %11110000                           ; Isolate upper nybble
    CP          %00100000                           ; Upper nybble == %0010?
    JR          Z,SKIP_UPPER_CLEAR                  ; Yes, leave upper nybble as-is
    LD          A,C                                 ; Restore map byte
    AND         %11011111                           ; Clear bit 5 (upper nybble hidden door flag)
    LD          C,A                                 ; Save updated byte
SKIP_UPPER_CLEAR:
    ; Lower nybble (W/E walls): only clear bit 0 when lower nybble != %0001
    LD          A,C                                 ; A = map byte
    AND         %00001111                           ; Isolate lower nybble
    CP          %00000001                           ; Lower nybble == %0001?
    JR          Z,SKIP_LOWER_CLEAR                  ; Yes, leave lower nybble as-is
    LD          A,C                                 ; Restore map byte
    AND         %11111110                           ; Clear bit 0 (lower nybble hidden door flag)
    LD          C,A                                 ; Save updated byte
SKIP_LOWER_CLEAR:
    LD          A,C                                 ; A = final map byte
    LD          (HL),A                              ; Store modified byte
    INC         HL                                  ; Move to next byte
    DJNZ        REVEAL_DOORS_LOOP                   ; Decrement B and loop if not zero
    CALL        PLAY_POWER_UP_SOUND                 ; Play power up music
    CALL        WHITE_NOISE_BURST                   ; Play disappear sound
    CALL        WHITE_NOISE_BURST                   ; Play disappear sound
    JP          UPDATE_VIEWPORT                     ; Jump to input debounce routine

;==============================================================================
; PROCESS_YEL_CHALICE - Activate Teleport to Ladder option for this level
;==============================================================================
PROCESS_YEL_CHALICE:
    CALL        PICK_UP_S0_ITEM                     ; Remove yellow chalice from floor
    LD          A,(GAME_BOOLEANS)                   ; Load game boolean flags
    BIT         0x4,A                               ; Check bit 4 (teleport flag)
    JP          NZ,ITEM_NOT_WORTHY                  ; Exit if Teleport already enabled
    SET         0x4,A                               ; Otherwise set Teleport flag
    LD          (GAME_BOOLEANS),A                   ; Store updated boolean flags
    LD          A,COLOR(MAG,BLK)                    ; Color Ladder Teleport icon
    LD          (COLRAM_LADDER_IDX),A               ; Store color value for key display left
    CALL        PLAY_POWER_UP_SOUND                 ; Play power up music
    JP          INPUT_DEBOUNCE                      ; Jump to input debounce routine

;==============================================================================
; PROCESS_MAG_CHALICE - Remove all walls for this level
;==============================================================================
PROCESS_MAG_CHALICE:
    CALL        PICK_UP_S0_ITEM                     ; Remove magenta chalice from floor

WIPE_WALLS:
    LD          HL,MAPSPACE_WALLS                   ; Point to wall data area
    LD          BC,0x0                              ; Set BC to 0 (B=0, C=0)
    LD          A,0x0                               ; Load value 0
WIPE_WALLS_LOOP:
    LD          (HL),A                              ; Clear byte at HL
    INC         HL                                  ; Move to next byte
    DJNZ        WIPE_WALLS_LOOP                     ; Repeat B times (256 iterations)
    CALL        PLAY_POWER_UP_SOUND                 ; Play power up music
    CALL        WHITE_NOISE_BURST                   ; Play disappear sound
    CALL        WHITE_NOISE_BURST                   ; Play disappear sound
    CALL        WHITE_NOISE_BURST                   ; Play disappear sound
    JP          UPDATE_VIEWPORT                     ; Jump to Update viewport display

;==============================================================================
; PROCESS_WHT_CHALICE - Remove all monsters from this level
;==============================================================================
PROCESS_WHT_CHALICE:
    CALL        PICK_UP_S0_ITEM                     ; Remove white chalice from floor
REMOVE_ALL_MONSTERS:
    LD          HL, $3900                           ; Point to start of item/monster map
MONSTER_LOOP:
    INC         HL                                  ; Skip offset byte, point to item/monster
    LD          A, (HL)                             ; Load item/monster value
    CP          $FF                                 ; Check for end of list
    JR          Z, MONSTERS_DONE                     ; If end, we're done
    ; Check if this is a monster ($78-$8F range)
    CP          $78                                 ; Check if >= $78
    JR          C, NEXT_MONSTER                     ; If less, skip
    CP          $90                                 ; Check if >= $90
    JR          NC, NEXT_MONSTER                    ; If >= $90, skip (not a monster)
    ; It's a monster, replace with blank ($FE)
    LD          (HL), $FE                           ; Write $FE to replace monster
NEXT_MONSTER:
    INC         HL                                  ; Move to next pair's offset
    JR          MONSTER_LOOP  
MONSTERS_DONE:
    CALL        PLAY_POWER_UP_SOUND                 ; Play power up music
    CALL        WHITE_NOISE_BURST                   ; Play disappear sound
    CALL        WHITE_NOISE_BURST                   ; Play disappear sound
    CALL        WHITE_NOISE_BURST                   ; Play disappear sound
    CALL        WHITE_NOISE_BURST                   ; Play disappear sound
    JP          UPDATE_VIEWPORT                     ; Jump to Update viewport display

;==============================================================================
; PICK_UP_NON_TREASURE
;==============================================================================
; Handles picking up non-treasure items (weapons, armor, etc.) from floor
; position F0 (directly in front of player). Swaps the floor item with the
; current right-hand item, updating both character and color RAM graphics,
; and recalculates weapon stats if applicable.
;
; Registers:
; --- Start ---
;   HL = RIGHT_HAND_ITEM address for item swap
;   A  = Current right-hand item code
;   BC = S0 item pointer
; --- In Process ---
;   HL = Various CHRRAM/COLRAM pointer addresses
;   DE = Target addresses for graphics copying operations
;   BC = Source/destination for temporary buffer operations
;   A  = Item codes and color values during updates
;   C  = Color comparison and fill values for recoloring
; ---  End  ---
;   All registers modified by called functions
;   Graphics and item inventories updated
;
; Memory Modified: RIGHT_HAND_ITEM, ITEM_S0, CHRRAM_*, COLRAM_*, ITEM_MOVE_CHR_BUFFER
; Calls: SWAP_BYTES_AT_HL_BC, UPDATE_MELEE_OBJECTS, COPY_GFX_SCRN_2_SCRN, COPY_GFX_FROM_BUFFER, RECOLOR_ITEM, NEW_RIGHT_HAND_ITEM
;==============================================================================
PICK_UP_NON_TREASURE:
    LD          HL,RIGHT_HAND_ITEM                  ; Point to current right-hand item
    LD          A,(HL)
    LD          (ITEM_S0),A
    CALL        SWAP_BYTES_AT_HL_BC                 ; Swap RIGHT_HAND_ITEM with floor item (BC=floor item ptr)

    PUSH        HL
    PUSH        AF
    PUSH        BC

    LD          HL,CHRRAM_S0_ITEM_IDX               ; Point to S0 item character graphics in CHRRAM
    LD          A,$20                               ; A = $20 (SPACE character)
    CALL        WIPE_ITEM_4X4                       ; Clear S0 character graphics with space (4x4 area)
    LD          HL,COLRAM_S0_ITEM_IDX               ; Point to S0 item color attributes in COLRAM
    LD          A,COLOR(BLK,DKGRY)                  ; A = BLK on DKGRY (floor color scheme)
    CALL        WIPE_ITEM_4X4                       ; Clear S0 color graphics with floor colors (4x4 area)

    LD          HL,CHRRAM_RIGHT_HAND_VP_IDX         ; Point to S0 item character graphics in CHRRAM
    LD          A,$20                               ; A = $20 (SPACE character)
    CALL        WIPE_ITEM_4X4                       ; Clear S0 character graphics with space (4x4 area)
    LD          HL,COLRAM_RIGHT_HAND_VP_IDX         ; Point to S0 item color attributes in COLRAM
    LD          A,COLOR(BLK,BLK)                    ; A = BLK on DKGRY (floor color scheme)
    CALL        WIPE_ITEM_4X4                       ; Clear S0 color graphics with floor colors (4x4 area)

    POP         BC
    POP         AF
    POP         HL

    CALL        CHK_ITEM_S0                         ; Check S0 item

    CALL        CHK_ITEM_RH                         ; Check RH item

    CALL        NEW_RIGHT_HAND_ITEM                 ; Recalculate weapon stats for new right-hand item
    JP          INPUT_DEBOUNCE                      ; Wait for input debounce then return to main loop

;==============================================================================
; RECOLOR_ITEM
;==============================================================================
; Recolors a 4x4 character cell area in COLRAM with selective color replacement.
; Searches for cells matching a specific color pattern and either replaces
; with a new color or applies conditional recoloring based on comparison values.
;
; Algorithm:
; 1. Process 4 rows of 4 characters each (16 cells total)
; 2. For each cell, mask with DKGRY on BLK to check existing color
; 3. If cell matches E register, apply conditional recoloring from C register
; 4. Otherwise, apply base recoloring from D register
; 5. Skip 36 cells between rows to advance to next row (40-4=36)
;
; Registers:
; --- Start ---
;   HL = Starting COLRAM address for 4x4 area
;   D  = Target BG color: 
;       $0 in upper nybble, BG in lower nybble
;   E  = Comparison FG color: 
;       FG in upper nybble, $0 in lower nybble 
;   C  = Target BG color for FG colors that match E: 
;       $0 in upper nybble, BG in lower nybble
;   A  = 4 (outer loop counter for rows)
; --- In Process ---
;   AF'= Preserved row counter during inner loops
;   B  = 4 (inner loop counter for columns per row)
;   A  = Cell color values, masked values, final color results
; ---  End  ---
;   HL = Advanced past 4x4 area (varies with memory layout)
;   A  = Last processed color value
;   B  = 0 (exhausted from inner loop)
;   AF'= Exhausted outer loop counter
;
; Memory Modified: 16 COLRAM cells in 4x4 area starting at HL
; Calls: None (leaf function)
;==============================================================================
RECOLOR_ITEM:
    LD          A,0x4                               ; A = 4 rows to process
RECOLOR_OUTER_LOOP:
    EX          AF,AF'                              ; Preserve row counter in alternate register
    LD          B,0x4                               ; B = 4 cells per row
CHECK_FG_COLOR:
    LD          A,(HL)                              ; Load current cell color from COLRAM
    AND         $f0                                 ; Mask to retain FG color
    CP          E                                   ; Compare with FG color in E
    JP          Z,CHANGE_FG_COLOR                   ; If FG colors match, jump to conditional recolor
    OR          D                                   ; No match: apply base recolor (OR with D)
STORE_COLORS_LOOP:
    LD          (HL),A                              ; Store updated color back to COLRAM
    INC         HL                                  ; Advance to next character cell
    DJNZ        CHECK_FG_COLOR                      ; Decrement B, loop for 4 columns
    PUSH        DE                                  ; Preserve DE registers
    LD          DE,$24                              ; DE = 36 (skip to next row: 40 - 4)
    ADD         HL,DE                               ; Advance HL to start of next row
    POP         DE                                  ; Restore DE registers
    EX          AF,AF'                              ; Restore row counter from alternate register
    DEC         A                                   ; Decrement row counter
    JP          NZ,RECOLOR_OUTER_LOOP               ; If more rows, continue outer loop
    RET                                             ; Return when all 4 rows processed
CHANGE_FG_COLOR:
    LD          A,(HL)                              ; Reload current cell color
    AND         $0f                                 ; Mask to retain BG color
    OR          C                                   ; Apply conditional color from C register
    JP          STORE_COLORS_LOOP                   ; Jump back to store result and continue
    
;==============================================================================
; WAIT_A_TICK
;==============================================================================
; Brief pause function that creates a short delay by calling the SLEEP routine
; with a predetermined cycle count. Used for timing control and input debouncing
; throughout the game to prevent rapid-fire inputs and provide smooth pacing.
;
; Registers:
; --- Start ---
;   BC = Will be loaded with cycle count
; --- End ---
;   BC = $8600 (cycle count value)
;   Other registers preserved by SLEEP function
;
; Memory Modified: None (SLEEP may modify internal timing variables)
; Calls: SLEEP
;==============================================================================
WAIT_A_TICK:
    LD          BC,$8600                            ; Load BC with 134 sleep cycles (0x86 = 134)
    JP          SLEEP                               ; Jump to sleep routine: void SLEEP(short cycleCount)

;==============================================================================
; PICK_UP_S0_ITEM
;==============================================================================
; Removes an item from floor position S0 (directly in front of player) and
; extracts the item's level information through bit manipulation. Clears the
; floor graphics with empty space character and default floor colors, then
; performs bit rotation operations to decode the item level from the item code.
;
; Item Level Extraction Algorithm:
; 1. Rotate item code right twice to isolate level bits
; 2. Use carry flag to build level value in D register
; 3. Final level = (item_code >> 2) & 0x03 (bits 2-3 become bits 0-1)
;
; Registers:
; --- Start ---
;   A  = Item code with level encoded in bits 2-3
;   AF'= Available for temporary storage during UPDATE_S0_ITEM calls
;   BC = Pointer to floor item storage location
;   D  = Will receive level information through bit manipulation
;   HL = Will point to CHRRAM and COLRAM addresses for graphics updates
; --- In Process ---
;   A  = $FE (empty item marker), $20 (space char), color values, item code
;   AF'= Item code preservation during graphics clearing operations
;   HL = CHRRAM_S0_ITEM_IDX, then COLRAM_S0_ITEM_IDX for graphics clearing
;   D  = Progressive level value built through bit rotations
; ---  End  ---
;   A  = Final rotated item code value
;   AF'= Restored item code (for level extraction)
;   D  = Item level (0-3) extracted from original bits 2-3
;   HL = Points to COLRAM_S0_ITEM_IDX area after clearing
;   BC = Unchanged (still points to floor item storage)
;   Floor graphics cleared to empty space with floor colors
;
; Memory Modified: Floor item storage (BC), CHRRAM_S0_ITEM_IDX area, COLRAM_S0_ITEM_IDX area
; Calls: UPDATE_S0_ITEM (twice - for character and color clearing)
;==============================================================================
PICK_UP_S0_ITEM:
    AND         A                                   ; Clear carry flag and test A for zero
    EX          AF,AF'                              ; Save item code in alternate AF register
    LD          A,$fe                               ; A = $FE (empty item marker)
    LD          (BC),A                              ; Clear floor item storage (mark as empty)
    LD          HL,CHRRAM_S0_ITEM_IDX               ; Point to S0 item character graphics in CHRRAM
    LD          A,$20                               ; A = $20 (SPACE character)
    CALL        WIPE_ITEM_4X4                       ; Clear S0 character graphics with space (4x4 area)
    LD          HL,COLRAM_S0_ITEM_IDX               ; Point to S0 item color attributes in COLRAM
    LD          A,COLOR(BLK,DKGRY)                  ; A = BLK on DKGRY (floor color scheme)
    CALL        WIPE_ITEM_4X4                       ; Clear S0 color graphics with floor colors (4x4 area)
    EX          AF,AF'                              ; Restore original item code to A register
    RRA                                             ; Rotate A right: bit 0 → carry, bits 7-1 → bits 6-0
    RR          D                                   ; Rotate D right: carry → bit 7, bits 7-1 → bits 6-0
    RRA                                             ; Rotate A right again: bit 0 → carry, bits 6-0 → bits 5-0
    RL          D                                   ; Rotate D left: carry → bit 0, bit 7 → carry
    RL          D                                   ; Rotate D left again: carry → bit 0, bit 7 → carry
                                                    ; Net effect: D = (original_item_code >> 2) & 0x03
                                                    ; D now contains item level (0-3) from bits 2-3
    RET                                             ; Return with level in D, floor cleared

;==============================================================================
; ITEM_ATTR_LOOKUP  
;==============================================================================
; Item attribute lookup. Implements a small switch by decrementing A through
; successive cases and loading BC accordingly. Used to derive fixed attribute
; pairs or pointer constants for subsequent item logic.
;
; Inputs:
;   A  = Item/level index (0..3; 4+ → default)
;
; Outputs:
;   BC = Selected attribute/pointer ($0501, $0804, ROM_CONST_19, ROM_CONST_FF; else $0000)
;   F  = Flags reflect last comparison/JP NZ tests
;
; Registers:
; --- Start ---
;   A  = Index to test
; --- In Process ---
;   A  = Decremented and compared; BC loaded per matched case
; ---  End  ---
;   A  = Final decremented value
;   BC = Result value for the matched case or default
;   F  = Condition codes per last compare/branch
;
; Memory Modified: None
; Calls: None
;==============================================================================
ITEM_ATTR_LOOKUP:
    DEC         A                                   ; Decrement A and test for specific values
    JP          NZ,ITEM_ATTR_0                      ; If A≠0, try next case
    LD          BC,$501                             ; Case A=0: Load PHYS=5, SPRT=1 attributes
    RET                                             ; Return with attribute values
ITEM_ATTR_0:
    DEC         A                                   ; Decrement A again (now A-1 → A-2)
    JP          NZ,ITEM_ATTR_1                      ; If A≠0, try next case  
    LD          BC,$804                             ; Case A=1: Load attributes $08,$04
    RET                                             ; Return with attribute values
ITEM_ATTR_1:
    DEC         A                                   ; Decrement A again (now A-2 → A-3)
    JP          NZ,ITEM_ATTR_2_PTR                  ; If A≠0, try next case
    LD          BC,ROM_CONST_19                     ; Case A=2: Load ROM constant address ($1208=$19)
    RET                                             ; Return with address
ITEM_ATTR_2_PTR:
    DEC         A                                   ; Decrement A again (now A-3 → A-4)
    JP          NZ,ITEM_ATTR_DEFAULT_ZERO           ; If A≠0, use default case
    LD          BC,ROM_CONST_FF                     ; Case A=3: Load ROM constant address ($2613=$FF)
    RET                                             ; Return with address
ITEM_ATTR_DEFAULT_ZERO:
    LD          BC,0x0                              ; Default case A=4+: Load null values
    RET                                             ; Return with zero values

;==============================================================================
; VALIDATE_RH_ITEM_PRESENT  
;==============================================================================
; Right-hand item validation and memory update function. Checks if the right
; hand contains an item ($FE = empty), and either aborts the calling operation
; if empty, or updates a memory buffer with item information if an item is
; present. This function is typically called as part of item manipulation
; operations to ensure valid item state.
;
; Key Operations:
; - Validates right-hand item exists (not $FE empty marker)
; - If empty: Pops return address and jumps to NO_ACTION_TAKEN
; - If item present: Updates memory buffer pointed to by BC with item data
; - Uses H register value as part of item data written to buffer
;
; Registers:
; --- Start ---
;   A  = Will be loaded with RIGHT_HAND_ITEM value
;   BC = Pointer to memory buffer for data storage  
;   H  = Item data value to store
; --- In Process ---
;   A  = RIGHT_HAND_ITEM value, then $FF, then H value, then $FE
;   BC = Memory buffer pointer, decremented and incremented for access
; ---  End  ---
;   A  = $FE (if normal return) or undefined (if NO_ACTION_TAKEN)
;   BC = Advanced pointer in memory buffer
;   Stack = May be modified (POP HL) if item validation fails
;
; Memory Modified: 3 consecutive locations starting at BC pointer
; Calls: NO_ACTION_TAKEN (conditional jump, not return)
;==============================================================================
VALIDATE_RH_ITEM_PRESENT:
    LD          A,(RIGHT_HAND_ITEM)                 ; Load current right-hand item
    CP          $fe                                 ; Compare with $FE (empty item marker)
    JP          NZ,UPDATE_RH_ITEM_BUFFER            ; If item present, jump to memory update
    POP         HL                                  ; Discard return address from stack
    JP          NO_ACTION_TAKEN                     ; Jump to no-action handler (abort operation)
; --- Memory update section (item present in right hand) ---
UPDATE_RH_ITEM_BUFFER:
    LD          A,$ff                               ; Load $FF marker value
    LD          (BC),A                              ; Store $FF at BC memory location
    DEC         C                                   ; Move to previous memory location (BC-1)
    DEC         C                                   ; Move to previous memory location (BC-2)
    LD          A,H                                 ; Load H register value (item data)
    LD          (BC),A                              ; Store item data at BC-2 location
    INC         C                                   ; Move forward to BC-1 location
    LD          A,$fe                               ; Load $FE marker value
    LD          (BC),A                              ; Store $FE at BC-1 location
    RET                                             ; Return to caller

;==============================================================================
; DO_ROTATE_PACK - Rotate inventory pack items forward one slot
;==============================================================================
; Rotates all six inventory pack slots forward by one position. Slot 1 wraps
; around to slot 6, creating a circular rotation. Uses both memory swaps and
; screen graphics copies to update both data and display.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   HL = Inventory slot pointers
;   BC = Destination pointers for swaps
;   DE = Graphics source/destination pointers
;   E  = Loop counter for slots 3-6
; ---  End  ---
;   Returns via WAIT_A_TICK to WAIT_FOR_INPUT
;
; Memory Modified: INV_ITEM_SLOT_1..6, ITEM_MOVE_COL_BUFFER, screen graphics
; Calls: SWAP_BYTES_AT_HL_BC, COPY_GFX_SCRN_2_SCRN, COPY_GFX_FROM_BUFFER, WAIT_A_TICK
;==============================================================================
DO_ROTATE_PACK:
    LD          HL,INV_ITEM_SLOT_1                  ; Point to inventory slot 1
    LD          BC,PL_BG_COLRAM_BUFFER              ; Point to temporary buffer
    XOR         A                                   ; Clear A (A = 0)
    LD          (BC),A                              ; Store 0 to temporary buffer
    CALL        SWAP_BYTES_AT_HL_BC                 ; Swap slot 1 with buffer (save slot 1)
    INC         HL                                  ; Point to inventory slot 2
    LD          BC,INV_ITEM_SLOT_1                  ; Point to inventory slot 1
    CALL        SWAP_BYTES_AT_HL_BC                 ; Swap slot 2 with slot 1
    LD          E,0x4                               ; Set counter to 4 (slots 3-6)
ROTATE_PACK_SWAP_LOOP:
    INC         HL                                  ; Point to next inventory slot
    INC         BC                                  ; Point to previous slot
    CALL        SWAP_BYTES_AT_HL_BC                 ; Swap current with previous
    DEC         E                                   ; Decrement counter
    JP          NZ,ROTATE_PACK_SWAP_LOOP            ; Loop until all 4 swaps done
    LD          HL,PL_BG_COLRAM_BUFFER              ; Point to temporary buffer (saved slot 1)
    INC         BC                                  ; Point to inventory slot 6
    CALL        SWAP_BYTES_AT_HL_BC                 ; Swap buffer (old slot 1) to slot 6
    LD          HL,CHRRAM_INV_1_IDX                 ; Point to inv slot 1 graphics
    LD          DE,PL_BG_CHRRAM_BUFFER              ; Point to temporary buffer
    CALL        COPY_GFX_2_BUFFER                   ; Copy slot 1 graphics to buffer
    LD          HL,CHRRAM_INV_2_IDX                 ; Point to inv slot 2 graphics
    LD          DE,CHRRAM_INV_1_IDX                 ; Point to inv slot 1 graphics
    CALL        COPY_GFX_SCRN_2_SCRN                ; Copy slot 2 graphics to slot 1
    LD          HL,CHRRAM_INV_3_IDX                 ; Point to inv slot 3 graphics
    LD          DE,CHRRAM_INV_2_IDX                 ; Point to inv slot 2 graphics
    CALL        COPY_GFX_SCRN_2_SCRN                ; Copy slot 3 graphics to slot 2
    LD          HL,CHHRAM_INV_4_IDX                 ; Point to inv slot 4 graphics
    LD          DE,CHRRAM_INV_3_IDX                 ; Point to inv slot 3 graphics
    CALL        COPY_GFX_SCRN_2_SCRN                ; Copy slot 4 graphics to slot 3
    LD          HL,CHRRAM_INV_5_IDX                 ; Point to inv slot 5 graphics
    LD          DE,CHHRAM_INV_4_IDX                 ; Point to inv slot 4 graphics
    CALL        COPY_GFX_SCRN_2_SCRN                ; Copy slot 5 graphics to slot 4
    LD          HL,CHRRAM_INV_6_IDX                 ; Point to inv slot 6 graphics
    LD          DE,CHRRAM_INV_5_IDX                 ; Point to inv slot 5 graphics
    CALL        COPY_GFX_SCRN_2_SCRN                ; Copy slot 6 graphics to slot 5
    LD          HL,WAIT_FOR_INPUT                   ; Stash WAIT_FOR_INPUT as a later return value
    PUSH        HL
    LD          HL,PL_BG_CHRRAM_BUFFER              ; Point to buffer (saved slot 1 graphics)
    LD          DE,CHRRAM_INV_6_IDX                 ; Point to inv slot 6 graphics
    CALL        COPY_GFX_FROM_BUFFER                ; Copy buffer to slot 6 (complete rotation)
    JP          WAIT_A_TICK                         ; Jump to delay routine (will RET to WAIT_FOR_INPUT)

;==============================================================================
; SWAP_BYTES_AT_HL_BC - Swap byte values between two memory locations
;==============================================================================
; Swaps the byte value at (HL) with the byte value at (BC). Uses D register
; as temporary storage. This is a utility routine called during inventory
; rotation operations.
;
; Registers:
; --- Start ---
;   BC = Second location pointer
;   HL = First location pointer
; --- In Process ---
;   A  = Value from (BC), then value from D
;   D  = Temporary storage for value from (HL)
; ---  End  ---
;   A  = Original value from (HL)
;   D  = Original value from (HL)
;   BC = Unchanged (still points to second location)
;   HL = Unchanged (still points to first location)
;
; Memory Modified: (HL) and (BC) - values swapped
; Calls: None
;==============================================================================
SWAP_BYTES_AT_HL_BC:
    LD          D,(HL)                              ; Load value from (HL) into D
    LD          A,(BC)                              ; Load value from (BC) into A
    LD          (HL),A                              ; Store A to (HL)
    LD          A,D                                 ; Load saved (HL) value from D
    LD          (BC),A                              ; Store to (BC)
    RET                                             ; Return (values swapped)

;==============================================================================
; DO_SWAP_PACK - Swap inventory slot 1 with right-hand item
;==============================================================================
; Swaps the item in inventory slot 1 with the current right-hand item. Updates
; both the item codes in memory and the graphics on screen. Recalculates weapon
; stats if the new right-hand item is a weapon.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   HL = Memory and graphics pointers
;   BC = Memory pointer for swap
;   DE = Graphics destination pointers
; ---  End  ---
;   Returns via WAIT_A_TICK to WAIT_FOR_INPUT
;
; Memory Modified: INV_ITEM_SLOT_1, RIGHT_HAND_ITEM, ITEM_MOVE_CHR_BUFFER, screen graphics
; Calls: SWAP_BYTES_AT_HL_BC, COPY_GFX_2_BUFFER, COPY_GFX_SCRN_2_SCRN, COPY_GFX_FROM_BUFFER, NEW_RIGHT_HAND_ITEM, WAIT_A_TICK
;==============================================================================
DO_SWAP_PACK:
    LD          HL,INV_ITEM_SLOT_1                  ; Point to inventory slot 1
    LD          BC,RIGHT_HAND_ITEM                  ; Point to right-hand item slot
    CALL        SWAP_BYTES_AT_HL_BC                 ; Swap inv slot 1 with right-hand item
    ; LD          HL,CHRRAM_RIGHT_HD_GFX_IDX          ; Point to right-hand graphics
    LD          HL,CHRRAM_RIGHT_HAND_VP_IDX          ; Point to right-hand graphics
    LD          DE,PL_BG_CHRRAM_BUFFER              ; Point to temporary buffer
    CALL        COPY_GFX_2_BUFFER                   ; Copy right-hand graphics to buffer
    LD          HL,CHRRAM_INV_1_IDX                 ; Point to inv slot 1 graphics
    ; LD          DE,CHRRAM_RIGHT_HD_GFX_IDX          ; Point to right-hand graphics
    LD          DE,CHRRAM_RIGHT_HAND_VP_IDX         ; Point to right-hand graphics
    CALL        COPY_GFX_SCRN_2_SCRN                ; Copy inv slot 1 graphics to right-hand
    LD          HL,WAIT_FOR_INPUT                   ; Stash WAIT_FOR_INPUT as a later return value
    PUSH        HL                                  ; Push return address to stack
    LD          HL,PL_BG_CHRRAM_BUFFER              ; Point to buffer (saved right-hand graphics)
    LD          DE,CHRRAM_INV_1_IDX                 ; Point to inv slot 1 graphics
    CALL        COPY_GFX_FROM_BUFFER                ; Copy buffer to inv slot 1 (complete swap)
    CALL        NEW_RIGHT_HAND_ITEM                 ; Update weapon stats for new right-hand item
    JP          WAIT_A_TICK                         ; Jump to delay routine (will RET to WAIT_FOR_INPUT)

;==============================================================================
; UPDATE_VIEWPORT - Redraw viewport and UI after position/state change
;==============================================================================
;   - Calls REDRAW_START to refresh non-viewport UI elements
;   - Calls REDRAW_VIEWPORT to render 3D maze view
;   - Falls through to INPUT_DEBOUNCE for input delay
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   Modified by REDRAW_START and REDRAW_VIEWPORT
; ---  End  ---
;   Viewport and UI fully updated
;   Falls through to INPUT_DEBOUNCE
;
UPDATE_VIEWPORT:
    CALL        REDRAW_START                        ; Refresh non-viewport UI (stats, compass, etc.)
    CALL        REDRAW_VIEWPORT                     ; Render 3D maze view

;==============================================================================
; INPUT_DEBOUNCE - Brief delay before accepting next input
;==============================================================================
;   - Provides input debounce delay via WAIT_A_TICK
;   - Falls through to WAIT_FOR_INPUT main loop
; Registers:
; --- Start ---
;   None
; ---  End  ---
;   Falls through to WAIT_FOR_INPUT
;
INPUT_DEBOUNCE:
    CALL        WAIT_A_TICK                         ; Brief delay for input debounce

;==============================================================================
; WAIT_FOR_INPUT - Main input loop with timer, animation, and screensaver
;==============================================================================
;   - Updates timers (MASTER_TICK_TIMER, INACTIVITY_TIMER) each iteration
;   - Handles blink/animation states for items and combat
;   - Triggers screensaver after inactivity timeout
;   - Checks for keyboard/handcontroller input
;   - Branches to animation routines or continues loop
; Registers:
; --- Start ---
;   None (entry to main loop)
; --- In Process ---
;   A  = Timer values, comparisons, input reads
;   BC = Sleep parameters, port addressing
;   DE = COLRAM addressing for screensaver
;   HL = Timer addresses, COLRAM pointers
;   H  = Screensaver outer loop counter
;   L  = Screensaver inner loop counter
; ---  End  ---
;   Loops indefinitely until input or animation trigger
;
WAIT_FOR_INPUT:
    CALL        TIMER_UPDATE                        ; Increment MASTER_TICK_TIMER, update game timers
    CALL        BLINK_ROUTINE                       ; Handle item/animation blink state
    JP          NC,TIMER_UPDATED_CHECK_INPUT        ; If no blink update needed, check input
    LD          HL,INACTIVITY_TIMER                 ; HL = inactivity timer address
    INC         (HL)                                ; Increment inactivity counter
    LD          A,(HL)                              ; A = current inactivity count
    CP          $15                                 ; Compare with screensaver threshold (21)
    JP          C,TIMER_UPDATED_CHECK_INPUT         ; If below threshold, skip screensaver
    XOR         A                                   ; A = 0 (reset counter)
    LD          (HL),A                              ; Reset inactivity timer

;==============================================================================
; SCREEN_SAVER_FULL_SCREEN - Animated color-cycling screensaver
;==============================================================================
;   - Rotates all COLRAM color bytes to create cycling effect
;   - Runs in loop until keyboard/handcontroller input detected
;   - Restores original colors before returning to INPUT_DEBOUNCE
; Registers:
; --- Start ---
;   HL = Outer/inner loop counters ($0800 initial)
; --- In Process ---
;   A  = Color byte values, port reads, comparisons
;   BC = SLEEP parameter, port addressing ($FF, $F7/$F6)
;   DE = COLRAM pointer ($3400-$37FF)
;   H  = Outer loop counter (8 rotations per check)
;   L  = Inner loop counter (controls check frequency)
; ---  End  ---
;   Colors restored, returns to INPUT_DEBOUNCE
;
SCREEN_SAVER_FULL_SCREEN:
    LD          HL,$800                             ; H=8 rotations, L=0 (loop counter init)
SCREEN_SAVER_REDRAW_LOOP:
    LD          DE,COLRAM                           ; DE = start of color RAM
RECALC_SCREEN_SAVER_COLORS:
    LD          A,(DE)                              ; Load current color byte
    RRCA										    ; Rotate right (shift color bits)
    LD          (DE),A                              ; Store rotated color
    INC         DE                                  ; Advance to next color cell
    LD          A,$38                               ; A = $38 (COLRAM end page + 1)
    CP          D                                   ; Check if past end of COLRAM
    JP          NZ,RECALC_SCREEN_SAVER_COLORS       ; Continue rotating all colors
    DEC         H                                   ; Decrement rotation pass counter
    JP          NZ,CHECK_INPUT_DURING_SCREEN_SAVER  ; If more passes remain, check input
    LD          H,0x8                               ; Reset rotation counter to 8
CHECK_INPUT_DURING_SCREEN_SAVER:
    DEC         L                                   ; Decrement check frequency counter
    JP          Z,SCREEN_SAVER_REDRAW_LOOP          ; If zero, restart rotation cycle
    LD          BC,$140                             ; BC = sleep duration parameter
    CALL        SLEEP                               ; Delay between animation frames
    LD          BC,$ff                              ; BC = keyboard port
    IN          A,(C)                               ; Read keyboard row
    INC         A                                   ; Test for $FF (no key pressed)
    JP          NZ,EXIT_SCREENSAVER                 ; If key pressed, exit screensaver
    LD          C,PSG_REGS                          ; C = PSG_REGS
    LD          A,0xf                               ; A = port enable mask
    OUT         (C),A                               ; Enable handcontroller port
    DEC         C                                   ; C = PSG_DATA
    IN          A,(C)                               ; Read handcontroller state
    INC         A                                   ; Test for $FF (no input)
    JP          NZ,EXIT_SCREENSAVER                 ; If input detected, exit screensaver
    INC         C                                   ; C = PSG_REGS
    LD          A,0xe                               ; A = disable mask
    OUT         (C),A                               ; Disable handcontroller port
    DEC         C                                   ; C = PSG_DATA
    IN          A,(C)                               ; Read again
    INC         A                                   ; Test for input
    JP          Z,CHECK_INPUT_DURING_SCREEN_SAVER   ; If no input, continue screensaver

EXIT_SCREENSAVER:
    LD          DE,COLRAM                           ; DE = start of COLRAM (restore colors)
RESTORE_COLOR_BYTE:
    LD          B,H                                 ; B = rotation counter (reverse rotations)
    LD          A,(DE)                              ; Load rotated color byte
REVERSE_ROTATE_LOOP:
    RRCA										    ; Rotate right to undo screensaver rotation
    DJNZ        REVERSE_ROTATE_LOOP                 ; Repeat H times to restore original
    LD          (DE),A                              ; Store restored color
    INC         DE                                  ; Advance to next color cell
    LD          A,$38                               ; A = COLRAM end check
    CP          D                                   ; Past end of COLRAM?
    JP          NZ,RESTORE_COLOR_BYTE               ; Continue restoring all colors
    JP          INPUT_DEBOUNCE                      ; Return to input loop
    
;==============================================================================
; TIMER_UPDATED_CHECK_INPUT - Timer-driven item/combat animation + AI checks
;==============================================================================
;   - Routes control to item animation or melee/monster animation based on
;     timer snapshots and state bytes (SCREENSAVER_STATE/KEYBOARD_SCAN_FLAG)
;   - Updates screensaver timer and may trigger simple AI when idle
;   - Falls back to WAIT_FOR_INPUT when no animation tick is due
; Registers:
; --- Start ---
;   None (uses memory-mapped flags and timers)
; --- In Process ---
;   A  = State/flag bytes, comparisons, randomness
;   B  = Loop/selector for direction cases (4 -> back/left/right/forward)
;   HL = Points to MASTER_TICK_TIMER or item lists (ITEM_S1/ITEM_SR1)
; ---  End  ---
;   Jumps to WAIT_FOR_INPUT or into AI branch (RANDOM_ACTION_HANDLER)
;
TIMER_UPDATED_CHECK_INPUT:
    LD          A,(PLAYER_MELEE_STATE)              ; Load player melee state
    CP          $32                                 ; Is state equal to $32? (branch set)
    JP          Z,IDLE_SCREENSAVER_CHK              ; Yes → handle screensaver/idle branch
    LD          A,(MONSTER_MELEE_STATE)             ; Load MONSTER_MELEE_STATE
    CP          $31                                 ; Player not pressing Key 1 (attacking)
    JP          NZ,MONSTER_PLAYER_ANIM_TICK         ; If not $31 → check monster/melee tick

PLAYER_ANIM_TICK:
    LD          HL,MASTER_TICK_TIMER                ; HL points to master tick counter
    LD          A,(PLAYER_TIMER_COMPARE)            ; A = last processed player anim tick
    CP          (HL)                                ; Has MASTER_TICK_TIMER advanced since last player tick?
    JP          NZ,WAIT_FOR_INPUT                   ; No → nothing to animate this frame
    CALL        COPY_PL_BUFF_TO_SCRN                ; Restore background under plater weapon sprite
    CALL        PLAYER_ANIM_ADVANCE                 ; Advance player weapon animation frame
    JP          WAIT_FOR_INPUT                      ; Return to main input loop

MONSTER_PLAYER_ANIM_TICK:
    LD          HL,MASTER_TICK_TIMER                ; HL points to master tick counter
    LD          A,(MONSTER_TIMER_COMPARE)           ; A = last processed monster anim tick
    CP          (HL)                                ; Has MASTER_TICK_TIMER advanced for monster anim?
    JP          NZ,WAIT_FOR_INPUT                   ; No → skip animation this frame
    CALL        COPY_MN_BUFF_TO_SCRN                ; Restore background under monster weapon sprite
    CALL        COPY_PL_BUFF_TO_SCRN                ; Restore background under plater weapon sprite
    CALL        PLAYER_ANIM_ADVANCE                 ; Redraw any UI impacted by anim state
    CALL        FIX_MELEE_GLITCH_BEGIN              ; Back up the pack area chars and cols
    CALL        MONSTER_ANIM_ADVANCE                ; Advance monster weapon animation frame
    CALL        FIX_MELEE_GLITCH_END                ; Restore the pack area chars and cols
    JP          WAIT_FOR_INPUT                      ; Back to main loop

MONSTER_ANIM_TICK:
    LD          HL,MASTER_TICK_TIMER                ; HL points to master tick counter
    LD          A,(MONSTER_TIMER_COMPARE)           ; A = last processed monster-anim tick
    CP          (HL)                                ; Has MASTER_TICK_TIMER advanced for monster anim?
    JP          NZ,WAIT_FOR_INPUT                   ; No → skip animation this frame
    CALL        COPY_MN_BUFF_TO_SCRN                ; Restore background under melee sprites
    CALL        FIX_MELEE_GLITCH_BEGIN              ; Back up the pack area chars and cols
    CALL        MONSTER_ANIM_ADVANCE                ; Advance monster weapon animation frame
    CALL        FIX_MELEE_GLITCH_END                ; Restore the pack area chars and cols
    JP          WAIT_FOR_INPUT                      ; Back to main loop

;-------------------------------------------------------------------------------
; Idle branch when SCREENSAVER_STATE == $32 (screensaver timer + conditional AI)
;-------------------------------------------------------------------------------
IDLE_SCREENSAVER_CHK:
    LD          A,(MONSTER_MELEE_STATE)             ; Load MONSTER_MELEE_STATE
    CP          $31                                 ; If player hasn't pressed Key 1 (attack), monster only
    JP          NZ,MONSTER_ANIM_TICK                ; Only Monster is attacking
    CALL        UPDATE_SCR_SAVER_TIMER              ; Bump inactivity/screensaver counters
    LD          A,(COMBAT_BUSY_FLAG)                ; Is combat currently running?
    AND         A                                   ; Set flags from A
    JP          NZ,POLL_INPUT                       ; If busy, bypass AI/random actions
    LD          B,0x4                               ; B = direction selector (4 probes)
    LD          HL,ITEM_S1                          ; HL = pointer to S1 cell (sprite row 1)
    LD          A,(HL)                              ; A = item/monster id at S1
    INC         A                                   ; Normalize/flag for threshold compare
    INC         A                                   ; (two INCs used consistently in this code)
    LD          HL,ITEM_SR1                         ; HL = pointer to SR1 (probing sequence)
PROBE_MONSTER_LOOP:
    CP          $7a                                 ; >= $7A ⇒ monster/eligible target present
    JP          NC,RANDOM_ACTION_HANDLER            ; If present, run AI/random action
    INC         HL                                  ; Else move to next probe cell
    LD          A,(HL)                              ; A = next item/monster id
    INC         A                                   ; Normalize/flag as above
    INC         A
    DJNZ        PROBE_MONSTER_LOOP                  ; Probe up to 4 positions
    JP          POLL_INPUT                          ; Nothing eligible → continue main loop

;==============================================================================
; RANDOM_ACTION_HANDLER
;==============================================================================
; Random AI nudge: occasional turn/advance + redraw/engage
;   - Low-probability trigger based on RANDOM_OUTPUT_BYTE and a random carry test
;   - Chooses an action based on B (probe index):
;       B==1 → consider back cell; turn 180° if passable
;       B==2 → consider left cell; turn left if passable
;       B==3 → consider right cell; turn right if passable
;       B==4 → consider forward cell; if blocked, try engage
;   - On successful facing change, redraw viewport and possibly enter combat
;
; Registers:
; --- Start ---
;   B = Probe index (1-4)
; --- In Process ---
;   A  = RANDOM_OUTPUT_BYTE value, random bytes, wall data
;   BC = Action parameters
;   HL = Wall data pointers
; ---  End  ---
;   Control may transfer to UPDATE_VIEWPORT or ENGAGE_FROM_FORWARD
;
; Memory Modified: PLAYER_FACING, viewport graphics if action taken
; Calls: MAKE_RANDOM_BYTE, DO_TURN_AROUND, DO_TURN_LEFT, DO_TURN_RIGHT, UPDATE_VIEWPORT, ENGAGE_FROM_FORWARD
;==============================================================================
RANDOM_ACTION_HANDLER:
    LD          A,(PLAYER_MELEE_RANDOMIZER)              ; Load random output byte
    CP          0x5                                 ; Compare to threshold (5)
    JP          NC,POLL_INPUT                       ; If >= 5, too soon - skip monster action
    CALL        MAKE_RANDOM_BYTE                    ; Generate random byte (0-255)
    ADD         A,0x8                               ; Add 8 (sets carry ~3% of time: 8/256)
    JP          NC,POLL_INPUT                       ; If no carry, abort monster action
    DEC         B                                   ; Decrement B (test if B was 1: back)
    JP          NZ,CHK_LEFT_DIRECTION               ; If not 1, check next case
    LD          A,(WALL_B0_STATE)                   ; Load back wall state
    BIT         0x2,A                               ; Test bit 2 (passable/door flag)
    JP          NZ,JUMP_BACK_OK                     ; If bit 2 set, back is passable
    AND         A                                   ; Test if A is zero (clear/passable)
    JP          NZ,POLL_INPUT                       ; If not zero (blocked), abort action
JUMP_BACK_OK:
    CALL        ROTATE_FACING_RIGHT                 ; Turn right (90°)
    CALL        ROTATE_FACING_RIGHT                 ; Turn right again (180° total - face back)
    JP          TURN_AND_REDRAW                     ; Jump to redraw and combat check
CHK_LEFT_DIRECTION:
    DEC         B                                   ; Decrement B (test if B was 2: left)
    JP          NZ,CHK_RIGHT_DIRECTION              ; If not 2, check next case
    LD          A,(WALL_L0_STATE)                   ; Load left wall state
    BIT         0x2,A                               ; Test bit 2 (passable/door flag)
    JP          NZ,LEFT_OK                          ; If bit 2 set, left is passable
    AND         A                                   ; Test if A is zero (clear/passable)
    JP          NZ,POLL_INPUT                       ; If not zero (blocked), abort action
LEFT_OK:
    CALL        ROTATE_FACING_LEFT                  ; Turn left (90°)
    JP          TURN_AND_REDRAW                     ; Jump to redraw and combat check
CHK_RIGHT_DIRECTION:
    DEC         B                                   ; Decrement B (test if B was 3: right)
    JP          NZ,CHK_FORWARD_COMBAT               ; If not 3, check case 4 (forward)
    LD          A,(WALL_R0_STATE)                   ; Load right wall state
    BIT         0x2,A                               ; Test bit 2 (passable/door flag)
    JP          NZ,RIGHT_OK                         ; If bit 2 set, right is passable
    AND         A                                   ; Test if A is zero (clear/passable)
    JP          NZ,POLL_INPUT                       ; If not zero (blocked), abort action
RIGHT_OK:
    CALL        ROTATE_FACING_RIGHT                 ; Turn right (90°)
TURN_AND_REDRAW:
    CALL        REDRAW_START                        ; Refresh non-viewport UI elements
    CALL        REDRAW_VIEWPORT                     ; Render 3D maze view with new facing

;==============================================================================
; PLAY_GROWL_INIT_COMBAT
;==============================================================================
; Play monster growl sound effect and jump to combat initialization
;   - Triggers audio cue for monster encounter
;   - Transfers control to INIT_MONSTER_COMBAT (no return)
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   Used by PLAY_MONSTER_GROWL and INIT_MONSTER_COMBAT
; ---  End  ---
;   Does not return (jumps to INIT_MONSTER_COMBAT)
;
; Memory Modified: Via PLAY_MONSTER_GROWL and INIT_MONSTER_COMBAT
; Calls: PLAY_MONSTER_GROWL, INIT_MONSTER_COMBAT (jump)
;==============================================================================
PLAY_GROWL_INIT_COMBAT:
    CALL        PLAY_MONSTER_GROWL                  ; Play monster growl sound
    JP          INIT_MONSTER_COMBAT                 ; Initialize combat sequence

;==============================================================================
; CHK_FORWARD_COMBAT
;==============================================================================
; Check forward wall state for combat engagement (direction case 4)
;   - Tests WALL_F0_STATE bit 2 (passable/door flag)
;   - Tests if wall state is zero (clear/passable)
;   - Engages combat if forward position is passable or clear
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = WALL_F0_STATE value, then bit tests
; ---  End  ---
;   Control transfers to PLAY_GROWL_INIT_COMBAT or POLL_INPUT
;
; Memory Modified: None
; Calls: PLAY_GROWL_INIT_COMBAT (via JP)
;==============================================================================
CHK_FORWARD_COMBAT:
    LD          A,(WALL_F0_STATE)                   ; Load forward wall state (B was 4)
    BIT         0x2,A                               ; Test bit 2 (passable/door flag)
    JP          NZ,PLAY_GROWL_INIT_COMBAT           ; If bit 2 set, forward passable - engage
    AND         A                                   ; Test if A is zero (clear/passable)
    JP          Z,PLAY_GROWL_INIT_COMBAT            ; If zero (clear), engage combat

;==============================================================================
; POLL_INPUT - Input polling and title screen difficulty selection
;==============================================================================
;   - Polls keyboard; if any key active, branch to keyboard handling
;   - Polls handcontroller; if active, capture state and branch to HC handling
;   - If no input, returns to WAIT_FOR_INPUT main loop
;   - On HC activity, plays a short descending tone to acknowledge input
; Registers:
; --- Start ---
;   BC = $00FF (keyboard port), then $F7/$F6 (HC control/data)
;   HL = Handcontroller input holder pointer during capture
; --- In Process ---
;   A  = Port reads, comparisons
;   C  = Port selector ($FF, $F7, $F6)
; ---  End  ---
;   Jumps to keyboard (`HANDLE_KEYBOARD_INPUT`) or HC handling (`HANDLE_HC_INPUT`),
;   else falls back to `WAIT_FOR_INPUT`
;
POLL_INPUT:
    LD          BC,$ff                              ; BC = keyboard port
    IN          A,(C)                               ; Read keyboard row
    INC         A                                   ; Test for $FF (no key pressed)
    JP          NZ,HANDLE_KEYBOARD_INPUT            ; Key pressed → handle keyboard input
    LD          C,$f7                               ; C = HC control port
    LD          A,0xf                               ; A = enable mask
    OUT         (C),A                               ; Enable HC read
    DEC         C                                   ; C = $F6 (HC data)
    IN          A,(C)                               ; Read HC state
    INC         A                                   ; Test for $FF (no input)
    JP          NZ,HANDLE_HC_INPUT                  ; If input present, go HC handling
    INC         C                                   ; C = PSG_REGS
    LD          A,0xe                               ; A = disable mask
    OUT         (C),A                               ; Disable HC port
    DEC         C                                   ; C = PSG_DATA
    IN          A,(C)                               ; Read again (stabilize)
    INC         A                                   ; $FF means no input
    JP          Z,WAIT_FOR_INPUT                    ; No input anywhere → continue loop
HANDLE_HC_INPUT:
    CALL        PLAY_INPUT_PIP_MID                  ; Acknowledge HC input with tone
    LD          HL,HC_INPUT_HOLDER                  ; Point to HC input storage buffer
DISABLE_JOY_04:
    LD          C,$f7                               ; C = PSG_REGS
    LD          A,0xf                               ; Command: disable joystick 4
    OUT         (C),A                               ; Send command to control port
    DEC         C                                   ; C = PSG_DATA
    IN          A,(C)                               ; Read HC input data (buttons 1-4)
    LD          (HL),A                              ; Store first byte to buffer
    INC         HL                                  ; Point to next buffer byte
    INC         C                                   ; C = PSG_REGS
ENABLE_JOY_04:
    LD          A,0xe                               ; Command: enable joystick 4
    OUT         (C),A                               ; Send command to control port
    DEC         C                                   ; C = PSG_DATA
    IN          A,(C)                               ; Read HC input data (additional buttons)
    LD          (HL),A                              ; Store second byte to buffer

    LD          A,(DIFFICULTY_LEVEL)                ; Load DIFFICULTY_LEVEL
    AND         A                                   ; Clear C and N flags
    JP          NZ,CHK_MONSTER_MELEE_STATE          ; If player is not dead, check melee state and then inputs
    LD          A,(DUNGEON_LEVEL)                   ; Load DUNGEON_LEVEL (BCD!)
    AND         A                                   ; Clear C and N flags
    JP          NZ,GAMEINIT                         ; If not in Main Menu, initialize game

    LD          A,(HL)                              ; Load second HC input byte
    INC         A                                   ; Increment (test if $FF: no input)
    JP          Z,TITLE_CHK_FOR_HC_INPUT            ; If $FF, check first byte instead

;==============================================================================
; HC_LEVEL_SELECT_LOOP - Handcontroller-based difficulty selection
;==============================================================================
; Processes handcontroller button input on the title screen to select game
; difficulty level. Maps specific button values to difficulty settings 1-4.
; This is part of the title screen input handling sequence.
;
; Button Mapping:
; - $60 (K3): Difficulty 1 (easiest)
; - $7C: Difficulty 2
; - $7E: Difficulty 3
; - $7F: Difficulty 4 (hardest)
; - Other: Re-initialize game (GAMEINIT)
;
; Registers:
; --- Start ---
;   A = HC button value
; --- In Process ---
;   A = Comparison operations
; ---  End  ---
;   Jumps to difficulty handler (does not return)
;
; Memory Modified: None directly (handlers modify game state)
; Calls: SET_DIFFICULTY_1/2/3, GAMEINIT (jumps)
;==============================================================================
HC_LEVEL_SELECT_LOOP:
    CP          $60                                 ; Compare to K3 button ($60)
    JP          Z,SET_DIFFICULTY_1                  ; If K3, set difficulty 1
    CP          $7c                                 ; Compare to button value $7C
    JP          Z,SET_DIFFICULTY_2                  ; If $7C, set difficulty 2
    CP          $c0                                 ; Compare to button value $C0
    JP          Z,SET_DIFFICULTY_3                  ; If $C0, set difficulty 3
    JP          SET_DIFFICULTY_4                    ; Otherwise, set difficulty 4
TITLE_CHK_FOR_HC_INPUT:
    DEC         HL                                  ; Point back to first HC input byte
    LD          A,(HL)                              ; Load first HC input byte
    INC         A                                   ; Increment (test if $FF: no input)
    JP          HC_LEVEL_SELECT_LOOP                ; Jump to check difficulty selection

;==============================================================================
; PLAY_INPUT_PIP_MID , HI , & LO - Play short pip sounds
;==============================================================================
; Plays a brief mid, high, or lo pip sound effect, typically used for negative
; feedback or denial actions. Resets all timers and outputs a series of tones
; to the speaker port to create an audible "beep" effect.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = 0, then speaker values
;   BC = SLEEP parameter ($100 cycles)
;   B  = Loop counter (6 iterations)
; ---  End  ---
;   A  = Last speaker output
;   B  = 0 (exhausted counter)
;   Timers reset
;
; Memory Modified: MASTER_TICK_TIMER, SECONDARY_TIMER, INACTIVITY_TIMER
; Calls: SLEEP
;==============================================================================
PLAY_INPUT_PIP_MID:
    LD          DE,$f0                              ; Load first delay ($F0 - mid pitch)
    LD          HL,$4c0                             ; Load second delay ($4C0 - mid pitch)
    JP          PLAY_INPUT_PIP                      ; Jump to common routine

PLAY_INPUT_PIP_HI:
    LD          DE,$C0                              ; Load first delay ($C0 - 0.8x for higher pitch)
    LD          HL,$3D0                             ; Load second delay ($3D0 - 0.8x for higher pitch)
    JP          PLAY_INPUT_PIP                      ; Jump to common routine

PLAY_INPUT_PIP_LO:
    LD          DE,$12C                             ; Load first delay ($12C - 1.25x for lower pitch)
    LD          HL,$5F0                             ; Load second delay ($5F0 - 1.25x for lower pitch)
    ; Fall through to PLAY_INPUT_PIP_COMMON

;==============================================================================
; PLAY_INPUT_PIP - Common pip sound routine
;==============================================================================
; Plays a brief pip sound effect with configurable delays for pitch control.
; Called by PLAY_INPUT_PIP_HI/MID/LO after they set up delay parameters.
;
; Registers:
; --- Start ---
;   DE = First delay value (controls initial tone duration)
;   HL = Second delay value (controls main tone duration)
; --- In Process ---
;   A  = 0, then speaker values
;   BC = SLEEP parameter (copied from DE, then HL)
; ---  End  ---
;   A  = Last speaker output (1)
;   BC = Last delay value
;   DE = Preserved first delay
;   HL = Preserved second delay
;   Timers reset
;
; Memory Modified: MASTER_TICK_TIMER, SECONDARY_TIMER, INACTIVITY_TIMER
; Calls: SLEEP
;==============================================================================
PLAY_INPUT_PIP:
    XOR         A                                   ; Clear A (A = 0)
    LD          (MASTER_TICK_TIMER),A               ; Reset MASTER_TICK_TIMER
    LD          (SECONDARY_TIMER),A                 ; Reset SECONDARY_TIMER
    LD          (INACTIVITY_TIMER),A                ; Reset INACTIVITY_TIMER
    OUT         (SPEAKER),A                         ; Output 0 to speaker (low tone)
    PUSH        HL                                  ; Preserve HL (second delay)
    LD          B,D                                 ; Copy DE to BC for SLEEP
    LD          C,E                                 ; BC = first delay value
    CALL        SLEEP                               ; Delay for BC cycles
    INC         A                                   ; Increment A (A = 1)
    OUT         (SPEAKER),A                         ; Output 1 to speaker (high tone)
    POP         BC                                  ; Restore second delay to BC
    CALL        SLEEP                               ; Delay for BC cycles
    RET                                             ; Return to caller

;==============================================================================
; HANDLE_KEYBOARD_INPUT - Keyboard title-screen scanning and difficulty selection
;==============================================================================
;   - Scans keyboard columns into `KEY_INPUT_COL0..` buffer
;   - If `MULTIPURPOSE_BYTE` already has a key, branch to `KEY_COMPARE`
;   - If `DUNGEON_LEVEL` is nonzero, start game (`GAMEINIT`)
;   - Otherwise, check specific keys for difficulty selection or author display
; Registers:
;   HL = Destination buffer pointer (`KEY_INPUT_COL0`) advanced by L
;   BC = Port and column bitmask ($FEFF, rotated)
;   D  = Loop counter (8 columns)
;   A  = Input value and comparisons
;
HANDLE_KEYBOARD_INPUT:
    CALL        PLAY_INPUT_PIP_MID                  ; Acknowledge key press with pip sound
    LD          HL,KEY_INPUT_COL0                   ; Point to key input buffer start
    LD          BC,0xfeff                           ; C=$FF (port), B=$FE (column 0 mask)
    LD          D,0x8                               ; Set counter to 8 (8 columns to scan)

;==============================================================================
; KBD_LEVEL_SELECT_LOOP - Scan keyboard and select difficulty level
;==============================================================================
; Scans all 8 keyboard columns and stores results in buffer, then checks for
; specific key presses to set game difficulty (1-3) or default (4). Handles
; both title screen input and in-game reinitialization.
;
; Key Mapping:
; - Key 3: Difficulty 1 (easier)
; - Key 2: Difficulty 2 (medium)
; - Key 1: Difficulty 3 (hard)
; - Key A: Show author credits (title screen only)
; - Other: Difficulty 4 (default/hardest)
;
; Registers:
; --- Start ---
;   BC = Port and column mask
;   D  = Column counter
;   HL = Buffer pointer
; --- In Process ---
;   A  = Port reads, comparisons, difficulty values
;   B  = Column mask (rotated left each iteration)
;   D  = Decremented counter
;   HL = Advanced through buffer
; ---  End  ---
;   Jumps to difficulty handler or GAMEINIT
;
; Memory Modified: KEY_INPUT_COL0..7, MULTIPURPOSE_BYTE, GAME_BOOLEANS
; Calls: BLANK_SCRN, GAMEINIT, SHOW_AUTHOR (jumps)
;==============================================================================
KBD_LEVEL_SELECT_LOOP:
    IN          A,(C)                               ; Read current keyboard column
    LD          (HL),A                              ; Store column data to buffer

    INC         L                                   ; Advance to next buffer position
    RLC         B                                   ; Rotate column mask left (next column)
    DEC         D                                   ; Decrement column counter
    JP          NZ,KBD_LEVEL_SELECT_LOOP            ; Loop if more columns to scan

    LD          A,(DIFFICULTY_LEVEL)                ; Load DIFFICULTY_LEVEL
    AND         A                                   ; Clear C and N flags
    JP          NZ,KEY_COMPARE                      ; If player is not dead, read new input
    LD          A,(DUNGEON_LEVEL)                   ; Load DUNGEON_LEVEL (BCD!)
    AND         A                                   ; Clear C and N flags
    JP          NZ,GAMEINIT                         ; If not in Main Menu, initialize game

    LD          A,(KEY_INPUT_COL6)                  ; Load column 6 key data
    CP          $fe                                 ; Compare to key 3 value ($FE)
    JP          Z,SET_DIFFICULTY_1                  ; If key 3, set difficulty 1
    CP          $df                                 ; Compare to key A value ($DF)
    JP          Z,SHOW_AUTHOR                       ; If key A, show author credits
                                                    ; (must be held on title screen)
    LD          A,(KEY_INPUT_COL7)                  ; Load column 7 key data
    CP          $fe                                 ; Compare to key 2 value ($FE)
    JP          Z,SET_DIFFICULTY_2                  ; If key 2, set difficulty 2
    CP          $fb                                 ; Compare to key 1 value ($FB)
    JP          Z,SET_DIFFICULTY_3                  ; If key 1, set difficulty 3
SET_DIFFICULTY_4:
    LD          A,0x4                               ; Set difficulty to 4 (hardest)
GOTO_GAME_START:
    LD          (DIFFICULTY_LEVEL),A                ; Store DIFFICULTY_LEVEL
    LD          A,(GAME_BOOLEANS)                   ; Load game boolean flags
    SET         0x0,A                               ; Set bit 0 (game start flag)
    LD          (GAME_BOOLEANS),A                   ; Store updated flags
    JP          BLANK_SCRN                          ; Jump to clear screen and start game
SET_DIFFICULTY_1:
    LD          A,0x1                               ; Set difficulty to 1
    JP          GOTO_GAME_START                     ; Jump to game start sequence
SET_DIFFICULTY_2:
    LD          A,0x2                               ; Set difficulty to 2
    JP          GOTO_GAME_START                     ; Jump to game start sequence
SET_DIFFICULTY_3:
    LD          A,0x3                               ; Set difficulty to 3 (hardest)
    JP          GOTO_GAME_START                     ; Jump to game start sequence

;==============================================================================
; CHK_ITEM - Decode item code into graphics pointer and color base
;==============================================================================
; Decodes a packed item code into a graphics table pointer (HL) and color
; base value (B). Item codes encode both type and color group through bit
; manipulation. Returns early if item code is $FE (empty slot).
;
; Registers:
; --- Start ---
;   A  = Item code
;   B  = Item size offset value - 0 regular, 2 small, 4 tiny
;   C  = Low byte of GFX pointer
;        (CHRRAM_SPRITE_ADDR_HI) should be loaded with the High byte
;        of the GFX pointer before calling CHK_ITEM
; --- In Process ---
;   A  = Shifted and calculated values
;   D  = Color base accumulator ($10, $30, $50, $70)
;   E  = Temporary item code storage
; ---  End  ---
;   HL = Graphics pointer ($FF00 + calculated offset)
;   B  = Final color base
;   D  = Color base
;   E  = Modified item code
;   Z flag indicates empty item
;
; Memory Modified: None
; Calls: None
;==============================================================================
CHK_ITEM:
    CP          $fe                                 ; Compare A to $FE (no item marker)
    RET         Z                                   ; If A == $FE, return (no item present)
    SRL         A                                   ; Shift A right, bit 0 to carry
    LD          E,A                                 ; Store shifted value in E
    JP          C,ITEM_WAS_YL_WH                    ; If carry set, item was yellow/white
    LD          D,$10                               ; Item was red/magenta, D = $10
    JP          ITEM_WAS_RD_MG                      ; Jump ahead
ITEM_WAS_YL_WH:
    LD          D,$30                               ; Item was yellow/white, D = $30
ITEM_WAS_RD_MG:
    SRL         A                                   ; Shift A right again, bit 0 to carry
    JP          NC,ITEM_NOT_RD_YL                   ; If no carry, item not red/yellow
    LD          A,$40                               ; Load $40 into A
    ADD         A,D                                 ; Add D to A
    LD          D,A                                 ; D = $50 (red/mag) or $70 (yellow/white)
ITEM_NOT_RD_YL:
    RES         0x0,E                               ; Clear bit 0 of E
    LD          A,E                                 ; Load E back to A
    SLA         A                                   ; Shift A left (multiply by 2)
    ADD         A,E                                 ; Add E (now A = E * 3)

    ADD         A,B                                 ; Add B size offset (0 = regular, 1 = small, 2 = tiny offset) to A

    LD          B,D                                 ; Store D in B (color base)
    LD          L,A                                 ; Store result in L
    LD          H,$ff                               ; Set H to $FF (graphics pointer table high byte)
    LD          E,(HL)                              ; Load graphics pointer low byte
    INC         HL                                  ; Point to high byte
    LD          D,(HL)                              ; Load graphics pointer high byte
    LD          A,(ITEM_CHRRAM_HI)                  ; Load sprite CHRRAM address high byte
    LD          H,A                                 ; Store in H register for GFX_DRAW

    LD          L,C                                 ; Store C in L

; INPUT: HL = CHRRAM cursor position
;        DE = AQUASCII string pointer
;        B  = color byte
;        C  = L
;        A  = H (from CHRRAM_SPRITE_ADDR_HI)

    JP          GFX_DRAW                            ; Jump to graphics drawing routine

;==============================================================================
; DO_OPEN_CLOSE - Handle opening/closing doors and chests
;==============================================================================
; Processes player action to open or close doors, or open treasure chests.
; For chests (BOX items), generates random loot based on chest level. For
; doors, toggles door state (open/closed) based on current wall configuration.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = Item code, level calculations, random values
;   C  = Item level (chest difficulty)
;   B  = Bit rotation temporary
;   HL = Graphics pointers
; ---  End  ---
;   Varies by door vs chest handler
;
; Memory Modified: ITEM_S0 (chest items), wall states (doors)
; Calls: UPDATE_SCR_SAVER_TIMER, PICK_UP_S0_ITEM, door handlers
;==============================================================================
DO_OPEN_CLOSE:
    LD          A,(ITEM_S0)                         ; Load sprite at S0 position
    LD          C,0x0                               ; Clear C (will hold item level)
    SRL         A                                   ; Shift item code right (extract level bits)
                                                    ; Move item level into C
    RR          C                                   ; Rotate right through C (bit from A)
    SRL         A                                   ; Shift A right again
    RL          C                                   ; Rotate left through C
    RL          C                                   ; Rotate left again (C now has level)
    CP          $11                                 ; Compare to BOX code ($11)
                                                    ; (codes $44-$47 become $11 after 2 SRL)
    JP          NZ,DOOR_HANDLER                     ; If not box, handle as door
    LD          A,C                                 ; Load item level into A
    AND         A                                   ; Test if zero (unlocked box)
    JP          Z,DO_OPEN_BOX                       ; If level 0, open box immediately
    CALL        UPDATE_SCR_SAVER_TIMER              ; Reset screensaver timer
    INC         C                                   ; Increment C (level + 1)
CHEST_LEVEL_LOOP:
    SUB         C                                   ; Subtract C from A
    JP          NC,CHEST_LEVEL_LOOP                 ; Loop while no carry (A >= C)
    ADD         A,C                                 ; Add C back (A now = A mod C)
    LD          C,A                                 ; Store remainder in C

;==============================================================================
; DO_OPEN_BOX - Generate random treasure item from chest
;==============================================================================
; Opens a treasure chest and generates a random item based on the semi-random
; R register value. Uses the R register (refresh counter) as entropy source,
; masks to 0-7 range, then maps to specific item codes.
;
; Registers:
; --- Start ---
;   C = Chest level
; --- In Process ---
;   A  = R value, masked value, item code calculations
;   B  = Bit rotation temporary
;   BC = Map position pointer
;   AF'= Preserved item code
; ---  End  ---
;   Jumps to UPDATE_VIEWPORT (does not return)
;
; Memory Modified: Map item data at player position
; Calls: PICK_RANDOM_ITEM, ITEM_MAP_CHECK, UPDATE_VIEWPORT (jump)
;==============================================================================
DO_OPEN_BOX:
    LD          A,R                                 ; Load semi-random value from R register
    AND         0x7                                 ; Mask to 0-7 range

;==============================================================================
; PICK_RANDOM_ITEM - Normalize random value and map to item code range
;==============================================================================
; Takes a value in range 0-7 and normalizes it to 0-6 through repeated
; subtraction, then maps to treasure item code range ($1D-$23). Applies
; chest level multiplier through bit rotation operations.
;
; Algorithm:
; 1. Subtract 7 repeatedly until result < 7 (normalize to 0-6)
; 2. Add $1D to map to item code base range
; 3. Apply chest level multiplier:
;    - Rotate chest level (C) right through carry
;    - Rotate item code left to multiply by level
; 4. Result is level-adjusted random treasure item
;
; Registers:
; --- Start ---
;   A = Random 0-7
;   C = Chest level
; --- In Process ---
;   A = Decremented, then offset, then rotated
;   B = Bit rotation carry
;   C = Bit rotation (level / 8)
; ---  End  ---
;   A = Final item code
;   B/C modified
;
; Memory Modified: None
; Calls: None (inline loop)
;==============================================================================
PICK_RANDOM_ITEM:
    SUB         0x7                                 ; Subtract 7
    JP          NC,PICK_RANDOM_ITEM                 ; Loop until carry (result 0-6)
    ADD         A,$1d                               ; Add $1D (result $1D-$23 range)
    RR          C                                   ; Rotate C right through carry
    RR          B                                   ; Rotate B right through carry
    RR          C                                   ; Rotate C right again (C = C / 8)
    RLA                                             ; Rotate A left through carry
    RL          B                                   ; Rotate B left through carry
    RLA                                             ; Rotate A left again
    EX          AF,AF'                              ; Save A to alternate register
    LD          A,(PLAYER_MAP_POS)                  ; Load player map position
    CALL        ITEM_MAP_CHECK                      ; Check/update item on map
    EX          AF,AF'                              ; Restore A from alternate register
    LD          (BC),A                              ; Store new item at BC address
    JP          UPDATE_VIEWPORT                     ; Update viewport and return
DOOR_HANDLER:
    LD          A,(PLAYER_MAP_POS)                  ; Load player's current map position
    LD          H,$38                               ; Set H to $38 (wall map high byte)
    LD          L,A                                 ; Set L to player position (HL = wall map addr)
    LD          A,(DIR_FACING_SHORT)                ; Load player facing direction (1-4)
    DEC         A                                   ; Decrement (test if 1: north)
    JP          Z,NORTH_OPEN_CLOSE_DOOR             ; If facing north, process north door
    DEC         A                                   ; Decrement (test if 2: east)
    JP          Z,SHIFT_EAST_OPEN_CLOSE_DOOR        ; If facing east, shift and process as west
    DEC         A                                   ; Decrement (test if 3: south)
    JP          NZ,WEST_DOOR_HANDLER                ; If facing west (4), jump to west handler
    LD          A,L                                 ; Facing south: load position into A
    ADD         A,$10                               ; Add $10 (shift to south neighbor)
    LD          L,A                                 ; Update L (now pointing to south cell)
                                                    ; Then process as north door

;==============================================================================
; NORTH_OPEN_CLOSE_DOOR - Toggle north-facing door state
;==============================================================================
; Handles opening or closing a door to the north of the player's position.
; Checks map data for door presence, tests door type (normal vs hidden), and
; toggles the appropriate door state bits. Routes to door animation routines.
;
; Registers:
; --- Start ---
;   HL = Map position north of player
; --- In Process ---
;   A  = Door mask ($44 or $22), bit test results
; ---  End  ---
;   Jumps to door animation routines (does not return)
;
; Memory Modified: Map door bits, WALL_F0_STATE
; Calls: NO_ACTION_TAKEN (conditional), SET_F0_DOOR_OPEN or CLOSE_N_DOOR
;==============================================================================
NORTH_OPEN_CLOSE_DOOR:
    BIT         0x6,(HL)                            ; Test bit 6 (north wall present)
    JP          Z,NO_ACTION_TAKEN                   ; If no wall, no action
    BIT         0x5,(HL)                            ; Test bit 5 (north hidden door)
    JP          Z,SET_N_DOOR_MASK                   ; If no hidden door, use door mask
    LD          A,$44                               ; Load wall mask ($44)
    JP          OPEN_N_CHECK                        ; Jump to check if door open
SET_N_DOOR_MASK:
    LD          A,$22                               ; Load door mask ($22)
OPEN_N_CHECK:
    BIT         0x7,(HL)                            ; Test bit 7 (north door open)
    JP          NZ,CLOSE_N_DOOR                     ; If door open, close it
    SET         0x7,(HL)                            ; Set bit 7 (mark door as closed on map)
    JP          SET_F0_DOOR_OPEN                    ; Jump to open door animation

;==============================================================================
; SHIFT_EAST_OPEN_CLOSE_DOOR - Toggle east-facing door (as west from east cell)
;==============================================================================
; Handles opening or closing a door to the east by shifting to the eastern
; map cell and processing it as a west-facing door. This allows east doors
; to be handled by the west door logic with a simple position adjustment.
;
; Registers:
; --- Start ---
;   HL = Current map position
; --- In Process ---
;   A  = Door mask ($44 or $22), bit test results
;   HL = Map position east of player (L incremented)
; ---  End  ---
;   Jumps to door animation routines
;
; Memory Modified: Map door bits (eastern cell), WALL_F0_STATE
; Calls: NO_ACTION_TAKEN (conditional), SET_F0_DOOR_OPEN or CLOSE_W_DOOR
;==============================================================================
SHIFT_EAST_OPEN_CLOSE_DOOR:
    INC         L                                   ; Increment L (shift east, process as west)
WEST_DOOR_HANDLER:
    BIT         0x1,(HL)                            ; Test bit 1 (west wall present)
    JP          Z,NO_ACTION_TAKEN                   ; If no wall, no action
    BIT         0x0,(HL)                            ; Test bit 0 (west hidden door)
    JP          Z,SET_W_DOOR_MASK                   ; If no hidden door, use door mask
    LD          A,$44                               ; Load wall mask ($44)
    JP          WEST_DOOR_OPEN_CHK                  ; Jump to check if door open
SET_W_DOOR_MASK:
    LD          A,$22                               ; Load door mask ($22)
WEST_DOOR_OPEN_CHK:
    BIT         0x2,(HL)                            ; Test bit 2 (west door open)
    JP          NZ,CLOSE_W_DOOR                     ; If door open, close it
    SET         0x2,(HL)                            ; Set bit 2 (mark door as closed on map)

;==============================================================================
; SET_F0_DOOR_OPEN - Initialize and animate door opening sequence
;==============================================================================
; Marks the F0 position as passable, waits for VSYNC, then performs an animated
; door opening sequence with synchronized graphics updates and rising pitch sound.
; Uses 12-step animation copying graphics data progressively to screen.
;
; Registers:
; --- Start ---
;   AF' = Door mask (preserved through animation)
; --- In Process ---
;   A  = VSYNC reads, color value, loop counter, graphics data
;   BC = CHK_ITEM parameters, LDIR count, offset calculations
;   DE = Graphics destination pointers
;   HL = WALL_F0_STATE, graphics source pointers
;   EXX = Alternates between sound/graphics contexts
; ---  End  ---
;   Jumps to WAIT_FOR_INPUT (does not return)
;
; Memory Modified: WALL_F0_STATE, COLRAM_F0_DOOR_IDX area, screen graphics
; Calls: DRAW_DOOR_F0, CHK_ITEM, COPY_DOOR_GFX, SETUP_OPEN_DOOR_SOUND, LO_HI_PITCH_SOUND, WAIT_FOR_INPUT (jump)
;==============================================================================
SET_F0_DOOR_OPEN:
    LD          HL,WALL_F0_STATE                    ; Point to F0 wall state
    SET         0x2,(HL)                            ; Set bit 2 (mark F0 as passable)
    EX          AF,AF'                              ; Save mask state in alternate A

;==============================================================================
; WAIT_TO_REDRAW_F0_DOOR - Synchronize to VSYNC before redrawing door
;==============================================================================
; Waits for the vertical blanking interval (VSYNC) signal before proceeding
; with door redraw operations, ensuring flicker-free animation by timing
; graphics updates to the CRT beam retrace period.
;
; Registers:
; --- Start ---
;   AF' = Door mask (preserved)
; --- In Process ---
;   A  = VSYNC port reads ($FF during retrace, $00 otherwise)
; ---  End  ---
;   A  = $00 (VSYNC detected)
;   F  = Z flag set from INC A after VSYNC detected
;
; Memory Modified: None
; Calls: None (polling loop)
;==============================================================================
WAIT_TO_REDRAW_F0_DOOR:
    IN          A,(VSYNC)                           ; Read VSYNC port
    INC         A                                   ; Increment (test if $FF)
    JP          Z,WAIT_TO_REDRAW_F0_DOOR            ; If $FF, wait for VSYNC
    LD          A,0x0                               ; Load color (black on black)
                                                    ; (was blue on blue, $BB)
    CALL        DRAW_DOOR_F0                        ; Draw door at F0 position

; Maybe we need to align this section with the CHK_ITEM_S1 routine and call it instead?
    LD          A,(ITEM_S1)                         ; Load sprite at S1 position
    LD          BC,$28a                             ; Load BC with offset/color
    CALL        CHK_ITEM                            ; Check and draw S1 item

    LD          HL,COLRAM_F0_DOOR_IDX               ; Point to F0 door color RAM
    LD          DE,PL_BG_CHRRAM_BUFFER              ; Point to temporary buffer
    CALL        COPY_DOOR_GFX                       ; Copy door graphics to buffer
    CALL        SETUP_OPEN_DOOR_SOUND               ; Initialize door opening sound parameters
    EXX                                             ; Switch to alternate register set
    LD          HL,DOOR_ANIM_GFX_DATA               ; Point to source graphics data
    LD          DE,COLRAM_F0_DOOR_ANIM_IDX          ; Point to destination screen location
    LD          A,0xc                               ; Set loop counter to 12 (animation steps)

;==============================================================================
; DOOR_ANIM_LOOP - Door opening animation loop
;==============================================================================
; Performs a 12-step progressive door opening animation by copying 8-byte chunks
; of graphics data to the screen while playing synchronized rising pitch sound.
; Uses complex pointer arithmetic to step through source and destination buffers,
; advancing row-by-row down the door graphic.
;
; Pointer Navigation:
; - Copy 8 bytes forward (LDIR)
; - Move source back 16 bytes (to next animation frame offset)
; - Move destination back 48 bytes (to adjust for row stride)
; - Repeat for 12 rows
;
; Registers:
; --- Start ---
;   A  = 12 (loop counter)
;   HL = Graphics source
;   DE = Screen destination
;   AF' = Door mask
; --- In Process ---
;   A  = Loop counter (alternates to AF')
;   BC = $08 (LDIR count), $10 (HL offset), $30 (DE offset)
;   DE,HL = Swap during pointer adjustments
; ---  End  ---
;   A  = 0 (loop complete)
;   F  = Z flag set from DEC A
;   Jumps to WAIT_FOR_INPUT (does not return)
;
; Memory Modified: Screen graphics at destination
; Calls: LO_HI_PITCH_SOUND, WAIT_FOR_INPUT (jump when complete)
;==============================================================================
DOOR_ANIM_LOOP:
    EX          AF,AF'                              ; Save loop counter to alternate A
    EXX                                             ; Switch to main register set
    CALL        LO_HI_PITCH_SOUND                   ; Play rising pitch sound effect
    EXX                                             ; Switch to alternate register set
    LD          BC,0x8                              ; Set byte count to 8
    LDIR                                            ; Copy 8 bytes (HL) to (DE), inc HL/DE
    LD          BC,$10                              ; Load $10 for offset calculation
    SBC         HL,BC                               ; Move HL back 16 bytes
    EX          DE,HL                               ; Swap DE and HL
    LD          BC,$30                              ; Load $30 for offset calculation
    SBC         HL,BC                               ; Move HL back 48 bytes
    EX          DE,HL                               ; Swap DE and HL back
    EX          AF,AF'                              ; Restore loop counter from alternate A
    DEC         A                                   ; Decrement loop counter
    JP          Z,WAIT_FOR_INPUT                    ; If counter = 0, done
    JP          DOOR_ANIM_LOOP                      ; Loop for next animation step

;==============================================================================
; COPY_DOOR_GFX - Copy 12 rows of 8 bytes with row stride
;==============================================================================
; Copies a 12-row by 8-column block of graphics data from source to destination.
; Advances source pointer by full screen row width (40 bytes) between each
; 8-byte row copy. Used for door graphics operations during open/close animations.
;
; Row Layout:
; - Each logical row is 8 bytes wide
; - Screen rows are 40 bytes wide ($28 hex)
; - After copying 8 bytes, add $20 (32) to skip remaining 32 bytes to next row
;
; Registers:
; --- Start ---
;   HL = Source address
;   DE = Destination address
; --- In Process ---
;   A  = Row counter (12 → 0)
;   BC = Copy count (8 bytes) then row offset ($20)
;   HL = Source pointer (advances with row stride)
;   DE = Destination pointer (sequential)
; ---  End  ---
;   A  = 0 (exhausted row counter)
;   AF'= Door mask from caller
;   Jumps to DRAW_DOOR_F0 (does not return)
;
; Memory Modified: 96 bytes at destination buffer
; Calls: DRAW_DOOR_F0 (jump)
;==============================================================================
COPY_DOOR_GFX:
    LD          A,0xc                               ; Set loop counter to 12 rows
COPY_DOOR_ROW_LOOP:
    LD          BC,0x8                              ; Set byte count to 8
    LDIR                                             ; Copy 8 bytes from (HL) to (DE)
    LD          BC,$20                              ; Load row offset ($20 = 32)
    ADD         HL,BC                               ; Move HL to next row
    DEC         A                                   ; Decrement row counter
    JP          NZ,COPY_DOOR_ROW_LOOP               ; Loop until all 12 rows copied
    EX          AF,AF'                              ; Restore mask from alternate A
    JP          DRAW_DOOR_F0                        ; Draw door and return

;==============================================================================
; CLOSE_N_DOOR - Mark north door as open on map and start close animation
;==============================================================================
; Clears the north door closed bit (bit 7) in the map data, marking the door
; as open, then jumps to the door closing animation sequence.
;
; Registers:
; --- Start ---
;   HL = Map position
; ---  End  ---
;   Jumps to START_DOOR_CLOSE_ANIM (does not return)
;
; Memory Modified: Map door bit 7
; Calls: START_DOOR_CLOSE_ANIM (jump)
;==============================================================================
CLOSE_N_DOOR:
    RES         0x7,(HL)                            ; Clear bit 7 (mark north door as open on map)
    JP          START_DOOR_CLOSE_ANIM               ; Jump to door closing animation

;==============================================================================
; CLOSE_W_DOOR - Mark west door as open on map and start close animation
;==============================================================================
; Clears the west door closed bit (bit 2) in the map data, marking the door
; as open, then falls through to the door closing animation sequence.
;
; Registers:
; --- Start ---
;   HL = Map position
; ---  End  ---
;   Falls through to START_DOOR_CLOSE_ANIM
;
; Memory Modified: Map door bit 2
; Calls: Falls through to START_DOOR_CLOSE_ANIM
;==============================================================================
CLOSE_W_DOOR:
    RES         0x2,(HL)                            ; Clear bit 2 (mark west door as open on map)

;==============================================================================
; START_DOOR_CLOSE_ANIM - Initialize and animate door closing sequence
;==============================================================================
; Marks F0 position as blocked, saves player position, and performs animated
; door closing sequence with synchronized color changes and descending pitch sound.
; Uses 12-row animation painting door color mask progressively across screen.
;
; Registers:
; --- Start ---
;   AF' = Door mask
; --- In Process ---
;   A  = Player position, door mask, color fills
;   BC = $C08 (B=12 rows, C=8 cols), then row offset
;   DE = $20 (row stride)
;   HL = WALL_F0_STATE, PLAYER_MAP_POS, COLRAM_F0_DOOR_IDX
;   EXX = Alternates between color/sound contexts
; ---  End  ---
;   Jumps to WAIT_FOR_INPUT (does not return)
;
; Memory Modified: WALL_F0_STATE, PLAYER_PREV_MAP_LOC, COLRAM_F0_DOOR_IDX area, monster stats
; Calls: SETUP_CLOSE_DOOR_SOUND, HI_LO_PITCH_SOUND, CLEAR_MONSTER_STATS, WAIT_FOR_INPUT (jump)
;==============================================================================
START_DOOR_CLOSE_ANIM:
    LD          HL,WALL_F0_STATE                    ; Point to F0 wall state
    RES         0x2,(HL)                            ; Clear bit 2 (mark F0 as blocked)
    EX          AF,AF'                              ; Save mask to alternate A
    LD          A,(PLAYER_MAP_POS)                  ; Load current player position
    LD          (PLAYER_PREV_MAP_LOC),A             ; Store as previous location
    CALL        SETUP_CLOSE_DOOR_SOUND              ; Initialize door closing sound parameters
    EXX                                             ; Switch to alternate register set
    EX          AF,AF'                              ; Get mask from alternate A
    LD          HL,COLRAM_F0_DOOR_IDX               ; Point to F0 door color RAM
    LD          DE,$20                              ; Set row offset ($20 = 32)
    LD          BC,$c08                             ; B = 12 rows, C = 8 columns

;==============================================================================
; DOOR_CLOSE_ANIM_LOOP - Progressive door closing color fill animation
;==============================================================================
; Fills the door area with color mask row-by-row (12 rows × 8 columns) while
; playing synchronized descending pitch sound. Alternates between register sets
; to maintain both graphics state and sound parameters simultaneously.
;
; Animation Pattern:
; - Fill 8 columns of current row with door color mask
; - Play descending pitch sound
; - Advance to next row (+$20 bytes)
; - Repeat for 12 rows
;
; Registers:
; --- Start ---
;   A  = Color mask
;   BC = $C08 (12 rows, 8 cols)
;   DE = $20 (row offset)
;   HL = Color RAM start
; --- In Process ---
;   L  = Incremented for each column
;   C  = Decremented per column (reset to 8 per row)
;   B  = Decremented per row (DJNZ)
;   EXX/EX AF,AF' = Alternates between color and sound contexts
; ---  End  ---
;   B  = 0 (all rows complete)
;   Jumps to WAIT_FOR_INPUT (does not return)
;
; Memory Modified: COLRAM_F0_DOOR_IDX area (12 rows × 8 columns), monster stats
; Calls: HI_LO_PITCH_SOUND, CLEAR_MONSTER_STATS, WAIT_FOR_INPUT (jump)
;==============================================================================
DOOR_CLOSE_ANIM_LOOP:
    LD          (HL),A                              ; Write color mask to color RAM
    INC         L                                   ; Move to next column
    DEC         C                                   ; Decrement column counter
    JP          NZ,DOOR_CLOSE_ANIM_LOOP             ; Loop until row complete (8 columns)
    EXX                                             ; Switch to main register set
    EX          AF,AF'                              ; Save color mask to alternate A
    CALL        HI_LO_PITCH_SOUND                   ; Play descending pitch sound effect
    EX          AF,AF'                              ; Restore color mask from alternate A
    EXX                                             ; Switch to alternate register set
    LD          C,0x8                               ; Reset column counter to 8
    ADD         HL,DE                               ; Move HL to next row ($20 bytes)
    DJNZ        DOOR_CLOSE_ANIM_LOOP                ; Loop until all 12 rows done
    CALL        CLEAR_MONSTER_STATS                 ; Clear monster statistics
    JP          WAIT_FOR_INPUT                      ; Return to main input loop

;==============================================================================
; DO_TURN_LEFT - Rotate player facing 90 degrees counterclockwise
;==============================================================================
; Turns the player left (counterclockwise) by one cardinal direction if not
; in combat, then updates the viewport to reflect the new facing direction.
;
; Direction Rotation: North(1) → West(4) → South(3) → East(2) → North(1)
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = Combat flag, then facing direction
;   HL = UPDATE_VIEWPORT address
; ---  End  ---
;   Returns to UPDATE_VIEWPORT via stack
;
; Memory Modified: DIR_FACING_SHORT
; Calls: NO_ACTION_TAKEN (if in combat), ROTATE_FACING_LEFT, UPDATE_VIEWPORT (via stack return)
;==============================================================================
DO_TURN_LEFT:
    LD          A,(COMBAT_BUSY_FLAG)                ; Load combat busy flag
    AND         A                                   ; Test if zero (not in combat)
    JP          NZ,NO_ACTION_TAKEN                  ; If in combat, no action
    LD          HL,UPDATE_VIEWPORT                  ; Load return address
    PUSH        HL                                  ; Push to stack (will return to update viewport)

;==============================================================================
; ROTATE_FACING_LEFT - Decrement facing direction with wraparound
;==============================================================================
; Decrements DIR_FACING_SHORT (1-4) with wraparound from 1→4. Used by both
; DO_TURN_LEFT (permanent turn) and DO_GLANCE_LEFT (temporary peek).
;
; Direction Values: 1=North, 2=East, 3=South, 4=West
; Rotation: 4→3→2→1→4 (counterclockwise)
;
; Registers:
; --- Start ---
;   A  = Current facing direction
; ---  End  ---
;   A  = New facing direction
;
; Memory Modified: DIR_FACING_SHORT
; Calls: None
;==============================================================================
ROTATE_FACING_LEFT:
    LD          A,(DIR_FACING_SHORT)                ; Load current facing direction (1-4)
    DEC         A                                   ; Decrement direction
    JP          NZ,STORE_LEFT_FACING                ; If not zero, store new direction
    LD          A,0x4                               ; Wrap: 1 decremented becomes 4 (west)

;==============================================================================
; STORE_LEFT_FACING - Store new leftward facing direction
;==============================================================================
; Stores the computed leftward facing direction to DIR_FACING_SHORT.
;
; Registers:
; --- Start ---
;   A  = New facing direction
; ---  End  ---
;   A  = New facing direction (preserved)
;
; Memory Modified: DIR_FACING_SHORT
; Calls: None
;==============================================================================
STORE_LEFT_FACING:
    LD          (DIR_FACING_SHORT),A                ; Store new facing direction
    RET                                             ; Return (to UPDATE_VIEWPORT if from turn)

;==============================================================================
; DO_TURN_RIGHT - Rotate player facing 90 degrees clockwise
;==============================================================================
; Turns the player right (clockwise) by one cardinal direction if not in
; combat, then updates the viewport to reflect the new facing direction.
;
; Direction Rotation: North(1) → East(2) → South(3) → West(4) → North(1)
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = Combat flag, then facing direction
;   HL = UPDATE_VIEWPORT address
; ---  End  ---
;   Returns to UPDATE_VIEWPORT via stack
;
; Memory Modified: DIR_FACING_SHORT
; Calls: NO_ACTION_TAKEN (if in combat), ROTATE_FACING_RIGHT, UPDATE_VIEWPORT (via stack return)
;==============================================================================
DO_TURN_RIGHT:
    LD          A,(COMBAT_BUSY_FLAG)                ; Load combat busy flag
    AND         A                                   ; Test if zero (not in combat)
    JP          NZ,NO_ACTION_TAKEN                  ; If in combat, no action
    LD          HL,UPDATE_VIEWPORT                  ; Load return address
    PUSH        HL                                  ; Push to stack (will return to update viewport)

;==============================================================================
; ROTATE_FACING_RIGHT - Increment facing direction with wraparound
;==============================================================================
; Increments DIR_FACING_SHORT (1-4) with wraparound from 4→1. Used by both
; DO_TURN_RIGHT (permanent turn) and DO_GLANCE_RIGHT (temporary peek).
;
; Direction Values: 1=North, 2=East, 3=South, 4=West
; Rotation: 1→2→3→4→1 (clockwise)
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = Facing direction value
; ---  End  ---
;   A  = New facing direction
;   F  = Z flag state from comparison
;
; Memory Modified: DIR_FACING_SHORT
; Calls: None
;==============================================================================
ROTATE_FACING_RIGHT:
    LD          A,(DIR_FACING_SHORT)                ; Load current facing direction (1-4)
    INC         A                                   ; Increment direction
    CP          0x5                                 ; Compare to 5 (beyond max)
    JP          NZ,STORE_RIGHT_FACING               ; If not 5, store new direction
    LD          A,0x1                               ; Wrap: 5 becomes 1 (north)

;==============================================================================
; STORE_RIGHT_FACING - Store new rightward facing direction
;==============================================================================
; Stores the computed rightward facing direction to DIR_FACING_SHORT.
;
; Registers:
; --- Start ---
;   A  = New facing direction
; ---  End  ---
;   A  = New facing direction (preserved)
;
; Memory Modified: DIR_FACING_SHORT
; Calls: None
;==============================================================================
STORE_RIGHT_FACING:
    LD          (DIR_FACING_SHORT),A                ; Store new facing direction
    RET                                             ; Return (to UPDATE_VIEWPORT if from turn)

;==============================================================================
; DO_GLANCE_RIGHT - Temporarily peek 90 degrees right then return
;==============================================================================
; Provides a quick peek to the right by rotating facing clockwise, rendering
; the view, pausing briefly, then rotating back to original facing. Blocked
; during combat.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = Combat flag
; ---  End  ---
;   Jumps to DO_TURN_LEFT (does not return)
;
; Memory Modified: DIR_FACING_SHORT (temporarily changed, then restored)
; Calls: NO_ACTION_TAKEN, ROTATE_FACING_RIGHT, REDRAW_START, REDRAW_VIEWPORT, SLEEP_ZERO, DO_TURN_LEFT (jump)
;==============================================================================
DO_GLANCE_RIGHT:
    LD          A,(COMBAT_BUSY_FLAG)                ; Load combat busy flag
    AND         A                                   ; Test if zero (not in combat)
    JP          NZ,NO_ACTION_TAKEN                  ; If in combat, no action
    CALL        ROTATE_FACING_RIGHT                 ; Turn right (increment facing)
    CALL        REDRAW_START                        ; Refresh non-viewport UI elements
    CALL        REDRAW_VIEWPORT                     ; Render 3D maze view (right view)
    CALL        SLEEP_ZERO                          ; Brief delay
    JP          DO_TURN_LEFT                        ; Turn back left (return to original facing)

;==============================================================================
; DO_GLANCE_LEFT - Temporarily peek 90 degrees left then return
;==============================================================================
; Provides a quick peek to the left by rotating facing counterclockwise,
; rendering the view, pausing briefly, then rotating back to original facing.
; Blocked during combat.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = Combat flag
; ---  End  ---
;   Jumps to DO_TURN_RIGHT (does not return)
;
; Memory Modified: DIR_FACING_SHORT (temporarily changed, then restored)
; Calls: NO_ACTION_TAKEN, ROTATE_FACING_LEFT, REDRAW_START, REDRAW_VIEWPORT, SLEEP_ZERO, DO_TURN_RIGHT (jump)
;==============================================================================
DO_GLANCE_LEFT:
    LD          A,(COMBAT_BUSY_FLAG)                ; Load combat busy flag
    AND         A                                   ; Test if zero (not in combat)
    JP          NZ,NO_ACTION_TAKEN                  ; If in combat, no action
    CALL        ROTATE_FACING_LEFT                  ; Turn left (decrement facing)
    CALL        REDRAW_START                        ; Refresh non-viewport UI elements
    CALL        REDRAW_VIEWPORT                     ; Render 3D maze view (left view)
    CALL        SLEEP_ZERO                          ; Brief delay
    JP          DO_TURN_RIGHT                       ; Turn back right (return to original facing)

;==============================================================================
; DO_USE_ATTACK - Parse and dispatch right-hand item usage
;==============================================================================
; Examines the right-hand item and routes to appropriate handler based on
; item type. Extracts item type and level from the encoded item code using
; bit shifting operations.
;
; Item Encoding: Item code = (Type << 2) | Level
; - Bits 0-1: Level (0-3)
; - Bits 2-7: Type (KEY=$16, PHYS=$19, SPRT=$1A, CHAOS=$1C, etc.)
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = Item code, then type after shifts
;   B  = Level bits (0-3) extracted from item code
; ---  End  ---
;   Jumps to handler (does not return here)
;
; Memory Modified: None directly (handlers modify state)
; Calls: DO_USE_KEY, DO_USE_PHYS_POTION, DO_USE_SPRT_POTION, DO_USE_CHAOS_POTION, or USE_SOMETHING_ELSE (jumps)
;==============================================================================
DO_USE_ATTACK:
    LD          A,(RIGHT_HAND_ITEM)                 ; Load right-hand item code
    LD          B,0x0                               ; Clear B (will hold level bits)
    SRL         A                                   ; Shift right, bit 0 to carry
                                                    ; (extract item type for comparison)
    RR          B                                   ; Rotate carry into B bit 7
                                                    ; (push bit 0 from A to B)
    SRL         A                                   ; Shift right again, bit 1 to carry
                                                    ; (further extract item type)
    RL          B                                   ; Rotate carry into B bit 0
                                                    ; (move bits 0 & 1 from A to B)
    RL          B                                   ; Rotate B left (B now has level 0-3)
    CP          AMULET_ITEM_CP                      ; Compare to AMULET
    JP          Z,RED_AMULET_CHK                    ; If amulet, jump to handler
    CP          WARRIOR_POTION_ITEM_CP              ; Compare to WARRIOR POTION
    JP          Z,DO_USE_PHYS_POTION                ; If phys potion, jump to handler
    CP          MAGE_POTION_ITEM_CP                 ; Compare to MAGE POTION
    JP          Z,DO_USE_SPRT_POTION                ; If sprt potion, jump to handler
    CP          CHAOS_POTION_ITEM_CP                ; Compare to CHAOS POTION
    JP          Z,DO_USE_CHAOS_POTION               ; If chaos potion, jump to handler

    JP          USE_SOMETHING_ELSE                  ; Fallthrough for other items

;==============================================================================
; RED_AMULET_CHK - Process amulet
;==============================================================================
; Handles amulet enchantment. Routes to color-specific effects:
; -     Red (level 0): Upgrade MAP (or add RED MAP)
; -  Yellow (level 1): Upgrade KEY (or add RED KEY)
; - Magenta (level 2): Upgrade S0 item
; -   White (level 3): Upgrade RHA and Left Hand Item
;
; Registers:
; --- Start ---
;   B  = Amulet level
; --- In Process ---
;   A,BC,DE,HL = various values
; ---  End  ---
;   Varies by called routine
;
;==============================================================================
RED_AMULET_CHK:
    INC         B                                   ; Increment B
    DEC         B                                   ; Decrement B (test if zero)
    JP          NZ,YEL_AMULET_CHK                   ; If not zero, check for yellow amulet
    LD          HL,MAP_INV_SLOT                     ; Set HL up for MAP_INV_SLOT access
    LD          A,(GAME_BOOLEANS)                   ; Get game booleans
    BIT         0x2,A                               ; Check HAVE MAP boolean
    JP          NZ,UPGRADE_EXISTING_MAP             ; Already have a map, jump to upgrade
    SET         0x2,A                               ; Set HAVE MAP
    LD          (GAME_BOOLEANS),A                   ; Save to GAME BOOLEANS
    LD          A,0x1                               ; Set map to base level
    JP          UPDATE_MAP                          ; Do map updates
UPGRADE_EXISTING_MAP:
    LD          A,(HL)                              ; Get current map level
    INC         A                                   ; Increment A...
    CP          $05                                 ; Check to see if it's top level
    JP          NC,ITEM_NOT_WORTHY                  ; If so, do nothing
UPDATE_MAP:
    LD          (HL),A                              ; Otherwise, update MAP_INV_SLOT
    CALL        LEVEL_TO_COLRAM_FIX                 ; Get correct color into A
    LD          (COLRAM_MAP_IDX),A                  ; Store color value for map display
    CALL        PLAY_POWER_UP_SOUND                 ; Play power up music
    CALL        CLEAR_RIGHT_HAND                    ; Clear the right hand item
    JP          INPUT_DEBOUNCE                      ; Done

YEL_AMULET_CHK:
    DEC         B                                   ; Decrement B (test if zero)
    JP          NZ,MAG_AMULET_CHK                   ; If not zero, check for magenta amulet
    CALL        CLEAR_RIGHT_HAND                    ; Clear the right hand item
    JP          INPUT_DEBOUNCE                      ; Done

MAG_AMULET_CHK:
    DEC         B                                   ; Decrement B (test if zero)
    JP          NZ,WHT_AMULET_CHK                   ; If not zero, check for white amulet
    CALL        CLEAR_RIGHT_HAND                    ; Clear the right hand item
    JP          INPUT_DEBOUNCE                      ; Done

WHT_AMULET_CHK:
    JP          CLEAR_RIGHT_HAND                    ; Done *** DEBUG ME! ***

;==============================================================================
; DO_USE_CHAOS_POTION - Process chaos (large) potion with random effects
;==============================================================================
; Handles large chaos potion consumption. Routes to color-specific effects:
; - Red (level 0): Full heal (phys + sprt)
; - Yellow (level 1): +10 phys health
; - Magenta (level 2): +6 sprt health
; - White (level 3): Random effect (4 possibilities)
;
; Registers:
; --- Start ---
;   B  = Potion level
; --- In Process ---
;   A,BC,DE,HL = Used by health calculation routines
; ---  End  ---
;   Varies by called routine
;
; Memory Modified: Health values, stats display, right-hand item
; Calls: PLAY_USE_PHYS_POTION_SOUND, TOTAL_HEAL, YEL_CHAOS_CHK (fall-through)
;==============================================================================
DO_USE_CHAOS_POTION:
    CALL        PLAY_USE_PHYS_POTION_SOUND          ; Play potion use sound effect
    INC         B                                   ; Increment B
    DEC         B                                   ; Decrement B (test if zero)
    JP          NZ,YEL_CHAOS_CHK                    ; If not zero, handle other potion colors
                                                    ; If zero, large potion is red (full heal)
    CALL        TOTAL_HEAL                          ; Restore all health (phys + sprt)

;==============================================================================
; PROCESS_POTION_UPDATES - Finalize potion consumption and update display
;==============================================================================
; Common exit point for all potion handlers. Updates stats display and
; determines whether to enter combat animation or return to input loop.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = Combat flag
; ---  End  ---
;   Jumps to INIT_MELEE_ANIM or INPUT_DEBOUNCE (does not return)
;
; Memory Modified: Screen stats area
; Calls: REDRAW_STATS, INIT_MELEE_ANIM or INPUT_DEBOUNCE (jumps)
;==============================================================================
PROCESS_POTION_UPDATES:
    CALL        REDRAW_STATS                        ; Update health display on screen
    LD          A,(COMBAT_BUSY_FLAG)                ; Load combat busy flag
    AND         A                                   ; Test if zero (not in combat)
    JP          NZ,INIT_MN_MELEE_ANIM               ; If in combat, init animation
    JP          INPUT_DEBOUNCE                      ; Otherwise, return to input loop

;==============================================================================
; PLAY_USE_PHYS_POTION_SOUND - Play potion consumption sound effect
;==============================================================================
; Produces a triple sound effect for potion usage, then clears the right-hand
; item slot. Uses alternate register set to preserve main state.
;
; Sound Pattern: SOUND_03 played three times in sequence
;
; Registers:
; --- Start ---
;   Main registers preserved via EXX
; --- In Process ---
;   Alternate registers used for sound calls
; ---  End  ---
;   Main registers restored
;
; Memory Modified: RIGHT_HAND_ITEM, right-hand graphics area
; Calls: EXX (SWAP_TO_ALT_REGS), SOUND_03 (3x), CLEAR_RIGHT_HAND
;==============================================================================
PLAY_USE_PHYS_POTION_SOUND:
    EXX                                             ; Switch to alternate register set
    CALL        SOUND_03                            ; Play sound effect (step 1)
    CALL        SOUND_03                            ; Play sound effect (step 2)
    CALL        SOUND_03                            ; Play sound effect (step 3)
    JP          CLEAR_RIGHT_HAND                    ; Clear right-hand item and return

;==============================================================================
; SWAP_TO_ALT_REGS - Switch to alternate register set
;==============================================================================
; Preserves main register state by swapping to alternate register set.
; Falls through to CLEAR_RIGHT_HAND.
;
; Registers:
; --- Start ---
;   BC,DE,HL in main set
; ---  End  ---
;   BC',DE',HL' now active
;
; Memory Modified: None
; Calls: Falls through to CLEAR_RIGHT_HAND
;==============================================================================
SWAP_TO_ALT_REGS:
    EXX                                             ; Switch to alternate register set
CLEAR_RIGHT_HAND:                                   ; Clear right-hand item and draw empty sprite
                                                    ; Effects: Sets RIGHT_HAND_ITEM to $FE (empty)
                                                    ; Draws "poof" animation in right-hand area
    LD          A,$fe                               ; Load empty item marker ($FE)
    LD          (RIGHT_HAND_ITEM),A                 ; Store to right-hand slot (clear item)
    CALL        CLEAR_RIGHT_HAND_GFX                ; Clear right hand graphics
    LD          DE,POOF_6                           ; Point to poof graphics ("    ", $01)
    LD          HL,CHRRAM_RIGHT_HAND_VP_IDX         ; Point to right-hand graphics location
    LD          B,$d0                               ; Load color attribute ($D0)
    CALL        GFX_DRAW                            ; Draw poof graphics
    EXX                                             ; Switch back to main register set
    RET                                             ; Return to caller

;==============================================================================
; TOTAL_HEAL - Restore all health to maximum values
;==============================================================================
; Performs a complete health restoration by setting both physical and spiritual
; health to their respective maximum values. Used by red chaos potions and
; certain white chaos potion random effects.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = Max health value (phys)
;   A  = Max health value (sprt)
; ---  End  ---
;   A  = Spiritual max value
;   HL = Physical max value
;
; Memory Modified: PLAYER_PHYS_HEALTH, PLAYER_SPRT_HEALTH
; Calls: None
;==============================================================================
TOTAL_HEAL:
    LD          HL,(PLAYER_PHYS_HEALTH_MAX)         ; Load max physical health (2 bytes)
    LD          (PLAYER_PHYS_HEALTH),HL             ; Store to current physical health (full heal)
    LD          A,(PLAYER_SPRT_HEALTH_MAX)          ; Load max spiritual health
    LD          (PLAYER_SPRT_HEALTH),A              ; Store to current spiritual health (full heal)
    RET                                             ; Return to caller

;==============================================================================
; YEL_CHAOS_CHK - Process yellow large potion (+10 phys health)
;==============================================================================
; Handles yellow chaos potion (level 1) which grants +10 physical health.
; Falls through to PROCESS_CHAOS_POTION with BC=$10 (10 BCD), E=0.
;
; Registers:
; --- Start ---
;   B  = 0 after DEC (yellow level)
; ---  End  ---
;   BC = $10, E = 0
;
; Memory Modified: None directly (PROCESS_CHAOS_POTION handles updates)
; Calls: MAG_CHAOS_CHK (if not yellow), PROCESS_CHAOS_POTION (fall-through)
;==============================================================================
YEL_CHAOS_CHK:
    DEC         B                                   ; Decrement level (B=0 for yellow large)
    JP          NZ,MAG_CHAOS_CHK                    ; If not zero, check magenta
    LD          BC,$10                              ; BC = 10 physical health increase
    LD          E,0x0                               ; E = 0 spiritual health increase

;==============================================================================
; PROCESS_CHAOS_POTION - Apply chaos potion effects
;==============================================================================
; Common handler for chaos potion modifications. Adds BC to
; physical health and E to spiritual health, updating maximums if new highs.
;
; Registers:
; --- Start ---
;   BC = Phys increase
;   E  = Sprt increase
; ---  End  ---
;   Jumps to PROCESS_POTION_UPDATES (does not return)
;
; Memory Modified: PLAYER_PHYS_HEALTH, PLAYER_SPRT_HEALTH, possibly max values
; Calls: CALC_CURR_PHYS_HEALTH, CALC_MAX_PHYS_HEALTH, PROCESS_POTION_UPDATES (jump)
;==============================================================================
PROCESS_CHAOS_POTION:
    CALL        CALC_CURR_PHYS_HEALTH               ; Add BC to current physical health
    CALL        CALC_MAX_PHYS_HEALTH                ; Update max health if increased
    JP          PROCESS_POTION_UPDATES              ; Continue with updates

;==============================================================================
; MAG_CHAOS_CHK - Process magenta large potion (+6 sprt health)
;==============================================================================
; Handles magenta chaos potion (level 2) which grants +6 spiritual health.
; Jumps to PROCESS_CHAOS_POTION with BC=0, E=$06.
;
; Registers:
; --- Start ---
;   B  = 0 after second DEC (magenta level)
; ---  End  ---
;   BC = 0, E = $06
;
; Memory Modified: None directly (PROCESS_CHAOS_POTION handles updates)
; Calls: WHT_CHAOS_CHK (if not magenta), PROCESS_CHAOS_POTION (jump)
;==============================================================================
MAG_CHAOS_CHK:
    DEC         B                                   ; Decrement level (B=0 for magenta large)
    JP          NZ,WHT_CHAOS_CHK                    ; If not zero, check white
    LD          BC,0x0                              ; BC = 0 physical health increase
    LD          E,0x6                               ; E = 6 spiritual health increase
    JP          PROCESS_CHAOS_POTION                ; Process the chaos potion

;==============================================================================
; WHT_CHAOS_CHK - Process white large potion (random effect)
;==============================================================================
; Handles white chaos potion (level 3) which has one of four random effects:
; Case 0: +20 physical health
; Case 1: +12 spiritual health
; Case 2: Full heal + 10 phys + 6 sprt bonus
; Case 3: Cursed (-30/-15 phys, -15/-7 sprt current/max)
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = Random value (0-3 after mask)
; ---  End  ---
;   Jumps to PROCESS_CHAOS_POTION or continues to case 3
;
; Memory Modified: Health values (varies by case)
; Calls: MAKE_RANDOM_BYTE, PROCESS_CHAOS_POTION (cases 0-2), TOTAL_HEAL (case 2), health reduction routines (case 3)
;==============================================================================
WHT_CHAOS_CHK:
    CALL        MAKE_RANDOM_BYTE                    ; Get semi-random number in A
    AND         0x3                                 ; Mask to 0-3 for 4 cases
    DEC         A                                   ; Test for case 0
    JP          NZ,WHT_CHAOS_SPRT_HEAL              ; If not case 0, check case 1

;------------------------------------------------------------------------------
; WHT_CHAOS_PHYS_HEAL - White potion case 0: +20 physical health (fall-through)
;------------------------------------------------------------------------------
WHT_CHAOS_PHYS_HEAL:
    LD          E,0x0                               ; Case 0: E = 0 spiritual increase
    LD          BC,$20                              ; BC = 20 physical increase (BCD)
    JP          PROCESS_CHAOS_POTION                ; Process with these values

;==============================================================================
; WHT_CHAOS_SPRT_HEAL - White potion case 1: +12 spiritual health
;==============================================================================
; Handles white chaos potion random case 1 which grants +12 spiritual health
; with no physical health increase.
;
; Registers:
; --- Start ---
;   A  = 0 after DEC (case 1)
; ---  End  ---
;   BC = 0, E = $12
;
; Memory Modified: None directly (PROCESS_CHAOS_POTION handles updates)
; Calls: WHT_CHAOS_FULL_HEAL (if not case 1), PROCESS_CHAOS_POTION (jump)
;==============================================================================
WHT_CHAOS_SPRT_HEAL:
    DEC         A                                   ; Test for case 1
    JP          NZ,WHT_CHAOS_FULL_HEAL              ; If not case 1, check case 2
    LD          BC,0x0                              ; Case 1: BC = 0 physical increase
    LD          E,$12                               ; E = 12 spiritual increase (BCD)
    JP          PROCESS_CHAOS_POTION                ; Process with these values

;==============================================================================
; WHT_CHAOS_FULL_HEAL - White potion case 2: Full heal + bonus
;==============================================================================
; Handles white chaos potion random case 2 which performs a full heal then
; grants additional +10 physical and +6 spiritual health bonus.
;
; Registers:
; --- Start ---
;   A  = 0 after second DEC (case 2)
; ---  End  ---
;   BC = $10, E = $06
;
; Memory Modified: PLAYER_PHYS_HEALTH, PLAYER_SPRT_HEALTH (via TOTAL_HEAL)
; Calls: WHT_CHAOS_CURSED (if not case 2), TOTAL_HEAL, PROCESS_CHAOS_POTION (jump)
;==============================================================================
WHT_CHAOS_FULL_HEAL:
    DEC         A                                   ; Test for case 2
    JP          NZ,WHT_CHAOS_CURSED                 ; If not case 2, must be case 3
    CALL        TOTAL_HEAL                          ; Case 2: Full heal first
    LD          BC,$10                              ; BC = 10 additional physical (BCD)
    LD          E,0x6                               ; E = 6 additional spiritual (BCD)
    JP          PROCESS_CHAOS_POTION                ; Process bonus increases

;==============================================================================
; WHT_CHAOS_CURSED - White potion case 3: Cursed (health reduction)
;==============================================================================
; Handles white chaos potion random case 3 which is cursed. Reduces both
; current health (-30 phys, -15 sprt) and maximum health (-15 phys, -7 sprt).
;
; Health Reductions:
; Current: -30 physical (BCD), -15 spiritual (BCD)
; Maximum: -15 physical (BCD), -7 spiritual (BCD)
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   BC = $30, then $15 (health decreases)
;   E  = $15, then $07 (health decreases)
; ---  End  ---
;   Jumps to PROCESS_POTION_UPDATES
;
; Memory Modified: All health values (current and max)
; Calls: REDUCE_HEALTH_BIG, REDUCE_HEALTH_SMALL, PROCESS_POTION_UPDATES (jump), possibly PLAYER_DIES
;==============================================================================
WHT_CHAOS_CURSED:
    LD          BC,$30                              ; Case 3: BC = 30 physical decrease (BCD)
    LD          E,$15                               ; E = 15 spiritual decrease (BCD)
    CALL        REDUCE_HEALTH_BIG                   ; Reduce current health
    LD          BC,$15                              ; BC = 15 physical max decrease (BCD)
    LD          E,0x7                               ; E = 7 spiritual max decrease (BCD)
    CALL        REDUCE_HEALTH_SMALL                 ; Reduce max health
    JP          PROCESS_POTION_UPDATES              ; Continue with updates

;==============================================================================
; CALC_CURR_PHYS_HEALTH - Add BCD value to current physical and spiritual health
;==============================================================================
; Performs BCD addition to increase both physical and spiritual health with
; overflow capping. Physical health capped at 199 BCD, spiritual at 99 BCD.
;
; BCD Format:
; Physical: 2 bytes (HL) = 0000-0199 (max)
; Spiritual: 1 byte (A) = 00-99 (max)
;
; Registers:
; --- Start ---
;   BC = Phys increase
;   E  = Sprt increase
; --- In Process ---
;   HL = Physical health value
;   A  = Low/high bytes during calc, then spiritual health
; ---  End  ---
;   HL = New physical health
;   A  = New spiritual health
;   F  = Carry clear if no sprt overflow
;
; Memory Modified: PLAYER_PHYS_HEALTH, PLAYER_SPRT_HEALTH
; Calls: UPDATE_HEALTH_VALUES (fall-through)
;==============================================================================
CALC_CURR_PHYS_HEALTH:
    LD          HL,(PLAYER_PHYS_HEALTH)             ; Load current physical health (BCD)
    LD          A,L                                 ; Get low byte (1000s & 100s)
    ADD         A,C                                 ; Add low byte of increase
    DAA                                             ; Decimal adjust (BCD correction)
    LD          L,A                                 ; Store corrected low byte
    LD          A,H                                 ; Get high byte (10s & 1s)
    ADC         A,B                                 ; Add high byte with carry
    DAA                                             ; Decimal adjust (BCD correction)
    CP          0x2                                 ; Check if >= 200
    LD          H,A                                 ; Store corrected high byte
    JP          NZ,UPDATE_HEALTH_VALUES             ; If < 200, continue
    LD          H,0x1                               ; Cap at 199 (high byte)
    LD          L,$99                               ; Cap at 199 (low byte = 99 BCD)

;==============================================================================
; UPDATE_HEALTH_VALUES - Store updated health values with spiritual capping
;==============================================================================
; Stores the calculated physical health to memory and adds spiritual health
; increase with overflow capping at 99 BCD.
;
; Registers:
; --- Start ---
;   HL = New phys health
;   E  = Sprt increase
; --- In Process ---
;   A  = Spiritual health calculation
; ---  End  ---
;   A  = New spiritual health (possibly capped)
;   F  = Carry if overflow occurred
;
; Memory Modified: PLAYER_PHYS_HEALTH, PLAYER_SPRT_HEALTH
; Calls: None
;==============================================================================
UPDATE_HEALTH_VALUES:
    LD          (PLAYER_PHYS_HEALTH),HL             ; Store updated physical health
    LD          A,(PLAYER_SPRT_HEALTH)              ; Load current spiritual health (BCD)
    ADD         A,E                                 ; Add spiritual increase
    DAA                                             ; Decimal adjust (BCD correction)
    LD          (PLAYER_SPRT_HEALTH),A              ; Store updated spiritual health
    RET         NC                                  ; Return if no overflow
    LD          A,$99                               ; Cap spiritual at 99 (BCD)
    LD          (PLAYER_SPRT_HEALTH),A              ; Store capped value
    RET                                             ; Return to caller

;==============================================================================
; CALC_MAX_PHYS_HEALTH - Update max physical health if current exceeds it
;==============================================================================
; Compares current physical health to maximum. If current is higher, updates
; the maximum to match current (player has gained permanent health increase).
;
; Comparison Logic:
; - Compare high bytes first
; - If equal, compare low bytes
; - Update max if current >= max
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = Current physical health
;   BC = Max physical health
;   A  = Comparison bytes
; ---  End  ---
;   HL = Current health (may be stored to max)
;   Falls through to CALC_MAX_SPRT_HEALTH
;
; Memory Modified: PLAYER_PHYS_HEALTH_MAX (if current exceeds it)
; Calls: CALC_MAX_SPRT_HEALTH (fall-through)
;==============================================================================
CALC_MAX_PHYS_HEALTH:
    LD          HL,(PLAYER_PHYS_HEALTH)             ; Load current physical health
    LD          BC,(PLAYER_PHYS_HEALTH_MAX)         ; Load max physical health
    LD          A,H                                 ; Compare high bytes
    CP          B                                   ; Current vs max high byte
    JP          C,CALC_MAX_SPRT_HEALTH              ; If current < max, skip update
    LD          A,L                                 ; Compare low bytes
    CP          C                                   ; Current vs max low byte
    JP          C,CALC_MAX_SPRT_HEALTH              ; If current < max, skip update
    LD          (PLAYER_PHYS_HEALTH_MAX),HL         ; Update max to current (new high)

;==============================================================================
; CALC_MAX_SPRT_HEALTH - Update max spiritual health if current exceeds it
;==============================================================================
; Compares current spiritual health to maximum. If current is higher, updates
; the maximum to match current (player has gained permanent health increase).
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = Pointer to max spiritual health
;   A  = Current spiritual health
; ---  End  ---
;   A  = Current spiritual health
;   F  = Carry if current < max
;
; Memory Modified: PLAYER_SPRT_HEALTH_MAX (if current exceeds it)
; Calls: None
;==============================================================================
CALC_MAX_SPRT_HEALTH:
    LD          HL,PLAYER_SPRT_HEALTH_MAX           ; Point to max spiritual health
    LD          A,(PLAYER_SPRT_HEALTH)              ; Load current spiritual health
    CP          (HL)                                ; Compare current vs max
    RET         C                                   ; Return if current < max
    LD          (HL),A                              ; Update max to current (new high)
    RET                                             ; Return to caller

;==============================================================================
; REDUCE_HEALTH_BIG - Subtract BCD values from current health (may cause death)
;==============================================================================
; Performs BCD subtraction to reduce both physical and spiritual health.
; If either value goes negative (carry set), triggers PLAYER_DIES sequence.
;
; Used by cursed white chaos potion (case 3) to reduce current health.
;
; Registers:
; --- Start ---
;   BC = Phys decrease
;   E  = Sprt decrease
; --- In Process ---
;   HL = Physical health value
;   A  = Low/high bytes during calc, then spiritual health
; ---  End  ---
;   HL = New physical health (if survived)
;   A  = New spiritual health (if survived)
;   Jumps to PLAYER_DIES if health < 0
;
; Memory Modified: PLAYER_PHYS_HEALTH, PLAYER_SPRT_HEALTH (or triggers death)
; Calls: PLAYER_DIES (jump if health goes negative)
;==============================================================================
REDUCE_HEALTH_BIG:
    LD          HL,(PLAYER_PHYS_HEALTH)             ; Load current physical health (BCD)
    LD          A,L                                 ; Get low byte
    SUB         C                                   ; Subtract low byte of decrease
    DAA                                             ; Decimal adjust (BCD correction)
    LD          L,A                                 ; Store result in low byte
    LD          A,H                                 ; Get high byte
    SBC         A,B                                 ; Subtract high byte with borrow
    DAA                                             ; Decimal adjust (BCD correction)
    LD          H,A                                 ; Store result in high byte
    JP          C,PLAYER_DIES                       ; If carry (negative), player dies
    LD          (PLAYER_PHYS_HEALTH),HL             ; Store reduced physical health
    LD          A,(PLAYER_SPRT_HEALTH)              ; Load current spiritual health
    SUB         E                                   ; Subtract spiritual decrease
    DAA                                             ; Decimal adjust (BCD correction)
    JP          C,PLAYER_DIES                       ; If carry (negative), player dies
    LD          (PLAYER_SPRT_HEALTH),A              ; Store reduced spiritual health
    RET                                             ; Return to caller

;==============================================================================
; REDUCE_HEALTH_SMALL - Subtract BCD values from max health (may cause death)
;==============================================================================
; Performs BCD subtraction to reduce maximum physical and spiritual health.
; If either max value goes negative (carry set), triggers PLAYER_DIES sequence.
;
; Used by cursed white chaos potion (case 3) to reduce maximum health.
;
; Registers:
; --- Start ---
;   BC = Phys max decrease
;   E  = Sprt max decrease
; --- In Process ---
;   HL = Max physical health value
;   A  = Low/high bytes during calc, then max spiritual health
; ---  End  ---
;   HL = New max physical health (if survived)
;   A  = New max spiritual health (if survived)
;   Jumps to PLAYER_DIES if max health < 0
;
; Memory Modified: PLAYER_PHYS_HEALTH_MAX, PLAYER_SPRT_HEALTH_MAX (or triggers death)
; Calls: PLAYER_DIES (jump if max health goes negative)
;==============================================================================
REDUCE_HEALTH_SMALL:
    LD          HL,(PLAYER_PHYS_HEALTH_MAX)         ; Load max physical health (BCD)
    LD          A,L                                 ; Get low byte
    SUB         C                                   ; Subtract low byte of decrease
    DAA                                             ; Decimal adjust (BCD correction)
    LD          L,A                                 ; Store result in low byte
    LD          A,H                                 ; Get high byte
    SBC         A,B                                 ; Subtract high byte with borrow
    DAA                                             ; Decimal adjust (BCD correction)
    LD          H,A                                 ; Store result in high byte
    JP          C,PLAYER_DIES                       ; If carry (negative), player dies
    LD          (PLAYER_PHYS_HEALTH_MAX),HL         ; Store reduced max physical health
    LD          A,(PLAYER_SPRT_HEALTH_MAX)          ; Load max spiritual health
    SUB         E                                   ; Subtract spiritual decrease
    DAA                                             ; Decimal adjust (BCD correction)
    JP          C,PLAYER_DIES                       ; If carry (negative), player dies
    LD          (PLAYER_SPRT_HEALTH_MAX),A          ; Store reduced max spiritual health
    RET                                             ; Return to caller

;==============================================================================
; PLAYER_DIES - Handle player death sequence
;==============================================================================
; Triggered when player health drops to zero or below. Displays death screen,
; clears health values, and transitions to screen saver mode.
;
; Death Sequence:
; 1. Black out viewport (24×24)
; 2. Display "YOU DIED" text
; 3. Zero all health values
; 4. Update stats display
; 5. Call cleanup subroutine
; 6. Brief delay
; 7. Enter screen saver mode
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   HL = Screen/color RAM addresses, health values
;   BC = Rectangle size
;   DE = Text data pointer
;   A  = Color values, input state, health zeros
;   B  = Graphics index
; ---  End  ---
;   Jumps to SCREEN_SAVER_FULL_SCREEN (does not return)
;
; Memory Modified: Viewport colors, CHRRAM_YOU_DIED_IDX, COMBAT_BUSY_FLAG, all health values, MULTIPURPOSE_BYTE, SCREENSAVER_STATE
; Calls: FILL_CHRCOL_RECT, GFX_DRAW, REDRAW_STATS, PLAY_PITCH_DOWN_SLOW, SLEEP_ZERO, SCREEN_SAVER_FULL_SCREEN (jump)
;==============================================================================
PLAYER_DIES:
    LD          HL,COLRAM_VIEWPORT_IDX              ; Point to viewport color RAM
    LD          BC,RECT(24,24)                      ; 24x24 rectangle size
    LD          A,COLOR(BLK,BLK)                    ; Black on black color
    CALL        FILL_CHRCOL_RECT                    ; Fill viewport with black

    LD          HL,CHRRAM_END_TEXT_IDX              ; Point to END_TEXT_IDX
    LD          DE,PLAYER_DIES_TEXT                 ; Point to PLAYER_DIES_TEXT data
    LD          B,COLOR(RED,BLK)                    ; RED on BLK
    CALL        GFX_DRAW                            ; Draw "YOU DIED" text

    LD          HL,CHRRAM_PLAYER_SKELETON_TEXT
    LD          DE,PLAYER_SKELETON_TEXT
    LD          B,COLOR(BLU,BLK)
    CALL        GFX_DRAW

    LD          HL,CHRRAM_FINAL_SKELETON_IDX
    LD          DE,PLAYER_AS_SKELETON
    LD          B,COLOR(GRY,BLK)
    CALL        GFX_DRAW

    LD          HL,0x0                              ; Zero value
    LD          (PLAYER_PHYS_HEALTH),HL             ; Set physical health to 0
    XOR         A                                   ; A = 0
    LD          (PLAYER_SPRT_HEALTH),A              ; Set spiritual health to 0
    LD          (DIFFICULTY_LEVEL),A                ; Clear DIFFICULTY_LEVEL
    CALL        REDRAW_STATS                        ; Update stats display
    LD          A,$32                               ; Value $32
    LD          (PLAYER_MELEE_STATE),A              ; Store to PLAYER_MELEE_STATE
    CALL        PLAY_PITCH_DOWN_SLOW                ; Play slow pitch-down sound
    CALL        SLEEP_ZERO                          ; Wait/delay function
    JP          SCREEN_SAVER_FULL_SCREEN            ; Jump to screen saver

;==============================================================================
; DO_USE_PHYS_POTION - Consume small physical potion (visual color effect)
;==============================================================================
; Handles small physical potion consumption by playing sound and changing
; health stat display colors to indicate potion level. Does not modify health
; values, only visual presentation.
;
; Color Mapping:
; Level 0 (red) → Color 1
; Level 1 (yellow) → Color 2
; Level 2 (magenta) → Color 3
; Level 3 (white) → Color 4
;
; Registers:
; --- Start ---
;   B  = Potion level (0-3)
; --- In Process ---
;   H,L = Color values
;   B  = Level+1 (color value 1-4)
; ---  End  ---
;   Jumps to PROCESS_POTION_UPDATES
;
; Memory Modified: COLRAM_PHYS_STATS_1000, COLRAM_PHYS_STATS_10, COLRAM_SPRT_STATS_10, COLRAM_SPRT_STATS_1
; Calls: PLAY_USE_PHYS_POTION_SOUND, PROCESS_POTION_UPDATES (jump)
;==============================================================================
DO_USE_PHYS_POTION:
    CALL        PLAY_USE_PHYS_POTION_SOUND          ; Play potion usage sound (3x SOUND_03)
    INC         B                                   ; Convert level (0-3) to color value (1-4)
    LD          H,B                                 ; H = color value
    LD          L,B                                 ; L = color value (both bytes)
    LD          (COLRAM_PHYS_STATS_1000),HL         ; Set phys health color (1000s/100s)
    LD          (COLRAM_PHYS_STATS_10),HL           ; Set phys health color (10s/1s)
    LD          H,COLOR(DKGRN,BLK)                  ; H = dark green on black
    LD          L,H                                 ; L = dark green on black
    LD          (COLRAM_SPRT_STATS_10),HL           ; Set sprt health color (10s) to dark green
    LD          (COLRAM_SPRT_STATS_1),HL            ; Set sprt health color (1s) to dark green
    JP          PROCESS_POTION_UPDATES              ; Continue with potion processing

;==============================================================================
; DO_USE_SPRT_POTION - Consume small spiritual potion (visual color effect)
;==============================================================================
; Handles small spiritual potion consumption by playing sound and changing
; health stat display colors to indicate potion level. Does not modify health
; values, only visual presentation.
;
; Color Mapping:
; Level 0 (red) → Color 1
; Level 1 (yellow) → Color 2
; Level 2 (magenta) → Color 3
; Level 3 (white) → Color 4
;
; Registers:
; --- Start ---
;   B  = Potion level (0-3)
; --- In Process ---
;   H,L = Color values
;   B  = Level+1 (color value 1-4)
; ---  End  ---
;   Jumps to PROCESS_POTION_UPDATES
;
; Memory Modified: COLRAM_SPRT_STATS_10, COLRAM_SPRT_STATS_1, COLRAM_PHYS_STATS_1000, COLRAM_PHYS_STATS_10
; Calls: PLAY_USE_PHYS_POTION_SOUND, PROCESS_POTION_UPDATES (jump)
;==============================================================================
DO_USE_SPRT_POTION:
    CALL        PLAY_USE_PHYS_POTION_SOUND          ; Play potion usage sound (3x SOUND_03)
    INC         B                                   ; Convert level (0-3) to color value (1-4)
    LD          H,B                                 ; H = color value
    LD          L,B                                 ; L = color value (both bytes)
    LD          (COLRAM_SPRT_STATS_10),HL           ; Set sprt health color (10s)
    LD          (COLRAM_SPRT_STATS_1),HL            ; Set sprt health color (1s)
    LD          H,COLOR(DKGRN,BLK)                  ; H = dark green on black
    LD          L,H                                 ; L = dark green on black
    LD          (COLRAM_PHYS_STATS_1000),HL         ; Set phys health color (1000s/100s) to dark green
    LD          (COLRAM_PHYS_STATS_10),HL           ; Set phys health color (10s/1s) to dark green
    JP          PROCESS_POTION_UPDATES              ; Continue with potion processing

;==============================================================================
; USE_KEY - Use key to unlock door and generate treasure
;==============================================================================
; Handles key item usage on locked chests. Validates key level against chest level,
; then generates random treasure item to replace the chest on the map.
;
; Door Code Validation:
; - Extract chest type and level from ITEM_S0
; - Must be chest type ($14 base code)
; - Key level must be >= chest level
;
; Treasure Generation:
; - Uses R register for randomness
; - Generates item code from range $1D-$23 (plus adjustments)
; - Special case: Level 4 chests give chaos potion instead of key
; - Level adjustment algorithm for lower-level chests
;
; Registers:
; --- Start ---
;   B   = Key level
; --- In Process ---
;   A   = Chest code, type, level calculations, random values, final item code
;   BC  = Item map address (from ITEM_MAP_CHECK)
;   C   = Chest level, loop counter
;   AF' = Item code (saved during map lookup)
; ---  End  ---
;   Jumps to INIT_MELEE_ANIM or UPDATE_VIEWPORT (does not return)
;
; Memory Modified: Map item at PLAYER_MAP_POS
; Calls: NO_ACTION_TAKEN (if invalid), UPDATE_SCR_SAVER_TIMER, ITEM_MAP_CHECK, INIT_MELEE_ANIM or UPDATE_VIEWPORT (jumps)
;==============================================================================

USE_KEY:
    LD          A,(GAME_BOOLEANS)                   ; Load game state flags
    BIT         0x3,A                               ; Check bit 3 (key owned flag)
    JP          Z,NO_ACTION_TAKEN                   ; If not owned, exit without action
    LD          A,(KEY_INV_SLOT)                    ; Load key level (0-4)
    LD          B,A                                 ; Save key level to B
    AND         A                                   ; Test if zero (no map)
    JP          Z,INIT_MN_MELEE_ANIM                ; If no key slot, exit to melee animation

    LD          A,(ITEM_S0)                         ; Load sprite at current position (S0)
    LD          C,0x0                               ; Initialize C = 0
    SRL         A                                   ; Shift right 1 bit
    RR          C                                   ; Rotate right through C
    SRL         A                                   ; Shift right again (total 2 bits)
    RL          C                                   ; Rotate left through C
    RL          C                                   ; Rotate left again (extract level)
    CP          $14                                 ; Compare to $14 (chest base code)
    JP          NZ,NO_ACTION_TAKEN                  ; If not a chest, no action

    DEC         B

    LD          A,B                                 ; A = key level (from item)
    CP          C                                   ; Compare key level to chest level
    JP          C,NO_ACTION_TAKEN                   ; If key < chest level, can't unlock
    LD          A,C                                 ; A = chest level
    LD          B,A                                 ; B = chest level
    AND         A                                   ; Test if zero (lowest level)
    JP          Z,GEN_RANDOM_ITEM                   ; If level 0, skip loop
    CALL        UPDATE_SCR_SAVER_TIMER              ; Reset screen saver timer
    INC         C                                   ; C = chest level + 1

;==============================================================================
; NORM_LEVEL_LOOP - Level adjustment normalization loop
;==============================================================================
; Repeatedly subtracts (chest_level + 1) from chest level until underflow,
; then adds back to get normalized remainder. Part of treasure item level
; calculation for unlocked chests.
;
; Registers:
; --- Start ---
;   A  = Chest level
;   C  = Chest level + 1
; --- In Process ---
;   A  = Iteratively reduced
; ---  End  ---
;   A  = Remainder after normalization
;   F  = Carry set from final subtraction
;
; Memory Modified: None
; Calls: Falls through to GEN_RANDOM_ITEM
;==============================================================================
NORM_LEVEL_LOOP:
    SUB         C                                   ; Subtract (door level + 1)
    JP          NC,NORM_LEVEL_LOOP                  ; Loop while no borrow
    ADD         A,C                                 ; Add back to get remainder
    LD          B,A                                 ; B = adjusted level

;==============================================================================
; GEN_RANDOM_ITEM - Generate random treasure item type
;==============================================================================
; Uses R register (memory refresh) for semi-random number generation to
; determine which treasure item to place. Normalizes random value to 0-6
; range, then adds base offset $1D for item type.
;
; Random Value Processing:
; - Get R register (0-127, semi-random)
; - Mask to 0-7
; - Normalize to 0-6 range via subtraction loop
; - Add $1D base offset for item type
;
; Registers:
; --- Start ---
;   B  = Chest level
;   C  = Chest level data
; --- In Process ---
;   A  = R register, masked, normalized
; ---  End  ---
;   A  = Item type base + random offset
;
; Memory Modified: None
; Calls: CHK_RANDOM_ZERO, GEN_KEY_OR_POTION (special cases), ENCODE_PLACE_ITEM (fall-through)
;==============================================================================
GEN_RANDOM_ITEM:
    LD          A,R                                 ; Get semi-random value from refresh register
    AND         0x7                                 ; Mask to 0-7

;==============================================================================
; CHK_RANDOM_ZERO - Random value zero check and normalization
;==============================================================================
; Checks if random value is zero (special case), otherwise normalizes to
; 0-6 range by subtracting 7 until underflow.
;
; Registers:
; --- Start ---
;   A  = Random (0-7)
; ---  End  ---
;   A  = Normalized (0-6) + $1D offset, or jumps to special handler
;
; Memory Modified: None
; Calls: GEN_KEY_OR_POTION (if zero), NORMALIZE_RANDOM (normalization loop), ENCODE_PLACE_ITEM (fall-through)
;==============================================================================
CHK_RANDOM_ZERO:
    JP          Z,GEN_KEY_OR_POTION                 ; If 0, handle special case
    SUB         0x7                                 ; Subtract 7

;==============================================================================
; NORMALIZE_RANDOM - Normalize random value to 0-6 range
;==============================================================================
; Repeatedly subtracts 7 until underflow, ensuring value is in 0-6 range.
; Then adds $1D base offset for item type codes.
;
; Registers:
; --- Start ---
;   A  = Random value
; ---  End  ---
;   A  = Item type ($1D-$23)
;
; Memory Modified: None
; Calls: ENCODE_PLACE_ITEM (fall-through)
;==============================================================================
NORMALIZE_RANDOM:
    JP          NC,CHK_RANDOM_ZERO                  ; Loop while >= 7 (normalize to 0-6)
    ADD         A,$1d                               ; Add $1D base offset

;==============================================================================
; ENCODE_PLACE_ITEM - Encode item code with level and place on map
;==============================================================================
; Encodes the final item code by combining item type (in A) with level bits
; (in B) using bit rotation operations, then places the encoded item on the
; map at the player's current position.
;
; Item Encoding Formula: (Type << 2) | Level
; - Type in bits 7-2
; - Level in bits 1-0
;
; Bit Manipulation:
; 1. Extract level bits from B via RR operations
; 2. Shift type left via RLA operations
; 3. Combine via rotations through carry flag
;
; Registers:
; --- Start ---
;   A  = Item type
;   B  = Item level
; --- In Process ---
;   A  = Encoded item (type<<2 | level)
;   BC = Map address (from ITEM_MAP_CHECK)
;   C  = Temporary for bit rotations
;   AF' = Encoded item (preserved during map lookup)
; ---  End  ---
;   Jumps to INIT_MELEE_ANIM or UPDATE_VIEWPORT (does not return)
;
; Memory Modified: Map item at player position
; Calls: ITEM_MAP_CHECK, INIT_MELEE_ANIM or UPDATE_VIEWPORT (jumps)
;==============================================================================
ENCODE_PLACE_ITEM:
    RR          B                                   ; Rotate B right (level bits)
    RR          C                                   ; Rotate C right
    RR          B                                   ; Rotate B right again
    RLA                                             ; Rotate A left (item type)
    RL          C                                   ; Rotate C left
    RLA                                             ; Rotate A left again
    EX          AF,AF'                              ; Save AF to alternate set
    LD          A,(PLAYER_MAP_POS)                  ; Load player's map position
    CALL        ITEM_MAP_CHECK                      ; Get item map address in BC
    EX          AF,AF'                              ; Restore AF from alternate set
    LD          (BC),A                              ; Store item code at map position
    LD          A,(COMBAT_BUSY_FLAG)                ; Check combat state
    AND         A                                   ; Test if in combat
    JP          NZ,INIT_MN_MELEE_ANIM               ; If in combat, init animation
    JP          UPDATE_VIEWPORT                     ; Otherwise update viewport

;==============================================================================
; GEN_KEY_OR_POTION - Special case: Random 0 gives key or chaos potion
;==============================================================================
; Handles special treasure case when random value is 0. Generates either a
; key (for doors level 0-3) or chaos potion (for level 4 doors).
;
; Door Level Mapping:
; - Level 0-3: Generate key of same level
; - Level 4: Generate level 3 chaos potion instead
;
; Registers:
; --- Start ---
;   C  = Door level
; --- In Process ---
;   A  = Door level comparison, then item type
;   B  = Item level
; ---  End  ---
;   Jumps to ENCODE_PLACE_ITEM (does not return)
;
; Memory Modified: None directly (ENCODE_PLACE_ITEM handles map update)
; Calls: GEN_CHAOS_POTION (if level 4), ENCODE_PLACE_ITEM (jump)
;==============================================================================
GEN_KEY_OR_POTION:
    LD          A,C                                 ; A = door level from C
    CP          0x4                                 ; Compare to 4
    JP          Z,GEN_CHAOS_POTION                  ; If level 4, special case
    LD          B,A                                 ; B = door level
    LD          A,$16                               ; A = $16 (key item base)
    JP          ENCODE_PLACE_ITEM                   ; Jump to encode and place item

;==============================================================================
; GEN_CHAOS_POTION - Level 4 door gives chaos potion
;==============================================================================
; Special handler for level 4 doors when random treasure is key slot.
; Gives level 3 chaos potion instead of a level 4 key.
;
; Registers:
; --- Start ---
;   None specific
; ---  End  ---
;   A  = $1C
;   B  = 3
;   Jumps to ENCODE_PLACE_ITEM
;
; Memory Modified: None directly (ENCODE_PLACE_ITEM handles map update)
; Calls: ENCODE_PLACE_ITEM (jump)
;==============================================================================
GEN_CHAOS_POTION:
    LD          B,0x3                               ; B = 3 (level 3)
    LD          A,$1c                               ; A = $1C (chaos potion base)
    JP          ENCODE_PLACE_ITEM                   ; Jump to encode and place item

;==============================================================================
; USE_SOMETHING_ELSE - Handle non-potion/non-key item usage
;==============================================================================
; Dispatcher for weapons and special items (bow, scroll, staff, crossbow,
; melee weapons, ladder, door). Validates usage context (wall state, target
; presence) before routing to appropriate handler.
;
; Item Categories:
; - Ranged weapons: Bow (6), Crossbow ($0C)
; - Magic: Scroll (7), Staff ($0B)
; - Melee: Sword/Axe/Mace (8-$A)
; - Special: Ladder ($10-$11), Door ($14)
;
; Registers:
; --- Start ---
;   AF' = Item type from DO_USE_ATTACK
; --- In Process ---
;   A  = Wall state, item checks, comparisons
; ---  End  ---
;   Jumps to various handlers (does not return)
;
; Memory Modified: Varies by weapon handler
; Calls: CHECK_FOR_NON_ITEMS, CHECK_FOR_END_ITEM, CHECK_IF_BOW_XBOW, etc.
;==============================================================================
USE_SOMETHING_ELSE:
    EX          AF,AF'                              ; Swap to alternate AF register
    LD          A,(WALL_F0_STATE)                   ; Load wall state at position F0
    AND         A                                   ; Test if wall exists
    JP          Z,CHECK_FOR_NON_ITEMS               ; If no wall, check for items/monsters
    BIT         0x2,A                               ; Test bit 2 of wall state
    JP          Z,CHECK_FOR_END_ITEM                ; If bit 2 clear, check end item

;==============================================================================
; CHECK_FOR_NON_ITEMS - Validate target exists at F1 (monster or item)
;==============================================================================
; Checks if there's a valid target at position F1 for weapon usage.
; Distinguishes between empty space, items, and monsters.
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = ITEM_S1 value
; ---  End  ---
;   Jumps to next handler
;
; Memory Modified: None
; Calls: CHECK_FOR_END_ITEM or CHECK_IF_BOW_XBOW (jumps)
;==============================================================================
CHECK_FOR_NON_ITEMS:
    LD          A,(ITEM_S1)                         ; Load sprite at position S1
    CP          $fe                                 ; Compare to $FE (empty)
    JP          Z,CHECK_FOR_END_ITEM                ; If empty, check end item
    CP          $78                                 ; Compare to $78 (monster base)
    JP          NC,CHECK_IF_BOW_XBOW                ; If >= $78 (monster), check weapon

;==============================================================================
; CHECK_FOR_END_ITEM - Validate end marker for special item usage
;==============================================================================
; Checks if right-hand item is the end marker ($FF), which is valid for
; ladder/door usage during combat. Falls through to weapon checks if not.
;
; Registers:
; --- Start ---
;   AF' = Item type
; --- In Process ---
;   A  = Item type (swapped from AF')
; ---  End  ---
;   Jumps to NO_ACTION_TAKEN or falls through
;
; Memory Modified: None
; Calls: NO_ACTION_TAKEN (if not $FF), CHECK_IF_BOW_XBOW (fall-through)
;==============================================================================
CHECK_FOR_END_ITEM:
    EX          AF,AF'                              ; Swap back to main AF register
    CP          $ff                                 ; Compare to $FF (end marker)
    JP          NZ,NO_ACTION_TAKEN                  ; If not end marker, no action
    EX          AF,AF'                              ; Swap to alternate AF again

;==============================================================================
; CHECK_IF_BOW_XBOW - Route to bow/crossbow handler if item type matches
;==============================================================================
; Checks if right-hand item is a bow (type 6). If so, routes to bow/crossbow
; usage handler. Otherwise checks for scroll/staff.
;
; Registers:
; --- Start ---
;   AF' swapped, A = item type
; --- In Process ---
;   A  = Item type comparison
; ---  End  ---
;   Jumps to handler
;
; Memory Modified: None
; Calls: USE_BOW_XBOW or CHECK_IF_SCROLL_STAFF (jumps)
;==============================================================================
CHECK_IF_BOW_XBOW:
    EX          AF,AF'                              ; Swap back to main AF register
    CP          0x6                                 ; Compare to 6 (bow item type)
    JP          NZ,CHECK_IF_SCROLL_STAFF            ; If not bow, check scroll/staff

;==============================================================================
; USE_BOW_XBOW - Fire bow or crossbow (consumes arrow, may break)
;==============================================================================
; Handles bow/crossbow usage by consuming an arrow from inventory and
; checking for weapon breakage. Sets up arrow animation for combat.
;
; Requirements:
; - At least 1 arrow in ARROW_INV
; - Valid target at F1 (checked by caller)
;
; Breakage:
; - CHK_ITEM_BREAK determines if weapon breaks
; - If broken, clear right hand ($FE)
;
; Registers:
; --- Start ---
;   BC = Item level
; --- In Process ---
;   A  = Arrow count
;   BC = Saved/restored around CHK_ITEM_BREAK
; ---  End  ---
;   D  = 5
;   Jumps to SETUP_ITEM_ANIM
;
; Memory Modified: ARROW_INV, possibly RIGHT_HAND_ITEM
; Calls: NO_ACTION_TAKEN (if no arrows), CHK_ITEM_BREAK, SETUP_ITEM_ANIM (jump)
;==============================================================================
USE_BOW_XBOW:
    PUSH        BC                                  ; Save BC (item level)
    LD          A,(ARROW_INV)                       ; Load arrow inventory count
    SUB         0x1                                 ; Decrement by 1
    JP          C,NO_ACTION_TAKEN                   ; If < 0 (no arrows), no action
    LD          (ARROW_INV),A                       ; Store decremented arrow count
    CALL        REDRAW_ARROWS_GRAPH                 ; Redraw arrows inv graphic
    CALL        CHK_ITEM_BREAK                      ; Check if bow/crossbow breaks
    POP         BC                                  ; Restore BC (item level)
    JP          NC,BOW_XBOW_NO_BREAK                ; If no break, continue
    LD          A,$fe                               ; A = $FE (empty item marker)
    LD          (RIGHT_HAND_ITEM),A                 ; Clear right hand (bow broke)

;==============================================================================
; BOW_XBOW_NO_BREAK - Setup arrow animation
;==============================================================================
; Sets animation type to 5 (arrow/bolt) and jumps to animation setup.
;
; Registers:
; ---  End  ---
;   D  = 5
;
; Memory Modified: None
; Calls: SETUP_ITEM_ANIM (jump)
;==============================================================================
BOW_XBOW_NO_BREAK:
    LD          D,0x5                               ; D = 5 (bow/arrow animation type)
    JP          SETUP_PL_ANIM                       ; Jump to setup animation

;==============================================================================
; CHECK_IF_SCROLL_STAFF - Route to scroll/staff handler if type matches
;==============================================================================
; Checks if right-hand item is a scroll (type 7). If so, routes to
; scroll/staff usage handler. Otherwise checks other weapon types.
;
; Registers:
; --- In Process ---
;   A  = Item type comparison
; ---  End  ---
;   Jumps to handler
;
; Memory Modified: None
; Calls: USE_SCROLL_STAFF or CHECK_OTHERS (jumps)
;==============================================================================
CHECK_IF_SCROLL_STAFF:
    CP          0x7                                 ; Compare to 7 (scroll item type)
    JP          NZ,CHECK_OTHERS                     ; If not scroll, check other items

;==============================================================================
; USE_SCROLL_STAFF - Cast fireball spell (may break scroll/staff)
;==============================================================================
; Handles scroll/staff usage by checking for item breakage and setting up
; fireball animation for combat.
;
; Breakage:
; - CHK_ITEM_BREAK determines if scroll/staff breaks
; - If broken, clear right hand ($FE)
;
; Registers:
; --- Start ---
;   BC = Item level
; --- In Process ---
;   A  = $FE if broke
;   BC = Saved/restored around CHK_ITEM_BREAK
; ---  End  ---
;   D  = 9
;   Jumps to SETUP_ITEM_ANIM
;
; Memory Modified: Possibly RIGHT_HAND_ITEM
; Calls: CHK_ITEM_BREAK, SETUP_ITEM_ANIM (jump)
;==============================================================================
USE_SCROLL_STAFF:
    PUSH        BC                                  ; Save BC (item level)
    CALL        CHK_ITEM_BREAK                      ; Check if scroll/staff breaks
    POP         BC                                  ; Restore BC (item level)
    JP          NC,SCROLL_STAFF_NO_BREAK            ; If no break, continue
    LD          A,$fe                               ; A = $FE (empty item marker)
    LD          (RIGHT_HAND_ITEM),A                 ; Clear right hand (scroll/staff broke)

;==============================================================================
; SCROLL_STAFF_NO_BREAK - Setup fireball animation
;==============================================================================
; Sets animation type to 9 (fireball) and jumps to animation setup.
;
; Registers:
; ---  End  ---
;   D  = 9
;
; Memory Modified: None
; Calls: SETUP_ITEM_ANIM (jump)
;==============================================================================
SCROLL_STAFF_NO_BREAK:
    LD          D,0x9                               ; D = 9 (fireball animation type)
    JP          SETUP_PL_ANIM                       ; Jump to setup animation

;==============================================================================
; CHECK_OTHERS - Route staff/crossbow/melee/special items
;==============================================================================
; Handles remaining item types by checking for staff ($0B), crossbow ($0C),
; melee weapons (6-$F), or special items (ladder $10-$11, door $14).
;
; Item Type Routing:
; - $0B (staff) → USE_SCROLL_STAFF
; - $0C (crossbow) → USE_BOW_XBOW
; - 6-$F (melee) → Animation setup with item type as D
; - $10-$14 (special) → CHK_SPECIAL_ITEM handler
;
; Registers:
; --- In Process ---
;   A  = Item type comparisons
;   D  = Item type (for animation)
; ---  End  ---
;   Jumps to various handlers
;
; Memory Modified: None directly
; Calls: USE_SCROLL_STAFF, USE_BOW_XBOW, SETUP_ITEM_ANIM, CHK_SPECIAL_ITEM, NO_ACTION_TAKEN (jumps)
;==============================================================================
CHECK_OTHERS:
    CP          0xb                                 ; Compare to $0B (staff item type)
    JP          Z,USE_SCROLL_STAFF                  ; If staff, use as scroll/staff
    CP          0xc                                 ; Compare to $0C (crossbow item type)
    JP          Z,USE_BOW_XBOW                      ; If crossbow, use as bow/crossbow
    CP          0x6                                 ; Compare to 6 (bow)
    JP          C,NO_ACTION_TAKEN                   ; If < 6, no action
    CP          $10                                 ; Compare to $10 (ladder)
    JP          NC,CHK_SPECIAL_ITEM                 ; If >= $10, jump to special handler
    LD          D,A                                 ; D = item type (for animation)
    CALL        SWAP_TO_ALT_REGS                    ; Swap to alternate registers

;==============================================================================
; SETUP_PL_ANIM - Setup player animation and initialize combat
;==============================================================================
; Common entry point for weapon usage. Sets up item animation parameters
; and initializes monster combat sequence.
;
; Registers:
; --- Start ---
;   D  = Animation type
;   B  = Item level
; ---  End  ---
;   Jumps to INIT_MONSTER_COMBAT
;
; Memory Modified: Animation state variables
; Calls: SETUP_ITEM_ANIMATION, INIT_MONSTER_COMBAT (jump)
;==============================================================================
SETUP_PL_ANIM:
    CALL        INIT_PL_MELEE_ANIM                  ; Setup item animation parameters
    JP          INIT_MONSTER_COMBAT                 ; Initialize monster combat

CLEAR_RIGHT_ITEM_AND_SETUP_ANIM:
    CALL        SWAP_TO_ALT_REGS                    ; Swap to alternate register set

;==============================================================================
; INIT_PL_MELEE_ANIM - Configure player sprite animation parameters
;==============================================================================
; Initializes all animation state variables for weapon/item usage animation.
; Calculates sprite index from item type and level, sets loop count, and
; configures graphics memory pointers.
;
; Sprite Index Calculation: (Type * 4) + Level
; - Types: 5=arrow, 6=sword, 7=axe, 8=mace, 9=fireball, etc.
; - Levels: 0-3
; - Result: Sprite frames 0-63
;
; Registers:
; --- Start ---
;   D  = Item type
;   B  = Item level
; --- In Process ---
;   A  = State value, sprite calculation
;   HL = Loop count, graphics pointer
; ---  End  ---
;   Jumps to COPY_RH_ITEM_FRAME_GFX
;
; Memory Modified: ITEM_ANIM_STATE, ITEM_SPRITE_INDEX, ITEM_ANIM_LOOP_COUNT, ITEM_ANIM_CHRRAM_PTR, SCREENSAVER_STATE
; Calls: COPY_RH_ITEM_FRAME_GFX (jump)
;==============================================================================
INIT_PL_MELEE_ANIM:
    LD          A,0x3                               ; A = 3 (animation state)
    LD          (PLAYER_ANIM_STATE),A               ; Store animation state
    LD          A,D                                 ; A = item type
    SLA         A                                   ; Shift left (multiply by 2)
    SLA         A                                   ; Shift left again (multiply by 4)
    OR          B                                   ; OR with item level (bits 0-1)
    LD          (PLAYER_WEAPON_SPRITE),A            ; Store sprite index (type*4 + level)
    LD          HL,$203                             ; HL = $203 (loop count)
    LD          (PLAYER_ANIM_LOOP_COUNT),HL         ; Store animation loop count
;    LD          HL,CHRRAM_RIGHT_HD_GFX_IDX          ; Point to right-hand graphics area
    LD          HL,CHRRAM_VP_PL_WEAPON_START_IDX    ; Point to new right-hand graphics area   **** CHANGE ME ****
    LD          (PLAYER_WEAPON_CHRRAM_PTR),HL       ; Store graphics pointer
    LD          A,L                                 ; A = low byte of CHRRAM pointer
    LD          (PLAYER_MELEE_STATE),A              ; Store to PLAYER_MELEE_STATE
    JP          DRAW_PLAYER_WEAPON_FRAME            ; Copy frame graphics and return

;==============================================================================
; CHK_SPECIAL_ITEM - Check for ladder or door special items
;==============================================================================
; Validates special item types (ladder $10-$11, door $14) for combat-only
; usage. Routes to appropriate handler.
;
; Registers:
; --- In Process ---
;   A  = Item type comparison
; ---  End  ---
;   Jumps to handler
;
; Memory Modified: None
; Calls: CHK_DOOR_ITEM or USE_LADDER_DOOR_ESCAPE (jumps)
;==============================================================================
CHK_SPECIAL_ITEM:
    CP          $11                                 ; Compare to $11 (ladder up/down)
    JP          NZ,CHK_DOOR_ITEM                    ; If not ladder, check next
    JP          USE_LADDER_DOOR_ESCAPE              ; If ladder, jump to handler

;==============================================================================
; CHK_DOOR_ITEM - Check for door item
;==============================================================================
; Validates door item type ($14) for combat-only usage.
;
; Registers:
; --- In Process ---
;   A  = Item type comparison
; ---  End  ---
;   Jumps to handler
;
; Memory Modified: None
; Calls: NO_ACTION_TAKEN or USE_LADDER_DOOR_ESCAPE (jumps)
;==============================================================================
CHK_DOOR_ITEM:
    CP          $14                                 ; Compare to $14 (door)
    JP          NZ,NO_ACTION_TAKEN                  ; If not door, no action

;==============================================================================
; USE_LADDER_DOOR_ESCAPE - Use ladder/door to escape combat
;==============================================================================
; Handles ladder and door usage during combat. These items allow escape from
; combat by clearing combat flag and setting up escape animation.
;
; Requirements:
; - Must be in combat (COMBAT_BUSY_FLAG != 0)
; - Item must be ladder ($10-$11) or door ($14)
;
; Registers:
; --- Start ---
;   A  = Item type
; --- In Process ---
;   D  = Item type (saved)
;   A  = Combat flag, then 0
; ---  End  ---
;   Jumps to WAIT_FOR_INPUT
;
; Memory Modified: COMBAT_BUSY_FLAG, animation state
; Calls: NO_ACTION_TAKEN (if not in combat), CLEAR_RIGHT_ITEM_AND_SETUP_ANIM, WAIT_FOR_INPUT (jump)
;==============================================================================
USE_LADDER_DOOR_ESCAPE:
    LD          D,A                                 ; D = item type (ladder or door)
    LD          A,(COMBAT_BUSY_FLAG)                ; Load combat state flag
    AND         A                                   ; Test if in combat
    JP          Z,NO_ACTION_TAKEN                   ; If not in combat, no action
    XOR         A                                   ; A = 0 (clear flags)
    LD          (COMBAT_BUSY_FLAG),A                ; Clear combat busy flag
    CALL        CLEAR_RIGHT_ITEM_AND_SETUP_ANIM     ; Setup animation for item
    JP          WAIT_FOR_INPUT                      ; Return to input wait

;==============================================================================
; INIT_MONSTER_COMBAT - Initialize combat with monster at S1
;==============================================================================
; Sets up combat state by extracting monster type and level from ITEM_S1,
; then calculates monster health based on dungeon level and monster stats.
;
; Monster Code Extraction:
; - Bits 0-1: Monster level (0-3)
; - Bits 2-7: Monster type
;
; Health Calculation:
; - Uses dungeon level (BCD) from DUNGEON_LEVEL
; - Extracts low nibble, performs digit rotation (RLD)
; - Adds adjustments based on bit patterns
; - Complex BCD manipulation for final health value
;
; Registers:
; --- Start ---
;   None specific
; --- In Process ---
;   A  = Combat flag, monster code, level digits
;   B  = Monster level extraction, then final level
;   D,E = Level digit components
;   HL = DUNGEON_LEVEL pointer
;   AF' = Monster type (saved)
; ---  End  ---
;   Falls through to CALC_MONSTER_HP or jumps to INIT_MELEE_ANIM
;
; Memory Modified: COMBAT_BUSY_FLAG
; Calls: INIT_MELEE_ANIM (if already in combat), falls through to CALC_MONSTER_HP
;==============================================================================
INIT_MONSTER_COMBAT:
    LD          A,(COMBAT_BUSY_FLAG)                ; Check if already in combat
    AND         A                                   ; Test combat flag
    JP          NZ,INIT_MN_MELEE_ANIM               ; If in combat, init animation
    INC         A                                   ; A = 1
    LD          (COMBAT_BUSY_FLAG),A                ; Set combat flag (block movement)
    LD          A,(ITEM_S1)                         ; Load monster code at position S1
    LD          B,0x0                               ; Initialize B = 0
    SRL         A                                   ; Shift right (extract level bit 0 to carry)
    RR          B                                   ; Rotate carry into B
    RRA                                             ; Rotate A right (extract level bit 1)
    RL          B                                   ; Rotate left through B
    RL          B                                   ; Rotate left again (B now has level 0-3)
    EX          AF,AF'                              ; Save AF (monster type) to alternate
    XOR         A                                   ; A = 0
    LD          HL,DUNGEON_LEVEL                    ; Point to DUNGEON_LEVEL address
    RLD                                             ; Rotate left digit (get low nibble)
    LD          D,A                                 ; D = low nibble of level
    SRL         A                                   ; Shift right
    JP          NC,CALC_MONSTER_HP                  ; If no carry, skip adjustment
    ADD         A,$50                               ; Add $50 BCD adjustment

;==============================================================================
; CALC_MONSTER_HP - Continue monster health calculation
;==============================================================================
; Continues complex BCD-based health calculation for monster, processing
; additional dungeon level digits and performing more adjustments.
;
; Registers:
; --- In Process ---
;   A  = Level digits and calculations
;   D  = Level components
;   E  = Accumulated values
; ---  End  ---
;   Continues processing
;
; Memory Modified: None directly
; Calls: Continues to next calculation stage
;==============================================================================
CALC_MONSTER_HP:
    RLCA                                            ; Rotate left 4 times
    RLCA                                            ; to move low nibble
    RLCA                                            ; to high nibble
    RLCA                                            ; (multiply by 16)
    LD          E,A                                 ; E = shifted value
    LD          A,D                                 ; A = original low nibble
    RLD                                             ; Rotate left digit again
    LD          D,A                                 ; D = next digit
    SRL         A                                   ; Shift right
    ADD         A,E                                 ; Add to E (combine digits)
    ADD         A,0x3                               ; Add base value 3
    DAA                                             ; Decimal adjust (BCD correction)
    LD          C,A                                 ; C = dungeon level damage bonus
    LD          A,D                                 ; A = digit value
    RLD                                             ; Rotate left digit (restore)
    EX          AF,AF'                              ; Restore monster type from alternate

;==============================================================================
; CHK_FOR_SKELETON - Check if monster type is Skeleton ($1E)
;==============================================================================
; Tests if the current monster type code matches Skeleton ($1E). If match,
; sets Skeleton-specific stats: base damage 7, HP 3/4 (SPRT/PHYS BCD),
; spiritual sprite type (magenta), then seeds HP/attack values.
;
; Registers:
; --- Start ---
;   A  = Monster type - $1E
;   B  = Monster level (0-3)
; --- In Process ---
;   D  = Base damage (7)
;   HL = Base HP ($304 = 3 SPRT, 4 PHYS BCD)
;   A  = Sprite calculation ($3C + level)
; ---  End  ---
;   Control transfers to SEED_MONSTER_HP_AND_ATTACK or CHK_FOR_SNAKE
;
; Memory Modified: MELEE_WEAPON_SPRITE (if Skeleton)
; Calls: SEED_MONSTER_HP_AND_ATTACK (if Skeleton)
;==============================================================================
CHK_FOR_SKELETON:
    SUB         $1e                                 ; Subtract $1E (first monster code)
    JP          NZ,CHK_FOR_SNAKE                    ; If not $1E, check next monster
    LD          D,SKELETON_BASE_DMG                 ; Skeleton: base damage
    LD          HL,SKELETON_BASE_HP                 ; Skeleton: base HP (SPRT, PHYS in BCD)
    LD          A,SKELETON_WEAPON_SPRITE            ; Skeleton: weapon sprite base
    ADD         A,B                                 ; Add level (0-3) for sprite index
    LD          (MONSTER_WEAPON_SPRITE),A           ; Store sprite frame index
    JP          SEED_MONSTER_HP_AND_ATTACK          ; Jump to seed HP and attack
CHK_FOR_SNAKE:
    DEC         A                                   ; Test for Snake ($1F)
    JP          NZ,CHK_FOR_SPIDER                   ; If not $1F, check next
    LD          D,SNAKE_BASE_DMG                    ; Snake: base damage
    LD          HL,SNAKE_BASE_HP                    ; Snake: base HP (SPRT, PHYS in BCD)
    LD          A,SNAKE_WEAPON_SPRITE               ; Snake: weapon sprite base
    ADD         A,B                                 ; Add level (0-3) for sprite index
    LD          (MONSTER_WEAPON_SPRITE),A           ; Store sprite frame index
    JP          SEED_MONSTER_HP_AND_ATTACK          ; Jump to seed HP and attack
CHK_FOR_SPIDER:
    DEC         A                                   ; Test for Spider ($20)
    JP          NZ,CHK_FOR_MIMIC                    ; If not $20, check next
    LD          D,SPIDER_BASE_DMG                   ; Spider: base damage
    LD          HL,SPIDER_BASE_HP                   ; Spider: base HP (SPRT, PHYS in BCD)
    LD          A,SPIDER_WEAPON_SPRITE              ; Spider: weapon sprite base
    ADD         A,B                                 ; Add level (0-3) for sprite index
    LD          (MONSTER_WEAPON_SPRITE),A           ; Store sprite frame index
    JP          SEED_MONSTER_HP_AND_ATTACK          ; Jump to seed HP and attack
CHK_FOR_MIMIC:
    DEC         A                                   ; Test for Mimic ($21)
    JP          NZ,CHK_FOR_MALOCCHIO                ; If not $21, check next
    LD          D,MIMIC_BASE_DMG                    ; Mimic: base damage
    LD          HL,MIMIC_BASE_HP                    ; Mimic: base HP (SPRT, PHYS in BCD)
    LD          A,MIMIC_WEAPON_SPRITE               ; Mimic: weapon sprite base
    ADD         A,B                                 ; Add level (0-3) for sprite index
    LD          (MONSTER_WEAPON_SPRITE),A           ; Store sprite frame index
    JP          SEED_MONSTER_HP_AND_ATTACK          ; Jump to seed HP and attack
CHK_FOR_MALOCCHIO:
    DEC         A                                   ; Test for Malocchio ($22)
    JP          NZ,CHK_FOR_DRAGON                   ; If not $22, check next
    LD          D,MALOCCHIO_BASE_DMG                ; Malocchio: base damage
    LD          HL,MALOCCHIO_BASE_HP                ; Malocchio: base HP (SPRT, PHYS in BCD)
    LD          A,MALOCCHIO_WEAPON_SPRITE           ; Malocchio: weapon sprite base
    ADD         A,B                                 ; Add level (0-3) for sprite index
    LD          (MONSTER_WEAPON_SPRITE),A           ; Store sprite frame index
    JP          SEED_MONSTER_HP_AND_ATTACK          ; Jump to seed HP and attack
CHK_FOR_DRAGON:
    DEC         A                                   ; Test for Dragon ($23)
    JP          NZ,CHK_FOR_MUMMY                    ; If not $23, check next
    LD          D,DRAGON_BASE_DMG                   ; Dragon: base damage
    LD          HL,DRAGON_BASE_HP                   ; Dragon: base HP (SPRT, PHYS in BCD)
    LD          A,DRAGON_WEAPON_SPRITE              ; Dragon: weapon sprite base
    ADD         A,B                                 ; Add level (0-3) for sprite index
    LD          (MONSTER_WEAPON_SPRITE),A           ; Store sprite frame index
    JP          SEED_MONSTER_HP_AND_ATTACK          ; Jump to seed HP and attack
CHK_FOR_MUMMY:
    DEC         A                                   ; Test for Mummy ($24)
    JP          NZ,CHK_FOR_NECROMANCER              ; If not $24, check next
    LD          D,MUMMY_BASE_DMG                    ; Mummy: base damage
    LD          HL,MUMMY_BASE_HP                    ; Mummy: base HP (SPRT, PHYS in BCD)
    LD          A,MUMMY_WEAPON_SPRITE               ; Mummy: weapon sprite base
    ADD         A,B                                 ; Add level (0-3) for sprite index
    LD          (MONSTER_WEAPON_SPRITE),A           ; Store sprite frame index
    JP          SEED_MONSTER_HP_AND_ATTACK          ; Jump to seed HP and attack
CHK_FOR_NECROMANCER:
    DEC         A                                   ; Test for Necromancer ($25)
    JP          NZ,CHK_FOR_GRYPHON                  ; If not $25, check next
    LD          D,NECROMANCER_BASE_DMG              ; Necromancer: base damage (BCD)
    LD          HL,NECROMANCER_BASE_HP              ; Necromancer: base HP (SPRT, PHYS in BCD)
    LD          A,NECROMANCER_WEAPON_SPRITE         ; Necromancer: weapon sprite base
    ADD         A,B                                 ; Add level (0-3) for sprite index
    LD          (MONSTER_WEAPON_SPRITE),A           ; Store sprite frame index
    JP          SEED_MONSTER_HP_AND_ATTACK          ; Jump to seed HP and attack
CHK_FOR_GRYPHON:
    DEC         A                                   ; Test for Gryphon ($26)
    JP          NZ,CHK_FOR_MINOTAUR                 ; If not $26, must be Minotaur
    LD          D,GRYPHON_BASE_DMG                  ; Gryphon: base damage
    LD          HL,GRYPHON_BASE_HP                  ; Gryphon: base HP (SPRT, PHYS in BCD)
    LD          A,GRYPHON_WEAPON_SPRITE             ; Gryphon: weapon sprite base
    ADD         A,B                                 ; Add level (0-3) for sprite index
    LD          (MONSTER_WEAPON_SPRITE),A           ; Store sprite frame index
    JP          SEED_MONSTER_HP_AND_ATTACK          ; Jump to seed HP and attack
CHK_FOR_MINOTAUR:
    DEC         A                                   ; Test for Minotaur ($27)
    JP          NZ,INVALID_MONSTER_CODE             ; If not $27, invalid monster code
    LD          D,MINOTAUR_BASE_DMG                 ; Minotaur: base damage (BCD)
    LD          HL,MINOTAUR_BASE_HP                 ; Minotaur: base HP (SPRT, PHYS in BCD)
    EXX                                             ; Switch to alternate registers
    LD          HL,(PLAYER_PHYS_HEALTH)             ; Load player physical health
    CALL        DIVIDE_BCD_HL_BY_2                  ; Divide by 2 (halve phys health)
    EX          DE,HL                               ; Move to DE
    LD          A,(PLAYER_SPRT_HEALTH)              ; Load player spiritual health
    LD          L,A                                 ; L = spiritual health
    LD          H,0x0                               ; H = 0
    CALL        RECALC_PHYS_HEALTH                  ; Add phys/2 + sprt health
    EXX                                             ; Switch back to main registers
    JP          NC,MINOTAUR_MERCY_SPRITE            ; If player would die, use easier sprite
    LD          A,MINOTAUR_WEAPON_SPRT              ; Player survives: harder weapon
MINOTAUR_SET_SPRITE:
    ADD         A,B                                 ; Add level for sprite index
    LD          (MONSTER_WEAPON_SPRITE),A           ; Store sprite frame index
    JP          SEED_MONSTER_HP_AND_ATTACK          ; Jump to seed HP and attack
MINOTAUR_MERCY_SPRITE:
    LD          A,MINOTAUR_WEAPON_PHYS              ; Player would die: mercy weapon
    JP          MINOTAUR_SET_SPRITE                 ; Jump to set sprite
INVALID_MONSTER_CODE:
    JP          NO_ACTION_TAKEN                     ; Invalid code, take no action
SEED_MONSTER_HP_AND_ATTACK:
    CALL        GET_RANDOM_0_TO_7                   ; Get random 0-7 in E for HP reduction
    PUSH        HL                                  ; Save HL (HP pair: H=sprt, L=phys)
    LD          HL,CURR_MONSTER_SPRT                ; Point to spiritual HP storage (3 bytes)
    CALL        WRITE_HP_TRIPLET                    ; Write spiritual HP triplet (value, *2, carry)
    POP         HL                                  ; Restore HL (HP pair)
    LD          D,H                                 ; D = spiritual HP base value
    CALL        GET_RANDOM_0_TO_7                   ; Get random 0-7 in E for HP reduction
    PUSH        HL                                  ; Save HL (HP pair)
    LD          HL,MONSTER_PHYS_HP_BASE             ; Point to physical HP storage (3 bytes)
    CALL        WRITE_HP_TRIPLET                    ; Write physical HP triplet (value, *2, carry)
    POP         HL                                  ; Restore HL (HP pair)
    LD          D,L                                 ; D = physical HP base value
    LD          E,0x0                               ; E = 0 (no random reduction for attack)
    CALL        CALC_WEAPON_VALUE                   ; Calculate monster attack value
    LD          (WEAPON_VALUE_HOLDER),A             ; Store attack value
    CALL        REDRAW_MONSTER_HEALTH               ; Update monster health display
    JP          INIT_MN_MELEE_ANIM                  ; Added for relocatability code

INIT_MN_MELEE_ANIM:
    LD          A,0x3                               ; A = 3 (melee animation state)
    LD          (MONSTER_ANIM_STATE),A              ; Store animation state
    LD          HL,$206                             ; HL = $206 (position count)
    LD          (MONSTER_ANIM_LOOP_COUNT),HL        ; Store position count
;    LD          HL,CHRRAM_MONSTER_WEAPON_GFX_IDX    ; HL = CHRRAM_MONSTER_WEAPON_GFX_IDX
    LD          HL,CHRRAM_VP_MN_WEAPON_START_IDX    ; Point to new monster graphics area **** CHANGE ME ****
    LD          (MONSTER_WEAPON_CHRRAM_PTR),HL      ; Store position offset
    LD          A,L                                 ; A = low byte ($EA)
    LD          (MONSTER_MELEE_STATE),A             ; Store to MONSTER_MELEE_STATE
    CALL        DRAW_MONSTER_WEAPON_FRAME           ; Draw weapon frame for initial melee state
    JP          WAIT_FOR_INPUT                      ; Return to input wait

REDRAW_MONSTER_HEALTH:
    LD          DE,CHRRAM_MONSTER_PHYS              ; Point to monster physical health display
    LD          HL,CURR_MONSTER_PHYS                ; Point to current monster physical HP
    LD          B,0x2                               ; 2 bytes (BCD format)
    CALL        RECALC_AND_REDRAW_BCD               ; Recalculate and redraw physical HP
    LD          DE,CHRRAM_MONSTER_SPRT              ; Point to monster spiritual health display
    LD          HL,CURR_MONSTER_SPRT                ; Point to current monster spiritual HP
    LD          B,0x1                               ; 1 byte (BCD format)
    JP          RECALC_AND_REDRAW_BCD               ; Recalculate and redraw spiritual HP

;==============================================================================
; GET_RANDOM_0_TO_7 - Generate random value 0-7 for HP variance
;==============================================================================
; Uses the screen saver timer to generate a random value in range 0-7,
; which is used as a reduction factor for monster HP randomization.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = Raw random value from timer, then masked
; ---  End  ---
;   E  = Random value 0-7
;   A  = Random value 0-7 (same as E)
;
; Memory Modified: RANDOM_OUTPUT_BYTE, RND_SEED_POLY (by UPDATE_SCR_SAVER_TIMER)
; Calls: UPDATE_SCR_SAVER_TIMER
;==============================================================================
GET_RANDOM_0_TO_7:
    CALL        UPDATE_SCR_SAVER_TIMER              ; Update screen saver timer (returns random in A)
    AND         0x7                                 ; Mask to 0-7
    LD          E,A                                 ; E = random value 0-7
;==============================================================================
; CALC_WEAPON_VALUE - Calculate final weapon/monster damage value with randomization
;==============================================================================
; Calculates final damage value using BCD multiplication: base_damage * (level+1),
; then subtracts random reduction (0-7 from E), adds dungeon bonus (C), all with
; BCD decimal adjustment. Prevents negative results by adding back if borrow occurs.
;
; Formula: ((base_damage * (level+1)) - random_0_to_7 + dungeon_bonus) in BCD
;
; Registers:
; --- Start ---
;   D  = Base damage
;   B  = Level (0-3)
;   E  = Random reduction
;   C  = Dungeon bonus
; --- In Process ---
;   BC = Pushed/popped for preservation
;   A  = Accumulator for BCD multiplication and adjustments
; ---  End  ---
;   A  = Final damage value (BCD)
;   BC = Restored
;   F  = Flags from final DAA
;
; Memory Modified: None
; Calls: None (inline BCD math loop)
;==============================================================================
CALC_WEAPON_VALUE:
    PUSH        BC                                  ; Save BC (weapon level)
    INC         B                                   ; B = weapon level + 1 (1-4)
    LD          A,D                                 ; A = base damage value
    JP          WEAPON_DAMAGE_MULT_ENTRY            ; Jump into multiplication loop
WEAPON_DAMAGE_MULT_LOOP:
    ADD         A,D                                 ; A = A + base damage
    DAA                                             ; Decimal adjust (BCD correction)
WEAPON_DAMAGE_MULT_ENTRY:
    DJNZ        WEAPON_DAMAGE_MULT_LOOP             ; Loop B times (multiply by level+1)
    SUB         E                                   ; Subtract random reduction (0-7)
    DAA                                             ; Decimal adjust (BCD correction)
    JP          NC,WEAPON_DAMAGE_ADD_BONUS          ; If no borrow, continue
    ADC         A,E                                 ; Add back E with carry (prevent negative)
    DAA                                             ; Decimal adjust (BCD correction)
WEAPON_DAMAGE_ADD_BONUS:
    ADD         A,C                                 ; Add dungeon level bonus
    DAA                                             ; Decimal adjust (BCD correction)
    POP         BC                                  ; Restore BC (weapon level)
    RET                                             ; Return with final value in A
;==============================================================================
; WRITE_HP_TRIPLET - Write 3-byte HP data structure (value, doubled, carry)
;==============================================================================
; Stores a 3-byte HP triplet used for monster health tracking. First byte is
; the original HP value (BCD), second byte is HP*2 (BCD with DAA), third byte
; captures the carry bit from the doubling operation for extended precision.
;
; Triplet Format: [HP_base][HP_base*2][carry_from_doubling]
;
; Registers:
; --- Start ---
;   A  = HP base value (BCD)
;   HL = Triplet storage pointer
; --- In Process ---
;   A  = HP*2 (BCD), then carry bit
;   HL = Incremented through triplet
; ---  End  ---
;   A  = Carry bit (0 or 1)
;   HL = Original HL + 3
;   F  = Flags from RLA
;
; Memory Modified: (HL), (HL+1), (HL+2)
; Calls: None
;==============================================================================
WRITE_HP_TRIPLET:
    LD          (HL),A                              ; Store original HP value
    INC         HL                                  ; Point to next byte
    ADD         A,A                                 ; A = A * 2 (double the value)
    DAA                                             ; Decimal adjust (BCD correction)
    LD          (HL),A                              ; Store doubled HP value
    INC         HL                                  ; Point to next byte
    LD          A,0x0                               ; A = 0
    RLA                                             ; Rotate carry left into A
    LD          (HL),A                              ; Store carry from doubling
    RET                                             ; Return to caller
;==============================================================================
; DO_USE_LADDER - Advance to next dungeon level via ladder
;==============================================================================
; Checks for ladder at player position ($42), verifies not in combat, then
; advances to next dungeon level by regenerating map and incrementing level.
; Stores previous position for potential return mechanics.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = Combat flag, item check, map position
;   All registers modified by BUILD_MAP and display routines
; ---  End  ---
;   Control transfers to RESET_SHIFT_MODE
;
; Memory Modified: PLAYER_PREV_MAP_LOC, DUNGEON_LEVEL, entire map space
; Calls: BUILD_MAP, PLAY_PITCH_DOWN_MED, INC_DUNGEON_LEVEL, RESET_SHIFT_MODE
;==============================================================================
DO_USE_LADDER:
    LD          A,(COMBAT_BUSY_FLAG)                ; Check if in combat
    AND         A                                   ; Test combat flag
    JP          NZ,NO_ACTION_TAKEN                  ; If in combat, no action
    LD          A,(ITEM_S0)                         ; Load sprite at current position (S0)
    CP          $42                                 ; Compare to $42 (ladder code)
    JP          NZ,NO_ACTION_TAKEN                  ; If not ladder, no action
    LD          A,(PLAYER_MAP_POS)                  ; Load current map position
    LD          (PLAYER_PREV_MAP_LOC),A             ; Store as previous location
    CALL        RESET_MAP                           ; Clear map ownership for new level
    CALL        BUILD_MAP                           ; Generate new dungeon level
    CALL        PLAY_PITCH_DOWN_MED                 ; Call pitch-down routine
    CALL        INC_DUNGEON_LEVEL                   ; Update dungeon level display
    JP          RESET_SHIFT_MODE                    ; Reset shift mode and return

;==============================================================================
; RESET_MAP - Clear map and teleport ownership when descending to new level
;==============================================================================
; Resets all map-related state when player uses ladder to descend. Clears
; the "have map" flag in GAME_BOOLEANS, resets MAP_INV_SLOT to zero, and
; sets the map icon color back to default (dark grey on black).
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = GAME_BOOLEANS value, then 0, then COLOR(DKGRY,BLK)
; ---  End  ---
;   A  = COLOR(DKGRY,BLK) ($F0)
;
; Memory Modified: GAME_BOOLEANS (bit 2 cleared), MAP_INV_SLOT, COLRAM_MAP_IDX
; Calls: None
;==============================================================================
RESET_MAP:
    LD          A,(GAME_BOOLEANS)                   ; Load game boolean flags
    AND         %11101011                           ; Clear bits 2 and 4
    LD          (GAME_BOOLEANS),A                   ; Store updated boolean flags
    XOR         A                                   ; A = 0
    LD          (MAP_INV_SLOT),A                    ; Clear map inventory slot
    LD          A,COLOR(DKGRY,BLK)                  ; Load default map icon color
    LD          (COLRAM_MAP_IDX),A                  ; Reset map icon to dark grey
    LD          (COLRAM_LADDER_IDX),A               ; Reset ladder icon to dark grey
    RET                                             ; Return to caller

;==============================================================================
; INC_DUNGEON_LEVEL - Increment and display dungeon level
;==============================================================================
; Increments the dungeon level by 1 (BCD arithmetic), updates the display,
; and redraws start screen elements. If level exceeds 99, displays "loop"
; notice indicating the dungeon wraps around, then resets to bottom line char.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = Increment value (1), new level, then display characters
;   HL = DUNGEON_LEVEL pointer
;   DE = Display address (CHRRAM_LEVEL_IND_TENS), then text pointers
;   B  = BCD byte count (1), color values, delay counter
; ---  End  ---
;   All registers modified by display routines
;
; Memory Modified: DUNGEON_LEVEL, CHRRAM level display area
; Calls: RECALC_AND_REDRAW_BCD, REDRAW_START, REDRAW_VIEWPORT, DRAW_BKGD, GFX_DRAW, SLEEP_ZERO
;==============================================================================
INC_DUNGEON_LEVEL:
    LD          DE,CHRRAM_LEVEL_IND_TENS            ; DE = display address for level
    LD          HL,DUNGEON_LEVEL                    ; Point to DUNGEON_LEVEL address
    LD          A,0x1                               ; A = 1 (increment value)
    ADD         A,(HL)                              ; Add 1 to DUNGEON_LEVEL (BCD!)
    DAA                                             ; Decimal adjust (BCD correction)
    JP          C,DRAW_99_LOOP_NOTICE               ; If overflow (>99), show loop notice

;==============================================================================
; STORE_LEVEL_AND_REDRAW - Store new level and update display
;==============================================================================
; Stores the incremented dungeon level value, updates the display with BCD
; formatting, redraws start screen elements, and refreshes viewport. Normal
; path after level increment (non-overflow case).
;
; Registers:
; --- Start ---
;   A  = New level value
;   HL = DUNGEON_LEVEL
;   DE = Display address
; --- In Process ---
;   B  = 1 (BCD byte count)
;   All registers modified by display routines
; ---  End  ---
;   Control transfers to REDRAW_VIEWPORT
;
; Memory Modified: DUNGEON_LEVEL, CHRRAM display area
; Calls: RECALC_AND_REDRAW_BCD, REDRAW_START, REDRAW_VIEWPORT
;==============================================================================
STORE_LEVEL_AND_REDRAW:
    LD          (HL),A                              ; Store new dungeon level
    LD          B,0x1                               ; 1 byte (BCD format)
    CALL        RECALC_AND_REDRAW_BCD               ; Recalculate and redraw level
    CALL        REDRAW_START                        ; Redraw start screen elements
    JP          REDRAW_VIEWPORT                     ; Redraw viewport and return

;==============================================================================
; DRAW_99_LOOP_NOTICE - Display dungeon loop message
;==============================================================================
; Shows "Looks like this dungeon loops..." message when player reaches level
; 100 (overflow from BCD 99+1). Displays message for ~30 VSYNC cycles, then
; resets level display to CHAR_BOTTOM_LINE and continues normal flow.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   HL = Screen positions, DUNGEON_LEVEL pointer
;   DE = Text pointer, display address
;   B  = Color ($F0), delay counter (30)
;   A  = CHAR_BOTTOM_LINE
;   EXX switches register sets for delay
; ---  End  ---
;   Control transfers to STORE_LEVEL_AND_REDRAW via JP
;
; Memory Modified: CHRRAM (full screen), DUNGEON_LEVEL
; Calls: DRAW_BKGD, GFX_DRAW, SLEEP_ZERO (via EXX alternate set)
;==============================================================================
DRAW_99_LOOP_NOTICE:
    LD          HL,COLRAM_VIEWPORT_IDX              ; Point to viewport color RAM
    LD          BC,RECT(24,19)                      ; 24x19 rectangle size
    LD          A,COLOR(BLK,BLK)                    ; Black on black color
    CALL        FILL_CHRCOL_RECT                    ; Fill viewport with black

    LD          HL,CHRRAM_END_TEXT_IDX              ; Point to END_TEXT_IDX
    LD          DE,LEVEL_99_START_TEXT              ; Point to LEVEL_99_START_TEXT data
    LD          B,COLOR(YEL,BLK)                    ; YEL on BLK
    CALL        GFX_DRAW                            ; Draw level 99 text

    LD          HL,CHRRAM_PLAYER_SKELETON_TEXT
    LD          DE,LEVEL_99_DETAIL_TEXT
    LD          B,COLOR(GRY,BLK)
    CALL        GFX_DRAW

    LD          B,15                                ; B = 15 (delay loop count)

;==============================================================================
; LEVEL_99_NOTICE_DELAY - Delay loop for level 99 notice display
;==============================================================================
; Executes 30 VSYNC-synchronized delays to display the level loop notice for
; approximately 0.5 seconds (30 frames at 60Hz). Uses alternate register set
; to preserve main registers.
;
; Registers:
; --- Start ---
;   B  = 30
; --- In Process ---
;   EXX switches to alternate set
;   Alternate registers modified by SLEEP_ZERO
;   B  = Decremented each iteration
; ---  End  ---
;   B  = 0
;   Main registers preserved via EXX
;
; Memory Modified: None directly (SLEEP_ZERO may modify alternate set memory)
; Calls: SLEEP_ZERO (in alternate register set)
;==============================================================================
LEVEL_99_NOTICE_DELAY:
    EXX                                             ; Switch to alternate registers
    CALL        SLEEP_ZERO                          ; Delay/wait function
    EXX                                             ; Switch back to main registers
    DJNZ        LEVEL_99_NOTICE_DELAY               ; Loop 30 times for delay
    LD          A,$90                               ; A = Loop back to Level 90 ($90 BCD)
    LD          HL,DUNGEON_LEVEL                    ; Point to DUNGEON_LEVEL address
    ; LD          DE,CHHRAM_LVL_IDX                   ; Point to level display address
    LD          DE,CHRRAM_LEVEL_IND_TENS            ; Point to level display address
    JP          STORE_LEVEL_AND_REDRAW              ; Jump to update level display

;==============================================================================
; RECALC_AND_REDRAW_BCD - Convert BCD value to ASCII and render on screen
;==============================================================================
; Converts multi-byte BCD value to ASCII string with leading zero suppression,
; then renders to screen. Each BCD byte becomes 2 ASCII digits. Conversion
; happens right-to-left in temp buffer, then copied left-to-right to display
; with leading zeros replaced by spaces.
;
; Registers:
; --- Start ---
;   HL = BCD source pointer
;   DE = Screen destination
;   B  = Byte count
; --- In Process ---
;   A  = BCD bytes, nibble extractions, ASCII conversions
;   DE = Temp buffer BCD_CONVERSION_TEMP, then reverts to screen dest
;   HL = Screen write pointer (from original DE)
;   B  = Character count for display loop
;   AF'= Character count storage
; ---  End  ---
;   HL = Screen position + character count
;   A  = Last digit character written
;   F  = Flags from final store
;
; Memory Modified: BCD_CONVERSION_TEMP, CHRRAM at original DE
; Calls: None
;==============================================================================
RECALC_AND_REDRAW_BCD:
    PUSH        DE                                  ; Save DE (display address)
    LD          DE,BCD_CONVERSION_TEMP              ; DE = temp buffer for BCD conversion
    LD          A,B                                 ; A = byte count
    SLA         A                                   ; Shift left (multiply by 2)
    DEC         A                                   ; Decrement (2*B - 1)
    EX          AF,AF'                              ; Save to alternate AF

;==============================================================================
; BCD_TO_ASCII_LOOP - Convert BCD bytes to ASCII digits
;==============================================================================
; Converts each BCD byte into two ASCII characters (tens and ones) and stores
; them in BCD_CONVERSION_TEMP. Processes from low to high byte, storing
; digits in reverse order (right-to-left) for later display reversal.
;
; Registers:
; --- Start ---
;   HL = BCD source
;   DE = Temp buffer
;   B  = Byte count
; --- In Process ---
;   A  = BCD byte, nibble extractions, ASCII conversions
;   HL = Incremented through BCD bytes
;   DE = Incremented through temp buffer (2 chars per BCD byte)
;   B  = Decremented
; ---  End  ---
;   HL = Past last BCD byte
;   DE = Past last ASCII character
;   B  = 0
;
; Memory Modified: BCD_CONVERSION_TEMP
; Calls: None
;==============================================================================
BCD_TO_ASCII_LOOP:
    LD          A,(HL)                              ; Load BCD byte
    AND         0xf                                 ; Mask lower nibble (ones digit)
    ADD         A,$30                               ; Add ASCII '0' offset
    LD          (DE),A                              ; Store ASCII character
    LD          A,(HL)                              ; Load BCD byte again
    AND         $f0                                 ; Mask upper nibble (tens digit)
    RRCA                                            ; Rotate right 4 times
    RRCA                                            ; to move upper nibble
    RRCA                                            ; to lower nibble
    RRCA                                            ; position
    ADD         A,$30                               ; Add ASCII '0' offset
    INC         DE                                  ; Move to next buffer position
    LD          (DE),A                              ; Store ASCII character
    INC         DE                                  ; Move to next buffer position
    INC         HL                                  ; Move to next BCD byte
    DJNZ        BCD_TO_ASCII_LOOP                   ; Loop for all bytes
    DEC         DE                                  ; Move back one position
    POP         HL                                  ; Restore HL (display address)
    EX          AF,AF'                              ; Restore count from alternate AF
    LD          B,A                                 ; B = character count (2*bytes - 1)

;==============================================================================
; SUPPRESS_LEAD_ZEROS - Suppress leading zeros with spaces
;==============================================================================
; Copies digits from temp buffer to display, replacing leading zeros with
; spaces for clean numeric display. Processes right-to-left from temp buffer,
; left-to-right to display. Stops at first non-zero digit.
;
; Registers:
; --- Start ---
;   DE = End of temp buffer
;   HL = Display start
;   B  = Character count
; --- In Process ---
;   A  = Character from buffer
;   HL = Incremented (left-to-right in display)
;   DE = Decremented (right-to-left in buffer)
;   B  = Decremented
; ---  End  ---
;   Falls through to COPY_DIGITS or jumps to STORE_FINAL_CHAR if all zeros
;
; Memory Modified: CHRRAM display area (spaces written)
; Calls: None
;==============================================================================
SUPPRESS_LEAD_ZEROS:
    LD          A,(DE)                              ; Load character from buffer
    CP          $30                                 ; Compare to '0' ASCII
    JP          NZ,COPY_DIGITS                      ; If not '0', start copying digits
    LD          (HL),$20                            ; Store space (suppress leading zero)
    INC         HL                                  ; Move forward in display
    DEC         DE                                  ; Move backward in buffer (big-endian)
    DJNZ        SUPPRESS_LEAD_ZEROS                 ; Loop while B > 0
    LD          A,(DE)                              ; Load final character
    JP          STORE_FINAL_CHAR                    ; Jump to store and return

;==============================================================================
; COPY_DIGITS - Copy non-zero digits to display
;==============================================================================
; Copies remaining significant digits from temp buffer to display after
; leading zero suppression completes. Continues copying until all characters
; processed, then stores final character via STORE_FINAL_CHAR.
;
; Registers:
; --- Start ---
;   A  = First non-zero digit
;   DE = Temp buffer position
;   HL = Display position
;   B  = Character count
; --- In Process ---
;   A  = Characters from buffer
;   HL = Incremented
;   DE = Decremented
;   B  = Decremented
; ---  End  ---
;   B  = 0
;   Falls through to STORE_FINAL_CHAR
;
; Memory Modified: CHRRAM display area
; Calls: None
;==============================================================================
COPY_DIGITS:
    LD          (HL),A                              ; Store character to display
    INC         HL                                  ; Move forward in display
    DEC         DE                                  ; Move backward in buffer (big-endian)
    LD          A,(DE)                              ; Load next character
    DJNZ        COPY_DIGITS                         ; Loop while B > 0

;==============================================================================
; STORE_FINAL_CHAR - Store final character and return
;==============================================================================
; Stores the last digit character to display and completes the BCD to ASCII
; conversion and rendering process. Reached when loop counter exhausted or
; all characters were leading zeros.
;
; Registers:
; --- Start ---
;   A  = Final character
;   HL = Display position
; --- In Process ---
;   None
; ---  End  ---
;   A  = Unchanged
;   HL = Unchanged
;
; Memory Modified: (HL) = final character
; Calls: None
;==============================================================================
STORE_FINAL_CHAR:
    LD          (HL),A                              ; Store final character
    RET                                             ; Return to caller

;==============================================================================
; GFX_DRAW - Render AQUASCII graphics with cursor control
;==============================================================================
; PURPOSE: Renders character graphics using AQUASCII control codes for positioning
;          and cursor movement. Processes graphics strings with embedded control codes
;          to draw characters and colors to screen memory.
;
; PROCESS: 1. Parse AQUASCII control codes ($00-$04, $A0, $FF)
;          2. Handle cursor movement and color changes
;          3. Draw characters to CHRRAM and colors to COLRAM
;          4. Continue until $FF terminator found
;
; Registers:
; --- Start ---
;   HL = CHRRAM start position
;   DE = AQUASCII GFX start position
;   B  = Color byte (FG,BG)
; --- In Process ---
;   A  = Processing bytes
;   C  = Row stride ($28 / 40)
;   DE = Current position in AQUASCII GFX
;   HL = SCREEN RAM cursor tracking
;   B  = Temp, color, etc.
; --- End ---
;   HL = Last SCREEN RAM location
;   DE = One byte in AQUASCII GFX past $FF)
;   B  = Last color OR temp value used
;   A  = ($00) ???
;   C  = Last row stride used ($28 / 40)
;
; Uses:    Stack for preserving cursor positions during row operations
; Calls:   Internal subroutines for each AQUASCII control code
; Notes:   Screen is 40x25 characters. Control codes: $00=right, $01=CR+LF, 
;          $02=backspace, $03=LF, $04=up, $A0=reverse colors, $FF=end

;==============================================================================
GFX_DRAW:
    PUSH        HL                                  ; Save original cursor position on stack
    LD          C,$28                               ; $28 = +40, down one row
GFX_DRAW_MAIN_LOOP:
    LD          A,(DE)                              ; Get next AQUASCII byte from string
    INC         DE                                  ; Advance to next byte in string
    INC         A                                   ; Test if byte was $FF (becomes $00, sets Z flag)
    JP          NZ,GFX_MOVE_RIGHT                   ; If not $FF, continue processing this character
    POP         HL                                  ; $FF found - restore original HL from stack
    RET                                             ; End of graphics string, return to caller
GFX_MOVE_RIGHT:
    DEC         A                                   ; Test if character was $00 (becomes $FF after earlier INC)
    JP          NZ,GFX_CRLF                         ; If not $00, check for $01 (carriage return)
    INC         HL                                  ; $00 = move cursor right one position
    JP          GFX_DRAW_MAIN_LOOP                  ; Continue with next character
GFX_CRLF:
    CP          0x1                                 ; $01 = down one row, back to index (CR+LF)
    JP          NZ,GFX_BACKSPACE
    LD          A,B                                 ; Save color in A
    LD          B,0x0                               ; Clear B for 16-bit math
    POP         HL                                  ; Get original line start from stack
    ADD         HL,BC                               ; Move down one row (C=$28=40 chars)
    PUSH        HL                                  ; Save new line start to stack
    LD          B,A                                 ; Restore color to B
    JP          GFX_DRAW_MAIN_LOOP
GFX_BACKSPACE:
    CP          0x2                                 ; $02 = back up one column
    JP          NZ,GFX_LINE_FEED                    ; If not $02, check for $03 (line feed)
    DEC         HL                                  ; $02 = move cursor back one position
    JP          GFX_DRAW_MAIN_LOOP                  ; Continue with next character
GFX_LINE_FEED:
    CP          0x3                                 ; $03 = down one row, same column (LF)
    JP          NZ,GFX_CURSOR_UP
    LD          A,B                                 ; Save color in A
    LD          B,0x0                               ; Clear B for 16-bit math
    ADD         HL,BC                               ; Move current position down one row
    EX          (SP),HL                             ; Put new cursor pos on stack, get line start in HL
    ADD         HL,BC                               ; Move line start down one row too
    EX          (SP),HL                             ; Put updated line start back on stack
    LD          B,A                                 ; Restore color value from A back to B
    JP          GFX_DRAW_MAIN_LOOP                  ; Continue with next character
GFX_CURSOR_UP:
    CP          0x4                                 ; $04 = up one row, same column (reverse LF)
    JP          NZ,GFX_REVERSE_COLOR                ; If not $04, check for $A0 (reverse colors)
    LD          A,B                                 ; Save color in A
    LD          B,0x0                               ; Clear B for 16-bit math
    SBC         HL,BC                               ; Move current position up one row (subtract 40)
    EX          (SP),HL                             ; Put new cursor pos on stack, get line start in HL
    SBC         HL,BC                               ; Move line start up one row too
    EX          (SP),HL                             ; Put updated line start back on stack
    LD          B,A                                 ; Restore color value from A back to B
    JP          GFX_DRAW_MAIN_LOOP                  ; Continue with next character
GFX_REVERSE_COLOR:
    CP          $a0                                 ; $a0 = reverse FG & BG colors
    JP          NZ,GFX_DRAW_CHAR                    ; If not $A0, treat as normal character
    RRC         B                                   ; Rotate color byte right 4 times
    RRC         B                                   ; to swap foreground and background
    RRC         B                                   ; nybbles (FG=1,BG=2 becomes FG=2,BG=1)
    RRC         B
    JP          GFX_DRAW_MAIN_LOOP                  ; Continue with next character
GFX_DRAW_CHAR:
    LD          (HL),A                              ; Draw character to CHRRAM
                                                    ; Map from CHRRAM to COLRAM: add $400 offset
                                                    ; CHRRAM $3000-$33FF maps to COLRAM $3400-$37FF
    INC         H                                   ; +$100 
    INC         H                                   ; +$200
    INC         H                                   ; +$300  
    INC         H                                   ; +$400 = COLRAM offset
                                                    ; Determine color nybble placement in COLRAM byte
    LD          A,0xf                               ; Load $0F as threshold value
    CP          B                                   ; Compare $0F with color in B register
    LD          A,(HL)                              ; Load current COLRAM byte
    JP          C,GFX_COLOR_LOW_NYBBLE              ; If B > $0F (foreground), store in low nybble
                                                    ; Store color in high nybble (foreground colors $0x-$Fx)
    RLCA							                ; Rotate existing COLRAM byte left 4 times
    RLCA							                ; to move low nybble to high position
    RLCA				            			    ; (preserves existing foreground color)
    RLCA  
    AND         $f0                                 ; Keep only high nybble, clear low nybble
    JP          GFX_SWAP_FG_BG                      ; Continue to merge with new color
GFX_COLOR_LOW_NYBBLE:
                                                    ; Store color in low nybble (background colors $10+)  
    AND         0xf                                 ; Keep only low nybble of existing COLRAM
GFX_SWAP_FG_BG:
    OR          B                                   ; Merge new color with existing COLRAM byte
    LD          (HL),A                              ; Write combined color to COLRAM
                                                    ; Return from COLRAM back to CHRRAM: subtract $400 offset
    DEC         H                                   ; -$100
    DEC         H                                   ; -$200  
    DEC         H                                   ; -$300
    DEC         H                                   ; -$400 = back to CHRRAM
    INC         HL                                  ; Move to next character position
    JP          GFX_DRAW_MAIN_LOOP                  ; Continue with next character

;==============================================================================
; BUILD_MAP
;==============================================================================
; Generates a complete dungeon level including walls, items, monsters, and
; special objects. Creates both wall layout and item table with duplicate
; filtering through temporary shadow buffer.
;
; Map Generation Process:
; 1. Generate random wall layout (256 positions) with 3-bit encoding
; 2. Mark player starting area in wall map ($42 = N+W visible closed doors)
; 3. Generate and place ladder position (first item in table, also $42)
; 4. Generate random items/monsters up to 128 limit
; 5. Filter duplicates through TEMP_MAP shadow buffer
; 6. Copy filtered results to final item table
;
; Note: Only closed door states are generated. Open doors created by player interaction.
;
; Wall Encoding: Low bits=West wall, High bits=North wall
; Map Generation: $x0/$0x=no wall, $x1/$2x=solid wall, $x2/$4x=visible closed door, $x4/$6x=hidden closed door
; Runtime Only: $x6/$Cx=visible open door, $x7/$Ex=hidden open door (created by player interaction)
; Item Types: Level-dependent distribution of treasures, weapons, monsters
; 
; Registers:
; --- Start ---
;   HL = MAPSPACE_WALLS address ($3800)
;   B  = 0 (256 wall generation loop counter)
; --- In Process ---
;   A  = Random bytes, player position, item codes, level calculations
;   B  = Loop counters (walls: 256→0, items: 128→0), item count tracker  
;   C  = Item positions, type calculations, level thresholds
;   D  = Item type base offsets, level scaling factors
;   E  = Random masking, position validation, temp values
;   HL = Memory pointers (MAPSPACE_WALLS→ITEM_TABLE→TEMP_MAP)
;   AF'= Random number preservation during duplicate checking
; ---  End  ---
;   HL = MAP_LADDER_OFFSET + final item count + 1 ($FF terminator)
;   B  = 0 (exhausted from copy loop)
;   
; Memory Modified: MAPSPACE_WALLS, ITEM_TABLE, TEMP_MAP, ITEM_HOLDER
; Calls: MAKE_RANDOM_BYTE, UPDATE_SCR_SAVER_TIMER, CHK_DUP_POS
;==============================================================================
BUILD_MAP:
    LD          HL,MAPSPACE_WALLS                   ; Point to start of wall map ($3800)
    LD          B,0x0                               ; B=0 for 256-byte loop (0→255)
GENERATE_MAPWALLS_LOOP:
    CALL        MAKE_RANDOM_BYTE                    ; Get first random byte
    LD          E,A                                 ; Store in E for AND masking
    CALL        MAKE_RANDOM_BYTE                    ; Get second random byte  
    AND         E                                   ; AND with first random byte
    AND         $63                                 ; Mask to valid starting wall bits (0110 0011)
    LD          (HL),A                              ; Store starting wall data at current position
    INC         L                                   ; Move to next wall position (wraps at 256)
    DJNZ        GENERATE_MAPWALLS_LOOP              ; Loop for all 256 wall positions

POSITION_PLAYER_IN_MAP:
    LD          A,(PLAYER_MAP_POS)                  ; Get player's map position from the last floor
    LD          L,A                                 ; Use as index into wall map
    LD          (HL),$42                            ; Set player starting spot with N and W walls and closed doors
GENERATE_LADDER_POSITION:
    CALL        UPDATE_SCR_SAVER_TIMER              ; Get random value from timer
    INC         A                                   ; Test for $FF (invalid position)
    JP          Z,GENERATE_LADDER_POSITION          ; Keep trying if $FF
    DEC         A                                   ; Restore original value
    LD          (ITEM_HOLDER),A                     ; Save ladder position
    LD          L,A                                 ; Use as wall map index
    LD          (HL),$63                            ; Mark ladder position in wall map     

START_ITEM_TABLE:                   
    LD          HL,ITEM_TABLE                       ; Point to start of item table
    LD          (HL),A                              ; Store ladder position as first item
    INC         L                                   ; Move to item type field
    LD          (HL),$42                            ; Store ladder item type ($42)
								                    ; (always 1st item after offset)

    INC         L                                   ; Move to first item slot (after ladder)
    LD          A,(DIFFICULTY_LEVEL)                ; Load DIFFICULTY_LEVEL
    LD          B,A                                 ; Use as loop counter
    LD          A,0x2                               ; Start with base value 2
    JP          BCD_DOUBLE_ENTRY                    ; Jump into BCD multiplication loop
BCD_DOUBLE_LOOP:
    ADD         A,A                                 ; Double the value (A = A * 2)
    DAA                                             ; Decimal adjust for BCD arithmetic
BCD_DOUBLE_ENTRY:
    DJNZ        BCD_DOUBLE_LOOP                     ; Loop B times (2^B in BCD)
    LD          C,A                                 ; Save calculated threshold in C
    LD          A,(DUNGEON_LEVEL)                   ; Load DUNGEON_LEVEL (BCD!)
    CP          C                                   ; Compare level to threshold
    JP          C,SET_ITEM_LIMIT                    ; Skip item generation if level < threshold

GENERATE_ITEM_TABLE:
    CALL        UPDATE_SCR_SAVER_TIMER              ; Get random position value in A
    INC         A                                   ; Increment (test for $FF)
    JP          Z,GENERATE_ITEM_TABLE               ; If $FF, retry (avoid terminator)
    DEC         A                                   ; Restore original value
    LD          C,A                                 ; C = random position
    LD          A,(ITEM_HOLDER)                     ; Load ladder position
    CP          C                                   ; Compare to random position
    JP          Z,GENERATE_ITEM_TABLE               ; If same as ladder, retry
    LD          A,(PLAYER_MAP_POS)                  ; Load player position
    CP          C                                   ; Compare to random position
    JP          Z,GENERATE_ITEM_TABLE               ; If same as player, retry
    LD          (HL),C                              ; Store position in table
    INC         HL                                  ; Move to next byte
    LD          (HL),$9f                            ; Store $9F (Minotaur code)
    INC         HL                                  ; Move to next position
SET_ITEM_LIMIT:
    LD          B,$50                               ; B = $50 (80 items/monsters max)
    
GENERATE_RANDOM_ITEM:
    CALL        MAKE_RANDOM_BYTE                    ; Get random byte in A
    INC         A                                   ; Increment (test for $FF)
    JP          Z,GENERATE_RANDOM_ITEM              ; If $FF, retry (avoid terminator)
    DEC         A                                   ; Restore original value
    EX          AF,AF'                              ; Save position to alternate AF
    LD          A,(DUNGEON_LEVEL)                   ; Load DUNGEON_LEVEL (BCD!)
    AND         A                                   ; Clear C and N flags
    JP          NZ,CHECK_ITEM_POSITION              ; If not in Main Menu, check item position
    EX          AF,AF'                              ; Restore position from alternate
    CP          0x1                                 ; Compare to position 1
    JP          Z,GENERATE_RANDOM_ITEM              ; If position 1, retry (reserved)
    CP          $10                                 ; Compare to position $10
    JP          Z,GENERATE_RANDOM_ITEM              ; If position $10, retry (reserved)
    EX          AF,AF'                              ; Save position to alternate
CHECK_ITEM_POSITION:
    EX          AF,AF'                              ; Restore position from alternate
    LD          E,A                                 ; E = random position
    LD          A,(PLAYER_MAP_POS)                  ; Load player position
    CP          E                                   ; Compare to random position
    JP          Z,GENERATE_RANDOM_ITEM              ; If same as player, retry
    LD          A,(ITEM_HOLDER)                     ; Load ladder position
    CP          E                                   ; Compare to random position
    JP          Z,GENERATE_RANDOM_ITEM              ; If same as ladder, retry
    LD          (HL),E                              ; Store position in table
    INC         L                                   ; Move to next byte (low byte only)
    CALL        UPDATE_SCR_SAVER_TIMER              ; Get random value for item type
    AND         $c0                                 ; Mask to bits 6-7 (0, 64, 128, 192)
    RLCA                                            ; Rotate left twice
    RLCA                                            ; to get 0, 1, 2, 3
    DEC         A                                   ; A = -1, 0, 1, 2
    JP          NZ,ITEM_WEAPONS                     ; If not 0, check next category                     ; If not 0, check next category
    LD          C,0x5                               ; Category 0: C = 5 (range 0-4)
    LD          D,0x0                               ; D = 0 (base offset)
    JP          GEN_ITEM_TYPE                       ; Jump to generate item code
ITEM_WEAPONS:
    DEC         A                                   ; Test for category 1
    JP          NZ,ITEM_SPECIALS                    ; If not 1, check next category
    LD          C,0x5                               ; Category 1: C = 5 (range 0-4)
    LD          D,0x6                               ; D = 6 (base offset for bows/scrolls)
    LD          A,(DUNGEON_LEVEL)                   ; Load DUNGEON_LEVEL (BCD!)
    CP          0x6                                 ; Compare to level 6
    JP          C,GEN_ITEM_TYPE                     ; If < 6, use range 0-4
    LD          C,0x7                               ; If >= 6, C = 7 (range 0-6)
    JP          GEN_ITEM_TYPE                       ; Jump to generate item code
ITEM_SPECIALS:
    DEC         A                                   ; Test for category 2
    JP          NZ,ITEM_MONSTERS                    ; If not 2, must be category 3 (monsters)
    LD          C,0x4                               ; Category 2: C = 4 (range 0-3)
    LD          D,$11                               ; D = $11 (base offset for chests/items)
    JP          GEN_ITEM_TYPE                       ; Jump to generate item code
ITEM_MONSTERS:
    LD          D,$1e                               ; Category 3 (monsters): D = $1E (base offset)
    LD          C,0x5                               ; C = 5 (range 0-4, monsters $1E-$22)
    LD          A,(DUNGEON_LEVEL)                   ; Load DUNGEON_LEVEL (BCD!)
    CP          0x6                                 ; Compare to level 6
    JP          C,GEN_ITEM_TYPE                     ; If < 6, use range 0-4
    LD          C,0x7                               ; If >= 6, C = 7 (range 0-6, adds $23-$24)
    CP          $16                                 ; Compare to level 22 (BCD)
    JP          C,GEN_ITEM_TYPE                     ; If < 22, use range 0-6
    LD          C,0x9                               ; If >= 22, C = 9 (range 0-8, adds $25-$26)
GEN_ITEM_TYPE:
    CALL        MAKE_RANDOM_BYTE                    ; Get random byte
    AND         0xf                                 ; Mask to 0-15
GEN_ITEM_TYPE_LOOP:
    SUB         C                                   ; Subtract range limit
    JP          NC,GEN_ITEM_TYPE_LOOP               ; Loop while >= C (normalize to 0..C-1)
    ADD         A,C                                 ; Add back to get final offset
    ADD         A,D                                 ; Add base offset (item type)
    LD          C,A                                 ; C = item type code
    LD          A,(DUNGEON_LEVEL)                   ; Load DUNGEON_LEVEL (BCD!)
    INC         A                                   ; Increment level
    INC         A                                   ; Increment again (level + 2)
    SRL         A                                   ; Shift right (divide by 2)
    LD          D,A                                 ; D = (level + 2) / 2 (max color value)
    CALL        UPDATE_SCR_SAVER_TIMER              ; Get random value
    LD          E,A                                 ; E = random mask value
    CALL        MAKE_RANDOM_BYTE                    ; Get another random byte
    AND         E                                   ; AND with mask (randomize further)
    AND         0x3                                 ; Mask to 0-3 (color bits)
NORM_COLOR_LOOP:
    SUB         D                                   ; Subtract max color value
    JP          NC,NORM_COLOR_LOOP                  ; Loop while >= D (normalize to 0..D-1)
    ADD         A,D                                 ; Add back to get final color
    RRA                                             ; Rotate right (shift color bit 0 to carry)
    RRA                                             ; Rotate right again
    RL          C                                   ; Rotate carry into item code bit 0
    RLA                                             ; Rotate A left
    RL          C                                   ; Rotate carry into item code bit 1
    LD          (HL),C                              ; Store final item code with encoded color
    INC         L                                   ; Move to next position (low byte only)
    DEC         B                                   ; Decrement item counter
    JP          NZ,GENERATE_RANDOM_ITEM             ; If more items, continue loop
    LD          (HL),$ff                            ; Store $FF terminator
    LD          DE,TEMP_MAP                         ; DE = temp map buffer for filtering
    LD          HL,MAP_LADDER_OFFSET                ; HL = source map (with ladder)
    LD          B,0x0                               ; B = 0 (item counter)

;==============================================================================
; FILTER_ITEMS_LOOP - Filter duplicate items from generated table
;==============================================================================
; Iterates through raw generated item table, checks each position for duplicates
; using CHK_DUP_POS, and copies non-duplicate entries to TEMP_MAP buffer.
; Handles special $FE markers (empty slots) by removing them from final table.
;
; Registers:
; --- Start ---
;   HL = MAP_LADDER_OFFSET
;   DE = TEMP_MAP
;   B  = 0
; --- In Process ---
;   A  = Item positions and codes
;   HL = Source table pointer (advancing)
;   DE = Destination buffer pointer (advancing)
;   B  = Item counter (incrementing/decrementing)
;   EXX switches between main and alternate register sets
; ---  End  ---
;   HL = Points past $FF terminator in source
;   DE = Points past last filtered item in TEMP_MAP
;   B  = Final filtered item count
;
; Memory Modified: TEMP_MAP (filled with filtered items)
; Calls: CHK_DUP_POS (duplicate checker)
;==============================================================================
FILTER_ITEMS_LOOP:
    LD          A,(HL)                              ; Load item code from map
    CP          $ff                                 ; Compare to $FF (terminator)
    JP          Z,SETUP_MAP_COPY                    ; If terminator, copy filtered map back
    INC         B                                   ; Increment item counter
    CALL        CHK_DUP_POS                         ; Check for duplicate position
    EXX                                             ; Switch to alternate registers
    JP          Z,SKIP_DUPLICATE                    ; If duplicate, skip this entry
    LD          (DE),A                              ; Store position to temp map
    INC         DE                                  ; Move to next temp position
    INC         HL                                  ; Move to item code
    LD          A,(HL)                              ; Load item code
    CP          $fe                                 ; Compare to $FE (empty marker)
    JP          Z,SKIP_EMPTY_MARKER                 ; If empty, handle specially
    INC         B                                   ; Increment item counter
    LD          (DE),A                              ; Store item code to temp map
    INC         DE                                  ; Move to next temp position
    INC         HL                                  ; Move to next source entry
    JP          FILTER_ITEMS_LOOP                   ; Continue loop

;==============================================================================
; SKIP_DUPLICATE - Skip duplicate item entry
;==============================================================================
; Advances source pointer past a duplicate item entry (position + code = 2 bytes)
; and decrements item counter to account for removed duplicate.
;
; Registers:
; --- Start ---
;   HL = Duplicate item position
;   B  = Item count
; --- In Process ---
;   HL = Incremented twice
;   B  = Decremented once
; ---  End  ---
;   HL = Past duplicate entry
;   B  = Updated count
;
; Memory Modified: None
; Calls: None
;==============================================================================
SKIP_DUPLICATE:
    INC         HL                                  ; Skip position byte
    INC         HL                                  ; Skip item code byte
    DEC         B                                   ; Decrement counter (duplicate removed)
    JP          FILTER_ITEMS_LOOP                   ; Continue loop
SKIP_EMPTY_MARKER:
    INC         HL                                  ; Skip $FE marker
    DEC         DE                                  ; Back up (don't store $FE)
    DEC         B                                   ; Decrement counter
    JP          FILTER_ITEMS_LOOP                   ; Continue loop

;==============================================================================
; SETUP_MAP_COPY - Initialize pointers for filtered item copy
;==============================================================================
; Resets source and destination pointers to copy filtered items from TEMP_MAP
; back to final MAP_LADDER_OFFSET table. Tests item count for early exit if
; filtering removed all items.
;
; Registers:
; --- Start ---
;   B  = Item count
; --- In Process ---
;   DE = Set to TEMP_MAP
;   HL = Set to MAP_LADDER_OFFSET
;   B  = Tested via INC/DEC (preserves value)
; ---  End  ---
;   DE = TEMP_MAP
;   HL = MAP_LADDER_OFFSET
;   B  = Unchanged
;   F  = Zero flag set if B was 0
;
; Memory Modified: None
; Calls: None
;==============================================================================
SETUP_MAP_COPY:
    LD          DE,TEMP_MAP                         ; DE = temp map (filtered)
    LD          HL,MAP_LADDER_OFFSET                ; HL = destination (real map)
    INC         B                                   ; Increment counter
    DEC         B                                   ; Test if zero
    JP          Z,MAP_DONE                          ; If no items, skip copy

;==============================================================================
; COPY_TEMP_MAP_TO_REAL_MAP - Copy filtered items to final item table
;==============================================================================
; Copies B bytes from TEMP_MAP (filtered items with no duplicates) to
; MAP_LADDER_OFFSET (final item table). Simple byte-by-byte transfer.
;
; Registers:
; --- Start ---
;   DE = TEMP_MAP
;   HL = MAP_LADDER_OFFSET
;   B  = Byte count
; --- In Process ---
;   A  = Transfer byte
;   DE = Incremented
;   HL = Incremented
;   B  = Decremented
; ---  End  ---
;   DE = TEMP_MAP + byte count
;   HL = MAP_LADDER_OFFSET + byte count
;   B  = 0
;
; Memory Modified: MAP_LADDER_OFFSET (B bytes written)
; Calls: None
;==============================================================================
COPY_TEMP_MAP_TO_REAL_MAP:
    LD          A,(DE)                              ; Load byte from temp map
    LD          (HL),A                              ; Store to real map
    INC         HL                                  ; Move to next destination
    INC         DE                                  ; Move to next source
    DJNZ        COPY_TEMP_MAP_TO_REAL_MAP           ; Loop for all items

;==============================================================================
; MAP_DONE - Finalize item table with terminator
;==============================================================================
; Writes $FF terminator byte to end of item table and returns to caller.
; Marks completion of BUILD_MAP routine.
;
; Registers:
; --- Start ---
;   HL = End of item table
; --- In Process ---
;   None
; ---  End  ---
;   HL = Unchanged
;
; Memory Modified: (HL) = $FF
; Calls: None
;==============================================================================
MAP_DONE:
    LD          (HL),$ff                            ; Store $FF terminator
    RET                                             ; Return to caller

;==============================================================================
; CHK_DUP_POS - Check for duplicate position in filtered items
;==============================================================================
; Searches TEMP_MAP for an item at the same position as the current item being
; processed. Uses alternate register set to preserve main registers. Returns
; with Z flag set if duplicate found, clear if position is unique.
;
; Algorithm:
;   - Transfers BC to alternate set via stack
;   - Searches TEMP_MAP comparing positions (every 2 bytes: pos, code)
;   - Returns Z set if match found, Z clear if unique
;
; Registers:
; --- Start ---
;   A  = Position to check
;   BC = Main set item counter (preserved via stack)
; --- In Process ---
;   Main: BC pushed/available for EXX transfer
;   Alt:  BC = Item counter, HL = TEMP_MAP scanner
; ---  End  ---
;   A  = Position (preserved)
;   F  = Z flag indicates duplicate status
;   Main registers preserved
;   Alt: BC = Updated counter, HL = Scan position or TEMP_MAP
;
; Memory Modified: None
; Calls: None
;==============================================================================
CHK_DUP_POS:
    PUSH        BC                                  ; Save BC to stack
    EXX                                             ; Switch to alternate registers
    POP         BC                                  ; Restore BC from stack (to alt set)
    DEC         B                                   ; Decrement counter
    JP          Z,RETURN_NO_DUP                     ; If zero, no items to check
    LD          HL,TEMP_MAP                         ; Point to temp map

;==============================================================================
; SEARCH_DUP_LOOP - Search loop for duplicate positions
;==============================================================================
; Iterates through TEMP_MAP entries (position, code pairs) comparing each
; position byte to the target position in A. Returns immediately with Z set
; if match found.
;
; Registers:
; --- Start ---
;   A  = Target position
;   HL = TEMP_MAP
;   B  = Item count
; --- In Process ---
;   HL = Incremented by 2 each iteration (position + code)
;   B  = Decremented each iteration
; ---  End  ---
;   A  = Unchanged
;   HL = Points to matching position or past last checked item
;   B  = 0 if exhausted, >0 if match found early
;   F  = Z set if match, cleared by DJNZ if no match
;
; Memory Modified: None
; Calls: None
;==============================================================================
SEARCH_DUP_LOOP:
    CP          (HL)                                ; Compare position to temp map entry
    RET         Z                                   ; If match (duplicate), return with Z set
    DEC         B                                   ; Decrement counter
    INC         HL                                  ; Skip position byte
    INC         HL                                  ; Skip item code byte
    DJNZ        SEARCH_DUP_LOOP                     ; Loop for all items

;==============================================================================
; RETURN_NO_DUP - Return with Z clear (no duplicate)
;==============================================================================
; Called when no items exist to check or search loop exhausted without finding
; a match. Executes DEC B to clear the Z flag, signaling unique position.
;
; Registers:
; --- Start ---
;   B  = 0
; --- In Process ---
;   B  = Decremented (becomes $FF)
; ---  End  ---
;   B  = $FF
;   F  = Z clear
;
; Memory Modified: None
; Calls: None
;==============================================================================
RETURN_NO_DUP:
    DEC         B                                   ; Clear Z flag (no duplicate found)
    RET                                             ; Return with Z clear

;==============================================================================
; REDRAW_START - Calculate wall states and dispatch to direction handler
;==============================================================================
; Main entry point for recalculating all wall states based on player position
; and facing direction. Sets up return address (CALC_ITEMS) on stack, then
; dispatches to direction-specific wall calculation routines (FACING_NORTH/
; EAST/SOUTH/WEST). Each direction handler will RET through CALC_ITEMS.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   HL = CALC_ITEMS, then PLAYER_MAP_POS, then WALL_F0_STATE
;   E  = Player position
;   D  = $38 (MAPSPACE_WALLS high byte)
;   C  = 5 (step value)
;   A  = DIR_FACING_SHORT, decremented for tests
; ---  End  ---
;   Control transfers to FACING_* routine (no return)
;
; Memory Modified: Stack (CALC_ITEMS address pushed)
; Calls: FACING_NORTH, FACING_EAST, FACING_SOUTH, or FACING_WEST
;==============================================================================
REDRAW_START:
    LD          HL,CALC_ITEMS                       ; Save CALC_ITEMS function address
    PUSH        HL                                  ; PUSH it onto the stack for RET value after COMPASS redraw
    LD          HL,PLAYER_MAP_POS                   ; Get player map position variable address
    LD          E,(HL)                              ; Put player's position into E
    LD          D,$38                               ; DE = Player map position in WALL MAP SPACE (starts at $3800)
    LD          HL,WALL_F0_STATE                    ; Start of WALL_xx_STATE bytes
    LD          C,0x5                               ; C is a step value to more easily jump to WALL_xx_STATE values
    LD          A,(DIR_FACING_SHORT)                ; Load DIR_FACING_SHORT into A (1=N, 2=E, 3=S, 4=W)
    DEC         A
    JP          Z,FACING_NORTH                      ; Dir facing was 1, north
    DEC         A                               
    JP          Z,FACING_EAST                       ; Dir facing was 2, east
    DEC         A
    JP          Z,FACING_SOUTH                      ; Dir facing was 3, south
    JP          FACING_WEST                         ; Dir facing was 4, west

;==============================================================================
; FACING_WEST
;==============================================================================
; Calculate all wall states when player is facing west
;   - Calculates wall states for all 18 wall positions (including 4 half-walls) plus B0 behind player
;   - Uses map cursor navigation to sample wall data from MAPSPACE_WALLS
;   - Calls CALC_HALF_WALLS for FL2, FR2, FL1, FR1 perspective rendering
;   - Sets compass direction bytes and stages west-pointing compass text
;
; Registers:
; --- Start ---
;   DE = Player map position in WALL MAP SPACE ($3800+)
;   HL = WALL_F0_STATE address ($33e8)
;   C  = Step value for CALC_HALF_WALLS jumps (5)
; --- In Process ---
;   A  = Wall data and map position calculations
;   DE = Map cursor for navigation [S0→S1→S2→SL2→S2→SR2→SL1→S1→SR1→SL0→SL22→S0→SR0→SR1→SR2→SB]
;   HL = Wall state variable pointer progression ($33e8→$33fd)
;   C  = Incremented step value (5→6→7→8) for CALC_HALF_WALLS
; ---  End  ---
;   DE = WEST_TXT pointer for compass rendering
;   HL = Final wall state address (WALL_B0_STATE + 1)
;
; Memory Modified: WALL_F0_STATE through WALL_B0_STATE ($33e8-$33fd)
; Calls: GET_WEST_WALL, GET_NORTH_WALL, CALC_HALF_WALLS, CALC_REDRAW_COMPASS
;==============================================================================
FACING_WEST:    
    LD          A,(DE)                              ; Get S0 walls data
    AND         0x7                                 ; Mask to west wall data (F0)
    LD          (HL),A                              ; Save WALL_F0_STATE ($33e8)
    DEC         E                                   ; Move to S1
    CALL        GET_WEST_WALL                       ; Save WALL_F1_STATE ($33e9)
    DEC         E                                   ; Move to S2
    CALL        GET_WEST_WALL                       ; Save WALL_F2_STATE ($33ea)
    LD          A,E                                 ; Put E in A for math
    ADD         A,$10                               ; Increase A by 16
    LD          E,A                                 ; Save A to E (Move to SL2)
    CALL        GET_NORTH_WALL                      ; Get L2 wall data
    INC         L                                   ; Next wall state byte (L2)
    LD          (HL),A                              ; Save WALL_L2_STATE ($33eb)
    LD          A,(DE)                              ; Get SL2 data 
    AND         0x7                                 ; Mask to west wall data (FL2)
    CALL        CALC_HALF_WALLS                     ; Save FL2 A and B half-states ($33ec & $33f1 (+5))
    LD          A,E                                 ; Save E into A for math
    SUB         $10                                 ; Decrease A by 16
    LD          E,A                                 ; Save A to E (Move to S2)
    CALL        GET_NORTH_WALL                      ; Get R2 wall data
    LD          (HL),A                              ; Save WALL_R2_STATE ($33ed)
    LD          A,E                                 ; Save E into A for math
    SUB         $10                                 ; Decrease A by 16
    LD          E,A                                 ; Save A to E (Move to SR2)
    LD          A,(DE)                              ; Get SR2 data
    AND         0x7                                 ; Mask to west wall data (FR2)
    CALL        CALC_HALF_WALLS                     ; Save FR2 A and B half-states ($33ee & $33f4 (+6))
    LD          A,E                                 ; Copy E to A for math
    ADD         A,$21                               ; Increase A by 33
    LD          E,A                                 ; Save A to E (Move to SL1)
    CALL        GET_NORTH_WALL                      ; Get L1 wall data
    LD          (HL),A                              ; Save WALL_L1_STATE ($33ef)
    LD          A,(DE)                              ; Get SL1 data
    AND         0x7                                 ; Mask to west wall data (FL1)
    CALL        CALC_HALF_WALLS                     ; Save FL1 A and B half-states ($33f0 & $33f7 (+7))
    LD          A,E                                 ; Save E to A for math
    SUB         $10                                 ; Decrease A by 16
    LD          E,A                                 ; Save A to E (Move to S1)
    CALL        GET_NORTH_WALL                      ; Get R1 wall data
    INC         L                                   ; ($33f2)
    LD          (HL),A                              ; Save WALL_R1_STATE ($33f2)
    LD          A,E                                 ; Save E to A for math
    SUB         $10                                 ; Decrease A by 16
    LD          E,A                                 ; Save A to E (Move to SR1)
    LD          A,(DE)                              ; Get SR1 data
    AND         0x7                                 ; Mask to west wall data (FR1)
    CALL        CALC_HALF_WALLS                     ; Save FR1 A and B half-states ($33f3 & $33fb (+8))
    LD          A,E                                 ; Save E to A for math
    ADD         A,$21                               ; Increase A by 33
    LD          E,A                                 ; Save A to E (Move to SL0)
    CALL        GET_NORTH_WALL                      ; Get L0 wall data
    INC         L                                   ; ($33f5)
    LD          (HL),A                              ; Save WALL_L0_STATE ($33f5)
    CALL        GET_WEST_WALL                       ; Save WALL_FL0_STATE ($33f6)
    LD          A,E                                 ; Save E to A for math
    ADD         A,0xe                               ; Increase A by 14
    LD          E,A                                 ; Save A to E (Move to SL22)
    CALL        GET_NORTH_WALL                      ; Get L22 wall data
    INC         L                                   ; ($33f7)
    INC         L                                   ; ($33f8)
    LD          (HL),A                              ; Save WALL_L22_STATE ($33f8)
    LD          A,E                                 ; Save E to A for math
    SUB         $1e                                 ; Decrease A by 30
    LD          E,A                                 ; Save A to E (Move to S0)
    CALL        GET_NORTH_WALL                      ; Get R0 wall data
    INC         L                                   ; ($33f9)
    LD          (HL),A                              ; Save WALL_R0_STATE ($33f9)
    LD          A,E                                 ; Save E to A for math
    SUB         $10                                 ; Decrease A by 16
    LD          E,A                                 ; Save A to E (Move to SR0)
    CALL        GET_WEST_WALL                       ; Save WALL_FR0_STATE ($33fa)
    DEC         E                                   ; Move to SR1
    DEC         E                                   ; Move to SR2
    CALL        GET_NORTH_WALL                      ; Get R22 wall data
    INC         L                                   ; ($33fb)
    INC         L                                   ; ($33fc)
    LD          (HL),A                              ; Save WALL_R22_STATE ($33fc)
    LD          A,E                                 ; Save E to A for math
    ADD         A,$13                               ; Increase A by 19
    LD          E,A                                 ; Save A to E (Move to SB)
    CALL        GET_WEST_WALL                       ; Save WALL_B0_STATE ($33fd)
    LD          D,$ff
    LD          E,$f0
    LD          (DIR_FACING_HI),DE                  ; Set west-facing bytes
    LD          DE,WEST_TXT                         ; Stage west pointing compass text
    JP          CALC_REDRAW_COMPASS                 ; Included for code relocatability
                                                    ; even though it currently follows

;==============================================================================
; CALC_REDRAW_COMPASS
;==============================================================================
; Calculate and redraw compass
;   - Takes current direction and renders it on the compass
;
; Registers:
; --- Start ---
;   DE = Direction GFX pointer
; ---  End  ---
;   B  = Compass pointer color
;   DE = Direction GFX pointer
;   HL = Compass pointer screen index (CHRRAM)
;
; Memory Modified: CHRRAM_POINTER_IDX (compass display area)
; Calls: GFX_DRAW
;==============================================================================
CALC_REDRAW_COMPASS:
    LD          B,COLOR(RED,BLK)                    ; RED on BLK
    LD          HL,CHRRAM_POINTER_IDX
    JP          GFX_DRAW

;==============================================================================
; GET_WEST_WALL
;==============================================================================
; Get data of west wall and put into bottom 3 bits
;   - Data IS saved into (HL)
;
; Registers:
; --- Start ---
;   DE = Current wall map space in RAM ($3800 - $8FF)
;   HL = Current WALL_xx_STATE variable location
; ---  End  ---
;   A  = Wall state for given west wall in bottom 3 bits
;   DE = Current wall map space in RAM (unchanged)
;   HL = Next WALL_xx_STATE variable location
;
; Memory Modified: (HL) - wall state variable updated
; Calls: None
;==============================================================================
GET_WEST_WALL:
    LD          A,(DE)                              ; Get current map space walls data
    AND         0x7                                 ; Mask to only lower nybble (West wall)
    INC         L                                   ; Move ahead in WALL_xx_STATE memory
    LD          (HL),A                              ; Store west wall data
    RET

;==============================================================================
; GET_NORTH_WALL
;==============================================================================
; Get data of north wall and put into bottom 3 bits
;   - Data is NOT saved into (HL)
;
; Registers:
; --- Start ---
;   DE = Current wall map space in RAM ($3800 - $8FF)
;   HL = Current WALL_xx_STATE variable location
; ---  End  ---
;   A  = Wall state for given north wall in bottom 3 bits
;   DE = Current wall map space in RAM (unchanged)
;   HL = SAME WALL_xx_STATE variable location
;
; Memory Modified: None
; Calls: None
;==============================================================================
GET_NORTH_WALL:
    LD          A,(DE)                              ; Get current wall map space byte
    AND         $e0                                 ; Mask to upper nybble (north wall)
    RLCA                                            ; Rotate bits...
    RLCA                                            ; ...into bottom...
    RLCA                                            ; ...nybble bits
    RET

;==============================================================================
; CALC_HALF_WALLS
;==============================================================================
; Get wall data and put into bottom 3 bits
;   - Data is saved into (HL+1)
;   - Data is saved into (HL+C)
;
; Registers:
; --- Start ---
;   A  = Masked wall data (west/lower)
;   C  = Current half-wall WALL_xx_STATE offset
;   DE = Current wall map space in RAM ($3800 - $8FF)
;   HL = Current WALL_xx_STATE variable location
; ---  End  ---
;   A  = Wall state for given north wall in bottom 3 bits
;   C  = C + 1
;   DE = Current wall map space in RAM (unchanged)
;   HL = Two wall states ahead from original WALL_xx_STATE variable location
;
; Memory Modified: (HL+1), (HL+C) - wall state variables updated
; Calls: None
;==============================================================================
CALC_HALF_WALLS:
    INC         L                                   ; Move to next WALL_xx_STATE variable location   
    LD          (HL),A                              ; Save wall state data
    LD          B,A                                 ; Save A into B
    LD          A,L                                 ; Save L into A
    ADD         A,C                                 ; Add C (current half-wall WALL_xx_STATE shift offset) to A
    LD          L,A                                 ; Save A back into L
    LD          (HL),B                              ; Save wall value into shifted WALL_xx_STATE slot
    LD          A,L                                 ; Put L into A
    SUB         C                                   ; Subtract C from A
    LD          L,A                                 ; Load A into L (undo the shift)
    INC         L                                   ; Move to next WALL_xx_STATE location (unshifted)
    INC         C                                   ; Increment C
    RET

;==============================================================================
; FACING_NORTH
;==============================================================================
; Calculate all wall states when player is facing north
;   - Calculates wall states for all 18 wall positions (including 4 half-walls) plus B0 behind player
;   - Uses map cursor navigation to sample wall data from MAPSPACE_WALLS
;   - Calls CALC_HALF_WALLS for FL2, FR2, FL1, FR1 perspective rendering
;   - Sets compass direction bytes and stages north-pointing compass text
;
; Registers:
; --- Start ---
;   DE = Player map position in WALL MAP SPACE ($3800+)
;   HL = WALL_F0_STATE address ($33e8)
;   C  = Step value for CALC_HALF_WALLS jumps (5)
; --- In Process ---
;   A  = Wall data and map position calculations
;   DE = Map cursor for navigation [S0→S1→S2→SL2→S2→SR2→S1→SL1→S1→SR1→S0→SL0→SL22→SR0→SR22→SB]
;   HL = Wall state variable pointer progression ($33e8→$33fd)
;   C  = Incremented step value (5→6→7→8) for CALC_HALF_WALLS
; ---  End  ---
;   DE = NORTH_TXT pointer for compass rendering
;   HL = Final wall state address (WALL_B0_STATE + 1)
;
; Memory Modified: WALL_F0_STATE through WALL_B0_STATE ($33e8-$33fd)
; Calls: GET_NORTH_WALL, CALC_HALF_WALLS, CALC_REDRAW_COMPASS
;==============================================================================
FACING_NORTH:
    CALL        GET_NORTH_WALL                      ; Get F0 wall data
    LD          (HL),A                              ; Save WALL_F0_STATE ($33e8)
    LD          A,E                                 ; Put E in A for math
    SUB         $10                                 ; Decrease A by 16
    LD          E,A                                 ; Save A to E (Move to S1)
    CALL        GET_NORTH_WALL                      ; Get F1 wall data
    INC         L                                   ; Next wall state byte (F1)
    LD          (HL),A                              ; Save WALL_F1_STATE ($33e9)
    LD          A,E                                 ; Put E in A for math
    SUB         $10                                 ; Decrease A by 16
    LD          E,A                                 ; Save A to E (Move to S2)
    CALL        GET_NORTH_WALL                      ; Get F2 wall data
    INC         L                                   ; Next wall state byte (F2)
    LD          (HL),A                              ; Save WALL_F2_STATE ($33ea)
    CALL        GET_WEST_WALL                       ; Save WALL_L2_STATE ($33eb)
    DEC         E                                   ; Move to SL2
    CALL        GET_NORTH_WALL                      ; Get FL2 wall data
    CALL        CALC_HALF_WALLS                     ; Save FL2 A and B half-states ($33ec & $33f1 (+5))
    INC         E                                   ; Move to S2
    INC         E                                   ; Move to SR2
    LD          A,(DE)                              ; Get SR2 data
    AND         0x7                                 ; Mask to west wall data (FR2)
    LD          (HL),A                              ; Save WALL_R2_STATE ($33ed)
    CALL        GET_NORTH_WALL                      ; Get FR2 wall data
    CALL        CALC_HALF_WALLS                     ; Save FR2 A and B half-states ($33ee & $33f4 (+6))
    LD          A,E                                 ; Put E in A for math
    ADD         A,0xf                               ; Increase A by 15
    LD          E,A                                 ; Save A to E (Move to S1)
    LD          A,(DE)                              ; Get S1 data
    AND         0x7                                 ; Mask to west wall data (L1)
    LD          (HL),A                              ; Save WALL_L1_STATE ($33ef)
    DEC         E                                   ; Move to SL1
    CALL        GET_NORTH_WALL                      ; Get FL1 wall data
    CALL        CALC_HALF_WALLS                     ; Save FL1 A and B half-states ($33f0 & $33f7 (+7))
    INC         E                                   ; Move to S1
    INC         E                                   ; Move to SR1
    CALL        GET_WEST_WALL                       ; Save WALL_R1_STATE ($33f2)
    CALL        GET_NORTH_WALL                      ; Get FR1 wall data
    CALL        CALC_HALF_WALLS                     ; Save FR1 A and B half-states ($33f3 & $33fb (+8))
    LD          A,E                                 ; Put E in A for math
    ADD         A,0xf                               ; Increase A by 15
    LD          E,A                                 ; Save A to E (Move to S0)
    CALL        GET_WEST_WALL                       ; Save WALL_L0_STATE ($33f5)
    DEC         E                                   ; Move to SL0
    CALL        GET_NORTH_WALL                      ; Get FL0 wall data
    INC         L                                   ; ($33f5)
    LD          (HL),A                              ; Save WALL_FL0_STATE ($33f6)
    LD          A,E                                 ; Put E in A for math
    SUB         $20                                 ; Decrease A by 32
    LD          E,A                                 ; Save A to E (Move to SL2)
    LD          A,(DE)                              ; Get SL22 data
    AND         0x7                                 ; Mask to west wall data (L22)
    INC         L                                   ; ($33f7)
    INC         L                                   ; ($33f8)
    LD          (HL),A                              ; Save WALL_L22_STATE ($33f8)
    LD          A,E                                 ; Put E in A for math
    ADD         A,$22                               ; Increase A by 34
    LD          E,A                                 ; Save A to E (Move to SR0)
    CALL        GET_WEST_WALL                       ; Save WALL_R0_STATE ($33f9)
    CALL        GET_NORTH_WALL                      ; Get FR0 wall data
    INC         L                                   ; ($33fa)
    LD          (HL),A                              ; Save WALL_FR0_STATE ($33fa)
    LD          A,E                                 ; Put E in A for math
    SUB         $1f                                 ; Decrease A by 31
    LD          E,A                                 ; Save A to E (Move to SR22)
    LD          A,(DE)                              ; Get SR22 data
    AND         0x7                                 ; Mask to west wall data (R22)
    INC         L                                   ; ($33fb)
    INC         L                                   ; ($33fc)
    LD          (HL),A                              ; Save WALL_R22_STATE ($33fc)
    LD          A,E                                 ; Put E in A for math
    ADD         A,$2e                               ; Increase A by 46
    LD          E,A                                 ; Save A to E (Move to SB)
    CALL        GET_NORTH_WALL                      ; Get B0 wall data
    INC         L                                   ; ($33fd)
    LD          (HL),A                              ; Save WALL_B0_STATE ($33fd)
    LD          D,$f0                               ; Set north-facing bytes
    LD          E,0x1
    LD          (DIR_FACING_HI),DE                  ; Set north-facing bytes
    LD          DE,NORTH_TXT                        ; Stage north pointing compass text
    JP          CALC_REDRAW_COMPASS

;==============================================================================
; FACING_SOUTH
;==============================================================================
; Calculate all wall states when player is facing south
;   - Calculates wall states for all 18 wall positions (including 4 half-walls) plus B0 behind player
;   - Uses map cursor navigation to sample wall data from MAPSPACE_WALLS
;   - Calls CALC_HALF_WALLS for FL2, FR2, FL1, FR1 perspective rendering
;   - Sets compass direction bytes and stages south-pointing compass text
;
; Registers:
; --- Start ---
;   DE = Player map position in WALL MAP SPACE ($3800+)
;   HL = WALL_F0_STATE address ($33e8)
;   C  = Step value for CALC_HALF_WALLS jumps (5)
; --- In Process ---
;   A  = Wall data and map position calculations
;   DE = Map cursor for navigation [S0→S1→S2→(S2+1)→SL2→(SL2+1)→S2→(SR2+1)→SL1→SL2→S1→SR2→SL0→SL1→SL22→S0→SR1→SR2→S0]
;   HL = Wall state variable pointer progression ($33e8→$33fd)
;   C  = Incremented step value (5→6→7→8) for CALC_HALF_WALLS
; ---  End  ---
;   DE = SOUTH_TXT pointer for compass rendering
;   HL = Final wall state address (WALL_B0_STATE + 1)
;
; Memory Modified: WALL_F0_STATE through WALL_B0_STATE ($33e8-$33fd)
; Calls: GET_NORTH_WALL, CALC_HALF_WALLS, CALC_REDRAW_COMPASS
;==============================================================================
FACING_SOUTH:
    LD          A,E                                 ; Put E in A for math
    ADD         A,$10                               ; Increase A by 16
    LD          E,A                                 ; Save A to E (Move to S1)
    CALL        GET_NORTH_WALL                      ; Get F0 wall data
    LD          (HL),A                              ; Save WALL_F0_STATE ($33e8)
    LD          A,E                                 ; Put E in A for math
    ADD         A,$10                               ; Increase A by 16
    LD          E,A                                 ; Save A to E (Move to S2)
    CALL        GET_NORTH_WALL                      ; Get F1 wall data
    INC         L                                   ; Next wall state byte (F1)
    LD          (HL),A                              ; Save WALL_F1_STATE ($33e9)
    LD          A,E                                 ; Put E in A for math
    ADD         A,$10                               ; Increase A by 16
    LD          E,A                                 ; Save A to E (Move to S2 + 1)
    CALL        GET_NORTH_WALL                      ; Get F2 wall data
    INC         L                                   ; Next wall state byte (F2)
    LD          (HL),A                              ; Save WALL_F2_STATE ($33ea)
    LD          A,E                                 ; Put E in A for math
    SUB         0xf                                 ; Decrease A by 15
    LD          E,A                                 ; Save A to E (Move to SL2)
    CALL        GET_WEST_WALL                       ; Save WALL_L2_STATE ($33eb)
    LD          A,E                                 ; Put E in A for math
    ADD         A,$10                               ; Increase A by 16
    LD          E,A                                 ; Save A to E (Move to SL2 + 1)
    CALL        GET_NORTH_WALL                      ; Get FL2 wall data
    CALL        CALC_HALF_WALLS                     ; Save FL2 A and B half-states ($33ec & $33f1 (+5))
    LD          A,E                                 ; Put E in A for math
    SUB         $11                                 ; Decrease A by 17
    LD          E,A                                 ; Save A to E (Move to S2)
    LD          A,(DE)                              ; Get S2 data
    AND         0x7                                 ; Mask to west wall data (R2)
    LD          (HL),A                              ; Save WALL_R2_STATE ($33ed)
    LD          A,E                                 ; Put E in A for math
    ADD         A,0xf                               ; Increase A by 15
    LD          E,A                                 ; Save A to E (Move to SR2 + 1)
    CALL        GET_NORTH_WALL                      ; Get FR2 wall data
    CALL        CALC_HALF_WALLS                     ; Save FR2 A and B half-states ($33ee & $33f4 (+6))
    LD          A,E                                 ; Put E in A for math
    SUB         $1e                                 ; Decrease A by 30
    LD          E,A                                 ; Save A to E (Move to SL1)
    LD          A,(DE)                              ; Get SL1 data
    AND         0x7                                 ; Mask to west wall data (L1)
    LD          (HL),A                              ; Save WALL_L1_STATE ($33ef)
    LD          A,E                                 ; Put E in A for math
    ADD         A,$10                               ; Increase A by 16
    LD          E,A                                 ; Save A to E (Move to SL2)
    CALL        GET_NORTH_WALL                      ; Get FL1 wall data
    CALL        CALC_HALF_WALLS                     ; Save FL1 A and B half-states ($33f0 & $33f7 (+7))
    LD          A,E                                 ; Put E in A for math
    SUB         $11                                 ; Decrease A by 17
    LD          E,A                                 ; Save A to E (Move to S1)
    CALL        GET_WEST_WALL                       ; Save WALL_R1_STATE ($33f2)
    LD          A,E                                 ; Put E in A for math
    ADD         A,0xf                               ; Increase A by 15
    LD          E,A                                 ; Save A to E (Move to SR2)
    CALL        GET_NORTH_WALL                      ; Get FR1 wall data
    CALL        CALC_HALF_WALLS                     ; Save FR1 A and B half-states ($33f3 & $33fb (+8))
    LD          A,E                                 ; Put E in A for math
    SUB         $1e                                 ; Decrease A by 30
    LD          E,A                                 ; Save A to E (Move to SL0)
    CALL        GET_WEST_WALL                       ; Save WALL_L0_STATE ($33f5)
    LD          A,E                                 ; Put E in A for math
    ADD         A,$10                               ; Increase A by 16
    LD          E,A                                 ; Save A to E (Move to SL1)
    CALL        GET_NORTH_WALL                      ; Get FL0 wall data
    INC         L                                   ; ($33f5)
    LD          (HL),A                              ; Save WALL_FL0_STATE ($33f6)
    LD          A,E                                 ; Put E in A for math
    ADD         A,$11                               ; Increase A by 17
    LD          E,A                                 ; Save A to E (Move to SL22)
    LD          A,(DE)                              ; Get SL22 data
    AND         0x7                                 ; Mask to west wall data (L22)
    INC         L                                   ; ($33f7)
    INC         L                                   ; ($33f8)
    LD          (HL),A                              ; Save WALL_L22_STATE ($33f8)
    LD          A,E                                 ; Put E in A for math
    SUB         $22                                 ; Decrease A by 34
    LD          E,A                                 ; Save A to E (Move to S0)
    CALL        GET_WEST_WALL                       ; Save WALL_R0_STATE ($33f9)
    LD          A,E                                 ; Put E in A for math
    ADD         A,0xf                               ; Increase A by 15
    LD          E,A                                 ; Save A to E (Move to SR1)
    CALL        GET_NORTH_WALL                      ; Get FR0 wall data
    INC         L                                   ; ($33fa)
    LD          (HL),A                              ; Save WALL_FR0_STATE ($33fa)
    LD          A,E                                 ; Put E in A for math
    ADD         A,$10                               ; Increase A by 16
    LD          E,A                                 ; Save A to E (Move to SR2)
    LD          A,(DE)                              ; Get SR2 data
    AND         0x7                                 ; Mask to west wall data (R22)
    INC         L                                   ; ($33fb)
    INC         L                                   ; ($33fc)
    LD          (HL),A                              ; Save WALL_R22_STATE ($33fc)
    LD          A,E                                 ; Put E in A for math
    SUB         $1f                                 ; Decrease A by 31
    LD          E,A                                 ; Save A to E (Move to S0)
    CALL        GET_NORTH_WALL                      ; Get B0 wall data
    INC         L                                   ; ($33fd)
    LD          (HL),A                              ; Save WALL_B0_STATE ($33fd)
    LD          D,$10                               ; Set south-facing bytes
    LD          E,$ff
    LD          (DIR_FACING_HI),DE                  ; Set south-facing bytes
    LD          DE,SOUTH_TXT                        ; Stage south pointing compass text
    JP          CALC_REDRAW_COMPASS

;==============================================================================
; FACING_EAST
;==============================================================================
; Calculate all wall states when player is facing east
;   - Calculates wall states for all 18 wall positions (including 4 half-walls) plus B0 behind player
;   - Uses map cursor navigation to sample wall data from MAPSPACE_WALLS
;   - Calls CALC_HALF_WALLS for FL2, FR2, FL1, FR1 perspective rendering
;   - Sets compass direction bytes and stages east-pointing compass text
;
; Registers:
; --- Start ---
;   DE = Player map position in WALL MAP SPACE ($3800+)
;   HL = WALL_F0_STATE address ($33e8)
;   C  = Step value for CALC_HALF_WALLS jumps (5)
; --- In Process ---
;   A  = Wall data and map position calculations
;   DE = Map cursor for navigation [S0→S1→S2→(S2+1)→S2→(SL2+1)→SR2→(SR2+1)→S1→SL2→SR1→(SR2)→S0→SL1→(SL2)→SR0→(SR1)→SR22→S0]
;   HL = Wall state variable pointer progression ($33e8→$33fd)
;   C  = Incremented step value (5→6→7→8) for CALC_HALF_WALLS
; ---  End  ---
;   DE = EAST_TXT pointer for compass rendering
;   HL = Final wall state address (WALL_B0_STATE + 1)
;
; Memory Modified: WALL_F0_STATE through WALL_B0_STATE ($33e8-$33fd)
; Calls: GET_WEST_WALL, GET_NORTH_WALL, CALC_HALF_WALLS, CALC_REDRAW_COMPASS
;==============================================================================
FACING_EAST:
    INC         E                                   ; Move to S1
    LD          A,(DE)                              ; Get S1 data
    AND         0x7                                 ; Mask to west wall data (F0)
    LD          (HL),A                              ; Save WALL_F0_STATE ($33e8)
    INC         E                                   ; Move to S2
    CALL        GET_WEST_WALL                       ; Save WALL_F1_STATE ($33e9)
    INC         E                                   ; Move to S2 + 1
    CALL        GET_WEST_WALL                       ; Save WALL_F2_STATE ($33ea)
    DEC         E                                   ; Move to S2
    CALL        GET_NORTH_WALL                      ; Get L2 wall data
    INC         L                                   ; Next wall state byte (L2)
    LD          (HL),A                              ; Save WALL_L2_STATE ($33eb)
    LD          A,E                                 ; Put E in A for math
    SUB         0xf                                 ; Decrease A by 15
    LD          E,A                                 ; Save A to E (Move to SL2 + 1)
    LD          A,(DE)                              ; Get SL2 + 1 data
    AND         0x7                                 ; Mask to west wall data (FL2)
    CALL        CALC_HALF_WALLS                     ; Save FL2 A and B half-states ($33ec & $33f1 (+5))
    LD          A,E                                 ; Put E in A for math
    ADD         A,$1f                               ; Increase A by 31
    LD          E,A                                 ; Save A to E (Move to SR2)
    CALL        GET_NORTH_WALL                      ; Get R2 wall data
    LD          (HL),A                              ; Save WALL_R2_STATE ($33ed)
    INC         E                                   ; Move to SR2 + 1
    LD          A,(DE)                              ; Get SR2 + 1 data
    AND         0x7                                 ; Mask to west wall data (FR2)
    CALL        CALC_HALF_WALLS                     ; Save FR2 A and B half-states ($33ee & $33f4 (+6))
    LD          A,E                                 ; Put E in A for math
    SUB         $12                                 ; Decrease A by 18
    LD          E,A                                 ; Save A to E (Move to S1)
    CALL        GET_NORTH_WALL                      ; Get L1 wall data
    LD          (HL),A                              ; Save WALL_L1_STATE ($33ef)
    LD          A,E                                 ; Put E in A for math
    SUB         0xf                                 ; Decrease A by 15
    LD          E,A                                 ; Save A to E (Move to SL2)
    LD          A,(DE)                              ; Get SL2 data
    AND         0x7                                 ; Mask to west wall data (FL1)
    CALL        CALC_HALF_WALLS                     ; Save FL1 A and B half-states ($33f0 & $33f7 (+7))
    LD          A,E                                 ; Put E in A for math
    ADD         A,$1f                               ; Increase A by 31
    LD          E,A                                 ; Save A to E (Move to SR1)
    CALL        GET_NORTH_WALL                      ; Get R1 wall data
    INC         L                                   ; ($33f2)
    LD          (HL),A                              ; Save WALL_R1_STATE ($33f2)
    INC         E                                   ; Move to SR2
    LD          A,(DE)                              ; Get SR2 data
    AND         0x7                                 ; Mask to west wall data (FR1)
    CALL        CALC_HALF_WALLS                     ; Save FR1 A and B half-states ($33f3 & $33fb (+8))
    LD          A,E                                 ; Put E in A for math
    SUB         $12                                 ; Decrease A by 18
    LD          E,A                                 ; Save A to E (Move to S0)
    CALL        GET_NORTH_WALL                      ; Get L0 wall data
    INC         L                                   ; ($33f5)
    LD          (HL),A                              ; Save WALL_L0_STATE ($33f5)
    LD          A,E                                 ; Put E in A for math
    SUB         0xf                                 ; Decrease A by 15
    LD          E,A                                 ; Save A to E (Move to SL1)
    CALL        GET_WEST_WALL                       ; Save WALL_FL0_STATE ($33f6)
    INC         E                                   ; Move to SL2
    CALL        GET_NORTH_WALL                      ; Get L22 wall data
    INC         L                                   ; ($33f7)
    INC         L                                   ; ($33f8)
    LD          (HL),A                              ; Save WALL_L22_STATE ($33f8)
    LD          A,E                                 ; Put E in A for math
    ADD         A,$1e                               ; Increase A by 30
    LD          E,A                                 ; Save A to E (Move to SR0)
    CALL        GET_NORTH_WALL                      ; Get R0 wall data
    INC         L                                   ; ($33f9)
    LD          (HL),A                              ; Save WALL_R0_STATE ($33f9)
    INC         E                                   ; Move to SR1
    CALL        GET_WEST_WALL                       ; Save WALL_FR0_STATE ($33fa)
    LD          A,E                                 ; Put E in A for math
    ADD         A,$11                               ; Increase A by 17
    LD          E,A                                 ; Save A to E (Move to SR22)
    CALL        GET_NORTH_WALL                      ; Get R22 wall data
    INC         L                                   ; ($33fb)
    INC         L                                   ; ($33fc)
    LD          (HL),A                              ; Save WALL_R22_STATE ($33fc)
    LD          A,E                                 ; Put E in A for math
    SUB         $22                                 ; Decrease A by 34
    LD          E,A                                 ; Save A to E (Move to S0)
    CALL        GET_WEST_WALL                       ; Save WALL_B0_STATE ($33fd)
    LD          D,0x1                               ; Set east-facing bytes
    LD          E,$10
    LD          (DIR_FACING_HI),DE                  ; Set east-facing bytes
    LD          DE,EAST_TXT                         ; Stage east pointing compass text
    JP          CALC_REDRAW_COMPASS

;==============================================================================
; CALC_ITEMS - Calculate item/monster states for viewport and proximity detection
;==============================================================================
;   Populates item position slots with items/monsters in the player's vicinity.
;   Items/monsters exist throughout the map but this function determines which
;   ones are relevant for current viewport rendering and proximity triggers.
;   
;   Unlike wall calculation which reads from dense map grid ($3800), items are
;   stored in a sparse table at $3900 and must be searched via ITEM_MAP_CHECK.
;   
;   Monsters >= $78 at forward position (F1) block player movement. Monsters
;   in adjacent positions (SL0, SR0, SB) can trigger proximity effects even if
;   not rendered, provided no wall/closed door blocks line of effect.
;
; Position Scope (exact mapping TBD):
;   The function processes 8 positions using IX+offset indexing (IX+0 through IX+7)
;   These likely correspond to viewport and adjacent positions but exact
;   mapping to ITEM_xx variables and physical positions requires verification.
;   
;   Known rendered positions include: F2, F1, F0, FL1, FR1, L1, R1 (7 total)
;   Additional positions may include proximity detection for SL0, SR0, SB
;
; Item vs Wall Differences:
;   - Uses directional offset arithmetic (DIR_FACING_HI) vs complex map navigation
;   - Searches sparse item table ($3900) vs direct map access ($3800)  
;   - Returns $FE for empty vs 3-bit wall encoding
;   - Handles both rendered and non-rendered proximity positions
;   - Single pass calculation vs direction-specific algorithms
;
; Registers:
; --- Start ---
;   DE = Direction facing deltas loaded from (DIR_FACING_HI)
;   A  = Current player map position loaded from (PLAYER_MAP_POS)
; --- In Process ---
;   IX = Item position array pointer (starting at ITEM_S2)
;   DE = Direction facing deltas (D = vertical, E = horizontal)
;   A  = Map position calculations using DIR_FACING_HI offsets
;   H  = Working position register for ITEM_MAP_CHECK calls
; ---  End  ---
;   Item position array populated with item/monster codes or $FE (empty)
;
; Memory Input:
;   DIR_FACING_HI ($3a9e-$3a9f) - Direction facing offset values
;   PLAYER_MAP_POS ($3a9d) - Current player map position  
;   Sparse item table at $3900 - [position,item_code] pairs, $FF terminated
;
; Memory Output:
;   Item position array starting at ITEM_S2 ($37e8+) - item/monster state bytes
;   NOTE: Exact variable names and memory layout require verification
;
;==============================================================================
CALC_ITEMS:
    LD          IX,ITEM_S2                          ; Point IX to start of item position array
    LD          DE,(DIR_FACING_HI)                  ; Load direction facing deltas (D=vertical, E=horizontal)
    LD          A,(PLAYER_MAP_POS)                  ; Get current player map position
    ADD         A,D                                 ; Move forward by D (direction dependent)
    ADD         A,D                                 ; Move forward again (2 spaces ahead)
    CALL        ITEM_MAP_CHECK                      ; Check for item at position (IX+0)
    LD          (IX+0),A                            ; Store result in first item slot
    LD          A,H                                 ; Use H as working position (set by ITEM_MAP_CHECK)
    SUB         D                                   ; Move back by D (1 space ahead)
    CALL        ITEM_MAP_CHECK                      ; Check for item at position (IX+1)
    LD          (IX+1),A                            ; Store result in second item slot
    LD          A,H                                 ; Continue with H as working position
    SUB         D                                   ; Move back by D (player position)
    CALL        ITEM_MAP_CHECK                      ; Check for item at position (IX+2)
    LD          (IX+2),A                            ; Store result in third item slot
    LD          A,H                                 ; Continue with H as working position
    ADD         A,D                                 ; Move forward by D (back to 1 space ahead)
    SUB         E                                   ; Move left by E (diagonal left forward)
    CALL        ITEM_MAP_CHECK                      ; Check for item at position (IX+3)
    LD          (IX+3),A                            ; Store result in fourth item slot
    LD          A,H                                 ; Continue with H as working position
    ADD         A,E                                 ; Move right by E (back to center forward)
    ADD         A,E                                 ; Move right again (diagonal right forward)
    CALL        ITEM_MAP_CHECK                      ; Check for item at position (IX+4)
    LD          (IX+4),A                            ; Store result in fifth item slot
    LD          A,H                                 ; Continue with H as working position
    SUB         D                                   ; Move back by D (diagonal right at player level)
    CALL        ITEM_MAP_CHECK                      ; Check for item at position (IX+5)
    LD          (IX+5),A                            ; Store result in sixth item slot
    LD          A,H                                 ; Continue with H as working position
    SUB         E                                   ; Move left by E (back to player position)
    SUB         E                                   ; Move left again (left side of player)
    CALL        ITEM_MAP_CHECK                      ; Check for item at position (IX+6)
    LD          (IX+6),A                            ; Store result in seventh item slot
    LD          A,H                                 ; Continue with H as working position
    SUB         D                                   ; Move back by D (behind and left of player)
    ADD         A,E                                 ; Move right by E (directly behind player)
    CALL        ITEM_MAP_CHECK                      ; Check for item at position (IX+7)
    LD          (IX+7),A                            ; Store result in eighth item slot

;==============================================================================
; RET_EMPTY_SPACE - Return empty position marker
;==============================================================================
; Returns $FE to indicate no item/monster found at searched position. Called
; by ITEM_MAP_CHECK when table search reaches $FF terminator without finding
; a match. Also serves as fallback return point.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = Set to $FE
; ---  End  ---
;   A  = $FE
;
; Memory Modified: None
; Calls: None
;==============================================================================
RET_EMPTY_SPACE:
    LD          A,$fe                               ; Return $FE (empty space marker)
    RET

;==============================================================================
; ITEM_MAP_CHECK - Search sparse item table for item at specific map position
;==============================================================================
;   Searches the sparse item/monster table at MAP_LADDER_OFFSET ($3900) for
;   an item or monster at the specified map position. The table contains
;   [position,item_code] pairs terminated by $FF.
;   
;   Returns either the item/monster code found at the position, or $FE if
;   the position is empty. Used by CALC_ITEMS to populate item position slots.
;
; Table Format:
;   MAP_LADDER_OFFSET ($3900): [pos1,item1][pos2,item2]...[posN,itemN][$FF]
;   - Each entry is 2 bytes: position followed by item/monster code
;   - Table terminated by $FF marker
;   - Ladder entry is always first: [ladder_pos,$42]
;
; Registers:
; --- Start ---
;   A  = Map position to search for
; --- In Process ---
;   H  = Target map position (saved from input A)
;   BC = Pointer into sparse item table (MAP_LADDER_OFFSET + offset)
;   A  = Current table entry (position or item code)
; ---  End  ---
;   A  = Item/monster code at position, or $FE if empty
;   H  = Target map position (preserved for caller)
;   BC = Points to item code byte in table (if found)
;
; Memory Input:
;   MAP_LADDER_OFFSET ($3900) - Sparse item table with [position,code] pairs
;
;==============================================================================
ITEM_MAP_CHECK:
    LD          H,A                                 ; Save target position in H
    LD          BC,MAP_LADDER_OFFSET                ; Point BC to start of sparse item table
ITEM_SEARCH_LOOP:
    LD          A,(BC)                              ; Load position from table entry
    INC         BC                                  ; Move to item code byte
    INC         BC                                  ; Move to next table entry position
    INC         A                                   ; Test for $FF terminator (becomes $00)
    JP          Z,RET_EMPTY_SPACE                   ; Jump if end of table (return $FE)
    DEC         A                                   ; Restore original position value
    CP          H                                   ; Compare with target position
    JP          NZ,ITEM_SEARCH_LOOP                 ; Continue loop if no match
    DEC         C                                   ; Back up to item code byte
    LD          A,(BC)                              ; Load item/monster code
    RET                                             ; Return with item code in A

;==============================================================================
; REDRAW_VIEWPORT - Render 3D maze viewport using painter's algorithm
;==============================================================================
;   Renders the complete 3D maze view by processing wall states from far to near
;   using the painter's algorithm. Each wall position uses 3-bit encoding to
;   determine wall presence, door presence, and door state (open/closed).
;   
;   The function handles both main wall positions (F0, F1, F2) and half-wall
;   positions (FL2, FR2, FL1, FR1, FL0, FR0) for perspective rendering.
;
; Wall State Encoding (per wall_diagram.txt):
;   Low bits (West): $x0=no wall, $x1=solid wall, $x2=visible closed door
;                    $x4=hidden closed door, $x6=visible open door, $x7=hidden open door
;   High bits (North): $0x=no wall, $2x=solid wall, $4x=visible closed door  
;                      $6x=hidden closed door, $Cx=visible open door, $Ex=hidden open door
;   
;   Standard RRCA sequence used throughout:
;     RRCA     ; Test wall state bits
;     RRCA     ; Continue testing
;     RRCA     ; Final state check
;
; Rendering Algorithm (Conditional Front-to-Back with Occlusion Culling):
;   Uses strategic JP jumps to skip rendering when walls block visibility.
;   NOT Painter's Algorithm - renders closest walls first, then conditionally
;   renders distant walls only when visible through gaps or open doors.
;
; Rendering Order:
;   1. Background (ceiling/floor)
;   2. F0 wall (closest) - IF CLOSED: skip to step 7 (268 lines jumped)
;   3. F1 wall (middle)  - IF CLOSED: skip to step 5 (114 lines jumped)
;   4. F2 wall (farthest visible)
;   5. Distance-2 side walls (L2, FL2_A, R2, FR2_A)
;   6. Distance-1 side walls (L1, FL1_A/B, FL2_B, R1, FR1_A/B, FR2_B)
;   7. Distance-0 side walls (L0, FL0, FL1_B, FL22, R0, FR0, FR1_B, FR22)
;   8. Items at F2, FL1 (×5), F1, FR1 (×5), F0 positions
;
; Occlusion Optimization:
;   F0 closed → JP line 8427 (skips F1, F2, distance-2, distance-1 walls)
;   F0 open   → JP line 8422 (skips distant walls, renders F1 item)
;   F1 closed → JP line 8306 (skips F2, distance-2 walls)
;   F1 open   → JP line 8303 (skips distance-2 walls, renders F2 item)
;
; Registers:
; --- Start ---
;   None (uses wall state memory block $33e8-$33fd)
; --- In Process ---
;   A  = Wall state data and bit testing via RRCA sequences
;   BC = Item position pointers (ITEM_S2, ITEM_S1, etc.)
;   DE = Wall state memory pointer ($33e8 = WALL_F0_STATE onwards)
;   HL = Graphics memory addresses for rendering
;   AF'= Saved wall state during drawing operations
; ---  End  ---
;   Viewport fully rendered with all visible walls, doors, and items
;
; Memory Input:
;   WALL_F0_STATE to WALL_B0_STATE ($33e8-$33fd) - 22 wall position states
;   Half-wall states: WALL_FL2_A_STATE, WALL_FL2_B_STATE, etc. (calculated by CALC_HALF_WALLS)
;   Item data: ITEM_S2, ITEM_S1, ITEM_S0, etc.
;
; Memory Output:
;   CHRRAM $3000-$33e7 - Character data for viewport area
;   COLRAM $3400-$37e7 - Color data for viewport area
;
;==============================================================================
REDRAW_VIEWPORT:
    CALL        DRAW_BKGD                           ; Draw background
    LD          BC,ITEM_S2                          ; BC = sprite at position S2
    LD          DE,WALL_F0_STATE                    ; DE = wall state at position F0
    LD          A,(DE)                              ; Load F0 wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,F0_NO_HD                         ; If no hidden door, check regular wall
    EX          AF,AF'                              ; Save wall state to alternate
    CALL        DRAW_F0_WALL                        ; Draw F0 wall
    EX          AF,AF'                              ; Restore wall state
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,F0_HD_NO_WALL                    ; If no wall, continue
    RRCA                                            ; Test bit 2 (door open flag)
    JP          NC,F0_HD_NO_WALL                    ; If door closed, continue
F0_NO_HD_WALL_OPEN:
    CALL        DRAW_WALL_F0_AND_OPEN_DOOR          ; Draw wall with open door
    JP          CHK_ITEM_S1                         ; Jump to S1 sprite check
;==============================================================================
; F0_NO_HD - Process F0 wall when no hidden door present
;==============================================================================
; Handles F0 wall rendering when bit 0 (hidden door flag) is clear. Tests
; bit 1 for wall existence and bit 2 for door state (open/closed). Branches
; to appropriate draw routine or continues to F1 processing.
;
; Registers:
; --- Start ---
;   A  = F0 state rotated once right
; --- In Process ---
;   A  = Further rotated for bit testing (RRCA sequences)
;   AF'= Saved during draw calls
; ---  End  ---
;   Control transfers to draw routine or next section
;
; Memory Modified: CHRRAM/COLRAM via draw calls
; Calls: DRAW_F0_WALL_AND_CLOSED_DOOR, DRAW_WALL_F0_AND_OPEN_DOOR
;==============================================================================
F0_NO_HD:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,F0_NO_HD_NO_WALL                 ; If no wall, check F1
    RRCA                                            ; Test bit 2 (door open flag)
    JP          C,F0_NO_HD_WALL_OPEN                ; If door open, draw open door
    CALL        DRAW_F0_WALL_AND_CLOSED_DOOR        ; Draw wall with closed door
    JP          F0_HD_NO_WALL                       ; Continue to L1/R1 walls
;==============================================================================
; F0_NO_HD_NO_WALL - Continue to F1 when F0 has no wall
;==============================================================================
; Entry point when F0 position has no wall present (bit 1 clear). Advances
; DE to F1_WALL_STATE and continues F1 wall rendering logic.
;
; Registers:
; --- Start ---
;   DE = WALL_F0_STATE
; --- In Process ---
;   DE = Incremented to F1
;   A  = F1 wall state
; ---  End  ---
;   Control to F1 hidden door check
;
; Memory Modified: None
; Calls: None (continues inline to F1 logic)
;==============================================================================
F0_NO_HD_NO_WALL:
    INC         DE                                  ; Move to F1 wall state
    LD          A,(DE)                              ; Load F1 wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,F1_NO_HD                         ; If no hidden door, check regular wall
    EX          AF,AF'                              ; Save wall state to alternate
    CALL        DRAW_WALL_F1                        ; Draw F1 wall
    EX          AF,AF'                              ; Restore wall state
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,F1_HD_NO_WALL                    ; If no wall, continue to L1/R1
    RRCA                                            ; Test bit 2 (door open flag)
    JP          NC,F1_HD_NO_WALL                    ; If door closed, continue
F1_NO_HD_WALL_OPEN:
    CALL        DRAW_WALL_F1_AND_OPEN_DOOR          ; Draw wall with open door
    JP          CHK_ITEM_S2                         ; Jump to S2 sprite check
;==============================================================================
; F1_NO_HD - Process F1 wall when no hidden door present
;==============================================================================
; Handles F1 wall rendering when bit 0 (hidden door flag) is clear. Tests
; bit 1 for wall existence and bit 2 for door state. Mirrors F0_NO_HD logic
; for F1 depth position.
;
; Registers:
; --- Start ---
;   A  = F1 state rotated once
; --- In Process ---
;   A  = Further rotated for bit tests
;   AF'= Saved during draw calls
; ---  End  ---
;   Control transfers to next section
;
; Memory Modified: CHRRAM/COLRAM via draw calls
; Calls: DRAW_WALL_F1_AND_CLOSED_DOOR, DRAW_WALL_F1_AND_OPEN_DOOR
;==============================================================================
F1_NO_HD:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_WALL_F2                      ; If no wall, check F2
    RRCA                                            ; Test bit 2 (door open flag)
    JP          C,F1_NO_HD_WALL_OPEN                ; If door open, draw open door
    CALL        DRAW_WALL_F1_AND_CLOSED_DOOR        ; Draw wall with closed door
    JP          F1_HD_NO_WALL                       ; Continue to L1/R1 walls
CHK_WALL_F2:
    INC         DE                                  ; Move to F2 wall state
    LD          A,(DE)                              ; Load F2 wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHECK_WALL_F2                    ; If no hidden door, check bit 1
F2_WALL:
    CALL        DRAW_WALL_F2                        ; Draw F2 wall
    JP          CHK_WALL_L2_HD                      ; Continue to L2 walls
;==============================================================================
; CHECK_WALL_F2 - Test F2 wall existence (bit 1) when no hidden door
;==============================================================================
; After confirming no hidden door at F2 (bit 0 clear), tests bit 1 to
; determine if a wall exists. Draws wall if present, or empty space if not.
; Simpler than F0/F1 logic since F2 uses simplified rendering.
;
; Registers:
; --- Start ---
;   A  = F2 state rotated once
; --- In Process ---
;   A  = Rotated again to test bit 1
; ---  End  ---
;   Control to L2 wall processing
;
; Memory Modified: CHRRAM/COLRAM via DRAW_WALL_F2 or DRAW_WALL_F2_EMPTY
; Calls: DRAW_WALL_F2, DRAW_WALL_F2_EMPTY
;==============================================================================
CHECK_WALL_F2:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          C,F2_WALL                           ; If wall exists, draw it
    CALL        DRAW_WALL_F2_EMPTY                  ; Draw empty F2 space
CHK_WALL_L2_HD:
    LD          DE,WALL_L2_STATE                    ; DE = left wall 2 state
    LD          A,(DE)                              ; Load L2 wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_WALL_L2_EXISTS               ; If no hidden door, check bit 1
DRAW_L2_WALL:
    CALL        DRAW_WALL_L2                        ; Draw L2 wall
    JP          CHK_WALL_R2_HD                      ; Continue to R2 walls
CHK_WALL_L2_EXISTS:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          C,DRAW_L2_WALL                      ; If wall exists, draw it
    INC         DE                                  ; Move to L2 left wall state
    LD          A,(DE)                              ; Load L2 left state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_WALL_FL2_A_EXISTS            ; If no hidden door, check bit 1
DRAW_FL2_A_WALL:
    CALL        DRAW_WALL_F2_FL2_GAP                     ; Draw FL2_A wall
    JP          CHK_WALL_R2_HD                      ; Continue to R2 walls
CHK_WALL_FL2_A_EXISTS:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          C,DRAW_FL2_A_WALL                   ; If wall exists, draw it
    CALL        DRAW_WALL_F2_FL2_GAP_EMPTY               ; Draw empty FL2_A space
CHK_WALL_R2_HD:
    LD          DE,WALL_R2_STATE                    ; DE = right wall 2 state
    LD          A,(DE)                              ; Load R2 wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_WALL_R2_EXISTS               ; If no hidden door, check bit 1
DRAW_R2_WALL:
    CALL        DRAW_WALL_R2                        ; Draw R2 wall
    JP          CHK_ITEM_S2                         ; Continue to S2 sprite check
CHK_WALL_R2_EXISTS:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          C,DRAW_R2_WALL                      ; If wall exists, draw it
    INC         DE                                  ; Move to R2 right wall state
    LD          A,(DE)                              ; Load R2 right state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_WALL_FR2_A_EXISTS            ; If no hidden door, check bit 1
DRAW_FR2_A_WALL:
    CALL        DRAW_WALL_F2_FR2_GAP                     ; Draw R2 right wall
    JP          CHK_ITEM_S2                         ; Continue to S2 sprite check
CHK_WALL_FR2_A_EXISTS:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          C,DRAW_FR2_A_WALL                   ; If wall exists, draw it
    CALL        DRAW_WALL_F2_FR2_GAP_EMPTY               ; Draw empty R2 right space
CHK_ITEM_S2:
    LD          A,(ITEM_S2)                         ; Load sprite at S2 position
    ; LD          BC,$48a                             ; B = 4 (tiny); C = Low Byte of $328a
    LD          BC,CHRRAM_S2_ITEM_DRAW_IDX          ; BC = $328a
    LD          B,4                                 ; BC = $048a
    CALL        CHK_ITEM                            ; Check and draw S2 item
F1_HD_NO_WALL:
    LD          DE,WALL_L1_STATE                    ; DE = left wall 1 state
    LD          A,(DE)                              ; Load L1 wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_L1_NO_HD                     ; If no hidden door, check bit 1
    EX          AF,AF'                              ; Save wall state to alternate
    CALL        DRAW_WALL_L1                        ; Draw L1 wall
    EX          AF,AF'                              ; Restore wall state
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_WALL_R1_HD                   ; If no wall, continue
    RRCA                                            ; Test bit 2 (door open flag)
    JP          NC,CHK_WALL_R1_HD                   ; If door closed, continue
DRAW_L1_DOOR_OPEN:
    CALL        DRAW_FL1_DOOR                       ; Draw FL1 door
    JP          CHK_WALL_R1_HD                      ; Continue to R1 walls
CHK_L1_NO_HD:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_WALL_FL1_B                   ; If no wall, check sub-wall
    RRCA                                            ; Test bit 2 (door open flag)
    JP          C,DRAW_L1_DOOR_OPEN                 ; If door open, draw door
    CALL        DRAW_L1                             ; Draw L1 wall/door
    JP          CHK_WALL_R1_HD                      ; Continue to R1 walls
CHK_WALL_FL1_B:
    INC         E                                   ; Move to L1 back wall state
    LD          A,(DE)                              ; Load L1 back wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_FL1_B_NO_HD                  ; If no hidden door, check bit 1
    EX          AF,AF'                              ; Save wall state to alternate
    CALL        DRAW_WALL_FL1_B                     ; Draw FL1 back wall
    EX          AF,AF'                              ; Restore wall state
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_WALL_R1_HD                   ; If no wall, continue
    RRCA                                            ; Test bit 2 (door open flag)
    JP          NC,CHK_WALL_R1_HD                   ; If door closed, continue
DRAW_FL1_B_DOOR_OPEN:
    CALL        DRAW_DOOR_FL1_B_HIDDEN              ; Draw hidden door on FL1 back
    JP          CHK_WALL_R1_HD                      ; Continue to R1 walls
CHK_FL1_B_NO_HD:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_WALL_FL2                     ; If no wall, check FL2
    RRCA                                            ; Test bit 2 (door open flag)
    JP          C,DRAW_FL1_B_DOOR_OPEN              ; If door open, draw door
    CALL        DRAW_DOOR_FL1_B_NORMAL              ; Draw normal door on FL1 back
    JP          CHK_WALL_R1_HD                      ; Continue to R1 walls
CHK_WALL_FL2:
    INC         E                                   ; Move to FL2 wall state
    LD          A,(DE)                              ; Load FL2 wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_WALL_FL2_EXISTS              ; If no hidden door, check bit 1
DRAW_FL2_WALL:
    CALL        DRAW_WALL_FL2                       ; Draw FL2 wall
    JP          CHK_WALL_R1_HD                      ; Continue to R1 walls
CHK_WALL_FL2_EXISTS:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          C,DRAW_FL2_WALL                     ; If wall exists, draw it
    CALL        DRAW_WALL_FL2_EMPTY                 ; Draw empty FL2 space
CHK_WALL_R1_HD:
    LD          DE,WALL_R1_STATE                    ; DE = right wall 1 state
    LD          A,(DE)                              ; Load R1 wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_R1_NO_HD                     ; If no hidden door, check bit 1
    EX          AF,AF'                              ; Save wall state to alternate
    CALL        DRAW_WALL_R1                        ; Draw R1 wall
    EX          AF,AF'                              ; Restore wall state
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_ITEM_S1                      ; If no wall, continue
    RRCA                                            ; Test bit 2 (door open flag)
    JP          NC,CHK_ITEM_S1                      ; If door closed, continue
DRAW_R1_DOOR_OPEN:
    CALL        DRAW_DOOR_R1_HIDDEN                 ; Draw hidden door on R1
    JP          CHK_ITEM_S1                         ; Continue to S1 sprite check
CHK_R1_NO_HD:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_WALL_FR1_A                   ; If no wall, check sub-wall
    RRCA                                            ; Test bit 2 (door open flag)
    JP          C,DRAW_R1_DOOR_OPEN                 ; If door open, draw door
    CALL        DRAW_DOOR_R1_NORMAL                 ; Draw normal door on R1
    JP          CHK_ITEM_S1                         ; Continue to S1 sprite check
CHK_WALL_FR1_A:
    INC         E                                   ; Move to FR1 wall state
    LD          A,(DE)                              ; Load FR1 wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_FR1_A_NO_HD                  ; If no hidden door, check bit 1
    EX          AF,AF'                              ; Save wall state to alternate
    CALL        DRAW_WALL_FR1_A                     ; Draw FR1 wall
    EX          AF,AF'                              ; Restore wall state
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_ITEM_S1                      ; If no wall, continue
    RRCA                                            ; Test bit 2 (door open flag)
    JP          NC,CHK_ITEM_S1                      ; If door closed, continue
DRAW_FR1_A_DOOR_OPEN:
    CALL        DRAW_DOOR_FR1_A_HIDDEN              ; Draw hidden door on FR1
    JP          CHK_ITEM_S1                         ; Continue to S1 sprite check
CHK_FR1_A_NO_HD:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_WALL_FR2                     ; If no wall, check FR2
    RRCA                                            ; Test bit 2 (door open flag)
    JP          C,DRAW_FR1_A_DOOR_OPEN              ; If door open, draw door
    CALL        DRAW_DOOR_FR1_A_NORMAL              ; Draw normal door on FR1
    JP          CHK_ITEM_S1                         ; Continue to S1 sprite check
CHK_WALL_FR2:
    INC         E                                   ; Move to FR2 wall state
    LD          A,(DE)                              ; Load FR2 wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_WALL_FR2_EXISTS              ; If no hidden door, check bit 1
DRAW_FR2_WALL:
    CALL        DRAW_WALL_FR2                       ; Draw FR2 wall
    JP          CHK_ITEM_S1                         ; Continue to S1 sprite check
CHK_WALL_FR2_EXISTS:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          C,DRAW_FR2_WALL                     ; If wall exists, draw it
    CALL        DRAW_WALL_FR2_EMPTY                 ; Draw empty FR2 space
CHK_ITEM_S1:
    LD          A,(ITEM_S1)                         ; Load sprite at S1 position
    ; LD          BC,$28a                             ; B = 2 (small); C = Low Byte of $318a
    LD          BC,CHRRAM_S1_ITEM_DRAW_IDX          ; BC = $328a
    LD          B,2                                 ; BC = $028a
    CALL        CHK_ITEM                            ; Check and draw S1 item
F0_HD_NO_WALL:
    LD          DE,WALL_L0_STATE                    ; DE = left wall 0 state
    LD          A,(DE)                              ; Load L0 wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_L0_NO_HD                     ; If no hidden door, check bit 1
    EX          AF,AF'                              ; Save wall state to alternate
    CALL        DRAW_WALL_L0                        ; Draw L0 wall
    EX          AF,AF'                              ; Restore wall state
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_WALL_R0                      ; If no wall, continue
    RRCA                                            ; Test bit 2 (door open flag)
    JP          NC,CHK_WALL_R0                      ; If door closed, continue
DRAW_L0_DOOR_OPEN:
    CALL        DRAW_DOOR_L0_HIDDEN                 ; Draw hidden door on L0
    JP          CHK_WALL_R0                         ; Continue to R0 walls
CHK_L0_NO_HD:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_WALL_FL0                     ; If no wall, check sub-wall
    RRCA                                            ; Test bit 2 (door open flag)
    JP          C,DRAW_L0_DOOR_OPEN                 ; If door open, draw door
    CALL        DRAW_DOOR_L0_NORMAL                 ; Draw normal door on L0
    JP          CHK_WALL_R0                         ; Continue to R0 walls
CHK_WALL_FL0:
    INC         E                                   ; Move to FL0 wall state
    LD          A,(DE)                              ; Load FL0 wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_WALL_FL0_EXISTS              ; If no hidden door, check bit 1
DRAW_FL0_WALL:
    CALL        DRAW_WALL_FL0                       ; Draw FL0 wall
    JP          CHK_WALL_R0                         ; Continue to R0 walls
CHK_WALL_FL0_EXISTS:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          C,DRAW_FL0_WALL                     ; If wall exists, draw it
    INC         E                                   ; Move to next wall state byte
    LD          A,(DE)                              ; Load wall state byte into A
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_FL1_A_NO_HD                  ; If no hidden door, check bit 1
    EX          AF,AF'                              ; Save wall state to alternate
    CALL        DRAW_WALL_FL1_A                     ; Draw L1 wall
    CALL        CHK_ITEM_SL1                        ; Check and draw SL1 item
    EX          AF,AF'                              ; Restore wall state
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_WALL_R0                      ; If no wall, continue to R0
    RRCA                                            ; Test bit 2 (door open flag)
    JP          NC,CHK_WALL_R0                      ; If door closed, continue to R0
DRAW_FL1_A_HD:
    CALL        DRAW_DOOR_L1_HIDDEN                 ; Draw hidden door on L1
    CALL        CHK_ITEM_SL1                        ; Check and draw SL1 item
    JP          CHK_WALL_R0                         ; Continue to R0 walls
;==============================================================================
; CHK_ITEM_SL1 - Check and draw item at SL1 position
;==============================================================================
; Helper subroutine called from multiple SL1 wall rendering paths. Loads the
; item code at ITEM_SL1 and dispatches to CHK_ITEM with SL1-specific distance
; and size parameters ($4d0).
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = ITEM_SL1 value
;   BC = $4d0 (distance/size for SL1)
; ---  End  ---
;   Modified by CHK_ITEM
;
; Memory Modified: CHRRAM/COLRAM if item drawn
; Calls: CHK_ITEM
;==============================================================================
CHK_ITEM_SL1:
    LD          A,(ITEM_SL1)                        ; Load item at SL1 position
    LD          BC,$4d0                             ; BC = distance/size parameters
    JP          CHK_ITEM                            ; Check and draw SL1 item
CHK_FL1_A_NO_HD:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_WALL_FL1_B_EXISTS            ; If no wall, check next position
    RRCA                                            ; Test bit 2 (door open flag)
    JP          C,DRAW_FL1_A_HD                     ; If door open, draw hidden door
    CALL        DRAW_DOOR_L1_NORMAL                 ; Draw normal door on L1
    CALL        CHK_ITEM_SL1                        ; Check and draw SL1 item
    JP          CHK_WALL_R0                         ; Continue to R0 walls
CHK_WALL_FL1_B_EXISTS:
    INC         E                                   ; Move to next wall state byte
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_FL22_EXISTS                  ; If no wall, draw empty
DRAW_FL1_B_WALL:
    CALL        DRAW_WALL_L1_SIMPLE                 ; Draw wall
    CALL        CHK_ITEM_SL1                        ; Check and draw SL1 item
    JP          CHK_WALL_R0                         ; Continue to R0 walls
CHK_FL22_EXISTS:
    RRCA                                            ; Test bit 2 (next flag)
    JP          C,DRAW_FL1_B_WALL                   ; If bit set, draw wall
    CALL        DRAW_WALL_FL22_EMPTY                ; Draw empty FL22 space
    CALL        CHK_ITEM_SL1                        ; Check and draw SL1 item
CHK_WALL_R0:
    LD          DE,WALL_R0_STATE                    ; DE = right wall 0 state
    LD          A,(DE)                              ; Load R0 wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_R0_NO_HD                     ; If no hidden door, check bit 1
    EX          AF,AF'                              ; Save wall state to alternate
    CALL        DRAW_WALL_R0                        ; Draw R0 wall
    EX          AF,AF'                              ; Restore A register state
    RRCA                                            ; Test next bit (door presence?)
    JP          NC,CHK_ITEM_S0                      ; If door bit clear, jump to end
    RRCA                                            ; Test third bit (door type?)
    JP          NC,CHK_ITEM_S0                      ; If door type bit clear, jump to end
DRAW_R0_HD:
    CALL        DRAW_R0_DOOR_HIDDEN                 ; Draw hidden door on R0
    JP          CHK_ITEM_S0                         ; Jump to S0 sprite check
CHK_R0_NO_HD:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_WALL_FR0                     ; If no wall, check FR0
    RRCA                                            ; Test bit 2 (door open flag)
    JP          C,DRAW_R0_HD                        ; If door open, draw hidden door
    CALL        DRAW_R0_DOOR_NORMAL                 ; Draw normal door on R0
    JP          CHK_ITEM_S0                         ; Jump to S0 sprite check
CHK_WALL_FR0:
    INC         E                                   ; Move to FR0 wall state
    LD          A,(DE)                              ; Load FR0 wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_WALL_FR0_EXISTS              ; If no hidden door, check bit 1
DRAW_FR0_WALL:
    CALL        DRAW_WALL_FR0                       ; Draw FR0 wall
    JP          CHK_ITEM_S0                         ; Jump to S0 sprite check
;==============================================================================
; CHK_ITEM_SR1 - Check and draw item at SR1 position
;==============================================================================
; Helper subroutine for SR1 wall rendering paths. Loads item code at ITEM_SR1
; and dispatches to CHK_ITEM with SR1-specific distance/size parameters ($4e4).
; Right side complement of CHK_ITEM_SL1.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = ITEM_SR1 value
;   BC = $4e4 (distance/size for SR1)
; ---  End  ---
;   Modified by CHK_ITEM
;
; Memory Modified: CHRRAM/COLRAM if item drawn
; Calls: CHK_ITEM
;==============================================================================
CHK_ITEM_SR1:
    LD          A,(ITEM_SR1)                        ; Load item at SR1 position
    LD          BC,$4e4                             ; BC = distance/size parameters
    JP          CHK_ITEM                            ; Check and draw SR1 item
CHK_WALL_FR0_EXISTS:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          C,DRAW_FR0_WALL                     ; If wall exists, draw it
    INC         E                                   ; Move to FR1 back wall state
    LD          A,(DE)                              ; Load FR1 back wall state
    RRCA                                            ; Test bit 0 (hidden door flag)
    JP          NC,CHK_FR1_B_NO_HD                  ; If no hidden door, check bit 1
    EX          AF,AF'                              ; Save wall state to alternate
    CALL        DRAW_WALL_FR1_B                     ; Draw FR1 back wall
    CALL        CHK_ITEM_SR1                        ; Check and draw SR1 item
    EX          AF,AF'                              ; Restore wall state
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_ITEM_S0                      ; If no wall, continue to S0
    RRCA                                            ; Test bit 2 (door open flag)
    JP          NC,CHK_ITEM_S0                      ; If door closed, continue to S0
DRAW_FR1_B_HD:
    CALL        DRAW_DOOR_FR1_B_HIDDEN              ; Draw hidden door on FR1 back
    CALL        CHK_ITEM_SR1                        ; Check and draw SR1 item
    JP          CHK_ITEM_S0                         ; Jump to S0 sprite check
CHK_FR1_B_NO_HD:
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_WALL_FR1_B_EXISTS            ; If no wall, check FR2
    RRCA                                            ; Test bit 2 (door open flag)
    JP          C,DRAW_FR1_B_HD                     ; If door open, draw hidden door
    CALL        DRAW_DOOR_FR1_B_NORMAL              ; Draw normal door on FR1 back
    CALL        CHK_ITEM_SR1                        ; Check and draw SR1 item
    JP          CHK_ITEM_S0                         ; Jump to S0 sprite check
CHK_WALL_FR1_B_EXISTS:
    INC         E                                   ; Move to FR2 wall state
    RRCA                                            ; Test bit 1 (wall exists flag)
    JP          NC,CHK_FR22_EXISTS                  ; If no wall, draw empty
DRAW_FR1_B_WALL:
    CALL        DRAW_WALL_R1_SIMPLE                 ; Draw FR2 wall
    CALL        CHK_ITEM_SR1                        ; Check and draw SR1 item
    JP          CHK_ITEM_S0                         ; Jump to S0 sprite check

CHK_FR22_EXISTS:
    RRCA                                            ; Test bit 2 (next flag)
    JP          C,DRAW_FR1_B_WALL                   ; If bit set, draw wall
    CALL        DRAW_WALL_FR22_EMPTY                ; Draw empty FR2 space
    CALL        CHK_ITEM_SR1                        ; Check and draw SR1 item

CHK_ITEM_S0:
    LD          A,(ITEM_S0)                         ; Load sprite at S0 position
    LD          BC,CHRRAM_S0_ITEM_DRAW_IDX          ; BC = $328a
    LD          B,0                                 ; BC = $008a; B = 0 (regular size item)
    JP          CHK_ITEM                            ; Check and draw S0 item

CHK_ITEM_RH:
    LD          A,(RIGHT_HAND_ITEM)                 ; Load sprite at RH position
    LD          BC,CHRRAM_RIGHT_HAND_VP_DRAW_IDX    ; BC = $3294
    LD          B,0                                 ; BC = $0094
    JP          CHK_ITEM                            ; Check and draw RH sprite

;==============================================================================
; MAKE_RANDOM_BYTE - Generate pseudo-random byte using 16-bit LFSR
;==============================================================================
; Generates a pseudo-random byte using a 16-bit Linear Feedback Shift Register
; (LFSR) with XOR taps. Runs 5 iterations of shift-and-XOR to produce quality
; randomness. Seeds from RND_SEED_LFSR which must be initialized at startup.
;
; Algorithm: For each iteration:
;   1. Shift HL left (L << 1, H << 1 with carry)
;   2. If carry: HL = HL (entropy from overflow)
;   3. If no carry: L ^= $87, H ^= $1D (polynomial taps)
;
; Registers:
; --- Start ---
;   BC = Pushed for preservation
;   HL = Pushed for preservation
; --- In Process ---
;   B  = Loop counter (5 iterations)
;   HL = LFSR state from RND_SEED_LFSR
;   A  = XOR masks ($87, $1D) during computation
; ---  End  ---
;   A  = Random byte (H from final LFSR state)
;   BC = Restored
;   HL = Restored
;   F  = Flags from final POP
;
; Memory Modified: RND_SEED_LFSR (updated seed)
; Calls: None
;==============================================================================
MAKE_RANDOM_BYTE:
    PUSH        BC                                  ; Preserve BC register
    PUSH        HL                                  ; Preserve HL register
    LD          B,0x5                               ; Run data randomizer 5 iterations
    LD          HL,(RND_SEED_LFSR)                  ; Load random seed value
RANDOM_BYTE_LOOP:
    SLA         L                                   ; Shift L left (multiply by 2)
    RL          H                                   ; Rotate H left with carry
    JP          C,FINISH_BYTE_LOOP                  ; If carry set, skip XOR step
    LD          A,$87                               ; Load XOR mask $87
    XOR         L                                   ; XOR with L
    LD          L,A                                 ; Store result in L
    LD          A,$1d                               ; Load XOR mask $1D
    XOR         H                                   ; XOR with H
    LD          H,A                                 ; Store result in H
FINISH_BYTE_LOOP:
    DJNZ        RANDOM_BYTE_LOOP                    ; Decrement B, loop if non-zero
    LD          (RND_SEED_LFSR),HL                  ; Store updated random seed
    LD          A,H                                 ; Return random byte in A
    POP         HL                                  ; Restore HL register
    POP         BC                                  ; Restore BC register
    RET                                             ; Return with random byte in A
;==============================================================================
; UPDATE_SCR_SAVER_TIMER - Update screen saver timer with polynomial feedback
;==============================================================================
; Updates a 16-bit timer using polynomial multiplication and XOR feedback to
; generate pseudo-random values. Formula: timer = (timer * 9) + $13, then
; returns H XOR L as a pseudo-random byte in RANDOM_OUTPUT_BYTE.
;
; Algorithm:
;   1. BC = timer * 4 (shift left twice)
;   2. timer = timer + BC (timer *= 5)
;   3. RANDOM_OUTPUT_BYTE = H XOR L (random output)
;   4. BC = timer * 4 (second shift sequence)
;   5. timer = timer + BC (timer *= 9 from original)
;   6. timer = timer + $13
;
; Registers:
; --- Start ---
;   BC = Pushed for preservation
;   HL = Pushed for preservation
; --- In Process ---
;   HL = RND_SEED_POLY value
;   BC = Multiplication intermediates (HL * 4)
;   A  = H XOR L result
; ---  End  ---
;   A  = Pseudo-random byte from RANDOM_OUTPUT_BYTE
;   BC = Restored
;   HL = Restored
;   F  = Flags from final POP
;
; Memory Modified: RND_SEED_POLY, RANDOM_OUTPUT_BYTE
; Calls: None
;==============================================================================
UPDATE_SCR_SAVER_TIMER:
    PUSH        BC                                  ; Preserve BC register
    PUSH        HL                                  ; Preserve HL register
    LD          HL,(RND_SEED_POLY)                  ; Load timer value into HL
    LD          B,H                                 ; Copy H to B
    LD          C,L                                 ; Copy L to C
    SLA         C                                   ; Shift C left (BC *= 2)
    RL          B                                   ; Rotate B left with carry
    SLA         C                                   ; Shift C left again (BC *= 4)
    RL          B                                   ; Rotate B left with carry
    ADD         HL,BC                               ; HL = HL + BC (HL *= 5)
    LD          A,H                                 ; Load H into A
    XOR         L                                   ; XOR H with L
    LD          (PLAYER_MELEE_RANDOMIZER),A              ; Store result in RANDOM_OUTPUT_BYTE
    LD          B,H                                 ; Copy H to B
    LD          C,L                                 ; Copy L to C
    SLA         C                                   ; Shift C left (BC *= 2)
    RL          B                                   ; Rotate B left with carry
    SLA         C                                   ; Shift C left again (BC *= 4)
    RL          B                                   ; Rotate B left with carry
    ADD         HL,BC                               ; HL = HL + BC (HL *= 9 from original)
    LD          BC,$13                              ; Load constant $13
    ADD         HL,BC                               ; HL = HL + $13
    LD          (RND_SEED_POLY),HL                  ; Store updated timer value
    POP         HL                                  ; Restore HL register
    POP         BC                                  ; Restore BC register
    RET                                             ; Return with pseudo-random in RANDOM_OUTPUT_BYTE
;==============================================================================
; MINOTAUR_DEAD - Victory sequence when Minotaur is defeated
;==============================================================================
; Displays "THE END" screen with Minotaur sprite, fully heals player, plays
; victory sound sequence, then transitions to screen saver. Marks successful
; completion of the game.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = Random values, rotated MULTIPURPOSE_BYTE
;   B  = Color values, sound loop counter
;   DE = Text pointers, sprite data pointer
;   HL = Screen positions
; ---  End  ---
;   Control transfers to SCREEN_SAVER_FULL_SCREEN (no return)
;
; Memory Modified: MULTIPURPOSE_BYTE (cleared), CHRRAM/COLRAM (full screen), player stats
; Calls: DRAW_BKGD, GFX_DRAW, MAKE_RANDOM_BYTE, TOTAL_HEAL, REDRAW_STATS, PLAY_MONSTER_GROWL, END_OF_GAME_SOUND, SCREEN_SAVER_FULL_SCREEN
;==============================================================================
MINOTAUR_DEAD:
    CALL        DRAW_BKGD                           ; Draw background
    LD          HL,CHRRAM_END_TEXT_IDX              ; HL = first text data address
    LD          DE,END_PORTAL_TEXT                  ; DE = screen position for END_PORTAL_TEXT
    LD          B,$10                               ; B = color (RED on BLACK)
    CALL        GFX_DRAW                            ; Draw END_PORTAL_TEXT
    LD          A,0                                 ; Clear A (A = 0)
    LD          (DIFFICULTY_LEVEL),A                ; Clear DIFFICULTY_LEVEL
    LD          B,COLOR(WHT,BLK)                    ; Portal color is WHT
    LD          DE,END_PORTAL                       ; DE = END_PORTAL sprite data
    LD          HL,CHRRAM_END_PORTAL_IDX            ; HL = END_PORTAL screen position
    CALL        GFX_DRAW                            ; Draw END_PORTAL sprite
    CALL        TOTAL_HEAL                          ; Fully heal player
    CALL        REDRAW_STATS                        ; Update stats display

    LD          B,0x2                               ; B = 2 (sound loop count, was 6)
MINOTAUR_DEAD_SOUND_LOOP:
    EXX                                             ; Switch to alternate register set
    CALL        END_PORTAL_FLICKER                  ; Display and flicker portal
    CALL        PLAY_MONSTER_GROWL                  ; Play monster growl sound
    EXX                                             ; Switch back to main registers
    DJNZ        MINOTAUR_DEAD_SOUND_LOOP            ; Loop B times
    CALL        END_OF_GAME_SOUND                   ; Play end game sound

    JP          INPUT_DEBOUNCE                      ; Jump to wait for key
END_PORTAL_FLICKER:
    LD          B,COLOR(WHT,BLK)                    ; WHT on BLK starting color
END_PORTAL_FLICKER_LOOP:
    LD          DE,END_PORTAL                       ; DE = END_PORTAL sprite data
    LD          HL,CHRRAM_END_PORTAL_IDX            ; HL = END_PORTAL screen position
    CALL        GFX_DRAW                            ; Draw END_PORTAL sprite
    DJNZ        END_PORTAL_FLICKER_LOOP             ; Loop until B is depleted
END_PORTAL_FINISH:
    LD          A,COLOR(WHT,BLK)                    ; WHT on BLK
    LD          HL,COLRAM_END_PORTAL                ; COLRAM background for portal graphic
    LD          BC,RECT(8,8)                        ; 8 x 8 rectangle
    CALL        FILL_CHRCOL_RECT                    ; Draw the background colors

    LD          B,COLOR(WHT,BLK)                    ; WHT on BLK
    LD          DE,END_PORTAL                       ; DE = END_PORTAL sprite data
    LD          HL,CHRRAM_END_PORTAL_IDX            ; HL = END_PORTAL screen position
    CALL        GFX_DRAW                            ; Draw END_PORTAL sprite
    RET                                             ; Done

;==============================================================================
; DO_REST - Rest to recover health by consuming food
;==============================================================================
; Allows player to rest and recover health (physical and spiritual) by consuming
; food from inventory. Each point of health costs 1 food. Cannot rest during
; combat. Continues until fully healed or food exhausted.
;
; Healing Order:
;   1. Physical health to max
;   2. Spiritual health to max
;   3. Cycles between phys/sprt if both partially damaged
;
; Registers:
; --- Start ---
;   A = Combat flag check
; --- In Process ---
;   A  = Health comparisons, inventory checks
;   HL = Health values, food pointer, rest counter
;   DE = Health deltas, increment values
;   C  = Max health comparison values
; ---  End  ---
;   Control transfers to INPUT_DEBOUNCE or CHK_NEEDS_HEALING loop
;
; Memory Modified: PLAYER_PHYS_HEALTH, PLAYER_SPRT_HEALTH, FOOD_INV, REST_FOOD_COUNTER
; Calls: RECALC_PHYS_HEALTH, ADD_BCD_HL_DE, REDRAW_STATS, INPUT_DEBOUNCE
;==============================================================================
DO_REST:
    LD          A,(COMBAT_BUSY_FLAG)                ; Load combat busy flag
    AND         A                                   ; Test if zero
    JP          NZ,NO_ACTION_TAKEN                  ; If in combat, can't rest
CHK_NEEDS_HEALING:
    LD          HL,(PLAYER_PHYS_HEALTH_MAX)         ; HL = max physical health
    LD          DE,(PLAYER_PHYS_HEALTH)             ; DE = current physical health
    CALL        RECALC_PHYS_HEALTH                  ; Calculate difference (HL - DE)
    OR          L                                   ; Check if result is non-zero
    JP          NZ,HEAL_PLAYER_PHYS_HEALTH          ; If needs phys healing, do it
    LD          A,(PLAYER_SPRT_HEALTH_MAX)          ; Load max spiritual health
    LD          C,A                                 ; Store in C for comparison
    LD          A,(PLAYER_SPRT_HEALTH)              ; Load current spiritual health
    CP          C                                   ; Compare current to max
    JP          Z,INPUT_DEBOUNCE                    ; If at max health, done resting
    JP          HEAL_PLAYER_SPRT_HEALTH             ; Otherwise heal spiritual
HEAL_PLAYER_PHYS_HEALTH:
    LD          HL,(REST_FOOD_COUNTER)              ; Load rest counter/timer
    LD          DE,0x1                              ; DE = 1 (amount to check)
    CALL        RECALC_PHYS_HEALTH                  ; Check if can consume food
    JP          C,INPUT_DEBOUNCE                    ; If can't afford, exit
    LD          (REST_FOOD_COUNTER),HL              ; Update rest counter
    LD          HL,FOOD_INV                         ; HL = food inventory address
    DEC         (HL)                                ; Decrease food by 1
    LD          HL,(PLAYER_PHYS_HEALTH)             ; Load current physical health
    CALL        ADD_BCD_HL_DE                       ; Add 1 to health (BCD)
    LD          (PLAYER_PHYS_HEALTH),HL             ; Store updated health
    CALL        REDRAW_STATS                        ; Update stats display
    CALL        REDRAW_FOOD_GRAPH                   ; Redraw food inv graphic
    LD          A,(PLAYER_SPRT_HEALTH_MAX)          ; Load max spiritual health
    LD          C,A                                 ; Store in C for comparison
    LD          A,(PLAYER_SPRT_HEALTH)              ; Load current spiritual health
    CP          C                                   ; Compare current to max
    JP          Z,CHK_NEEDS_HEALING                 ; If at max sprt, check phys again
HEAL_PLAYER_SPRT_HEALTH:
    LD          HL,(REST_FOOD_COUNTER)              ; Load rest counter/timer
    LD          DE,0x1                              ; DE = 1 (amount to check)
    CALL        RECALC_PHYS_HEALTH                  ; Check if can consume food
    JP          C,INPUT_DEBOUNCE                    ; If can't afford, exit
    LD          (REST_FOOD_COUNTER),HL              ; Update rest counter
    LD          HL,FOOD_INV                         ; HL = food inventory address
    DEC         (HL)                                ; Decrease food by 1
    LD          A,(PLAYER_SPRT_HEALTH)              ; Load current spiritual health
    ADD         A,0x1                               ; Add 1
    DAA                                             ; Decimal adjust for BCD
    LD          (PLAYER_SPRT_HEALTH),A              ; Store updated spiritual health
    CALL        REDRAW_STATS                        ; Update stats display
    CALL        REDRAW_FOOD_GRAPH                   ; Redraw food inv graphic
    JP          CHK_NEEDS_HEALING                   ; Check if more healing needed
;==============================================================================
; KEY_COMPARE - Scan keyboard matrix and dispatch to action handlers
;==============================================================================
; Scans all 8 keyboard columns (64 keys total) and dispatches to appropriate
; action handlers based on key states. Each column contains 6 rows tested with
; CP instructions. Key matrix uses active-low encoding ($FE-$DF for rows 0-5).
;
; Keyboard Layout (by column):
;   Col 0: =, BKSP, :, RET, ; (glance R), . (turn R)
;   Col 1: -, /, 0, P, L (move fwd), , (jump back)
;   Col 2: 9, O, K (move fwd), M (turn L), N (use/attack), J (glance L)
;   Col 3: 8, I, 7, U, H (open/close), B
;   Col 4: 6, Y (map), G, V, C (count arrows), F (rest)
;   Col 5: 5, T (teleport), 4, R (swap pack), D (ladder), X (count food)
;   Col 6: 3, E (swap hands), S (rotate pack), Z (wipe walls), SPC, A
;   Col 7: 2, W (pick up), 1, Q (max stats), SHFT, CTRL
;
; Registers:
; --- Start ---
;   A = KEYBOARD_SCAN_FLAG scan flag
; --- In Process ---
;   A  = Column states, row comparisons
;   HL = KEY_INPUT_COL0, incremented through columns
;   L  = Column offset (INC L for next column)
; ---  End  ---
;   Control transfers (no return)
;
; Memory Modified: None directly (action handlers modify game state)
; Calls: Various action handlers (DO_*, USE_*, etc.)
;==============================================================================
KEY_COMPARE:
    LD          A,(MONSTER_MELEE_STATE)             ; Load MONSTER_MELEE_STATE
    CP          $31                                 ; Check for if in battle
    JP          NZ,WAIT_FOR_INPUT                   ; If no key, wait for input
KEY_COL_0:
    LD          HL,KEY_INPUT_COL0                   ; HL = keyboard column 0 address
    LD          A,(HL)                              ; A = key column 0 state
    ; CP          $fe                                 ; Test row 0 "="
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    ; CP          $fd                                 ; Test row 1 "BKSP"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    ; CP          $fb                                 ; Test row 2 ":"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    ; CP          $f7                                 ; Test row 3 "RET"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    CP          $ef                                 ; Test row 4 ";"
    JP          Z,DO_GLANCE_RIGHT                   ; If pressed, glance right
    CP          $df                                 ; Test row 5 "."
    JP          Z,DO_TURN_RIGHT                     ; If pressed, turn right
KEY_COL_1:
    INC         L                                   ; Move to column 1
    LD          A,(HL)                              ; A = key column 1 state
    ; CP          $fe                                 ; Test row 0 "-"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    ; CP          $fd                                 ; Test row 1 "/"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    ; CP          $fb                                 ; Test row 2 "0"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    ; CP          $f7                                 ; Test row 3 "P"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    CP          $ef                                 ; Test row 4 "L"
    JP          Z,DO_MOVE_FW_CHK_WALLS              ; If pressed, move forward
    CP          $df                                 ; Test row 5 ","
    JP          Z,DO_JUMP_BACK                      ; If pressed, jump back
KEY_COL_2:
    INC         L                                   ; Move to column 2
    LD          A,(HL)                              ; A = key column 2 state
    ; CP          $fe                                 ; Test row 0 "9"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    ; CP          $fd                                 ; Test row 1 "O"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    CP          $fb                                 ; Test row 2 "K"
    JP          Z,DO_MOVE_FW_CHK_WALLS              ; If pressed, move forward
    CP          $f7                                 ; Test row 3 "M"
    JP          Z,DO_TURN_LEFT                      ; If pressed, turn left
    CP          $ef                                 ; Test row 4 "N"
    JP          Z,DO_USE_ATTACK                     ; If pressed, use attack
    CP          $df                                 ; Test row 5 "J"
    JP          Z,DO_GLANCE_LEFT                    ; If pressed, glance left
KEY_COL_3:
    INC         L                                   ; Move to column 3
    LD          A,(HL)                              ; A = key column 3 state
    ; CP          $fe                                 ; Test row 0 "8"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    ; CP          $fd                                 ; Test row 1 "I"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    ; CP          $fb                                 ; Test row 2 "7"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    ; CP          $f7                                 ; Test row 3 "U"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    CP          $ef                                 ; Test row 4 "H"
    JP          Z,DO_OPEN_CLOSE                     ; If pressed, open/close door
    ; CP          $df                                 ; Test row 5 "B"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
KEY_COL_4:
    INC         L                                   ; Move to column 4
    LD          A,(HL)                              ; A = key column 4 state
    ; CP          $fe                                 ; Test row 0 "6"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    ; CP          $fd                                 ; Test row 1 "Y"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    ; CP          $fb                                 ; Test row 2 "G"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    ; CP          $f7                                 ; Test row 3 "V"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    CP          $ef                                 ; Test row 4 "C"
    JP          Z,USE_MAP                           ; If pressed, use map
    CP          $df                                 ; Test row 5 "F"
    JP          Z,DO_REST                           ; If pressed, rest
KEY_COL_5:
    INC         L                                   ; Move to column 5
    LD          A,(HL)                              ; A = key column 5 state
    ; CP          $fe                                 ; Test row 0 "5"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    CP          $fd                                 ; Test row 1 "T"
    JP          Z,DO_TELEPORT                       ; If pressed, teleport
    ; CP          $fb                                 ; Test row 2 "4"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    CP          $f7                                 ; Test row 3 "R"
    JP          Z,DO_SWAP_PACK                      ; If pressed, swap pack
    CP          $ef                                 ; Test row 4 "D"
    JP          Z,DO_USE_LADDER                     ; If pressed, use ladder
    CP          $df                                 ; Test row 5 "X"
    JP          Z,USE_KEY                           ; If pressed, use key

KEY_COL_6:
    INC         L                                   ; Move to column 6
    LD          A,(HL)                              ; A = key column 6 state
    ; CP          $fe                                 ; Test row 0 "3"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    CP          $fd                                 ; Test row 1 "E"
    JP          Z,DO_SWAP_HANDS                     ; If pressed, swap hands
    CP          $fb                                 ; Test row 2 "S"
    JP          Z,DO_ROTATE_PACK                    ; If pressed, rotate pack
    ; CP          $f7                                 ; Test row 3 "Z"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    ; CP          $ef                                 ; Test row 4 "SPC"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    ; CP          $df                                 ; Test row 5 "A"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
KEY_COL_7:
    INC         L                                   ; Move to column 7
    LD          A,(HL)                              ; A = key column 7 state
    ; CP          $fe                                 ; Test row 0 "2"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    CP          $fd                                 ; Test row 1 "W"
    JP          Z,DO_PICK_UP                        ; If pressed, pick up item
    ; CP          $fb                                 ; Test row 2 "1"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    CP          $f7                                 ; Test row 3 "Q"
    JP          Z,MAX_HEALTH_ARROWS_FOOD            ; If pressed, max stats (cheat?)
    CP          $ef                                 ; Test row 4 "SHFT"
    JP          Z,TOGGLE_SHIFT_MODE                 ; If pressed, toggle SHIFT mode
    ; CP          $df                                 ; Test row 5 "CTRL"
    ; JP          Z,NO_ACTION_TAKEN                   ; If pressed, ignore
    JP          NO_ACTION_TAKEN                     ; No valid key, ignore

;==============================================================================
; MAX_HEALTH_ARROWS_FOOD - Debug cheat to maximize player stats
;==============================================================================
; Sets all player health values (PHYS current/max, SPRT current/max) and
; inventory (FOOD, ARROWS) to maximum value (99 BCD). Plays power-up sound,
; redraws stats display, and returns to input loop. Developer debug feature.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = $99 (max value in BCD)
;   HL = PLAYER_PHYS_HEALTH, incremented through stats block, then FOOD_INV
; ---  End  ---
;   A  = $99
;   HL = ARROW_INV + 1
;   Other registers modified by PLAY_POWER_UP_SOUND and REDRAW_STATS
;
; Memory Modified: PLAYER_PHYS_HEALTH (6 bytes), FOOD_INV, ARROW_INV
; Calls: PLAY_POWER_UP_SOUND, REDRAW_STATS, INPUT_DEBOUNCE
;==============================================================================
MAX_HEALTH_ARROWS_FOOD:
    LD          A,MAX_HEALTH                        ; Get from MAX_HEALTH constant (99)
UPDATE_HEALTH_ARROWS_FOOD:
    LD          HL,PLAYER_PHYS_HEALTH               ; HL = start of health stats block
    LD          (HL),A                              ; Store 99 in PLAYER_PHYS_HEALTH (current)
    INC         HL                                  ; Advance to PLAYER_PHYS_HEALTH+1 (current high)
    LD          (HL),A                              ; Store 99 in PLAYER_PHYS_HEALTH high byte
    INC         HL                                  ; Advance to PLAYER_PHYS_HEALTH_MAX
    LD          (HL),A                              ; Store 99 in PLAYER_PHYS_HEALTH_MAX (low)
    INC         HL                                  ; Advance to PLAYER_PHYS_HEALTH_MAX+1
    LD          (HL),A                              ; Store 99 in PLAYER_PHYS_HEALTH_MAX (high)
    INC         HL                                  ; Advance to PLAYER_SPRT_HEALTH
    LD          (HL),A                              ; Store 99 in PLAYER_SPRT_HEALTH (current)
    INC         HL                                  ; Advance to PLAYER_SPRT_HEALTH_MAX
    LD          (HL),A                              ; Store 99 in PLAYER_SPRT_HEALTH_MAX
    LD          A,MAX_FOOD                          ; Load MAX_FOOD
    LD          HL,FOOD_INV                         ; HL = food inventory address
    LD          (HL),A                              ; Store max food in FOOD_INV
    INC         HL                                  ; Advance to ARROW_INV
    LD          A,MAX_ARROWS                        ; Load MAX_ARROWS
    LD          (HL),A                              ; Store max arrows in ARROW_INV
    CALL        PLAY_POWER_UP_SOUND                 ; Play ascending tone sequence
    CALL        REDRAW_STATS                        ; Update stats panel display
    CALL        REFRESH_FOOD_ARROWS                 ; Refresh Arrow & Food graph
    JP          INPUT_DEBOUNCE                      ; Return to input loop

;==============================================================================
; DO_TELEPORT - Teleport player to ladder location
;==============================================================================
; Debug feature that instantly teleports the player to the ladder position
; stored in MAP_LADDER_OFFSET. Plays teleport sound effect and updates the
; viewport to show the new location.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A = MAP_LADDER_OFFSET value (ladder position)
; ---  End  ---
;   A = Ladder position
;   Other registers modified by PLAY_TELEPORT_SOUND and UPDATE_VIEWPORT
;
; Memory Modified: PLAYER_MAP_POS
; Calls: PLAY_TELEPORT_SOUND, UPDATE_VIEWPORT
;==============================================================================
DO_TELEPORT:
    LD          A,(GAME_BOOLEANS)                   ; Get game booleans
    BIT         0x4,A                               ; Check Teleport flag
    JP          Z,NO_ACTION_TAKEN                   ; Exit if Teleport isn't active
    CALL        CLEAR_MONSTER_STATS                 ; Get out of combat.
    LD          A,(MAP_LADDER_OFFSET)               ; A = ladder position on map
    LD          (PLAYER_MAP_POS),A                  ; Set player position to ladder
    CALL        PLAY_TELEPORT_SOUND                 ; Play descending tone sequence
    JP          UPDATE_VIEWPORT                     ; Redraw view at new location

;==============================================================================
; REDRAW_STATS - Update player stats display panel
;==============================================================================
; Redraws the stats panel by updating icon colors and redrawing both physical
; and spiritual health values in BCD format to their screen positions. Called
; after any change to player stats (healing, damage, max stat changes, etc.).
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   HL = PLAYER_PHYS_HEALTH, then PLAYER_SPRT_HEALTH
;   DE = CHRRAM_PHYS_HEALTH_1000, then CHRRAM_SPRT_HEALTH_10
;   B  = Byte count (2 for PHYS, 1 for SPRT)
; ---  End  ---
;   All registers modified by RECALC_AND_REDRAW_BCD
;
; Memory Modified: CHRRAM stats panel area
; Calls: DRAW_ICON_BAR, RECALC_AND_REDRAW_BCD
;==============================================================================
REDRAW_STATS:
    CALL        DRAW_ICON_BAR                       ; Update icon colors (Ring/Helmet/Armor)
    LD          HL,PLAYER_PHYS_HEALTH               ; HL = physical health address
    LD          DE,CHRRAM_PHYS_HEALTH_1000          ; DE = screen position for PHYS display
    LD          B,0x2                               ; B = 2 bytes (16-bit BCD)
    CALL        RECALC_AND_REDRAW_BCD               ; Draw physical health value
    LD          HL,PLAYER_SPRT_HEALTH               ; HL = spiritual health address
    LD          DE,CHRRAM_SPRT_HEALTH_10            ; DE = screen position for SPRT display
    LD          B,0x1                               ; B = 1 byte (8-bit BCD)
    JP          RECALC_AND_REDRAW_BCD               ; Draw spiritual health value and return

CHK_ITEM_S2_NEW:
    LD          A,(ITEM_S2)                         ; Load sprite at S2 position
    LD          BC,CHRRAM_S2_ITEM_DRAW_IDX          ; BC = $328a
    LD          B,4                                 ; BC = $048a; B = 4 (tiny size item)
    CALL        CHK_ITEM                            ; Check and draw S2 item tiny
    RET

CHK_ITEM_S1_NEW:
    LD          A,(ITEM_S1)                         ; Load sprite at S1 position
    LD          BC,CHRRAM_S1_ITEM_DRAW_IDX          ; BC = $328a
    LD          B,2                                 ; BC = $028a; B = 2 (small size item)
    CALL        CHK_ITEM                            ; Check and draw S1 item small
    RET

CHK_ITEM_S0_NEW:
    LD          A,(ITEM_S0)                         ; Load sprite at S0 position
    LD          BC,CHRRAM_S0_ITEM_DRAW_IDX          ; BC = $328a
    LD          B,0                                 ; BC = $008a; B = 0 (regular size item)
    JP          CHK_ITEM                            ; Check and draw S0 item regular

CHK_ITEM_RH_NEW:
    LD          A,(RIGHT_HAND_ITEM)                 ; Load sprite at RH position
    LD          BC,CHRRAM_RIGHT_HAND_VP_DRAW_IDX    ; BC = $3294
    LD          B,0                                 ; BC = $0094
    JP          CHK_ITEM                            ; Check and draw RH sprite

;==============================================================================
; REFRESH_FOOD_ARROWS - Redraw Food and Arrows Graphics
;==============================================================================
; Triggered after either food or arrows inventories have been altered,
; this function redraws the graphic representation of food and arrows
; in a vertical bar graph form.
;
; Registers:
; --- Start ---
;   None
; --- In Process ---
;   A  = Accumulator; inventory values
;   HL = Screen Location for updates; index for VERTICAL_BAR_METER character
;   BC = CHRRAM/COLRAM offset; offset for generating VERTICAL_BAR_METER character
;   All registers modified by PLAY_SOUND_LOOP
; ---  End  ---
;   All registers modified
;
; Memory Modified: ???
; Calls: ???
;==============================================================================

REFRESH_FOOD_ARROWS:
    CALL        REDRAW_FOOD_BKGD                    ; Redraw the food base graphics and colors
    CALL        REDRAW_FOOD_GRAPH                   ; Update the food graph
    CALL        REDRAW_ARROWS_BKGD                  ; Redraw the arrows base graphics and colors
    CALL        REDRAW_ARROWS_GRAPH                 ; Update the arrows graph
    RET                                             ; Return

REDRAW_FOOD_BKGD:
    LD          HL,CHRRAM_FOOD_ICON                 ; Food icon location
    LD          BC,$400                             ; COLRAM Offset
    LD          DE,40                               ; Row stride
    LD          A,'#'                               ; Food '#' AQUASCII
    LD          (HL),A                              ; Update food Icon CHRRAM
    ADD         HL,BC                               ; Jump to COLRAM
    LD          A,COLOR(DKMAG,BLK)                  ; DKMAG on BLK
    LD          (HL),A                              ; Update food Icon COLRAM
    ADD         HL,DE                               ; One row down in COLRAM
    LD          A,COLOR(DKMAG,DKBLU)                ; DKMAG on DKBLU
    LD          (HL),A                              ; Update Food HI value in COLRAM
    ADD         HL,DE                               ; One row down in COLRAM
    LD          (HL),A                              ; Update Food LO value in COLRAM
    RET                                             ; Done

REDRAW_ARROWS_BKGD:
    LD          HL,CHRRAM_ARROWS_ICON               ; Arrows icon location
    LD          BC,$400                             ; COLRAM Offset
    LD          DE,40                               ; Row stride
    LD          A,13                                ; Arrow UL char in AQUASCII
    LD          (HL),A                              ; Update Arrows Icon CHRRAM
    ADD         HL,BC                               ; Jump to COLRAM
    LD          A,COLOR(DKGRN,BLK)                  ; DKGRN on BLK
    LD          (HL),A                              ; Update Arrows Icon COLRAM
    ADD         HL,DE                               ; One row down in COLRAM
    LD          A,COLOR(DKGRN,DKBLU)                ; DKGRN on DKBLU
    LD          (HL),A                              ; Update Arrows HI value in COLRAM
    ADD         HL,DE                               ; One row down in COLRAM
    LD          (HL),A                              ; Update Arrows LO value in COLRAM
    RET                                             ; Done

REDRAW_FOOD_GRAPH:
    LD          A,(FOOD_INV)                        ; Get current food values
    LD          HL,CHRRAM_FOOD_HI_IDX               ; Set HL to Food HI index
    JP          REDRAW_INV_GRAPH                    ; Handle redraw of food inv graph

REDRAW_ARROWS_GRAPH:
    LD          A,(ARROW_INV)                       ; Get current arrows values
    LD          HL,CHRRAM_ARROWS_HI_IDX             ; Set HL to Arrows HI index
    JP          REDRAW_INV_GRAPH                    ; Handle redraw of arrows inv graph

;==============================================================================
; REDRAW_INV_GRAPH - Redraw Food or Arrows Graphics
;==============================================================================
; Redraw an individual inventory using a vertical bar, values 0 - 128 ($00 - $80).
;
; Registers:
; --- Start ---
;   A  = Item inventory value
;   HL = CHRRAM HI value index
; --- In Process ---
;   A  = Accumulator; inventory values
;   HL = Screen Location for updates; index for VERTICAL_BAR_METER character
;   BC = CHRRAM/COLRAM offset; offset for generating VERTICAL_BAR_METER character
; ---  End  ---
;   All registers modified
;
; Memory Modified: CHRRAM INV HI and LO blocks
;==============================================================================

REDRAW_INV_GRAPH:
    PUSH        HL                                  ; Save the CHRRAM INV HI location
    LD          DE,40                               ; Row stride
    LD          (HL),32                             ; Fill upper meter with SPACE char
    ADD         HL,DE                               ; Down one row
    LD          (HL),32                             ; Fill lower meter with SPACE char
    CP          65                                  ; Compare to hi/lo boundary
    JP          C,DRAW_INV_LO                       ; If 64 or less, do the lower graph
    
DRAW_INV_HI:
    LD          HL,VERTICAL_BAR_METER               ; Set screen index of bar characters, 0
    ADD         A,7                                 ; Normalize up to 8's level
    SBC         A,64                                ; Reduce hi to lo
    SRL         A
    SRL         A
    SRL         A                                   ; Divide by 8
    LD          B,$0                                ; Clear B...
    LD          C,A                                 ; ...and load A into C for BC
    ADD         HL,BC                               ; Offset to get correct "bar" character
    LD          A,(HL)                              ; Save it into A
    POP         HL                                  ; Restore the CHRRAM INV HI location
    LD          (HL),A                              ; Write A to it
    ADD         HL,DE                               ; Down one row
    LD          A,(VERTICAL_BAR_METER + 8)          ; Get "full" char for lower bars
    LD          (HL),A                              ; Write A to it
    RET                                             ; Done
DRAW_INV_LO:
    LD          HL,VERTICAL_BAR_METER               ; Set starting index of bar characters, 0)
    ADD         A,7                                 ; Normalize up to 8's level
    SRL         A
    SRL         A
    SRL         A                                   ; Divide by 8
    LD          B,$0                                ; Clear B...
    LD          C,A                                 ; ...and load A into C for BC
    ADD         HL,BC                               ; Offset to get correct "bar" character
    LD          A,(HL)                              ; Save it into A
    POP         HL                                  ; Restore the CHRRAM INV HI location
    ADD         HL,DE                               ; Down one row
    LD          (HL),A                              ; Write A to it
    SBC         HL,DE                               ; Up one row
    LD          A,(VERTICAL_BAR_METER)              ; Get "empty" char for upper bars
    LD          (HL),A                              ; Write A to it
    RET                                             ; Done

VERTICAL_BAR_METER:
    db          32                                  ; 0 meter
    db          144                                 ; 1 meter
    db          136                                 ; 2 meter
    db          240                                 ; 3 meter
    db          31                                  ; 4 meter
    db          252                                 ; 5 meter
    db          137                                 ; 6 meter
    db          128                                 ; 7 meter
    db          127                                 ; 8 meter

; Unused BCD to HEX conversion routine
; BCD2HEX:
;     PUSH        BC                                  ; Save register
;     LD          B,A                                 ; Store original BCD in B
;     AND         $F0                                 ; Isolate tens digit (high nibble)
;     RRCA                                            ; Shift right 4 times to get 0-9 value
;     RRCA
;     RRCA
;     RRCA
;     LD          C, A                                ; C = tens digit
;     ADD         A, A                                ; A = tens * 2
;     ADD         A, A                                ; A = tens * 4
;     ADD         A, C                                ; A = tens * 5
;     ADD         A, A                                ; A = tens * 10
;     LD          C, A                                ; C = tens * 10
;     LD          A, B                                ; Recover original BCD
;     AND         $0F                                 ; Isolate units digit (low nibble)
;     ADD         A, C                                ; Add tens*10 to units
;     POP         BC                                  ; Restore register
;     RET

;==============================================================================
; FIX_MELEE_GLITCH_BEGIN & END
;==============================================================================
; Fixes a visual glitch in the MONSTER's weapon animation where a remnant
; of their weapon sprite gets drawn above the pack area. This copies the
; CHRRAM and COLRAM data from those locations to a buffer, then restores them
; after the routine is complete.
;
; Registers:
; --- Start ---
;   HL = Saved offset for monster weapon.
; --- In Process ---
;   HL = Screen address from which we are copying
;   DE = Buffer address to which we are copying
; ---  End  ---
;   HL = Restored offset for monster weapon.
;
; Memory Modified: Screen memory at top of pack area
; Calls: COPY_GFX_2_BUFFER, COPY_GFX_FROM_BUFFER
;==============================================================================

FIX_MELEE_GLITCH_BEGIN:
    PUSH        HL                                  ; Save HL
    LD          HL,CHRRAM_MELEE_GLITCH_A            ; Set CHRRAM_MELEE_GLITCH_A source location
    LD          DE,MELEE_GLITCH_A_CHR_BUFF          ; Set MELEE_GLITCH_A_CHR_BUFF destination location
    CALL        COPY_GFX_2_BUFFER                   ; Copy screen to buffer

    LD          HL,CHRRAM_MELEE_GLITCH_B            ; Set CHRRAM_MELEE_GLITCH_B source location
    LD          DE,MELEE_GLITCH_B_CHR_BUFF          ; Set MELEE_GLITCH_B_CHR_BUFF desitnation location
    CALL        COPY_GFX_2_BUFFER                   ; Copy screen to buffer
    POP         HL                                  ; Restore HL
    RET                                             ; Done

FIX_MELEE_GLITCH_END:
    PUSH        HL                                  ; Save HL
    LD          HL,MELEE_GLITCH_A_CHR_BUFF          ; Set MELEE_GLITCH_A_CHR_BUFF source location
    LD          DE,CHRRAM_MELEE_GLITCH_A            ; Set CHRRAM_MELEE_GLITCH_A destination location
    CALL        COPY_GFX_FROM_BUFFER                ; Copy buffer to screen

    LD          HL,MELEE_GLITCH_B_CHR_BUFF          ; Set MELEE_GLITCH_B_CHR_BUFF source location
    LD          DE,CHRRAM_MELEE_GLITCH_B            ; Set CHRRAM_MELEE_GLITCH_B destination location
    CALL        COPY_GFX_FROM_BUFFER                ; Copy buffer to screen
    POP         HL                                  ; Restore HL
    RET                                             ; Done

;==============================================================================
; WHITE_NOISE_BURST
;==============================================================================
; Setup routine for white noise burst with default parameters. Configures
; outer and inner loop counts for standard "whoosh" effect duration and pitch,
; then calls PLAY_WHITE_NOISE_BURST. Preserves AF and BC on entry/exit.
;
; Default Parameters:
;   B = 128 (outer loop - burst duration in 32-toggle blocks)
;   C = 32  (inner loop - toggle rate per block)
;
; Registers:
; --- Start ---
;   AF, BC = Preserved internally
; --- In Process ---
;   A = repeat count (setup)
;   B = outer loop count (loaded into B register)
;   C = inner loop count (loaded into C register)
; ---  End  ---
;   AF, BC = Restored to entry state
;   Speaker output: burst of white noise completed
;
; Memory Modified: SOUND_REPEAT_COUNT
; Calls: PLAY_WHITE_NOISE_BURST
;==============================================================================
WHITE_NOISE_BURST:
    PUSH        AF                                  ; Preserve AF (caller's flags and accumulator)
    PUSH        BC                                  ; Preserve BC (caller's register pair)
    LD          A,0x7                               ; Load repeat count
    LD          (SOUND_REPEAT_COUNT),A              ; Store repeat count
    LD          B,0x80                              ; B = 128 (outer loop - burst duration)
    LD          C,0x20                              ; C = 32 (inner loop - toggle rate)
    CALL        PLAY_WHITE_NOISE_BURST              ; Call white noise routine
    POP         BC                                  ; Restore BC
    POP         AF                                  ; Restore AF
    RET                                             ; Return to caller

;==============================================================================
; PLAY_WHITE_NOISE_BURST
;==============================================================================
; Plays a quick burst of white noise effect with pseudo-random variation.
; Generates rapid speaker toggles using R register for entropy to create a
; chaotic "whoosh" or "zap" sound suitable for arrows, weapons, or item
; disappearance effects. Outer and inner loop counts determine duration/pitch.
;
; Parameters (passed in registers):
;   B = Outer loop counter (burst duration: number of toggle blocks)
;   C = Inner loop counter (toggle rate: number of toggles per block)
;   (Use SETUP_WHITE_NOISE_BURST for default standard values, or load custom B/C)
;
; Algorithm:
;   1. Load R register (pseudo-random value) for entropy
;   2. Output R value to speaker (bit 0 drives speaker)
;   3. Rotate R value right (RRA) for next pseudo-random bit pattern
;   4. Repeat C times (inner loop) for chaotic frequency
;   5. Reload R and repeat B times (outer loop) for burst duration
;   6. Chaotic bit patterns from R rotation create white noise effect
;
; Registers:
; --- Start ---
;   B = Outer loop count (consumed by routine)
;   C = Inner loop count (consumed by routine)
;   AF = Caller's responsibility to preserve
; --- In Process ---
;   A  = R register (pseudo-random), rotated bits for speaker output
;   E  = Inner loop counter (working copy of C)
;   B  = Outer loop counter (decremented to zero)
; ---  End  ---
;   B = 0, E = 0 (loop counters exhausted)
;   Speaker has been toggled (original B × C) times total with varying bit patterns
;
; Memory Modified: None
; Calls: None (leaf function)
;==============================================================================
PLAY_WHITE_NOISE_BURST:
    NOP
NOISE_OUTER_LOOP:
    LD          E,C                                 ; E = inner loop count (copy of C)
    LD          A,R                                 ; Load R register (refresh counter - pseudo-random)
NOISE_TOGGLE_LOOP:
    OUT         (SPEAKER),A                         ; Output to speaker (bit 0 drives speaker output)
    RRA                                             ; Rotate A right through carry (shift to next pseudo-random bit)
    DEC         E                                   ; Decrement inner loop counter
    JP          NZ,NOISE_TOGGLE_LOOP                ; Repeat inner loop if not zero
    DEC         B                                   ; Decrement outer loop counter
    JP          NZ,NOISE_OUTER_LOOP                 ; Repeat outer loop if not zero
    RET                                             ; Return to caller