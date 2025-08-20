
/*
	@REAL_FRAC
*/


.proc	@REAL_FRAC

RESULT	= :EAX

A	= :EAX

	ldy A+3
	bpl @+

	jsr @negEAX
@
	lda #$00
	sta A+1
	sta A+2
	sta A+3

	tya
	spl
	jmp @negEAX

	rts
.endp
