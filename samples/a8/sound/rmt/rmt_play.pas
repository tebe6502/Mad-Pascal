// RMT PLAYER

{$define romoff}

uses crt, rmt;

const
	rmt_player = $e000;
	rmt_modul = $c000;

var
	msx: TRMT;

	ch: char;

{$r 'rmt_play.rc'}


begin
	while true do begin

	msx.player:=pointer(rmt_player);
	msx.modul:=pointer(rmt_modul);

	msx.init(0);

	writeln('Pascal RMT player example');


	asm

	lda #$00		; $00 max volume ; $f0 silenc
	sta RMTGLOBALVOLUMEFADE

	end;


	repeat
		pause;

		msx.play;

	until keypressed;
	ch:=readkey();

	msx.stop;

	end;

end.

