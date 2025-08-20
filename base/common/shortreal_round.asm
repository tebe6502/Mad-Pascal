
/*
	@SHORTREAL_ROUND
*/


.proc	@SHORTREAL_ROUND

	ldy :STACKORIGIN+STACKWIDTH,x
	spl
	jsr @negSHORT

	lda :STACKORIGIN,x
//	add #$80
	cmp #$80
	lda :STACKORIGIN+STACKWIDTH,x
	adc #0
	sta :STACKORIGIN,x

	mva #$00 :STACKORIGIN+STACKWIDTH,x

	tya
	spl
	jmp @negSHORT

	rts
.endp
