// https://forums.atariage.com/topic/315537-rmt2lzss-convert-rmt-tunes-to-lzss-for-fast-playback/

uses crt, saplzss;

const

sapr_player = $6000;	// ..$9BFF
sapr_modul  = $6c00;

var
	msx: TLZSSPlay;

	ch: char;

	i: word;

{$r 'lzss_play.rc'}


begin
	while true do begin

	msx.modul:=pointer(sapr_modul);
	msx.player:=pointer(sapr_player);

	msx.init(0);

	writeln('Pascal SAP-R LZSS player example');

	repeat
		pause;

		msx.decode;
		msx.play;

	until keypressed;

	ch:=readkey();

	msx.stop(0);

	end;

end.
