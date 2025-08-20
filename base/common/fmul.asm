
.proc	fmulinit

	ldx #$00
	txa
	.byte $c9	; CMP #immediate - skip TYA and clear carry flag
lb1:	tya
	adc #$00
ml1:	sta square1_hi,x
	tay
	cmp #$40
	txa
	ror @
ml9:	adc #$00
	sta ml9+1
	inx
ml0:	sta square1_lo,x
	bne lb1
	inc ml0+2
	inc ml1+2
	clc
	iny
	bne lb1

	ldx #$00
	ldy #$ff
lp	lda square1_hi+1,x
	sta square2_hi+$100,x
	lda square1_hi,x
	sta square2_hi,y
	lda square1_lo+1,x
	sta square2_lo+$100,x
	lda square1_lo,x
	sta square2_lo,y
	dey
	inx
	bne lp

	rts

.endp