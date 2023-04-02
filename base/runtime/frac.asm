
/*
	@FRAC
	@FRAC_SHORT
*/

.proc	@FRAC

	ldy :STACKORIGIN+STACKWIDTH*3,x
	spl
	jsr negCARD

	lda #$00
	sta :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN+STACKWIDTH*2,x
	sta :STACKORIGIN+STACKWIDTH*3,x

	tya
	spl
	jsr negCARD

	rts
.endp


.proc	@FRAC_SHORT

	ldy :STACKORIGIN+STACKWIDTH,x
	spl
	jsr negSHORT

	lda #$00
	sta :STACKORIGIN+STACKWIDTH,x

	tya
	spl
	jsr negSHORT

	rts
.endp
