uses crt, cmc;

{$define romoff}

const
	cmc_player = $e000;
	cmc_modul = $4000;

var
	msx: TCMC;

	ch: char;

{$r 'cmc_play.rc'}


begin

	while true do begin

	msx.player:=pointer(cmc_player);
	msx.modul:=pointer(cmc_modul);

	msx.init;

	writeln('Pascal CMC player example');

	repeat
		pause;

		msx.play;

	until keypressed;
	ch:=readkey();

	msx.stop;

	end;

end.
