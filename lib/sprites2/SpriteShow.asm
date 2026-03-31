
.local	SpriteShow

	sta zp+@zp.hlp5
	stx zp+@zp.hlp5+1

	sty zp+@zp.hlp0
	iny
	sty zp+@zp.hlp0+1
	iny
	sty zp+@zp.hlp1

	ldy #PlayfieldWidth*0
	@row

	ldy #PlayfieldWidth*1
	@row

	ldy #PlayfieldWidth*2
	@row

	rts
.endl


.macro	@row

	lda (zp+@zp.hlp5),y
	and #$80
	ora zp+@zp.hlp0
	sta (zp+@zp.hlp5),y

	iny

	lda (zp+@zp.hlp5),y
	and #$80
	ora zp+@zp.hlp0+1
	sta (zp+@zp.hlp5),y

	iny

	lda (zp+@zp.hlp5),y
	and #$80
	ora zp+@zp.hlp1
	sta (zp+@zp.hlp5),y
.endm

