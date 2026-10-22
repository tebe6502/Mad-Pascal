
/*
	@REAL_FRAC
*/


.proc	@REAL_FRAC

RESULT	= :EAX

A	= :EAX

	ldy #0
	lda A+3
	spl
	dey

	sty A+1
	sty A+2
	sty A+3

	rts
.endp
