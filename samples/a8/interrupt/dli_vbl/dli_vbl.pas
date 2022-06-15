uses crt, rmt;

const
	dl: array [0..33] of byte = (
	$f0,$70,$70,$42,$40,$bc,$40,$02,
	$02,$02,$02,$02,$02,$02,$02,$02,
	$02,$02,$02,$02,$02,$02,$02,$02,
	$02,$02,$02,$02,$02,$02,$02,$41,
	lo(word(@dl)), hi(word(@dl))
	);

	dl2: array [0..39] of byte=(
	$70,$70,$70,
// some lines of gfx 0 at $8000
	$42,$00,$80,$70,$70,$70,
	$02,$02,$02,$02,
// gfx 1 & 2 at $9000
	$46,$00,$90,$06,$07,$06,$06,
// back to gfx 0 at line 5
	$42,$C8,$80,$02,$02,$02,
	$70,
// now some gfx 12 stuff at $8400
	$44,$00,$84,$04,$04,$04,
	$70,
// back to last gfx 0 line at $8168
	$42,$68,$81,
	$41,
	lo(word(@dl2)), hi(word(@dl2))
	);

	rmt_player = $a000;
	rmt_modul = $4000;

var	msx: TRMT;

	old_dli, old_vbl: pointer;


{$r 'rmt_play.rc'}


procedure vbl; interrupt;
begin
 msx.play;

asm
	jmp xitvbv
end;

end;


procedure dli_bs; interrupt; assembler;
asm
	phr

	ldx #$0
lp
	stx colbak
	txa
	and #$82
	sta color2
	stx wsync
	inx
	cpx #$e0
	bne lp

	plr
end;


begin

 GetIntVec(iDLI, old_dli);
 GetIntVec(iVBL, old_vbl);

 dpoke(560, word(@dl));

 msx.player:=pointer(rmt_player);
 msx.modul:=pointer(rmt_modul);

 msx.init(0);

 SetIntVec(iVBL, @vbl);

 SetIntVec(iDLI, @dli_bs);

 poke($d40e,$c0);

 writeln('   RMT-DL-VBL-DLI with MAD Pascal  ');
 writeln('NTSC / PAL detect for correct music');
 writeln('playback');
 writeln;
 writeln;
 writeln;
 writeln;
 writeln;
 writeln;
 writeln;
 writeln;
 writeln;
 writeln('You can put text to screen simple');
 writeln('write / writeln commands of Pascal');
 writeln;
 writeln;
 writeln;
 writeln;
 writeln;
 writeln;
 writeln;
 writeln;
 writeln;
 write('-----------press a key ------------');

 repeat

 until keypressed;

 SetIntVec(iVBL, old_vbl);
 SetIntVec(iDLI, old_dli);

 msx.stop;

 readkey;

 dpoke(560, word(@dl2));

// set screen area and clear it
 dpoke(88,$8000);
 clrscr;

 writeln('0 -      different gfx modes        ');
 writeln('1 - ten lines of gfx 0 at $8000');
 writeln('2 - inherit by some lines with');
 writeln('3 - gfx 1 & 2 on different screen');
 writeln('4 - memory area');
 writeln('5 - ($9000 here)');
 writeln('6 - first gfx0 write then');
 writeln('7 - change 88 to write gfx 1 & 2');
 writeln('8 - then same for writing gfx 12');
 writeln('9 - neat, isnt it?');

// now change the screen area
 dpoke(88,$9000);

// BASIC: POSITION(2,0)
 dpoke(85,2);
 poke(84,0);

// write don't know about the shorter lines of gfx 1 and 2 (changing RMARGN does not help here)
 write('   HEre We GO       ');
 write('   HEre We GO     ');
 write(' !!HEre We GO!!     ');
 write('   HEre We GO     ');
 write('   HEre We GO     ');

// gfx 12 stuff now
 dpoke(88,$8400);
 dpoke(85,2);
 poke(84,0);

 writeln('------------------------------------');
 writeln('     gfx 12 is hard to read :)');
 writeln('     better use a special font');
 writeln('-------------KEY--EXITS-------------');

 repeat

 until keypressed;

end.
