; Invert background palette every second.

INCLUDE "include/header.asm"

; RGBDS supports defining internal variables, for readability.
DEF WAIT_FRAMES EQU 60

SECTION "default", ROM0
main:
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

; The header.asm file *also* contains basic code to ensure the Game Boy jumps to
; one of the labels below when the corresponding interrupt occurs (provided
; interrupts are enabled).
vblank:
    ; Invert background palette value in hardware register $ff47, but only
    ; when our frame counter reaches zero.

    ; Decrement, then check frame counter value. Return if it's not zero.
    DEC C
    JR NZ, vblankDone

    ; If we got here, our counter is zero, so we Do The Thing.

    LDH A, [$FF00+$47]    ; Load current BGP value in A.
    XOR A, $FF            ; Invert the value by XORing every bit with 1.
    LDH [$FF00+$47], A    ; Store the inverted value back in BGP.

    ; Reload our frame counter to the initial value for the next iteration.
    LD C, 60

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
