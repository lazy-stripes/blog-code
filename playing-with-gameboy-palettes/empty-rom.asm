; Boilerplate code for an empty ROM that won't crash.
; Thanks to https://assemblydigest.tumblr.com/post/77198211186/tutorial-making-an-empty-game-boy-rom-in-rgbds

; The header.asm file contains the necessary hardcoded values to generate
; a mostly valid ROM header. I say "mostly" because it doesn't contain the
; header checksum, but that is computed externally by rgbds at build time.
INCLUDE "include/header.asm"

; The header.asm file also contains basic code to ensure the Game Boy jumps to
; the `main` label below at the end of the boot process.
SECTION "default", ROM0
main:
    ; Do Things Here.

lock:
    ; Stop execution here, all the work should be done from an interrupt.
    ; Also weird stuff will happen if we don't put that railguard instruction
    ; at the end of our code.
    JR lock

; The header.asm file *also* contains basic code to ensure the Game Boy jumps to
; one of the labels below when the corresponding interrupt occurs (provided
; interrupts are enabled).
;
; Here, they are all empty and will simply return without doing anything.
vblank:
stat:
timer:
serial:
joypad:
    RETI
