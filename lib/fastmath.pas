unit fastmath;
(*
 @type: unit
 @author: Cruzer/Camelot, Tebe/Madteam
 @name: Fast Math
 @version: 1.2

 @description:

 <http://www.txbobsc.com/aal/1986/aal8611.html#a1>

 <https://6502.org/users/mycorner/6502/code/root.html>

 <https://codebase64.org/doku.php?id=base:6502_6510_maths>

 <https://dwheeler.com/6502/oneelkruns/asm1step.html>
*)


{


}

interface

	function atan2(x1,x2,y1,y2: byte): byte; assembler;
	function sqrt16(Number: word): byte; assembler;

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

	{$link fdiv\fdiv.obj}

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


function sqrt16(Number: word): byte; assembler;
asm
; http://www.txbobsc.com/aal/1986/aal8611.html#a1

; SAVE S.PUTNEY-RBSC FISQR
; --------------------------------
;       ULTRA FAST INTEGER SQUARE ROOTS
;
;   BY: CHARLES H. PUTNEY
;       18 QUINNS ROAD
;       SHANKILL, CO. DUBLIN, IRELAND
;
;  INPUT: X = ARG HIGH BYTE
;         A = ARG LOW BYTE
;
;  OUTPUT: Y=INTEGER SQUARE ROOT OF X,A
;          X AND A DESTROYED
;
; --------------------------------

;BAS_ARG    =  $02           ; ,01
;NUMBER     =  $04           ; ,03

ARGSAV     =  :EAX           ; ,05
ARGLO      =  :EAX+2


	stx @sp+1

	ldx Number+1
	lda Number
	jsr SQRT

	sty Result
	
@sp	ldx #$00
	jmp @exit


SQRT
       cpx #$40             ; VALUE ALREADY NORMALIZED?
       bcc l2               ; ...NO

; ---ARG = $4000...FFFF-----------49152 CASES
       cpx #$FF             ; CHECK FOR ARG-HI = $FF
       beq l9               ; ...YES, SPECIAL CASE
       ldy ROOT,X           ; GET ROOT, USE AS INDEX
       cmp TABLE2,Y
       bcc l1               ; ...SPEEDS UP AVERAGE BY 0.8 CYCLE
       txa                  ; ARG-HI
       sbc TABLE3,Y
       bcc l1
       iny
l1     rts

; ---ARG = $0000...3FFF-----------
l2     stx ARGSAV+1         ; SAVE ARG-HI
       cpx #0               ; IS ARG-HI ZERO?
       beq l7               ; ...YES

; ---ARG = $01FF...3FFF-----------16128 CASES
       sta ARGSAV           ; SAVE ARG-LO FOR SHIFTING
       sta ARGLO            ; SAVE ARG-LO FOR LATER COMPARE
       txa                  ; ARG-HI TO A-REG
       ldy #0               ; START SHIFT COUNT = 0
l3     asl ARGLO
       rol
       asl ARGLO
       rol
       iny
       cmp #$40
       bcc l3

; ---A=NORM-ARG, Y=SHIFT-CNT------
l4     tax                  ; USE NORM-ARG FOR INDEX
       lda ROOT,X           ; GET ROOT FROM TABLE
l5     lsr                  ; HALF ROOT SHIFT-CNT TIMES
       dey
       bne l5
       tay                  ; USE SHIFTED ROOT FOR INDEX NOW
       lda ARGSAV           ; GET ARG-LO
       cmp TABLE2,Y
       bcc l6               ; ...SPEEDS UP AVERAGE BY 0.7 CYCLE
       lda ARGSAV+1
       sbc TABLE3,Y
       bcc l6
       iny
l6     rts

; ---ARG = $0000...00FF-----------
l7     tay                  ; IS ARG-LO ALSO ZERO?
       beq l1               ; ...YES, SQRT=0

; ---ARG = $0001...00FF-----------255 CASES
       sta ARGSAV           ; SAVE ARG-LO FOR LATER COMPARE
       ldy #4               ; START SHIFT COUNT = 4
l8     cmp #$40             ; NORMALIZED YET?
       bcs l4               ; ...YES, GET ROOT NOW
       asl
       asl
       iny                  ; COUNT THE SHIFT
       bne l8               ; ...ALWAYS

; ---ARG = $FFXX------------------
l9     ldy #$FF
       rts

