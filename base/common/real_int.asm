
/*
	@REAL_INT
*/

.proc	@REAL_INT

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
