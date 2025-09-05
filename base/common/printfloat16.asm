
// ----------------------------------------------------------------
// f16_f2a
// changes: 2023-03-03
// ----------------------------------------------------------------

.proc	@F16_F2A				; FUNCTION

DST	= :EDX

HALF	= :EDX
I	= HALF

MANTISSA= :ECX

HLP	= :EAX

SIGN	= :EAX+3


	lda HALF+1
	and #$80
	sta SIGN

	lda HALF+1
	and #$7C
	lsr @
	lsr @
	tay

	lda HALF
	sta MANTISSA
	lda HALF+1
	and #$03
	sta MANTISSA+1
	lda #$00
	sta MANTISSA+2
	sta MANTISSA+3

	tya
	jeq l_03B2
	cmp #$1F
	jcs l_03B2

	add #$70
	tay

	lda MANTISSA+2
	sta HLP+2
	lda MANTISSA+1
	sta HLP+1
	lda MANTISSA
	sta HLP

	lda #$00
	lsr HLP+2
	ror HLP+1
	ror HLP
	ror @
	lsr HLP+2
	ror HLP+1
	ror HLP
	ror @
	lsr HLP+2
	ror HLP+1
	ror HLP
	ror @
	sta MANTISSA+1
	
	lda #$00
	sta MANTISSA
	lda HLP
	sta MANTISSA+2
	lda HLP+1
	sta MANTISSA+3

	lda #$00
	lsr @
	tya
	ror @
	pha

	lda #$00
	ror @
	pha

	lda MANTISSA
	sta DST
	lda MANTISSA+1
	sta DST+1

	pla
	ora MANTISSA+2
	sta DST+2

	pla
	ora SIGN
	ora MANTISSA+3
;	sta DST+3

	jmp l_03E0
l_03B2

	tya
	bne l_03FC

	lda MANTISSA+3
	ora MANTISSA+2
	ora MANTISSA+1
	ora MANTISSA
	bne l_03FC

;	lda #$00
	sta DST
	sta DST+1
	sta DST+2
	lda SIGN
	sta DST+3
	jmp l_040A
l_03FC

;	tya
	jne l_0426

	lda MANTISSA+3
	ora MANTISSA+2
	ora MANTISSA+1
	ora MANTISSA
	jeq l_0426

; --- WhileProlog
	jmp l_0429
l_042A

	asl MANTISSA
	rol MANTISSA+1
	rol MANTISSA+2
	rol MANTISSA+3

	dey
l_0429

	lda MANTISSA+1
	and #$04
	beq l_042A

	iny

	lda MANTISSA+1
	and #$FB
	sta MANTISSA+1
	lda #$00
	sta MANTISSA+2
	sta MANTISSA+3

	tya
	add #$70
	tay

	lda MANTISSA+2
	sta HLP+2
	lda MANTISSA+1
	sta HLP+1
	lda MANTISSA
	sta HLP

	lda #$00
	lsr HLP+2
	ror HLP+1
	ror HLP
	ror @
	lsr HLP+2
	ror HLP+1
	ror HLP
	ror @
	lsr HLP+2
	ror HLP+1
	ror HLP
	ror @
	sta MANTISSA+1
	
	lda #$00
	sta MANTISSA
	
	lda HLP
	sta MANTISSA+2
	
	lda HLP+1
	sta MANTISSA+3

	lda #$00
	lsr @
	tya
	ror @
	pha

	lda #$00
	ror @
	pha

	lda MANTISSA
	sta DST

	lda MANTISSA+1
	sta DST+1

	pla
	ora MANTISSA+2
	sta DST+2

	pla
	ora SIGN
	ora MANTISSA+3
	sta DST+3

	jmp l_0480
l_0426

	tya
	cmp #$1F
	bne l_049C

	lda MANTISSA+3
	ora MANTISSA+2
	ora MANTISSA+1
	ora MANTISSA
	bne l_049C

;	lda #$00
	sta DST
	sta DST+1
	lda #$80
	sta DST+2
	lda SIGN
	ora #$7F
	sta DST+3
	jmp l_04AE
l_049C

	lda #$00
	sta DST

	lsr MANTISSA+2
	ror MANTISSA+1
	ror MANTISSA
	ror @
	lsr MANTISSA+2
	ror MANTISSA+1
	ror MANTISSA
	ror @
	lsr MANTISSA+2
	ror MANTISSA+1
	ror MANTISSA
	ror @
	sta DST+1

	lda #$80
	ora MANTISSA+1
	sta DST+2
	
	lda SIGN
	ora #$7f
	ora MANTISSA
l_03E0
	sta DST+3
l_04AE
l_0480
l_040A

	jmp @FTOA

.endp
