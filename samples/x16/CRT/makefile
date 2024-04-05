X16EMU=../../../../../X16/x16Emu/x16emu
MAD-PASCAL=../../../


hello:
	mp -t x16 -ipath:$(MAD-PASCAL)lib hello.pas
	mads hello.a65 -x -i:$(MAD-PASCAL)base -o:hello.prg
	$(X16EMU) -prg hello.prg -run

keypressed:
	mp -t x16 -ipath:$(MAD-PASCAL)lib keypressed.pas
	mads keypressed.a65 -x -i:$(MAD-PASCAL)base -o:keypressed.prg
	$(X16EMU) -prg keypressed.prg -run

colors:
	mp -t x16 -ipath:$(MAD-PASCAL)lib colors.pas
	mads colors.a65 -x -i:$(MAD-PASCAL)base -o:colors.prg
	$(X16EMU) -prg colors.prg -run

random:
	mp -t x16 -ipath:$(MAD-PASCAL)lib random.pas
	mads random.a65 -x -i:$(MAD-PASCAL)base -o:random.prg
	$(X16EMU) -prg random.prg -run

date:
	mp -t x16 -ipath:$(MAD-PASCAL)lib date.pas
	mads date.a65 -x -i:$(MAD-PASCAL)base -o:date.prg
	$(X16EMU) -prg date.prg -run -rtc

texmodes:
	mp -t x16 -ipath:$(MAD-PASCAL)lib texmodes.pas
	mads texmodes.a65 -x -i:$(MAD-PASCAL)base -o:texmodes.prg
	$(X16EMU) -prg texmodes.prg -run

characters:
	mp -t x16 -ipath:$(MAD-PASCAL)lib characters.pas
	mads characters.a65 -x -i:$(MAD-PASCAL)base -o:characters.prg
	$(X16EMU) -prg characters.prg -run

directchars:
	mp -t x16 -ipath:$(MAD-PASCAL)lib directchars.pas
	mads directchars.a65 -x -i:$(MAD-PASCAL)base -o:directchars.prg
	$(X16EMU) -prg directchars.prg -run

resource:
	mads space_font.asm -o:space_font.fnt
	mp -t x16 -ipath:$(MAD-PASCAL)lib resource.pas
	mads resource.a65 -x -i:$(MAD-PASCAL)base -o:resource.prg
	$(X16EMU) -prg resource.prg -run -debug -scale 2

piramid:
	mp -t x16 -ipath:$(MAD-PASCAL)lib piramid.pas
	mads piramid.a65 -x -i:$(MAD-PASCAL)base -o:piramid.prg
	$(X16EMU) -prg piramid.prg -run

life:
	mp -t x16 -ipath:$(MAD-PASCAL)lib life.pas
	mads life.a65 -x -i:$(MAD-PASCAL)base -o:life.prg
	$(X16EMU) -prg life.prg -run

snake:
	mp -t x16 -ipath:$(MAD-PASCAL)lib snake.pas
	mads snake.a65 -x -i:$(MAD-PASCAL)base -o:snake.prg
	$(X16EMU) -prg snake.prg -run

tetris:
	mp -t x16 -ipath:$(MAD-PASCAL)lib tetris.pas
	mads tetris.a65 -x -i:$(MAD-PASCAL)base -o:tetris.prg
	$(X16EMU) -prg tetris.prg -run

plasma:
	mp -t x16 -ipath:$(MAD-PASCAL)lib plasma.pas
	mads plasma.a65 -x -i:$(MAD-PASCAL)base -o:plasma.prg
	$(X16EMU) -prg plasma.prg -run
