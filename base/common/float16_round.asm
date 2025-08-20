
.proc	@F16_ROUND						; FUNCTION

RESULT	= :EAX

A	= :EAX+2

	lda A+1
	bpl plus

	lda #$00		; 0.5
	sta @F16_SUB.B
	lda #$38
	sta @F16_SUB.B+1
	lda A
	sta @F16_SUB.A
	lda A+1
	sta @F16_SUB.A+1
	jsr @F16_SUB

	jmp skip

plus	lda #$00		; 0.5
	sta @F16_ADD.B
	lda #$38
	sta @F16_ADD.B+1
	lda A
	sta @F16_ADD.A
	lda A+1
	sta @F16_ADD.A+1
	jsr @F16_ADD

skip
	lda @F16_ADD.RESULT
	sta @F16_INT.A
	lda @F16_ADD.RESULT+1
	sta @F16_INT.A+1
	jmp @F16_INT

.endp
