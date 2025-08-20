// Twister

uses crt, graph, fastmath;


var sine: array [0..255] of byte absolute $0600;

    mv, mv2: byte;

    LineAdr: word;


const
    height = 96 div 2;
    cx = 48;


procedure h_line(x0,x1: byte; c: byte); assembler;
asm
	txa:pha

	lda c
	asl @
	asl @
	sta color
	tay
	lda left,y
	sta fill

	mwa LineAdr ztmp

	lda x0		; left edge
	and #3
	tax
	lda lmask,x
	sta lmsk
	eor #$ff
	sta _lmsk
	txa
	add #0
color	equ *-1
	tax
	lda left,x
	sta lcol

	lda x0
	lsr @
	lsr @
	tay
	sty lf

	lda x1		; right edge
	and #3
	tax
	lda rmask,x
	sta rmsk
	eor #$ff
	sta _rmsk
	txa
	add color
	tax
	lda right,x
	sta rcol

	lda x1
	lsr @
	lsr @
	tay
	sty rg

	ldy #0
lf	equ *-1
	cpy rg
	beq piksel

	lda (ztmp),y
	and #0
lmsk	equ *-1
	ora #0
lcol	equ *-1
	sta (ztmp),y

	iny

	lda #0
fill	equ *-1

loop	cpy #0
rg	equ *-1
	bcs stop

	sta (ztmp),y
	iny
	bne loop

stop
	lda (ztmp),y
	and #0
rmsk	equ *-1
	ora #0
rcol	equ *-1
	sta (ztmp),y

	jmp exit

lmask	dta %00000000
	dta %11000000
	dta %11110000
	dta %11111100

left	dta 0,0,0,0

	dta %01010101
	dta %00010101
	dta %00000101
	dta %00000001

	dta %10101010
	dta %00101010
	dta %00001010
	dta %00000010

	dta %11111111
rmask
	dta %00111111
	dta %00001111
	dta %00000011

right	dta 0,0,0,0

	dta %01000000
	dta %01010000
	dta %01010100
	dta %01010101

	dta %10000000
	dta %10100000
	dta %10101000
	dta %10101010

	dta %11000000
	dta %11110000
	dta %11111100
	dta %11111111

piksel	lda fill
	and #0
_lmsk	equ *-1
	and #0
_rmsk	equ *-1
	ora (ztmp),y
	sta (ztmp),y

exit
	pla:tax
end;



procedure Twister(adY: byte);
var x1,x2,x3,x4: byte;
    minx, maxx, a, i: byte;
begin

 LineAdr := DPeek(88) + adY;


 for a := 0 to height-1 do begin

   i:=sine[a + mv2] + sine[mv];

   x1 := cx + sine[i] shr 1;
   x2 := cx + sine[byte(i + 64)] shr 1;
   x3 := cx + sine[byte(i + 128)] shr 1;
   x4 := cx + sine[byte(i + 192)] shr 1;

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

   H_line(minx-6, minx, 0);		// clear left/right twister border
   H_line(maxx, maxx+6, 0);


   if x1<x2 then H_line(x1,x2, 1);

   if x2<x3 then H_line(x2,x3, 2);

   if x3<x4 then H_line(x3,x4, 3);

   if x4<x1 then H_line(x4,x1, 2);

   inc(LineAdr, 80);

 end;


end;



begin

 InitGraph(7 + 16);

 Poke(708, $c6);
 Poke(709, $76);
 Poke(710, $f6);

 FillSinLow(@sine);		// initialize SINUS table

 mv:=0;
 mv2:=65;


 repeat

   pause;

   Twister(0);

   inc(mv, 2);
   dec(mv2, 3);

   Twister(40);

   inc(mv, 3);
   dec(mv2, 2);

 until keypressed;

end.
