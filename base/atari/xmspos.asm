
; unit MISC: DetectMem
; by Tebe

.proc	@xmsAddPosition

	.use @xmsReadBuf

	add ptr3
	sta ptr3
	lda #$00
	adc ptr3+1
	sta ptr3+1
	lda #$00
	adc ptr3+2
	sta ptr3+2
	lda #$00
	adc ptr3+3
	sta ptr3+3

	rts
.endp


.proc	@xmsUpdatePosition

	.use @xmsReadBuf

	tya
	jsr @xmsAddPosition

	ldy #0
	lda ptr3
	sta (pos),y
	iny
	lda ptr3+1
	sta (pos),y
	iny
	lda ptr3+2
	sta (pos),y
	iny
	lda ptr3+3
	sta (pos),y

	pla:tax
	rts
.endp
