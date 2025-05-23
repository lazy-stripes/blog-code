; Cycle background palette to give the illusion of vertical movement.

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

    ; Clear VRAM from 0x8000 to 0x9fff (borrowed from boot ROM code).
    LD HL, $9fff
clearVRAM:
    LD [HL-], A         ; Set byte at address [HL] to zero, then decrement HL.
    BIT 7, H            ; Check whether H is still larger than 0x80.
    JR NZ, clearVRAM    ; If not, keep clearing VRAM.

    ; Copy tile data from wherever the assembly stored it to 0x8000.
    ; We'll use DE to hold the source address and HL the destination.
    LD DE, tileData    ; RGBDS will replace tileData with its actual address.
    LD HL, $8000
copyTileData:
    LD A, [DE]          ; Load current tile byte into A.
    INC DE              ; Point DE to next tile byte.
    LD [HL+], A         ; Write data byte to address [HL], then increment HL.
    BIT 4, L            ; Check whether L has reached 0x10 (16).
    JR Z, copyTileData  ; If not (bit 4 of L is still zero), keep copying data.

    ; Configure BGP to show all four colors.
    LD A, $1b
    LDH [$FF00+$47], A

        ; Write to LCDC to turn PPU back on.
    ; Bit 7: enable PPU, bit 4: tile data at 0x8000, bit 0: show background.
    LD A, $91
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

; Raw tile data. One tile always uses 16 bytes: 2 per 8-pixel row. The first
; byte contains the lowest bit for all 8 pixels, the second byte the highest.
; Have I ever mentioned that endianness is a pain?
tileData:
    DB $00, $00 ; Row 0, color 0b00.
    DB $ff, $00 ; Row 1, color 0b01.
    DB $00, $ff ; Row 2, color 0b10.
    DB $ff, $ff ; Row 3, color 0b11.
    DB $00, $00 ; Row 4, color 0b00.
    DB $ff, $00 ; Row 5, color 0b01.
    DB $00, $ff ; Row 6, color 0b10.
    DB $ff, $ff ; Row 7, color 0b11.
