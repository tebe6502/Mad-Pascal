X16EMU=d:\Retro\X16\x16Emu\x16emu

hello:
	mp -t x16 hello.pas
	mads hello.a65 -x -i:../../../base -o:hello.prg
	$(X16EMU) -prg hello.prg -run

keypressed:
	mp -t x16 keypressed.pas
	mads keypressed.a65 -x -i:../../../base -o:keypressed.prg
	$(X16EMU) -prg keypressed.prg -run

colors:
	mp -t x16 colors.pas
	mads colors.a65 -x -i:../../../base -o:colors.prg
	$(X16EMU) -prg colors.prg -run

random:
	mp -t x16 random.pas
	mads random.a65 -x -i:../../../base -o:random.prg
	$(X16EMU) -prg random.prg -run

texmodes:
	mp -t x16 texmodes.pas
	mads texmodes.a65 -x -i:../../../base -o:texmodes.prg
	$(X16EMU) -prg texmodes.prg -run

characters:
	mp -t x16 characters.pas
	mads characters.a65 -x -i:../../../base -o:characters.prg
	$(X16EMU) -prg characters.prg -run

resource:
	mads space_font.asm -o:space_font.fnt
	mp -t x16 resource.pas
	mads resource.a65 -x -i:../../../base -o:resource.prg
	$(X16EMU) -prg resource.prg -run -debug

piramid:
	mp -t x16 piramid.pas
	mads piramid.a65 -x -i:../../../base -o:piramid.prg
	$(X16EMU) -prg piramid.prg -run

life:
	mp -t x16 life.pas
	mads life.a65 -x -i:../../../base -o:life.prg
	$(X16EMU) -prg life.prg -run


snake:
	mp -t x16 snake.pas
	mads snake.a65 -x -i:../../../base -o:snake.prg
	$(X16EMU) -prg snake.prg -run

tetris:
	mp -t x16 tetris.pas
	mads tetris.a65 -x -i:../../../base -o:tetris.prg
	$(X16EMU) -prg tetris.prg -run


