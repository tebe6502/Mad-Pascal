X16EMU=~/Retro/X16/x16Emu/x16emu
MAD-PASCAL=../../../

demo:
	mp -t x16 -ipath:$(MAD-PASCAL)lib vtuidemo.pas
	mads vtuidemo.a65 -x -i:$(MAD-PASCAL)base -o:vtuidemo.prg
	$(X16EMU) -prg vtuidemo.prg -run -debug -scale 2

mem:
	mp -t x16 -ipath:$(MAD-PASCAL)lib vtuimem.pas
	mads vtuimem.a65 -x -i:$(MAD-PASCAL)base -o:vtuimem.prg
	$(X16EMU) -prg vtuimem.prg -run -debug -scale 2