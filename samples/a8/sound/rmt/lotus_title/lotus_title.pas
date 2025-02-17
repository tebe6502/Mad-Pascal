{$DEFINE BASICOFF}

uses crt, rmt;

const
	dl: array [0..32] of byte = (
	$f0,$70,$30,$42,$40,$bc,$02,$02,
	$02,$02,$02,$02,$02,$02,$02,$02,
	$02,$02,$02,$02,$02,$02,$02,$02,
	$02,$02,$02,$02,$02,$02,$41,
	lo(word(@dl)), hi(word(@dl))
	);

	rmt_player = $a000;
	rmt_modul = $4000;

var	msx: TRMT;
	ntsc: byte;
	palntsc: byte absolute $d014;

	old_dli, old_vbl: pointer;


{$r 'lotus_title.rc'}


procedure vbl; interrupt;
begin

 msx.play;

asm
{
	jmp xitvbv
};

end;


procedure dli_bs; interrupt;
begin
asm
{	phr

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
	rti
};
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

 poke($d40e,$c0);	// nmien = $c0

 writeln('         Lotus II title song       ');
 writeln('quick and dirty dl and dli handling');
 writeln('with MAD Pascal');
 writeln;
 writeln;
 writeln;
 writeln;
 writeln;
 writeln;
 writeln;
 writeln;
 writeln('NTSC speeds up the song sometimes if');
 writeln('loop to higher than $e0 in DLI');
 writeln('play a bit with AND #$82 in dli to');
 writeln('have some other nice colours');

 repeat

 until keypressed;

 msx.stop;

 SetIntVec(iVBL, old_vbl);
 SetIntVec(iDLI, old_dli);

end.
