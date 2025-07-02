// inline

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
	xbuf0: array [0..39] of byte absolute $0600;
	xbuf1: array [0..39] of byte absolute $0630;

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
    i, ii: byte;
    scrn: PByte absolute $e0;
    tmp: byte absolute $e2;


procedure row; inline;
begin
	scrn[23] := lookupMul[xbuf1[23] + tmp] + lookupDiv[xbuf0[23] + tmp];
	scrn[22] := lookupMul[xbuf1[22] + tmp] + lookupDiv[xbuf0[22] + tmp];
	scrn[21] := lookupMul[xbuf1[21] + tmp] + lookupDiv[xbuf0[21] + tmp];
	scrn[20] := lookupMul[xbuf1[20] + tmp] + lookupDiv[xbuf0[20] + tmp];
	scrn[19] := lookupMul[xbuf1[19] + tmp] + lookupDiv[xbuf0[19] + tmp];
	scrn[18] := lookupMul[xbuf1[18] + tmp] + lookupDiv[xbuf0[18] + tmp];
	scrn[17] := lookupMul[xbuf1[17] + tmp] + lookupDiv[xbuf0[17] + tmp];
	scrn[16] := lookupMul[xbuf1[16] + tmp] + lookupDiv[xbuf0[16] + tmp];
	scrn[15] := lookupMul[xbuf1[15] + tmp] + lookupDiv[xbuf0[15] + tmp];
	scrn[14] := lookupMul[xbuf1[14] + tmp] + lookupDiv[xbuf0[14] + tmp];
	scrn[13] := lookupMul[xbuf1[13] + tmp] + lookupDiv[xbuf0[13] + tmp];
	scrn[12] := lookupMul[xbuf1[12] + tmp] + lookupDiv[xbuf0[12] + tmp];
	scrn[11] := lookupMul[xbuf1[11] + tmp] + lookupDiv[xbuf0[11] + tmp];
	scrn[10] := lookupMul[xbuf1[10] + tmp] + lookupDiv[xbuf0[10] + tmp];
	scrn[9] := lookupMul[xbuf1[9] + tmp] + lookupDiv[xbuf0[9] + tmp];
	scrn[8] := lookupMul[xbuf1[8] + tmp] + lookupDiv[xbuf0[8] + tmp];
	scrn[7] := lookupMul[xbuf1[7] + tmp] + lookupDiv[xbuf0[7] + tmp];
	scrn[6] := lookupMul[xbuf1[6] + tmp] + lookupDiv[xbuf0[6] + tmp];
	scrn[5] := lookupMul[xbuf1[5] + tmp] + lookupDiv[xbuf0[5] + tmp];
	scrn[4] := lookupMul[xbuf1[4] + tmp] + lookupDiv[xbuf0[4] + tmp];
	scrn[3] := lookupMul[xbuf1[3] + tmp] + lookupDiv[xbuf0[3] + tmp];
	scrn[2] := lookupMul[xbuf1[2] + tmp] + lookupDiv[xbuf0[2] + tmp];
	scrn[1] := lookupMul[xbuf1[1] + tmp] + lookupDiv[xbuf0[1] + tmp];
	scrn[0] := lookupMul[xbuf1[0] + tmp] + lookupDiv[xbuf0[0] + tmp];

	inc(scrn, 40);
end;


begin
    scrn := pointer(VIDEO_RAM_ADDRESS + 8 + 10*40);	// X=8 ; Y=10

    _c1a := c1A;
    _c1b := c1B;

    for i := 23 downto 0 do begin
        xbuf0[i] := sinustable[_c1a] + sinustable[_c1b];
        inc(_c1a, 3);
        inc(_c1b, 7);

        xbuf1[i] := sinustable[_c1a] + sinustable[_c1b];
        inc(_c1a, 3);
        inc(_c1b, 7);
    end;


    for ii := 19 downto 0 do begin

        tmp := xbuf0[ii];

	row;

        tmp := xbuf1[ii];

	row;

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

// 5324
