
//---------------------------------------------------------------------
//	SPRITE CHARS
//---------------------------------------------------------------------

.local	SpriteChars

	sty zp+@zp.hlp0

	tay

	mva	Charsets-4,x	zp+@zp.hlp2
	mva	Charsets-4+1,x	zp+@zp.hlp3

	clc

//------------------ ROW #0 ----------------------------

r0	lda zp+@zp.hlp2
	bne row0

	@Empty	0 1 2 3

	jmp r1

row0	@Chars	0 1 2 3	hlp2 0

//------------------ ROW #1 ----------------------------

r1	lda zp+@zp.hlp3
	bne row1

	@Empty	4 5 6 7

	rts

row1	@Chars	4 5 6 7 hlp3 1

	rts
.endl


//---------------------------------------------------------------------
//---------------------------------------------------------------------

.macro	@Empty

	lda <EmptyChar
	sta src:1+1
	sta src:2+1
	sta src:3+1
	sta src:4+1

	sta dst:1+1
	sta dst:2+1
	sta dst:3+1
	sta dst:4+1

	lda >EmptyChar
	sta src:1+2
	sta src:2+2
	sta src:3+2
	sta src:4+2

	sta dst:1+2
	sta dst:2+2
	sta dst:3+2
	sta dst:4+2
.endm


.macro	@Chars

	ldx CharsBackup+:1,y
	mva lAdrCharset,x src:1+1	; adres znaków z aktualnego bufora
	lda hAdrCharset,x
	ora zp+@zp.:5
	sta src:1+2

	ldx CharsBackup+:2,y
	mva lAdrCharset,x src:2+1	; adres znaków z aktualnego bufora
	lda hAdrCharset,x
	ora zp+@zp.:5
	sta src:2+2

	ldx CharsBackup+:3,y
	mva lAdrCharset,x src:3+1	; adres znaków z aktualnego bufora
	lda hAdrCharset,x
	ora zp+@zp.:5
	sta src:3+2

	ldx CharsBackup+:4,y
	mva lAdrCharset,x src:4+1	; adres znaków z aktualnego bufora
	lda hAdrCharset,x
	ora zp+@zp.:5
	sta src:4+2


	ldx zp+@zp.hlp0			; znak reprezentujący ducha

	lda lAdrCharset,x
	sta dst:1+1
	adc #8
	sta dst:2+1
	adc #8
	sta dst:3+1
	adc #8
	sta dst:4+1

	lda hAdrCharset,x
	ora zp+@zp.:5
	sta dst:1+2
	sta dst:2+2
	sta dst:3+2
	sta dst:4+2
.endm
