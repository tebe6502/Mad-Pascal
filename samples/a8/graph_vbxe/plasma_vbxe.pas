// plasma by groepaz/hitmen
// vbxe plasma 4x4

uses graph, crt, vbxe;

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

    charsets = $8000;

var
    chradr, i: byte;
    c1A,c1B: byte;
    c2A,c2B: byte;

    p: ^byte;
    old_dli, old_vbl: pointer;

    xbuf: array [0..47] of byte;
    ybuf: array [0..47] of byte;

    cmap: array [0..255] of byte absolute $0600;

    vram: TVBXEMemoryStream;


procedure doplasma;
var _c1a, _c1b: byte;
    _c2a, _c2b: byte;
    i, ii: byte;
begin

    _c1a := c1A;
    _c1b := c1B;

    for ii := 0 to high(ybuf) do begin
        ybuf[ii] := (sinustable[_c1a] + sinustable[_c1b]) shr 2;
        inc(_c1a, 3);
        inc(_c1b, 5);
    end;
    inc(c1A, 2);
    dec(c1B, 3);

    _c2a := c2A;
    _c2b := c2B;

    for i := 0 to high(xbuf) do begin
        xbuf[i] := (sinustable[_c2a] + sinustable[_c2b]) shr 2;
        inc(_c2a, 1);
        inc(_c2b, 3);
    end;
    inc(c2A, 3);
    dec(c2B, 1);

    for ii := 0 to high(ybuf) do begin

asm
{	txa:pha

	lda ii
	pha
	:4 lsr @
	add #$80+MAIN.SYSTEM.VBXE_MAPADR/$1000

	fxsa FX_MEMS

	pla
	and #$0f
	add >MAIN.SYSTEM.VBXE_WINDOW

	sta adr0+1
	sta adr1+1

	lda #16*4	; color map offset
	sta adr0
	sta adr1

	ldy ii
	lda adr.ybuf,y
	sta t0
	sta t1

	ldx #47
	ldy #0

lp	lda adr.xbuf,x
	adc #0
t0	equ *-1
	sta c0

	lda adr.cmap
c0	equ *-2

	sta $ffff,y
adr0	equ *-2
	iny

	dex
	lda adr.xbuf,x
	adc #0
t1	equ *-1
	sta c1

	lda adr.cmap
c1	equ *-2

	sta $ffff,y
adr1	equ *-2

	iny
	iny
	iny

	dex
	bpl lp

	pla:tax
};
    end;

end;


procedure vbl; interrupt; assembler;
asm
{	mva >charsets chrAdr

	jmp xitvbv
};
end;


procedure dli; interrupt; assembler;
asm
{	pha

	lda chrAdr
	sta wsync
	sta chbase

	add #4
	sta chrAdr

	pla
};
end;


procedure InitCmap;
var i, j: byte;
    ptr: ^byte;
    adr: word;
begin

 chradr:=hi(charsets);

 ptr:=pointer(dpeek(88));

 for i:=0 to 119 do begin
  ptr^:=i;
  inc(ptr);
 end;

 ptr:=pointer(dpeek(88));
 adr:=dpeek(88)+120;

 for i:=0 to 7 do begin
  move(ptr, pointer(adr), 120);
  inc(adr, 120);
 end;

 adr:=charsets;

 for i:=0 to 7 do begin

  ptr:=pointer(adr+16*8);
  fillchar(ptr, 192, %01011010);

  ptr:=pointer(adr+56*8);
  fillchar(ptr, 192, %01011010);

  ptr:=pointer(adr+96*8);
  fillchar(ptr, 192, %01011010);

  inc(adr, 1024);
 end;


 for i:=0 to 7 do begin
  for j:=0 to 15 do cmap[byte(i shl 5)+j]:=byte(i shl 5)+j;
  for j:=0 to 15 do cmap[byte(i shl 5)+16+j]:=byte(i shl 5)+15-j;
 end;

end;


procedure LoadVMC;
var p :pointer;
    f: file;
    buf: array [0..0] of byte absolute $0400;
begin

 p:=pointer(charsets);
 assign(f, 'D:BLINKYS.FNT'); reset(f, 1);
 blockread(f, p^, 1024*8);
 close(f);

 vram.position:=VBXE_MAPADR;

 assign(f, 'D:BLINKYS.CMP'); reset(f, 1);
 for i:=0 to 23 do begin
  blockread(f, buf, 160);

  vram.WriteBuffer(buf, $100);
  vram.WriteBuffer(buf, $100);
 end;
 close(f);

 InitCmap;
end;


begin

 GetIntVec(iDLI, old_dli);
 GetIntVec(iVBL, old_vbl);

 InitGraph(mVBXE, 12 + 16, '');

 if GraphResult <> grOK then begin
  writeln('VBXE not detected');

  writeln(#$9b'Press any key');
  repeat until keypressed;

  halt;
 end;

 LoadVMC;

 SetColorMapDimensions(8,4);

 SetIntVec(iVBL, @vbl);
 SetIntVec(iDLI, @dli);

 p:=pointer(dpeek($230)+2);

 p^:=$f0;

 inc(p, 5);

 for i:=0 to 6 do begin
  p^:=$84;
  inc(p, 3);
 end;

 poke($d40e, $c0);

 randomize;

 c1A := random(0);
 c1B := random(0);
 c2A := random(0);
 c2B := random(0);

 repeat

 pause;

 doplasma;

 until keypressed;

 VBXEOff;

 SetIntVec(iDLI, old_dli);
 SetIntVec(iVBL, old_vbl);

end.
