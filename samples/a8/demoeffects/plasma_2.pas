// 06_plasma.ras, Turbo Rascal example

uses crt, atari, fastmath;

const

scrw = 40;
scrh = 24;

    DataChar: array [0..127] of byte = (
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $10, $00, $00, $00, $00,
    $00, $00, $18, $18, $00, $00, $00, $00,
    $00, $00, $38, $38, $38, $00, $00, $00,
    $00, $00, $3c, $3c, $3c, $3c, $00, $00,
    $00, $7c, $7c, $7c, $7c, $7c, $00, $00,
    $00, $7e, $7e, $7e, $7e, $7e, $7e, $00,
    $fe, $fe, $fe, $fe, $fe, $fe, $fe, $00,
    $00, $7f, $7f, $7f, $7f, $7f, $7f, $7f,
    $00, $7e, $7e, $7e, $7e, $7e, $7e, $00,
    $00, $7c, $7c, $7c, $7c, $7c, $00, $00,
    $00, $00, $3c, $3c, $3c, $3c, $00, $00,
    $00, $00, $38, $38, $38, $00, $00, $00,
    $00, $00, $18, $18, $00, $00, $00, $00,
    $00, $00, $00, $08, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00
    );

var
    c1A: byte = 1;
    c1B: byte = 5;

    p: pointer;

    CHARSET: array [0..0] of byte absolute $a000;

    sinustable: array [0..255] of byte absolute $a100;

    lookupDiv16: array [0..255] of byte absolute $a200;

    xbuf: array [0..39] of byte absolute $a300;



procedure InitDivision16;
var x: byte;
begin
	for x:=0 to 255 do lookupDiv16[x]:=x shr 4;	// Simply store values divided by 16
end;


procedure InitCharset;
begin
	move(DataChar, charset, 128);

	chbas:=hi(word(@charset));
end;


procedure doPlasma (p: pointer);
var _c1a, _c1b: byte;
    i, ii, tmp: byte;
    scrn: PByte register;
begin
    scrn := p;

    _c1a := c1A;
    _c1b := c1B;

    for i := scrw-1 downto 0 do begin
        xbuf[i] := sinustable[_c1a] + sinustable[_c1b];
        inc(_c1a, 3);
        inc(_c1b, 7);
    end;

    for ii := scrh-1 downto 0 do begin

        tmp := sinustable[_c1a] + sinustable[_c1b];

        inc(_c1a, 4);
        inc(_c1b, 9);

 	for i := scrw-1 downto 0 do
	    scrn[i] := lookupDiv16[xbuf[i] + tmp];

	inc(scrn, 40);
    end;

    inc(c1A, 3);
    dec(c1B, 5);
end;


begin


 FillSinHigh(@sinustable);
 InitDivision16;
 InitCharset;

 p:=pointer(dpeek(88));

 repeat
	pause;

	doplasma(p);

 until keypressed;

 chbas:=$e0;

end.

// 1375