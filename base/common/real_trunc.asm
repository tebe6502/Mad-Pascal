
/*
	@REAL_TRUNC
*/


.proc	@REAL_TRUNC

RESULT	= :EAX

A	= :EAX

	ldy A+3
	bpl @+

	jsr @negEAX
@
	mva A+1 A
	mva A+2 A+1
	mva A+3 A+2
	mva #$00 A+3

	tya
	spl
	jmp @negEAX

	rts
.endp
