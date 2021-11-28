
/*
	@REAL_TRUNC
	@TRUNC_SHORT
*/

.proc	@REAL_TRUNC

RESULT	= :EAX

A	= :EAX

	ldy A+3
	bpl @+

	jsr negA
@
	mva A+1 A
	mva A+2 A+1
	mva A+3 A+2
	mva #$00 A+3

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


.proc	@TRUNC_SHORT

	ldy :STACKORIGIN+STACKWIDTH,x
	spl
	jsr negSHORT

	sta :STACKORIGIN,x
	mva #$00 :STACKORIGIN+STACKWIDTH,x

	tya
	spl
	jsr negSHORT

	rts
.endp
