
.proc	@putpixel

	ldy #$00

	lda (:bp2),y
msk	and #$00
	sta (:bp2),y

	rts

color	:8 brk

	.align

ladr	:256 dta l([#%200/8]*320+#%8)
hadr	:256 dta h([#%200/8]*320+#%8)

.endp
