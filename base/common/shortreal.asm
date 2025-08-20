; SHORTREAL	fixed-point Q8.8, 16bit
; https://en.wikipedia.org/wiki/Q_(number_format)

/*
	@SHORTREAL_MUL
	@SHORTREAL_DIV
*/

.proc	@SHORTREAL_MUL

RESULT	= :EAX

A	= :EAX
B	= :ECX

	lda A+1
	eor B+1
	pha

	bit A+1
	bpl @+

	lda #$00
	sub A
	sta A
	lda #$00
	sbc A+1
	sta A+1
@
	lda B+1
	bpl @+

	lda #$00
	sub B
	sta B
	lda #$00
	sbc B+1
	sta B+1
@

	.ifdef fmulinit
	jsr fmulu_16
	els
	jsr imulCX
	eif

	pla
	bpl @+

	lda #$00
	sub A+1
	sta A
	lda #$00
	sbc A+2
	sta A+1

	rts
@
	lda A+1
	sta A
	lda A+2
	sta A+1

	rts
.endp


.proc	@SHORTREAL_DIV

RESULT	= :EAX

A	= :EAX
B	= :ECX
C	= :ECX+2

	lda A+1
	eor B+1
	pha

	bit A+1
	bpl @+

	lda #$00
	sub A
	sta A
	lda #$00
	sbc A+1
	sta A+1
@
	bit B+1
	bpl @+

	lda #$00
	sub B
	sta B
	lda #$00
	sbc B+1
	sta B+1
@

.local	div24by15

; input:
; dividend:
; LSB: a
;      a+1
; MSB: accumulator
; divisor:
; LSB: b
; MSB: b+1 - bit 7 must be clear!
;
; Piotr Fusik, 19.04.2023

	stx rx
	
	lda #0

	ldy	#8
hi_loop
	rol	a
	rol	a+1
	rol	@
	ldx	a+1
	cpx	b
	tax
	sbc	b+1
	bcc	hi_below
	tax
	lda	a+1
	sbc	b
	sta	a+1
	sec
hi_below
	txa
	dey
	bne	hi_loop
	rol	a
	iny
	sty	c
lo_loop
	asl	a+1
	rol	@
	ldx	a+1
	cpx	b
	tax
	sbc	b+1
	bcc	lo_below
	tax
	lda	a+1
	sbc	b
	sta	a+1
	sec
lo_below
	txa
	rol	c
	bcc	lo_loop

; result: HI=a LO=c
	lda	c
	ldx	a

	sta A
	stx A+1

	ldx rx: #0

.endl
	pla
	bpl @+

	lda #$00
	sub A
	sta A
	lda #$00
	sbc A+1
	sta A+1
@
	rts
.endp
