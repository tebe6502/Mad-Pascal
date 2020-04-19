
/*
	@TRUNC
	@TRUNC_SHORT
*/

.proc	@TRUNC

	ldy :STACKORIGIN+STACKWIDTH*3,x
	spl
	jsr negCARD

	mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x
	mva :STACKORIGIN+STACKWIDTH*2,x :STACKORIGIN+STACKWIDTH,x
	mva :STACKORIGIN+STACKWIDTH*3,x :STACKORIGIN+STACKWIDTH*2,x
	mva #$00 :STACKORIGIN+STACKWIDTH*3,x

	tya
	spl
	jsr negCARD

	rts
.endp


.proc	@TRUNC_SHORT

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
