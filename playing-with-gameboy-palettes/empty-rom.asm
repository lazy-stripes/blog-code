; Boilerplate code for an empty ROM that won't crash.

INCLUDE "include/header.asm"

SECTION "default", ROM0
main:
    ; Do Things Here.

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
