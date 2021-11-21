
.proc	@F16_INT						; FUNCTION

RESULT	= :EAX
A	= :EAX

VALUE	= :ECX
SHIFT	= :ECX+2


	lda A+1
	and #$7C
	jne l_0A7F

	lda A+1
	and #$03
	sta VALUE+1
	jmp l_0A92
l_0A7F

	lda A+1
	and #$03
	ora #$04
	sta VALUE+1
l_0A92

	lda A
	sta VALUE

	lda A+1
	and #$7C
	lsr @
	lsr @
	sub #$19
	sta SHIFT

	jmi l_0AC1
	jeq l_0AC1

	lda VALUE
	ldy SHIFT
l_0004_b
	asl @
	rol VALUE+1
	dey
	bne l_0004_b

	sta VALUE
	jmp l_0AD5
l_0AC1

	lda SHIFT
	jpl l_0AE6

	lda #$00
	sub SHIFT
	tay
	lda VALUE
l_0005_b
	lsr VALUE+1
	ror @
	dey
	bne l_0005_b
	sta VALUE
l_0AE6
l_0AD5

	lda A+1
	jpl l_0B0B

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

	lda VALUE
	sta RESULT
	lda VALUE+1
	sta RESULT+1
	lda #$00
	sta RESULT+2
	sta RESULT+3

	RTS
.endp
