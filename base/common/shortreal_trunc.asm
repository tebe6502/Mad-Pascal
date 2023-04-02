
/*
	@SHORTREAL_TRUNC
*/


.proc	@SHORTREAL_TRUNC

RESULT	= :EAX

A	= :EAX

	ldy A+1
	bpl @+

	jsr negA
@
	sta A
	mva #$00 A+1

	tya
	bpl @+
	
negA	lda #$00
	sub A
	sta A

	lda #$00
	sbc A+1
	sta A+1
@
	rts
.endp
