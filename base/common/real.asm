
; REAL	fixed-point Q24.8, 32bit
; https://en.wikipedia.org/wiki/Q_(number_format)
;
; changes: 2024-10-01
;

/*
	@REAL_MUL
	@REAL_DIV
*/


.proc	@REAL_MUL

RESULT	= :EAX

A	= :EAX
B	= :ECX

	lda A+3
	eor B+3
	pha

	bit A+3
	spl
	jsr @negEAX	;jsr @negA

	lda B+3
	spl
	jsr @negECX	;jsr @negB

	ora A+3
;	ora B+3
	ora A+2
	ora B+2
	bne m32

	.ifdef fmulinit
	jsr fmulu_16
	els
	jsr imulCX
	eif

	pla
	bpl @+

	lda #0
	sub A+1
	sta A
	lda #0
	sbc A+2
	sta A+1
	lda #0
	sbc A+3
	sta A+2
	lda #0
	sbc #0
	sta A+3

	rts
@
	mva A+1 A
	mva A+2 A+1
	mva A+3 A+2

	mva #0 A+3

	rts
m32
	lda #$00
	sta :EDX	;Clear upper half of
	sta :EDX+1	;product
	sta :EDX+2
	sta :EDX+3

	sta :ZTMP8
	sta :ZTMP9
	sta :ZTMP10

	ldy #$20	;Set binary count to 32

SHIFT_R
	lsr A+3		;Shift multiplyer right
	ror A+2
	ror A+1
	ror A
	bcc ROTATE_R	;Go rotate right if c = 0

	clc
	lda :EDX	;Get upper half of product
	adc B		;and add multiplicand to
	sta :EDX
	lda :EDX+1
	adc B+1
	sta :EDX+1
	lda :EDX+2
	adc B+2
	sta :EDX+2
	lda :EDX+3
	adc B+3

ROTATE_R
	ror @		;Rotate partial product
	sta :EDX+3	;right

	ror :EDX+2
	ror :EDX+1
	ror :EDX
	ror :ZTMP10
	ror :ZTMP9
	ror :ZTMP8

	dey		;Decrement bit count and
	bne SHIFT_R	;loop until 32 bits are

	pla
	bpl @+

	lda #0
	sub :ZTMP8
	sta A
	lda #0
	sbc :ZTMP9
	sta A+1
	lda #0
	sbc :ZTMP10
	sta A+2
	lda #0
	sbc :EDX
	sta A+3

	rts
@
	mva :ZTMP8 A
	mva :ZTMP9 A+1
	mva :ZTMP10 A+2

	mva :EDX A+3

	rts
.endp


;---------------------------------------------------------------------------


.proc	@REAL_DIV

RESULT	= :EAX

A	= :EAX
B	= :ECX

	lda A+3
	eor B+3
	sta sign

	bit A+3		; dividend sign
	spl
	jsr @negEAX	;jsr @negA

	lda B+3
	spl
	jsr @negECX	;jsr @negB

	mva :ecx ecx0
	sta ecx0_
	mva :ecx+1 ecx1
	sta ecx1_
	mva :ecx+2 ecx2
	sta ecx2_
	mva :ecx+3 ecx3

	lda #$00
	sta :eax+4
	sta :eax+5
	sta :eax+6
	sta :eax+7

	LDY #40
	jmp UDIV321
	
UDIV320	DEY
	BEQ stop
UDIV321
	ASL :eax
	ROL :eax+1
	ROL :eax+2
	ROL :eax+3
	ROL :eax+4
	ROL :eax+5
	ROL :eax+6
	ROL :eax+7
			;do a subtraction
	LDA :eax+4
	CMP ecx0: #0
	LDA :eax+5
	SBC ecx1: #0
	LDA :eax+6
	SBC ecx2: #0
	LDA :eax+7
	SBC ecx3: #0
	BCC UDIV320

	INC :eax	;set result bit

	DEY
	BEQ stop

 			;overflow, do the subtraction again, this time store the result
	STA :eax+7	;we have the high byte already

	LDA :eax+4
	SBC ecx0_: #0	;byte 0
	STA :eax+4
	LDA :eax+5
	SBC ecx1_: #0
	STA :eax+5	;byte 1
	LDA :eax+6
	SBC ecx2_: #0
	STA :eax+6	;byte 2

	JMP UDIV321
stop
	lda sign: #0
	spl	
	jmp @negEAX	;jmp @negA

	rts
.endp
