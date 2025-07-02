MP=${HOME}/Programs/MadPascal/mp
MADS=${HOME}/Programs/mads/mads
BASE=${HOME}/Programs/MadPascal/base

all: clean build-vic20

vic20: clean build-vic20 start-vic20

build-vic20:
	$(MP) src/vic20.pas -t raw -code A009 -o output/vic20.a65
	$(MADS) output/vic20.a65 -x -i:$(BASE) -o:output/vic20-core.bin
	cat headers/vic20_cart.bin output/vic20-core.bin > bin/snake-vic20-pal-a000.crt

start-vic20:
	flatpak run --command=xvic net.sf.VICE -pal -cartA bin/snake-vic20-pal-a000.crt

clean:
	rm -f output/* bin/*