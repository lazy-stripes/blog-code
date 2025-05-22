; Cycle background palette to give the illusion of movement.

INCLUDE "include/header.asm"

; RGBDS supports defining internal variables, for readability.
DEF WAIT_FRAMES EQU 10

SECTION "default", ROM0
main:

    ; Initialize tile data. We first need to turn the PPU off. Which requires
    ; us to wait until VBlank. We could use the vblank interrupt too, but this
    ; is a short, one-time initialization so we'll do it the easy way.
waitForFrame:
    LDH A, [$FF00+$44] ; Wait for LY to reach value 144 (0x90 in hexadecimal).
    CP $90
    JR NZ, waitForFrame

    ; VBlank started, turn PPU off now.
    XOR A               ; Set A to zero
    LDH [$FF00+$40], A  ; Set all bits in LCDC to zero, turning off the PPU.

    ; Copy tile data from wherever the assembly stored it to 0x8000. We'll copy
    ; 9 tiles (8 graphic tiles and a background one), so 144 bytes.
    ; We'll use DE to hold the source address and HL the destination.
    LD DE, tileData    ; RGBDS will replace tileData with its actual address.
    LD HL, $8000
copyTileData:
    LD A, [DE]          ; Load current tile byte into A.
    INC DE              ; Point DE to next tile byte.
    LD [HL+], A         ; Write data byte to address [HL], then increment HL.
    LD A, $90           ; Check whether L has reached 0x90 (144).
    CP A, L
    JR NZ, copyTileData ; If not, keep copying data.

    ; Initialize background map (from 0x9800 to 0x9bff) with tile IDs.
    LD DE, tileMapData  ; RGBDS will replace tileMapData with its actual address.
    LD HL, $9800
copyTilemapData:
    LD A, [DE]              ; Load current tile ID into A.
    INC DE                  ; Point DE to next tile ID.
    LD [HL+], A             ; Write data byte to address [HL], then increment HL.
    LD A, $9c               ; Check whether H has reached 0x9c.
    CP A, H
    JR NZ, copyTilemapData  ; If not, keep copying IDs.

    ; Configure BGP to show all four colors.
    LD A, $1b
    LDH [$FF00+$47], A

    ; Turn PPU back on (bit 7), read tile data from 0x8000 (bit 4).
    LD A, $90
    LDH [$FF00+$40], A

    ; Initialize frame counter here. We'll wait 60 frames each time.
    LD C, WAIT_FRAMES

    ; Subscribe to vblank interrupt by setting bit zero of register IE ($ffff)
    ; to 1.
    LD A, $01
    LDH [$FF00+$ff], A

    ; Enable interrupts so that the Game Boy CPU will jump to the `vblank` label
    ; whenever a frame is done.
    EI

lock:
    ; Stop execution here, all the work should be done from the vblank interrupt.
    HALT
    JR lock

; Entry point for the VBlank interrupt.
vblank:
    ; Cycle background palette value in hardware register $ff47, but only
    ; when our frame counter reaches zero.

    ; Decrement, then check frame counter value. Return if it's not zero.
    DEC C
    JR NZ, vblankDone

    ; If we got here, our counter is zero, so we Do The Thing.

    LDH A, [$FF00+$47]    ; Load current BGP value in A.
    RLC A                 ; Rotate all bits left in BGP twice
    RLC A                 ; since a BGP entry is 2 bits wide.
    LDH [$FF00+$47], A    ; Store the cycled value back in BGP.

    ; Reload our frame counter to the initial value for the next iteration.
    LD C, WAIT_FRAMES

vblankDone:
    ; Return from interrupt call and re-enable interrupts.
    RETI

; All other interrupts are unimplemented and will simply return without doing
; anything special.
stat:
timer:
serial:
joypad:
    RETI

; Store data here. It doesn't really matter where we do that in the file, the
; assembler will know what to do.

; Raw tiles data.
tileData:
    INCBIN "cycle-palette-tilemap.tiles"

; Raw tilemap indices.
tileMapData:
    INCBIN "cycle-palette-tilemap.tilemap"
