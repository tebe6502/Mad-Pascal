
/*
	@REAL_ROUND
*/


.proc	@REAL_ROUND

RESULT	= :EAX

A	= :EAX

	ldy A+3
	bpl @+

	jsr negA

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
	bpl @+

negA	lda #$00
	sub A
	sta A

	lda #$00
	sbc A+1
	sta A+1

	lda #$00
	sbc A+2
	sta A+2

	lda #$00
	sbc A+3
	sta A+3
@
	rts
.endp