;       SQUARE ROOT TABLE OF N
;       FROM $4000 (16384)
;       TO $FF00   (65280)
;       BY $100    (256)
TABLE1 .byte $80 ,$80 ,$81 ,$82 ,$83 ,$84 ,$85 ,$86
       .byte $87 ,$88 ,$89 ,$8A ,$8B ,$8C ,$8D ,$8E
       .byte $8F ,$90 ,$90 ,$91 ,$92 ,$93 ,$94 ,$95
       .byte $96 ,$96 ,$97 ,$98 ,$99 ,$9A ,$9B ,$9B
       .byte $9C ,$9D ,$9E ,$9F ,$A0 ,$A0 ,$A1 ,$A2
       .byte $A3 ,$A3 ,$A4 ,$A5 ,$A6 ,$A7 ,$A7 ,$A8
       .byte $A9 ,$AA ,$AA ,$AB ,$AC ,$AD ,$AD ,$AE
       .byte $AF ,$B0 ,$B0 ,$B1 ,$B2 ,$B2 ,$B3 ,$B4
       .byte $B5 ,$B5 ,$B6 ,$B7 ,$B7 ,$B8 ,$B9 ,$B9
       .byte $BA ,$BB ,$BB ,$BC ,$BD ,$BD ,$BE ,$BF
       .byte $C0 ,$C0 ,$C1 ,$C1 ,$C2 ,$C3 ,$C3 ,$C4
       .byte $C5 ,$C5 ,$C6 ,$C7 ,$C7 ,$C8 ,$C9 ,$C9
       .byte $CA ,$CB ,$CB ,$CC ,$CC ,$CD ,$CE ,$CE
       .byte $CF ,$D0 ,$D0 ,$D1 ,$D1 ,$D2 ,$D3 ,$D3
       .byte $D4 ,$D4 ,$D5 ,$D6 ,$D6 ,$D7 ,$D7 ,$D8
       .byte $D9 ,$D9 ,$DA ,$DA ,$DB ,$DB ,$DC ,$DD
       .byte $DD ,$DE ,$DE ,$DF ,$E0 ,$E0 ,$E1 ,$E1
       .byte $E2 ,$E2 ,$E3 ,$E3 ,$E4 ,$E5 ,$E5 ,$E6
       .byte $E6 ,$E7 ,$E7 ,$E8 ,$E8 ,$E9 ,$EA ,$EA
       .byte $EB ,$EB ,$EC ,$EC ,$ED ,$ED ,$EE ,$EE
       .byte $EF ,$F0 ,$F0 ,$F1 ,$F1 ,$F2 ,$F2 ,$F3
       .byte $F3 ,$F4 ,$F4 ,$F5 ,$F5 ,$F6 ,$F6 ,$F7
       .byte $F7 ,$F8 ,$F8 ,$F9 ,$F9 ,$FA ,$FA ,$FB
       .byte $FB ,$FC ,$FC ,$FD ,$FD ,$FE ,$FE ,$FF

