
// ----------------------------------------------------------------
// f16_int
// changes: 2022-12-17 ; 2023-03-03
// ----------------------------------------------------------------

.proc	@F16_INT						; FUNCTION

RESULT	= :EAX
VALUE	= :EAX

A	= :EAX+2

	lda A+1
_
	and #$7C
	bne l_0A7F

	lda A+1
	and #$03
;	sta VALUE+1
	jmp l_0A92
l_0A7F

	lda A+1
	and #$03
	ora #$04
l_0A92
	sta VALUE+1

	lda A
	sta VALUE

	lda A+1
	and #$7C
	lsr @
	lsr @
	sub #$19
;	tay

	bmi l_0AC1
	beq l_0AE6

	lda VALUE
l_0004_b
	asl @
	rol VALUE+1

	dey
	bne l_0004_b

;	sta VALUE
	jmp l_0AD5
l_0AC1

;	tya
;	bpl l_0AE6
	
	eor #$ff
	tay
	;iny

	lda VALUE
l_0005_b
	lsr VALUE+1
	ror @

	dey
	bpl l_0005_b
l_0AD5
	sta VALUE
l_0AE6

	lda A+1
	bpl l_0B0B

	lda #$00
	sub VALUE
	sta RESULT
	lda #$00
	sbc VALUE+1
	sta RESULT+1
	lda #$00
	sbc #$00
	sta RESULT+2
	lda #$00
	sbc #$00
	sta RESULT+3

	RTS					; exit
l_0B0B

;	lda VALUE
;	sta RESULT
;	lda VALUE+1
;	sta RESULT+1
	lda #$00
	sta RESULT+2
	sta RESULT+3

	RTS
.endp
