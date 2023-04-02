
/*
	@SHORTREAL_TRUNC
*/


.proc	@SHORTREAL_TRUNC

	ldy :STACKORIGIN+STACKWIDTH,x
	spl
	jsr negSHORT

	sta :STACKORIGIN,x
	mva #$00 :STACKORIGIN+STACKWIDTH,x

	tya
	spl
	jsr negSHORT

	rts
.endp
