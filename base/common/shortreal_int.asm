
/*
	@SHORTREAL_INT
*/

.proc	@SHORTREAL_INT

	ldy :STACKORIGIN+STACKWIDTH,x
	spl
	jsr @negSHORT

	lda #$00
	sta :STACKORIGIN,x

	tya
	spl
	jmp @negSHORT

	rts
.endp
