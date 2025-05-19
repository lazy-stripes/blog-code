# Adjust paths to RGBDIS binaries here (or another assembler or your liking),
# or make sure they are in your PATH.
ASM = rgbasm
LINK = rgblink
FIX = rgbfix
GFX = rgbgfx

all: empty-rom.gb invert-palette.gb invert-palette-tiled.gb palette-cycle.gb

clean:
	rm -f *.o *.tiles *.gb

empty-rom.gb: empty-rom.o
	$(LINK) -o empty-rom.gb empty-rom.o
	$(FIX) -f hg -p 255 empty-rom.gb

empty-rom.o: empty-rom.asm
	$(ASM) -o empty-rom.o empty-rom.asm

invert-palette.gb: invert-palette.o
	$(LINK) -o invert-palette.gb invert-palette.o
	$(FIX) -f hg -p 255 invert-palette.gb

invert-palette.o: invert-palette.asm
	$(ASM) -o invert-palette.o invert-palette.asm

invert-palette-tiled.gb: invert-palette-tiled.o
	$(LINK) -o invert-palette-tiled.gb invert-palette-tiled.o
	$(FIX) -f hg -p 255 invert-palette-tiled.gb

invert-palette-tiled.o: invert-palette-tiled.asm
	$(ASM) -o invert-palette-tiled.o invert-palette-tiled.asm

palette-cycle.gb: palette-cycle.o
	$(LINK) -o palette-cycle.gb palette-cycle.o
	$(FIX) -f hg -p 255 palette-cycle.gb

palette-cycle.o: palette-cycle.asm palette-cycle.tiles
	$(ASM) -o palette-cycle.o palette-cycle.asm

palette-cycle.tiles: palette-cycle-tiles.png
	$(GFX) -o palette-cycle.tiles palette-cycle-tiles.png

