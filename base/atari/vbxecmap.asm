
; VBXE color map

.proc	@vbxe_cmap

	lda rowcrs
	pha
	:4 lsr @
	add #$80+MAIN.SYSTEM.VBXE_MAPADR/$1000
	fxsa FX_MEMS

	pla
	and #$0f
	add >MAIN.SYSTEM.VBXE_WINDOW
	sta :bp+1

	lda colcrs
	asl @
	asl @
	tay

	mva colpf0s (:bp),y
	iny
	mva colpf1s (:bp),y
	iny
	mva colpf2s (:bp),y
	iny
	lda config: #%00010000		; playfield #0 ; overlay palette #1
	sta (:bp),y

	fxs FX_MEMS #$00

	rts
.endp

