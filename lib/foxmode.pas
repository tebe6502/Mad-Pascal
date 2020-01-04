program foxmode;

{$r foxmode.rc}

uses crt, atari;


const

fnt = $a000;	// $0400
scr = $a400;	// $0a00

dlist: array [0..64] of byte = (
	$e4, lo(scr), hi(scr), 
	$84,$24,$84,$24,$84,$24,$84,$24,$84,$24,
	$84,$24,$84,$24,$84,$24,$84,$24,$84,$24,
	$84,$24,$84,$24,$84,$24,$84,$24,$84,$24,
	$84,$24,$84,$24,$84,$24,$84,$24,$84,$24,
	$84,$24,$84,$24,$84,$24,$84,$24,$84,$24,
	$84,$24,$84,$24,$84,$24,$84,$24,$04,$41,
	lo(word(@dlist)), hi(word(@dlist))
	);
	
var
	txt: array [0..0] of byte absolute scr;


procedure dli; assembler; interrupt;
asm
{
	sta rA

	sta wsync

	mva #4	vscrol
	mva #3	vscrol
	
;	sta colbak

	lda #0
rA	equ *-1
};
end;


procedure vbl; assembler; interrupt;
asm
{
	mva #4	vscrol

	mva >fnt	chbase
	
	jmp xitvbv
};
end;


begin


SetIntVec(iVBL, @vbl);
SetIntVec(iDli, @dli);

sdlstl := word(@dlist);
nmien := $c0;

colbk := $00;

color0 := $22;
color1 := $36;
color2 := $96;

repeat until keypressed;

end.

