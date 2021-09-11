
; VBXE put char
; input:
;	A - char

.proc	@vbxe_put (.byte a) .reg

	pha

	cmp #eol
	beq stop

	cmp #$7d		; clrscr
	bne skp

	jsr @vbxe_init.cmapini
	jmp stop

skp	lda rowcrs
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

	fxs FX_MEMS #$00

stop	pla

	rts
.endp
