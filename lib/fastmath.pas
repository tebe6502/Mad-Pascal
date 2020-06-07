unit fastmath;
(*
 @type: unit
 @author: Cruzer/Camelot, Tebe/Madteam
 @name: Fast Math
 @version: 1.0

 @description:

 https://codebase64.org/doku.php?id=base:6502_6510_maths
*)


{


}

interface

	procedure FillSinHigh(p: pointer);
	procedure FillSinLow(p: pointer);


implementation


procedure FillSin(p: pointer; eor,add: byte); assembler;
(*
@description:

https://codebase64.org/doku.php?id=base:generating_approximate_sines_in_assembly
*)
asm
{
	txa:pha

	lda p+1
	sta a0+2
	sta a1+2
	sta a2+2
	sta a3+2

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
a0	sta $ffc0,x
a1	sta $ff80,y
	eor eor
a2	sta $ff40,x
a3	sta $ff00,y

; Increase the delta, which creates the "acceleration" for a parabola
	lda ldelta
	adc add		; this value adds up to the proper amplitude
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


procedure FillSinLow(p: pointer);
(*
@description: Sine value table ($7f, $08)

@param: P - pointer to array (low address = 0)
*)
begin

 FillSin(p, $7f, $08);

end;


procedure FillSinHigh(p: pointer);
(*
@description: Sine value table ($ff, $10)

@param: P - pointer to array (low address = 0)
*)
begin

 FillSin(p, $ff, $10);

end;


end.

