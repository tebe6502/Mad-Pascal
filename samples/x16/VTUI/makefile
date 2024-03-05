X16EMU=d:\Retro\X16\x16Emu\x16emu

demo:
	mp -t x16 vtuidemo.pas
	mads vtuidemo.a65 -x -i:../../../base -o:vtuidemo.prg
	$(X16EMU) -prg vtuidemo.prg -run -debug -scale 2

mem:
	mp -t x16 vtuimem.pas
	mads vtuimem.a65 -x -i:../../../base -o:vtuimem.prg
	$(X16EMU) -prg vtuimem.prg -run -debug