; @VBXE_SetCursor

.proc	@vbxe_setcursor

	jsr @vbxe_Cursor.off

	ldy rowcrs

	lda colcrs
	asl @

	add lmul,y
	sta savadr

	lda #0
	adc hmul,y
	sta savadr+1

	jmp @vbxe_Cursor.on

lmul	:24 dta l(MAIN.SYSTEM.VBXE_WINDOW + #*160)
hmul	:24 dta h(MAIN.SYSTEM.VBXE_WINDOW + #*160)

.endp