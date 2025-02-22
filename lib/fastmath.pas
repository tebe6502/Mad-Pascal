unit fastmath;
(*
 @type: unit
 @author: Cruzer/Camelot, Tebe/Madteam
 @name: Fast Math
 @version: 1.0

 @description:

 <https://codebase64.org/doku.php?id=base:6502_6510_maths>

 <https://dwheeler.com/6502/oneelkruns/asm1step.html>
*)


{


}

interface

	function atan2(x1,x2,y1,y2: byte): byte; assembler;
	function sqrt16(a: word): byte; assembler;

	procedure FillSinHigh(p: pointer);
	procedure FillSinLow(p: pointer);

{$ifdef FASTMUL}
	function fastdiv(divisor, divider: word): word; external 'fdiv\fdiv';
	function fastdivS(divisor, divider: smallint): smallint; external 'fdiv\fdiv';
{$endif}


implementation


(*

function fastdiv(divisor, divider: word): word;

*)

{$ifdef FASTMUL}

	{$codealign link = $100}

	{$link fdiv\fdiv.obx}

	{$codealign link = 0}

{$endif}


function atan2(x1,x2,y1,y2: byte): byte; assembler;
(*
@description:
* Calculate the angle, in a 256-degree circle, between two points.
* The trick is to use logarithmic division to get the y/x ratio and
* integrate the power function into the atan table. Some branching is
* avoided by using a table to adjust for the octants.
* In otherwords nothing new or particularily clever but nevertheless
* quite useful.
*
* by Johan Forslöf (doynax)
* https://codebase64.org/doku.php?id=base:8bit_atan2_8-bit_angle

@param: x1 - byte
@param: x2 - byte
@param: y1 - byte
@param: y2 - byte

@return: Result - byte
*)
const

atan_tab: array [0..255] of byte = (		// atan(2^(x/32))*128/pi
	$00,$00,$00,$00,$00,$00,$00,$00,
	$00,$00,$00,$00,$00,$00,$00,$00,
	$00,$00,$00,$00,$00,$00,$00,$00,
	$00,$00,$00,$00,$00,$00,$00,$00,
	$00,$00,$00,$00,$00,$00,$00,$00,
	$00,$00,$00,$00,$00,$00,$00,$00,
	$00,$00,$00,$00,$00,$00,$00,$00,
	$00,$00,$00,$00,$00,$00,$00,$00,
	$00,$00,$00,$00,$00,$00,$00,$00,
	$00,$00,$00,$00,$00,$00,$00,$00,
	$00,$00,$00,$00,$00,$01,$01,$01,
	$01,$01,$01,$01,$01,$01,$01,$01,
	$01,$01,$01,$01,$01,$01,$01,$01,
	$01,$01,$01,$01,$01,$01,$01,$01,
	$01,$01,$01,$01,$01,$02,$02,$02,
	$02,$02,$02,$02,$02,$02,$02,$02,
	$02,$02,$02,$02,$02,$02,$02,$02,
	$03,$03,$03,$03,$03,$03,$03,$03,
	$03,$03,$03,$03,$03,$04,$04,$04,
	$04,$04,$04,$04,$04,$04,$04,$04,
	$05,$05,$05,$05,$05,$05,$05,$05,
	$06,$06,$06,$06,$06,$06,$06,$06,
	$07,$07,$07,$07,$07,$07,$08,$08,
	$08,$08,$08,$08,$09,$09,$09,$09,
	$09,$0a,$0a,$0a,$0a,$0b,$0b,$0b,
	$0b,$0c,$0c,$0c,$0c,$0d,$0d,$0d,
	$0d,$0e,$0e,$0e,$0e,$0f,$0f,$0f,
	$10,$10,$10,$11,$11,$11,$12,$12,
	$12,$13,$13,$13,$14,$14,$15,$15,
	$15,$16,$16,$17,$17,$17,$18,$18,
	$19,$19,$19,$1a,$1a,$1b,$1b,$1c,
	$1c,$1c,$1d,$1d,$1e,$1e,$1f,$1f
	);

