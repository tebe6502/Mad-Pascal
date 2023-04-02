// plasma by groepaz/hitmen

uses crt, graph;

type
	TScreen = PByte;

const
    sinustable: array [0..255] of byte = (
    $80, $7d, $7a, $77, $74, $70, $6d, $6a,
    $67, $64, $61, $5e, $5b, $58, $55, $52,
    $4f, $4d, $4a, $47, $44, $41, $3f, $3c,
    $39, $37, $34, $32, $2f, $2d, $2b, $28,
    $26, $24, $22, $20, $1e, $1c, $1a, $18,
    $16, $15, $13, $11, $10, $0f, $0d, $0c,
    $0b, $0a, $08, $07, $06, $06, $05, $04,
    $03, $03, $02, $02, $02, $01, $01, $01,
    $01, $01, $01, $01, $02, $02, $02, $03,
    $03, $04, $05, $06, $06, $07, $08, $0a,
    $0b, $0c, $0d, $0f, $10, $11, $13, $15,
    $16, $18, $1a, $1c, $1e, $20, $22, $24,
    $26, $28, $2b, $2d, $2f, $32, $34, $37,
    $39, $3c, $3f, $41, $44, $47, $4a, $4d,
    $4f, $52, $55, $58, $5b, $5e, $61, $64,
    $67, $6a, $6d, $70, $74, $77, $7a, $7d,
    $80, $83, $86, $89, $8c, $90, $93, $96,
    $99, $9c, $9f, $a2, $a5, $a8, $ab, $ae,
    $b1, $b3, $b6, $b9, $bc, $bf, $c1, $c4,
    $c7, $c9, $cc, $ce, $d1, $d3, $d5, $d8,
    $da, $dc, $de, $e0, $e2, $e4, $e6, $e8,
    $ea, $eb, $ed, $ef, $f0, $f1, $f3, $f4,
    $f5, $f6, $f8, $f9, $fa, $fa, $fb, $fc,
    $fd, $fd, $fe, $fe, $fe, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $fe, $fe, $fe, $fd,
    $fd, $fc, $fb, $fa, $fa, $f9, $f8, $f6,
    $f5, $f4, $f3, $f1, $f0, $ef, $ed, $eb,
    $ea, $e8, $e6, $e4, $e2, $e0, $de, $dc,
    $da, $d8, $d5, $d3, $d1, $ce, $cc, $c9,
    $c7, $c4, $c1, $bf, $bc, $b9, $b6, $b3,
    $b1, $ae, $ab, $a8, $a5, $a2, $9f, $9c,
    $99, $96, $93, $90, $8c, $89, $86, $83
    );

    bittab: array [0..7] of byte = ($01, $02, $04, $08, $10, $20, $40, $80);

var
    c1A,c1B: byte;
    c2A,c2B: byte;

    CHARSET: array [0..0] of byte absolute $a000;

    xbuf: array [0..39] of byte;
    ybuf: array [0..23] of byte;


procedure makechar;
var i, ii, b, s, c: byte;
begin

    for c := 127 downto 0 do begin

	s := sinustable[c];

        for i := 7 downto 0 do begin
            b := 0;
            for ii := 7 downto 0 do
                if peek($d20a) > s then b := b or bittab[ii];

	    CHARSET[(c shl 3) + i] := b;
        end;

    if c and 7=0 then write('.');
    end;
end;


procedure doplasma (scrn: TScreen); register;
var _c1a, _c1b: byte;
    _c2a, _c2b: byte;
    i, ii, tmp: byte;
begin

    _c1a := c1A;
    _c1b := c1B;

    for ii := 23 downto 0 do begin
        ybuf[ii] := sinustable[_c1a] + sinustable[_c1b];
        inc(_c1a, 4);
        inc(_c1b, 9);
    end;
    inc(c1A, 3);
    dec(c1B, 5);

    _c2a := c2A;
    _c2b := c2B;

    for i := 39 downto 0 do begin
        xbuf[i] := sinustable[_c2a] + sinustable[_c2b];
        inc(_c2a, 3);
        inc(_c2b, 7);
    end;
    inc(c2A, 2);
    dec(c2B, 3);

    for ii := 23 downto 0 do begin

	tmp := ybuf[ii];

	for i := 39 downto 0 do scrn[i] := byte(xbuf[i] + tmp);

	inc(scrn, 40);
    end;

end;


begin

 randomize;

 makechar;

// InitGraph(12+16);

 poke(756, hi(word(@charset)));

 c1A := random(0);
 c1B := random(0);
 c2A := random(0);
 c2B := random(0);

 repeat
 pause;

 doplasma(pointer(dpeek(88)));

 until keypressed;

end.

// 1006