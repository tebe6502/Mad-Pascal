; SHORTREAL	fixed-point Q8.8, 16bit
; https://en.wikipedia.org/wiki/Q_(number_format)

/*
	mulSHORTREAL
	divSHORTREAL
*/


.proc	@SHORTREAL_MUL

A	= :ECX
B	= :EAX

RESULT	= :EAX

	mva B	B0+1
	mva B+1	B1+1

	mva A	A0+1
	mva A+1	A1+1

	.ifdef fmulinit
	jsr fmulu_16
	els
	jsr imulCX
	eif	

	mva :eax+1 :eax
	mva :eax+2 :eax+1

A1	lda #0				; t1
	bpl @+
	sec
	lda :eax+1
B0	sbc #0
	sta :eax+1
@

B1	lda #0				; t2
	bpl @+
	sec
	lda :eax+1
A0	sbc #0
	sta :eax+1
@
	
	rts
.endp


.proc	@SHORTREAL_DIV

A	= :EAX
B	= :ECX

RESULT	= :EAX

	ldy #0

	lda A+1				; dividend sign
	bpl @+
	
	lda #$00
	sub A
	sta A

	lda #$00
	sbc A+1
	sta A+1

	iny
@
	lda B+1				; divisor sign
	bpl @+

	lda #$00
	sub B
	sta B

	lda #$00
	sbc B+1
	sta B+1

	iny
@
	tya
	and #1
	pha

	mva :eax+1 :eax+2
	mva :eax :eax+1
	
	lda #0
	sta :eax
	sta :eax+3

	jsr idivEAX_CX

	pla
	beq @+

	lda #$00
	sub :eax
	sta :eax

	lda #$00
	sbc :eax+1
	sta :eax+1
@
	rts
.endp
