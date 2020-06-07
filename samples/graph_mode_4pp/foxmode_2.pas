
{$r foxmode.rc}

{$define romoff}

uses crt, atari, gr4pp, fastmath;

const

DISPLAY_LIST_ADDRESS	= $d800;
CHARSET_RAM_ADDRESS	= $c000;
VIDEO_RAM_ADDRESS	= $c400;

var
	lookupDiv: array [0..255] of byte absolute $bd00;
	lookupMul: array [0..255] of byte absolute $be00;
	sinustable: array [0..255] of byte absolute $bf00;
	xbuf: array [0..79] of byte absolute $0600;

	c1A: byte = 1;
	c1B: byte = 5;


procedure vbl; assembler; interrupt;
asm
{
	lda VS_Upper
	sta vscrol

	mva >CHARSET_RAM_ADDRESS	chbase

	jmp xitvbv
};
end;


procedure InitMulDiv;
var x: byte;
    s: word;
begin
	s:=0;

	for x:=0 to 127 do begin
	 lookupDiv[x]:=hi(s);
	 lookupDiv[255-x]:=lookupDiv[x];

	 s:=s+22;			// (11/128) * 256 = 22
	end;

	for x:=0 to 255 do lookupMul[x]:=lookupDiv[x] * 11;
end;


procedure doPlasma;
var _c1a, _c1b: byte;
    i, ii, tmp: byte;
    a,b, k: byte;
    scrn: PByte absolute $e0;
begin
    scrn := pointer(VIDEO_RAM_ADDRESS + 8 + 10*40);	// X=8 ; Y=10

    _c1a := c1A;
    _c1b := c1B;

    for i := 0 to 79 do begin
        xbuf[i] := sinustable[_c1a] + sinustable[_c1b];
        inc(_c1a, 3);
        inc(_c1b, 7);
    end;

    for ii := 0 to 39 do begin

        tmp := sinustable[_c1a] - sinustable[_c1b];

        inc(_c1a, 4);
        inc(_c1b, 9);

	k:=0;
 	for i := 0 to 23 do begin
	    scrn[i] := lookupMul[xbuf[k] + tmp] + lookupDiv[xbuf[k+1] + tmp];

	    inc(k,2);
	end;

	inc(scrn, 40);
    end;

    inc(c1A, 3);
    dec(c1B, 5);
end;



begin

FillSinHigh(sinustable);

InitMulDiv;;

gr4init(DISPLAY_LIST_ADDRESS, VIDEO_RAM_ADDRESS, 60, 4, 0);

SetIntVec(iVBL, @vbl);

colbk := $00;

color0 := $22;
color1 := $36;
color2 := $96;

repeat
	doPlasma;

until keypressed;

end.
