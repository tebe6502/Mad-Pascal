
/*
	@ROUND
	@ROUND_SHORT
*/

.proc	@ROUND

	ldy :STACKORIGIN+STACKWIDTH*3,x
	spl
	jsr negCARD

	lda :STACKORIGIN,x
//	add #$80
	cmp #$80
	lda :STACKORIGIN+STACKWIDTH,x
	adc #0
	sta :STACKORIGIN,x
	lda :STACKORIGIN+STACKWIDTH*2,x
	adc #0
	sta :STACKORIGIN+STACKWIDTH,x
	lda :STACKORIGIN+STACKWIDTH*3,x
	adc #0
	sta :STACKORIGIN+STACKWIDTH*2,x

	mva #$00 :STACKORIGIN+STACKWIDTH*3,x

	tya
	spl
	jsr negCARD

	rts
.endp


.proc	@ROUND_SHORT

	ldy :STACKORIGIN+STACKWIDTH,x
	spl
	jsr negSHORT

	lda :STACKORIGIN,x
//	add #$80
	cmp #$80
	lda :STACKORIGIN+STACKWIDTH,x
	adc #0
	sta :STACKORIGIN,x

	mva #$00 :STACKORIGIN+STACKWIDTH,x

	tya
	spl
	jsr negSHORT

	rts
.endp
