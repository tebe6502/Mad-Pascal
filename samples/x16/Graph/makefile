X16EMU=../../../../../X16/x16Emu/x16emu
MAD-PASCAL=../../../


gfx:
	mp -t x16 -ipath:$(MAD-PASCAL)lib gfx.pas
	mads gfx.a65 -x -i:$(MAD-PASCAL)base -o:gfx.prg
	$(X16EMU) -prg gfx.prg -run -debug

direct:
	mp -t x16 -ipath:$(MAD-PASCAL)lib directgfx.pas
	mads directgfx.a65 -x -i:$(MAD-PASCAL)base -o:directgfx.prg
	$(X16EMU) -prg directgfx.prg -run -debug

peek:
	mp -t x16 -ipath:$(MAD-PASCAL)lib peek.pas
	mads peek.a65 -x -i:$(MAD-PASCAL)base -o:peek.prg
	$(X16EMU) -prg peek.prg -run -debug

kaleidoscope:
	mp -t x16 -ipath:$(MAD-PASCAL)lib kaleidoscope.pas
	mads kaleidoscope.a65 -x -i:$(MAD-PASCAL)base -o:kaleidoscope.prg
	$(X16EMU) -prg kaleidoscope.prg -run -debug