log2_tab : array [0..255] of byte = (		// log2(x)*32
	$00,$00,$20,$32,$40,$4a,$52,$59,
	$60,$65,$6a,$6e,$72,$76,$79,$7d,
	$80,$82,$85,$87,$8a,$8c,$8e,$90,
	$92,$94,$96,$98,$99,$9b,$9d,$9e,
	$a0,$a1,$a2,$a4,$a5,$a6,$a7,$a9,
	$aa,$ab,$ac,$ad,$ae,$af,$b0,$b1,
	$b2,$b3,$b4,$b5,$b6,$b7,$b8,$b9,
	$b9,$ba,$bb,$bc,$bd,$bd,$be,$bf,
	$c0,$c0,$c1,$c2,$c2,$c3,$c4,$c4,
	$c5,$c6,$c6,$c7,$c7,$c8,$c9,$c9,
	$ca,$ca,$cb,$cc,$cc,$cd,$cd,$ce,
	$ce,$cf,$cf,$d0,$d0,$d1,$d1,$d2,
	$d2,$d3,$d3,$d4,$d4,$d5,$d5,$d5,
	$d6,$d6,$d7,$d7,$d8,$d8,$d9,$d9,
	$d9,$da,$da,$db,$db,$db,$dc,$dc,
	$dd,$dd,$dd,$de,$de,$de,$df,$df,
	$df,$e0,$e0,$e1,$e1,$e1,$e2,$e2,
	$e2,$e3,$e3,$e3,$e4,$e4,$e4,$e5,
	$e5,$e5,$e6,$e6,$e6,$e7,$e7,$e7,
	$e7,$e8,$e8,$e8,$e9,$e9,$e9,$ea,
	$ea,$ea,$ea,$eb,$eb,$eb,$ec,$ec,
	$ec,$ec,$ed,$ed,$ed,$ed,$ee,$ee,
	$ee,$ee,$ef,$ef,$ef,$ef,$f0,$f0,
	$f0,$f1,$f1,$f1,$f1,$f1,$f2,$f2,
	$f2,$f2,$f3,$f3,$f3,$f3,$f4,$f4,
	$f4,$f4,$f5,$f5,$f5,$f5,$f5,$f6,
	$f6,$f6,$f6,$f7,$f7,$f7,$f7,$f7,
	$f8,$f8,$f8,$f8,$f9,$f9,$f9,$f9,
	$f9,$fa,$fa,$fa,$fa,$fa,$fb,$fb,
	$fb,$fb,$fb,$fc,$fc,$fc,$fc,$fc,
	$fd,$fd,$fd,$fd,$fd,$fd,$fe,$fe,
	$fe,$fe,$fe,$ff,$ff,$ff,$ff,$ff
	);

octant_adjust : array [0..7] of byte = (
	%00111111,		// x+,y+,|x|>|y|
	%00000000,		// x+,y+,|x|<|y|
	%11000000,		// x+,y-,|x|>|y|
	%11111111,		// x+,y-,|x|<|y|
	%01000000,		// x-,y+,|x|>|y|
	%01111111,		// x-,y+,|x|<|y|
	%10111111,		// x-,y-,|x|>|y|
	%10000000		// x-,y-,|x|<|y|
	);

asm
	txa:pha

octant	= :eax			// temporary zeropage variable

	lda #$00
	sta octant

atan2		lda x1
		sbc x2
		bcs *+4
		eor #$ff
		tax
		rol octant

		lda y1
		sbc y2
		bcs *+4
		eor #$ff
		tay
		rol octant

		lda adr.log2_tab,x
		sbc adr.log2_tab,y
		bcc *+4
		eor #$ff
		tax

		lda octant
		rol @
		and #%111
		tay

		lda adr.atan_tab,x
		eor adr.octant_adjust,y

		sta Result

	pla:tax

end;


function sqrt16(a: word): byte; assembler;
(*
@description:
Returns the 8-bit square root of the 16-bit number.
https://codebase64.org/doku.php?id=base:16bit_and_24bit_sqrt

@param: A - Word

@return: Result - Byte
*)
asm
	txa:pha

	LDY #$01	; lsby of first odd number = 1
	STY :eax
	DEY
	STY :eax+1	; msby of first odd number (sqrt = 0)
again
	SEC
	LDA a		; save remainder in X register
	TAX		; subtract odd lo from integer lo
	SBC :eax
	STA a
	LDA a+1		; subtract odd hi from integer hi
	SBC :eax+1
	STA a+1		; is subtract result negative?
	BCC nomore	; no. increment square root
	INY
	LDA :eax	; calculate next odd number
	ADC #$01
	STA :eax
	BCC again
	INC :eax+1
	JMP again
nomore
	STY Result	; all done, store square root

;	STX $21		; and remainder

	pla:tax
end;


procedure FillSin(p: pointer; eor,add: byte); assembler;
(*
@description:

https://codebase64.org/doku.php?id=base:generating_approximate_sines_in_assembly
*)
asm
	txa:pha

	lda p
	sta a3+1
	add <$40
	sta a2+1
	lda p+1
	sta a3+2
	adc >$40
	sta a2+2

	adw p #$80 a1+1
	adw p #$c0 a0+1


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
