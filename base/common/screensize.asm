
; in:	X:A	horizontal resolution
;	Y	vertical resolution

.proc	@SCREENSIZE

	sta MAIN.SYSTEM.ScreenWidth
	stx MAIN.SYSTEM.ScreenWidth+1

	sub #1
	sta MAIN.GRAPH.WIN_RIGHT
	txa
	sbc #0
	sta MAIN.GRAPH.WIN_RIGHT+1

	sty MAIN.SYSTEM.ScreenHeight
	lda #0
	sta MAIN.SYSTEM.ScreenHeight+1

	sta MAIN.GRAPH.WIN_LEFT
	sta MAIN.GRAPH.WIN_LEFT+1
	sta MAIN.GRAPH.WIN_TOP
	sta MAIN.GRAPH.WIN_TOP+1

	sta MAIN.GRAPH.WIN_BOTTOM+1	
	dey
	sty MAIN.GRAPH.WIN_BOTTOM

	rts
.endp
