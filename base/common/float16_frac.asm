
.proc	@F16_FRAC						; FUNCTION

RESULT	= :EAX
VALUE	= :EAX

A	= :EAX+2

	lda A
	sta @F16_INT.A
	pha
	lda A+1
	sta @F16_INT.A+1
	pha
	jsr @F16_INT
	jsr @F16_I2F
	lda @F16_I2F.RESULT
	sta @F16_SUB.B
	lda @F16_I2F.RESULT+1
	sta @F16_SUB.B+1
	pla
	sta @F16_SUB.A+1
	pla
	sta @F16_SUB.A

	jmp @F16_SUB

.endp