;       SQUARE TABLE CONTAINING LOW BYTE OF (N+1)
TABLE2 .byte $01 ,$04 ,$09 ,$10 ,$19 ,$24 ,$31 ,$40
       .byte $51 ,$64 ,$79 ,$90 ,$A9 ,$C4 ,$E1 ,$00
       .byte $21 ,$44 ,$69 ,$90 ,$B9 ,$E4 ,$11 ,$40
       .byte $71 ,$A4 ,$D9 ,$10 ,$49 ,$84 ,$C1 ,$00
       .byte $41 ,$84 ,$C9 ,$10 ,$59 ,$A4 ,$F1 ,$40
       .byte $91 ,$E4 ,$39 ,$90 ,$E9 ,$44 ,$A1 ,$00
       .byte $61 ,$C4 ,$29 ,$90 ,$F9 ,$64 ,$D1 ,$40
       .byte $B1 ,$24 ,$99 ,$10 ,$89 ,$04 ,$81 ,$00
       .byte $81 ,$04 ,$89 ,$10 ,$99 ,$24 ,$B1 ,$40
       .byte $D1 ,$64 ,$F9 ,$90 ,$29 ,$C4 ,$61 ,$00
       .byte $A1 ,$44 ,$E9 ,$90 ,$39 ,$E4 ,$91 ,$40
       .byte $F1 ,$A4 ,$59 ,$10 ,$C9 ,$84 ,$41 ,$00
       .byte $C1 ,$84 ,$49 ,$10 ,$D9 ,$A4 ,$71 ,$40
       .byte $11 ,$E4 ,$B9 ,$90 ,$69 ,$44 ,$21 ,$00
       .byte $E1 ,$C4 ,$A9 ,$90 ,$79 ,$64 ,$51 ,$40
       .byte $31 ,$24 ,$19 ,$10 ,$09 ,$04 ,$01 ,$00
       .byte $01 ,$04 ,$09 ,$10 ,$19 ,$24 ,$31 ,$40
       .byte $51 ,$64 ,$79 ,$90 ,$A9 ,$C4 ,$E1 ,$00
       .byte $21 ,$44 ,$69 ,$90 ,$B9 ,$E4 ,$11 ,$40
       .byte $71 ,$A4 ,$D9 ,$10 ,$49 ,$84 ,$C1 ,$00
       .byte $41 ,$84 ,$C9 ,$10 ,$59 ,$A4 ,$F1 ,$40
       .byte $91 ,$E4 ,$39 ,$90 ,$E9 ,$44 ,$A1 ,$00
       .byte $61 ,$C4 ,$29 ,$90 ,$F9 ,$64 ,$D1 ,$40
       .byte $B1 ,$24 ,$99 ,$10 ,$89 ,$04 ,$81 ,$00
       .byte $81 ,$04 ,$89 ,$10 ,$99 ,$24 ,$B1 ,$40
       .byte $D1 ,$64 ,$F9 ,$90 ,$29 ,$C4 ,$61 ,$00
       .byte $A1 ,$44 ,$E9 ,$90 ,$39 ,$E4 ,$91 ,$40
       .byte $F1 ,$A4 ,$59 ,$10 ,$C9 ,$84 ,$41 ,$00
       .byte $C1 ,$84 ,$49 ,$10 ,$D9 ,$A4 ,$71 ,$40
       .byte $11 ,$E4 ,$B9 ,$90 ,$69 ,$44 ,$21 ,$00
       .byte $E1 ,$C4 ,$A9 ,$90 ,$79 ,$64 ,$51 ,$40
       .byte $31 ,$24 ,$19 ,$10 ,$09 ,$04 ,$01 ,$00

;       SQUARE TABLE CONTAINING HIGH BYTE OF (N+1)
TABLE3 .byte $00 ,$00 ,$00 ,$00 ,$00 ,$00 ,$00 ,$00
       .byte $00 ,$00 ,$00 ,$00 ,$00 ,$00 ,$00 ,$01
       .byte $01 ,$01 ,$01 ,$01 ,$01 ,$01 ,$02 ,$02
       .byte $02 ,$02 ,$02 ,$03 ,$03 ,$03 ,$03 ,$04
       .byte $04 ,$04 ,$04 ,$05 ,$05 ,$05 ,$05 ,$06
       .byte $06 ,$06 ,$07 ,$07 ,$07 ,$08 ,$08 ,$09
       .byte $09 ,$09 ,$0A ,$0A ,$0A ,$0B ,$0B ,$0C
       .byte $0C ,$0D ,$0D ,$0E ,$0E ,$0F ,$0F ,$10
       .byte $10 ,$11 ,$11 ,$12 ,$12 ,$13 ,$13 ,$14
       .byte $14 ,$15 ,$15 ,$16 ,$17 ,$17 ,$18 ,$19
       .byte $19 ,$1A ,$1A ,$1B ,$1C ,$1C ,$1D ,$1E
       .byte $1E ,$1F ,$20 ,$21 ,$21 ,$22 ,$23 ,$24
       .byte $24 ,$25 ,$26 ,$27 ,$27 ,$28 ,$29 ,$2A
       .byte $2B ,$2B ,$2C ,$2D ,$2E ,$2F ,$30 ,$31
       .byte $31 ,$32 ,$33 ,$34 ,$35 ,$36 ,$37 ,$38
       .byte $39 ,$3A ,$3B ,$3C ,$3D ,$3E ,$3F ,$40
       .byte $41 ,$42 ,$43 ,$44 ,$45 ,$46 ,$47 ,$48
       .byte $49 ,$4A ,$4B ,$4C ,$4D ,$4E ,$4F ,$51
       .byte $52 ,$53 ,$54 ,$55 ,$56 ,$57 ,$59 ,$5A
       .byte $5B ,$5C ,$5D ,$5F ,$60 ,$61 ,$62 ,$64
       .byte $65 ,$66 ,$67 ,$69 ,$6A ,$6B ,$6C ,$6E
       .byte $6F ,$70 ,$72 ,$73 ,$74 ,$76 ,$77 ,$79
       .byte $7A ,$7B ,$7D ,$7E ,$7F ,$81 ,$82 ,$84
       .byte $85 ,$87 ,$88 ,$8A ,$8B ,$8D ,$8E ,$90
       .byte $91 ,$93 ,$94 ,$96 ,$97 ,$99 ,$9A ,$9C
       .byte $9D ,$9F ,$A0 ,$A2 ,$A4 ,$A5 ,$A7 ,$A9
       .byte $AA ,$AC ,$AD ,$AF ,$B1 ,$B2 ,$B4 ,$B6
       .byte $B7 ,$B9 ,$BB ,$BD ,$BE ,$C0 ,$C2 ,$C4
       .byte $C5 ,$C7 ,$C9 ,$CB ,$CC ,$CE ,$D0 ,$D2
       .byte $D4 ,$D5 ,$D7 ,$D9 ,$DB ,$DD ,$DF ,$E1
       .byte $E2 ,$E4 ,$E6 ,$E8 ,$EA ,$EC ,$EE ,$F0
       .byte $F2 ,$F4 ,$F6 ,$F8 ,$FA ,$FC ,$FE ,$00

