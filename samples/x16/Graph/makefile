X16EMU=d:\Retro\X16\x16Emu\x16emu


gfx:
	mp -t x16 gfx.pas
	mads gfx.a65 -x -i:../../../base -o:gfx.prg
	$(X16EMU) -prg gfx.prg -run -debug

direct:
	mp -t x16 directgfx.pas
	mads directgfx.a65 -x -i:../../../base -o:directgfx.prg
	$(X16EMU) -prg directgfx.prg -run -debug

peek:
	mp -t x16 peek.pas
	mads peek.a65 -x -i:../../../base -o:peek.prg
	$(X16EMU) -prg peek.prg -run -debug