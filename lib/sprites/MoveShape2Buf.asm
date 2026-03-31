
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

ofs4	ldx shpBuf+32,y
src1	lda $ffff,y
	and tMask,x
	ora tByte,x
dst1	sta $ffff,y

ofs8	ldx shpBuf+64,y
src2	lda $ffff,y
	and tMask,x
	ora tByte,x
dst2	sta $ffff,y

ofs12	ldx shpBuf+96,y
src3	lda $ffff,y
	and tMask,x
	ora tByte,x
dst3	sta $ffff,y


ofs1	ldx shpBuf+8,y		; row 1
src4	lda $ffff,y
	and tMask,x
	ora tByte,x
dst4	sta $ffff,y

ofs5	ldx shpBuf+8+32,y
src5	lda $ffff,y
	and tMask,x
	ora tByte,x
dst5	sta $ffff,y

ofs9	ldx shpBuf+8+64,y
src6	lda $ffff,y
	and tMask,x
	ora tByte,x
dst6	sta $ffff,y

ofs13	ldx shpBuf+8+96,y
src7	lda $ffff,y
	and tMask,x
	ora tByte,x
dst7	sta $ffff,y


ofs2	ldx shpBuf+16,y		; row 2
src8	lda $ffff,y
	and tMask,x
	ora tByte,x
dst8	sta $ffff,y

ofs6	ldx shpBuf+16+32,y
src9	lda $ffff,y
	and tMask,x
	ora tByte,x
dst9	sta $ffff,y

ofs10	ldx shpBuf+16+64,y
src10	lda $ffff,y
	and tMask,x
	ora tByte,x
dst10	sta $ffff,y

ofs14	ldx shpBuf+16+96,y
src11	lda $ffff,y
	and tMask,x
	ora tByte,x
dst11	sta $ffff,y


ofs3	ldx shpBuf+24,y		; row 3
src12	lda $ffff,y
	and tMask,x
	ora tByte,x
dst12	sta $ffff,y

ofs7	ldx shpBuf+24+32,y
src13	lda $ffff,y
	and tMask,x
	ora tByte,x
dst13	sta $ffff,y

ofs11	ldx shpBuf+24+64,y
src14	lda $ffff,y
	and tMask,x
	ora tByte,x
dst14	sta $ffff,y

ofs15	ldx shpBuf+24+96,y
src15	lda $ffff,y
	and tMask,x
	ora tByte,x
dst15	sta $ffff,y

ofs20
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

bit0	sta ofs0+1
	adc #8
bit1	sta ofs1+1
	adc #8
bit2	sta ofs2+1
	adc #8
bit3	sta ofs3+1
	adc #8
	sta ofs4+1
	adc #8
	sta ofs5+1
	adc #8
	sta ofs6+1
	adc #8
	sta ofs7+1
	adc #8
	sta ofs8+1
	adc #8
	sta ofs9+1
	adc #8
	sta ofs10+1
	adc #8
	sta ofs11+1
	adc #8
	sta ofs12+1
	adc #8
	sta ofs13+1
	adc #8
	sta ofs14+1
	adc #8
	sta ofs15+1

// ---------------------- Offset X --------------------------

	lda Sprite0+@Spr.xOk,x
	and #3
	bne ne0

// --------------------- X and 3 = 0 ------------------------

eq0	.local

	lda #$ff
	:21 sta shpBuf+96+8+#

	lda zp+@zp.hlp2
	sta adr0+1
	adc #21
	sta adr1+1
	adc #21
	sta adr2+1

	lda zp+@zp.hlp2+1
	sta adr0+2
	sta adr1+2
	sta adr2+2

	ldy #20

	.pages
	
adr0	lda $ffff,y
	sta shpBuf+8,y

adr1	lda $ffff,y
	sta shpBuf+32+8,y

adr2	lda $ffff,y
	sta shpBuf+64+8,y

	dey
	bpl adr0

	.endpg

	jmp MOVE

	.endl

// -------------------- X and 3 <> 0 ------------------------

ne0	.local
	tax
	lda tHShift,x
	sta tShfL0+2
	sta tShfL1+2
	sta tShfL2+2

	lda tLShift,x
	sta tShfH0+2
	sta tShfH1+2
	sta tShfH2+2

	mva tOraLeft,x	_ORA1+1
	mva tOraRight,x	_ORA0+1

	lda zp+@zp.hlp2
	sta adr0+1
	adc #21
	sta adr1+1
	adc #21
	sta adr2+1

	lda zp+@zp.hlp2+1
	sta adr0+2
	sta adr1+2
	sta adr2+2

	ldy #20

	.pages

adr2	ldx $ffff,y

tShfH0	lda $ff00,x
_ORA0	ora #$00
	sta shpBuf+96+8,y

tShfL0	lda $ff00,x

adr1	ldx $ffff,y

tShfH1	ora $ff00,x
	sta shpBuf+64+8,y

tShfL1	lda $ff00,x

adr0	ldx $ffff,y

tShfH2	ora $ff00,x
	sta shpBuf+32+8,y

tShfL2	lda $ff00,x
_ORA1	ora #$00
	sta shpBuf+0+8,y

	dey
	bpl adr2

	.endpg

	jmp MOVE
	.endl

.endl

