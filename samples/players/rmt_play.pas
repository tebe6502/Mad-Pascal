// RMT PLAYER

uses crt, rmt;

const
	rmt_player = $a000;
	rmt_modul = $4000;

var
	msx: TRMT;

{$r 'rmt_play.rc'}


begin
	msx.player:=pointer(rmt_player);
	msx.modul:=pointer(rmt_modul);

	msx.init(0);

	writeln('Pascal RMT player example');

	repeat
		pause;

		msx.play;

	until keypressed;

	msx.stop;

end.

