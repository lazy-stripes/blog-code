# Adjust paths to RGBDIS binaries here (or another assembler or your liking),
# or make sure they are in your PATH.
ASM = rgbasm
LINK = rgblink
FIX = rgbfix
GFX = rgbgfx

all: 	empty-rom.gb \
		invert-palette.gb \
		invert-palette-tiled.gb \
		cycle-palette-tiled.gb \
		palette-cycle.gb

clean:
	rm -f *.o *.tiles *.gb

# Generic rules for most of the input files.
%.gb: %.o
	$(LINK) -o $@ $<
	$(FIX) -f hg -p 255 $@

%.o: %.asm
	$(ASM) -o $@ $<

%.tiles %.tilemap &: %.tilemap.png
	$(GFX) -u -o $(basename $@).tiles -t $(basename $@).tilemap $<

# Specific rules for targets that need tiles.
palette-cycle.o: %.o: %.asm %.tiles %.tilemap
