
/*
	@REAL_ROUND
	@ROUND_SHORT
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

/*
.proc	@REAL_ROUND

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
*/

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
