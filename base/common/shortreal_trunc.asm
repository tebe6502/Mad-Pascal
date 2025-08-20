
/*
	@SHORTREAL_TRUNC
*/


.proc	@SHORTREAL_TRUNC

RESULT	= :EAX

A	= :EAX

	ldy A+1
	bpl @+

	jsr @negAX
@
	sta A
	mva #$00 A+1

	tya
	spl
	jmp @negAX

	rts
.endp
