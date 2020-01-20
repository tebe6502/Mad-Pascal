// Twister

uses crt, fastgraph;


var sine: array [0..255] of byte absolute $0600;

    mv, mv2: byte;

const
    height = 96 div 2;
    cx = 48;


procedure FillSin; assembler;
asm
{
	txa:pha

	ldy #$3f
	ldx #$00

; Accumulate the delta (normal 16-bit addition)
loop
	lda #0
lvalue	equ *-1
	clc
	adc #0
ldelta	equ *-1
	sta lvalue
	lda #0
hvalue	equ *-1
	adc #0
hdelta	equ *-1
	sta hvalue

; Reflect the value around for a sine wave
	sta adr.sine+$c0,x
	sta adr.sine+$80,y
	eor #$7f
	sta adr.sine+$40,x
	sta adr.sine+$00,y

; Increase the delta, which creates the "acceleration" for a parabola
	lda ldelta
	adc #8   ; this value adds up to the proper amplitude
	sta ldelta
	scc
	inc hdelta

; Loop
	inx
	dey
	bpl loop

	pla:tax
};
end;


procedure Twister(adY: byte);
var x1,x2,x3,x4: byte;
    minx, maxx, a, i: byte;
begin

 for a := 0 to height-1 do begin

   i:=sine[a + mv2] + sine[mv];

   x1 := cx + sine[i] shr 1;
   x2 := cx + sine[i + 64] shr 1;
   x3 := cx + sine[i + 128] shr 1;
   x4 := cx + sine[i + 192] shr 1;

   minx:=x1;

//   if x1<minx then minx:=x1;
   if x2<minx then minx:=x2;
   if x3<minx then minx:=x3;
   if x4<minx then minx:=x4;


   maxx:=x1;

//   if x1>=maxx then maxx:=x1;
   if x2>=maxx then maxx:=x2;
   if x3>=maxx then maxx:=x3;
   if x4>=maxx then maxx:=x4;

   dec(minx);
   inc(maxx);

   SetColor(0);
   HLine(minx-6, minx, adY);		// clear left/right twister border
   HLine(maxx, maxx+6, adY);


   if x1<x2 then begin SetColor(1); HLine(x1,x2, adY) end;

   if x2<x3 then begin SetColor(2); HLine(x2,x3, adY) end;

   if x3<x4 then begin SetColor(3); HLine(x3,x4, adY) end;

   if x4<x1 then begin SetColor(2); HLine(x4,x1, adY) end;

   inc(adY, 2);

 end;


end;



begin

 InitGraph(7+16);

 Poke(708, $c6);
 Poke(709, $76);
 Poke(710, $f6);

 FillSin;		// initialize SINUS table

 mv:=0;
 mv2:=65;


 repeat

   pause;

   Twister(0);

   inc(mv, 2);
   dec(mv2, 3);
   
   Twister(1);

   inc(mv, 3);
   dec(mv2, 2);

 until keypressed;


end.
