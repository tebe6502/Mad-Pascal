
/*
	@REAL_ROUND
*/


.proc	@REAL_ROUND

RESULT	= :EAX

A	= :EAX

	ldy A+3
	bpl @+

	jsr @negEAX

@	lda A
	cmp #$80
	lda A+1
	adc #0
	sta A
	lda A+2
	adc #0
	sta A+1
	lda A+3
	adc #0
	sta A+2

	lda #$00 
	sta A+3

	tya
	spl
	jmp @negEAX

	rts
.endp