ROOT   =  TABLE1-$40    ; SET UP SO $80 IS FIRST SQUARE ROOT
EXACTL =  TABLE2        ; SET UP SO 0 INDEX        (OF $4000)
EXACTH =  TABLE3        ; GIVES EXACT SQUARE OF 1

end;



(*
function sqrt16(Number: word): byte; assembler;
{
@description:
Returns the 8-bit square root of the 16-bit number.

https://6502.org/users/mycorner/6502/code/root.html

; Calculates the 8 bit root and 9 bit remainder of a 16 bit unsigned integer in	
; Numberl/Numberh. The result is always in the range 0 to 255 and is held in
; Root, the remainder is in the range 0 to 511 and is held in Reml/Remh
;
; partial results are held in templ/temph
;
; This routine is the complement to the integer square program.
;
; Destroys A, X registers.

; variables - must be in RAM

}
asm
Reml		= :EAX		; remainder low byte
Remh		= :EAX+1	; remainder high byte
templ		= :EAX+2	; temp partial low byte
temph		= :EAX+3	; temp partial high byte

	LDA	#$00		; clear A
	STA	Reml		; clear remainder low byte
	STA	Remh		; clear remainder high byte
	STA	Result		; clear Root
	LDY	#$08		; 8 pairs of bits to do
Loop
	ASL	Result		; Root = Root * 2

	ASL	Number		; shift highest bit of number ..
	ROL	Number+1	;
	ROL	Reml		; .. into remainder
	ROL	Remh		;

	ASL	Number		; shift highest bit of number ..
	ROL	Number+1	;
	ROL	Reml		; .. into remainder
	ROL	Remh		;

	LDA	Result		; copy Root ..
	STA	templ		; .. to templ
	LDA	#$00		; clear byte
	STA	temph		; clear temp high byte

	SEC			; +1
	ROL	templ		; temp = temp * 2 + 1
	ROL	temph		;

	LDA	Remh		; get remainder high byte
	CMP	temph		; comapre with partial high byte
	BCC	Next		; skip sub if remainder high byte smaller

	BNE	Subtr		; do sub if <> (must be remainder>partial !)

	LDA	Reml		; get remainder low byte
	CMP	templ		; comapre with partial low byte
	BCC	Next		; skip sub if remainder low byte smaller

				; else remainder>=partial so subtract then
				; and add 1 to root. carry is always set here
Subtr
	LDA	Reml		; get remainder low byte
	SBC	templ		; subtract partial low byte
	STA	Reml		; save remainder low byte
	LDA	Remh		; get remainder high byte
	SBC	temph		; subtract partial high byte
	STA	Remh		; save remainder high byte

	INC	Result		; increment Root
Next
	DEY			; decrement bit pair count
	BNE	Loop		; loop if not all done
end;
*)


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
