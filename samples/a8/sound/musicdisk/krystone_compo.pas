// https://forums.atariage.com/topic/315537-rmt2lzss-convert-rmt-tunes-to-lzss-for-fast-playback/
// Krystone was here... Just testing things.

uses crt, atari, music;

{$define romoff}

const
	CHARSET = $b000; 	// character set

	{$i music.inc}

var	p: pointer;
	ch: char;

{$r 'msxresource.rc'}


begin

	GetResourceHandle(p, 'FONT');
	Move(p, pointer(CHARSET), $400); // copy system charset to new location
	chbas := Hi(CHARSET); // activate new character set

asm // I know this can be done by poke, but I was just testing inline asm
	lda	#$0f
	sta 710
	sta 712
	lda	#0
	sta 709

	lda #$0c
	sta 708
	lda #$24
	sta 711
end;

  while true do begin

	clrscr;

	writeln;
	writeln('2023 Krystone Online Music Compo');
	writeln('Welcome to Apokeylipse Music Disk');
	writeln;
	writeln('1."Black Bouncy Blob" by PG');
	writeln('2."Fallen Hard" by rdefabri');
	writeln('3."Nuclear Sign" by Poison');
	writeln('4."Pokey Atmosphere" by Buddy');
	writeln('5."Tune 179" by 91SNESplayer');
	writeln('6."Unexpectedly Short" by Buddy');
	writeln;
	writeln('0. Exit');
	writeln;
	write('Press 1',char(123),'.6 to play a tune',char(123),'.');

	ch:=ReadKey;

	if ch='0' then Break;

	writeln;

	writeln;
	writeln('Playing #',ch,char(123),'.');

	writeln;
	writeln('Press any key to stop');

	PlaySong(ch);

  end;

 TextMode(0);

end.
