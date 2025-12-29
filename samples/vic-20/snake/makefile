# Use the following exports under Windows Git Bash
# export MP_HOME=/c/jac/system/Atari800/Programming/Repositories/Mad-Pascal
# export MADS_HOME=/c/jac/system/Atari800/Tools/ASM/MADS
# export VICE=/c/jac/system/C64/Tools/EMU/VICE/bin/xvic.exe

MP_HOME?=${HOME}/Programs/MadPascal
MP?=${MP_HOME}/bin/windows_x86_64/mp.exe
MADS_HOME?=${HOME}/Programs/mads
MADS?=${MADS_HOME}/bin/windows_x86_64/mads.exe
BASE?=${MP_HOME}/base
VICE?=flatpak run --command=xvic net.sf.VICE

all: clean build-vic20

vic20: clean build-vic20 start-vic20

build-vic20:
	mkdir -p output
	$(MP) vic20.pas -target:raw -code:A009 -o:output/vic20.a65
	$(MADS) output/vic20.a65 -x -i:$(BASE) -o:output/vic20-core.bin
	mkdir -p bin
	cat headers/vic20_cart.bin output/vic20-core.bin > bin/snake-vic20-pal-a000.crt

start-vic20:
	$(VICE) -pal -cartA bin/snake-vic20-pal-a000.crt

clean:
	rm -f output/* bin/*
