uses crt, mpt;

const
	mpt_player = $a000;
	mpt_modul = $4000;

var
	msx: TMPT;

{$r 'mpt_play.rc'}


begin
	msx.player:=pointer(mpt_player);
	msx.modul:=pointer(mpt_modul);

	msx.init;

	writeln('Pascal MPT player example');

	repeat
		pause;

		msx.play;

	until keypressed;

	msx.stop;

end.

