uses crt, md1;

const
	md1_player = $3000;
	md1_modul = $5000;
	md1_sample = $6000;	// !!! low byte = $00 !!!

var
	msx: TMD1;

	ch: char;

{$r md1_play.rc}
//{$r md1_play2.rc}


procedure vbl; interrupt;
begin

 msx.play;

 asm 
	jmp xitvbv
 end;

end;



begin
	SetIntVec(iVBL, @vbl);


	while true do begin

	msx.player:=pointer(md1_player);
	msx.modul:=pointer(md1_modul);
	msx.sample:=pointer(md1_sample);

	msx.init;

	writeln('Pascal MD1 player example');


	repeat
		msx.digi(true);		// TRUE = 15kHz ; FALSE = 8kHz

	until keypressed;
	ch:=readkey();

	msx.stop;

	end;


 repeat until keypressed;

end.
