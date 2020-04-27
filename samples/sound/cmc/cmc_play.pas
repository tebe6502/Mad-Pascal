uses crt, cmc;

const
	cmc_player = $a000;
	cmc_modul = $4000;

var
	msx: TCMC;

{$r 'cmc_play.rc'}


begin
	msx.player:=pointer(cmc_player);
	msx.modul:=pointer(cmc_modul);

	msx.init;

	writeln('Pascal CMC player example');

	repeat
		pause;

		msx.play;

	until keypressed;

	msx.stop;

end.
