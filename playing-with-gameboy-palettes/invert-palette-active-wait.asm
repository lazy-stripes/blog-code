; Invert background palette every second.

INCLUDE "include/header.asm"

DEF WAIT_FRAMES EQU 60

SECTION "default", ROM0
main:
    ; Load our frame Counter to C.
    LD C, WAIT_FRAMES

waitVBlankStart:
    LDH A, [$FF00+$44] ; Wait until LY is 144 (0x90)
    CP $90
    JR NZ, waitVBlankStart

decrementCounter:
    ; Decrement our frame counter. If it isn't zero, wait for end of VBlank
    ; and go back to waiting for the end of the next frame.
    DEC C
    JR NZ, waitVBlankEnd

changePalette:
    ; Counter reached zero. Reload counter, change palette and wait more.
    LD C, WAIT_FRAMES
    LDH A, [$FF00+$47] ; Load BGP value, invert it and store it back.
    XOR A, $FF
    LDH [$FF00+$47], A

waitVBlankEnd:
    LDH A, [$FF00+$44] ; Wait until LY is 0 again
    CP $00
    JR NZ, waitVBlankEnd

    ; Go back to waiting for next frame.
    JR waitVBlankStart

lock:
    ; Stop execution here, all the work should be done from the vblank interrupt.
    JR lock

; Unhandled interrupts.
vblank:
stat:
timer:
serial:
joypad:
    RETI
