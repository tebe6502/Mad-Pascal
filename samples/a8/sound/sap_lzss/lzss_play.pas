// https://forums.atariage.com/topic/315537-rmt2lzss-convert-rmt-tunes-to-lzss-for-fast-playback/

uses crt, saplzss;

var
	msx: TLZSSPlay;

	ch: char;

{$r 'lzss_play.rc'}


begin
	while true do begin

	GetResourceHandle(msx.data, 'lzss_modul');
	SizeOfResource(msx.size, 'lzss_modul');

	msx.buffer:=hi($a000);
	msx.pokey:=$00;

	msx.init;

	writeln('Pascal SAP-R LZSS player example');

	repeat
		pause;

		msx.play;

	until keypressed;

	ch:=readkey();

	msx.stop;

	end;

end.
