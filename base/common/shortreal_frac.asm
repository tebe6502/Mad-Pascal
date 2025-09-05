
/*
	@SHORTREAL_FRAC
*/


.proc	@SHORTREAL_FRAC

	ldy :STACKORIGIN+STACKWIDTH,x
	spl
	jsr @negSHORT

	lda #$00
	sta :STACKORIGIN+STACKWIDTH,x

	tya
	spl
	jmp @negSHORT

	rts
.endp
