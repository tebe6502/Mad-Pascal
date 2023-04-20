
/*
	@REAL_FRAC
*/


.proc	@REAL_FRAC

RESULT	= :EAX

A	= :EAX

	ldy A+3
	bpl @+

	jsr negA
@
	lda #$00
	sta A+1
	sta A+2
	sta A+3

	tya
	bpl @+

negA	lda #$00
	sub A
	sta A

	lda #$00
	sbc A+1
	sta A+1

	lda #$00
	sbc A+2
	sta A+2

	lda #$00
	sbc A+3
	sta A+3
@
	rts
.endp


/*
	ldy :STACKORIGIN+STACKWIDTH*3,x
	spl
	jsr negCARD

	lda #$00
	sta :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN+STACKWIDTH*2,x
	sta :STACKORIGIN+STACKWIDTH*3,x

	tya
	spl
	jsr negCARD

	rts
.endp
*/