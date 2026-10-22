
/*
	@SHORTREAL_FRAC
*/


.proc	@SHORTREAL_FRAC

RESULT	= :EAX

A	= :EAX

	ldy #0
	lda A+1
	spl
	dey

	sty A+1

	rts
.endp
