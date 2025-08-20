
// AX (16bit) * 320 = EAX
// (a shl 8) shr 2 + (a shl 8)

.proc   @mul320

	lda :eax
	sta :ecx

	ldy :eax+1
	sty :ecx+1
	sty :eax+2

	ldy #$00
	sty :eax

	lsr :eax+2
	ror @
	ror :eax
	lsr :eax+2
	ror @
	ror :eax

	add :ecx
	sta :eax+1
	lda :eax+2
	adc :ecx+1
	sta :eax+2
	lda #$00
	adc #$00
	sta :eax+3

        rts
.endp
