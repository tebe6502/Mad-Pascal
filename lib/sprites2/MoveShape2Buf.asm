
//---------------------------------------------------------------------
//	MOVE
//---------------------------------------------------------------------

	.pages

MOVE
	ldy #7
loop

ofs0	ldx shpBuf,y		; row 0
src0	lda $ffff,y
	and tMask,x
	ora tByte,x
dst0	sta $ffff,y

ofs4	ldx shpBuf+height,y
src1	lda $ffff,y
	and tMask,x
	ora tByte,x
dst1	sta $ffff,y

ofs8	ldx shpBuf+height*2,y
src2	lda $ffff,y
	and tMask,x
	ora tByte,x
dst2	sta $ffff,y


ofs1	ldx shpBuf+8,y		; row 1
src4	lda $ffff,y
	and tMask,x
	ora tByte,x
dst4	sta $ffff,y

ofs5	ldx shpBuf+8+height,y
src5	lda $ffff,y
	and tMask,x
	ora tByte,x
dst5	sta $ffff,y

ofs9	ldx shpBuf+8+height*2,y
src6	lda $ffff,y
	and tMask,x
	ora tByte,x
dst6	sta $ffff,y


ofs2	ldx shpBuf+16,y		; row 2
src8	lda $ffff,y
	and tMask,x
	ora tByte,x
dst8	sta $ffff,y

ofs6	ldx shpBuf+16+height,y
src9	lda $ffff,y
	and tMask,x
	ora tByte,x
dst9	sta $ffff,y

ofs10	ldx shpBuf+16+height*2,y
src10	lda $ffff,y
	and tMask,x
	ora tByte,x
dst10	sta $ffff,y

	dey
	jpl loop

	.endpg

	rts


//---------------------------------------------------------------------
//	MOVE SHAPE -> BUF
//---------------------------------------------------------------------

.local	MoveShape2Buf

	mva Sprite0+@Spr.bitmaps,x	zp+@zp.hlp1
	mva Sprite0+@Spr.bitmaps+1,x	zp+@zp.hlp1+1

	lda Sprite0+@Spr.index,x

	asl @

bck	tay
	lda (zp+@zp.hlp1),y
	sta zp+@zp.hlp2
	iny
	lda (zp+@zp.hlp1),y
	bne skp

	lda #0
	sta Sprite0+@Spr.index,x
	jmp bck

skp	sta zp+@zp.hlp2+1

	inc Sprite0+@Spr.delay,x
	lda Sprite0+@Spr.delay,x
	and #3
	sne

	inc Sprite0+@Spr.index,x

// ---------------------- Offset Y --------------------------

	lda Sprite0+@Spr.yOk,x
	and #7
	eor #7

	clc

	sta ofs0+1
	adc #8
	sta ofs1+1
	adc #8
	sta ofs2+1

	adc #8
	sta ofs4+1
	adc #8
	sta ofs5+1
	adc #8
	sta ofs6+1

	adc #8
	sta ofs8+1
	adc #8
	sta ofs9+1
	adc #8
	sta ofs10+1

// ---------------------- Offset X --------------------------

	lda Sprite0+@Spr.xOk,x
	and #3
	bne ne0

// --------------------- X and 3 = 0 ------------------------

eq0	.local

	lda zp+@zp.hlp2
	sta adr0+1
	adc #16
	sta adr1+1

	lda zp+@zp.hlp2+1
	sta adr0+2
	sta adr1+2


; ofs0 ofs4 ofs8	; row 0
; ofs1 ofs5 ofs9	; row 1
; ofs2 ofs6 ofs10	; row 2

	lda <FillChar
	sta ofs8+1
	sta ofs9+1
	sta ofs10+1

	lda >FillChar
	sta ofs8+2
	sta ofs9+2
	sta ofs10+2


	ldy #15

	.pages

adr0	lda $ffff,y
	sta shpBuf+8,y

adr1	lda $ffff,y
	sta shpBuf+height+8,y

	dey
	bpl adr0

	.endpg

	jmp MOVE

	.endl

// -------------------- X and 3 <> 0 ------------------------

ne0	.local
	tax
	lda tHShift,x
	sta tShfL1+2
	sta tShfL2+2

	lda tLShift,x
	sta tShfH1+2
	sta tShfH2+2

	mva tOraLeft,x	_ORA1+1
	mva tOraRight,x	_ORA0+1

	lda zp+@zp.hlp2
	sta adr0+1
	adc #16
	sta adr1+1

	lda zp+@zp.hlp2+1
	sta adr0+2
	sta adr1+2

	lda >shpBuf
	sta ofs8+2
	sta ofs9+2
	sta ofs10+2

	ldy #15

	.pages

adr1	ldx $ffff,y
tShfH1	lda $ff00,x
_ORA0	ora #$00
	sta shpBuf+height*2+8,y

tShfL1	lda $ff00,x
adr0	ldx $ffff,y
tShfH2	ora $ff00,x
	sta shpBuf+height+8,y

tShfL2	lda $ff00,x
_ORA1	ora #$00
	sta shpBuf+0+8,y

	dey
	bpl adr1

	.endpg

	jmp MOVE

	.endl

.endl
