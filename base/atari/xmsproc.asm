
; LIBRARY
; by Tebe

.proc	@xmsProc

	lda portb
	pha
	and #$01
	ora MAIN.SYSTEM.__PORTB_BANKS-1,y
	sta portb

	jsr ini: $ffff
	jsr prc: $ffff

	pla
	sta portb

	rts
.endp
