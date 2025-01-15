
/*
	@INT
	@INT_SHORT
*/

.proc	@INT

	ldy :STACKORIGIN+STACKWIDTH*3,x
	spl
	jsr @negCARD

	lda #$00
	sta :STACKORIGIN,x

	tya
	spl
	jmp @negCARD

	rts
.endp


.proc	@INT_SHORT

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
