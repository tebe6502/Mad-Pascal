uses crt, mpt;

{$define romoff}

const
	mpt_player = $e000;
	mpt_modul = $9000;

var
	msx: TMPT;

	ch: char;

{$r 'mpt_play.rc'}


begin
	while true do begin

	msx.player:=pointer(mpt_player);
	msx.modul:=pointer(mpt_modul);

	msx.init;

	writeln('Pascal MPT player example');

	repeat
		pause;

		msx.play;

	until keypressed;

	ch:=readkey();

	msx.stop;

	end;

end.
