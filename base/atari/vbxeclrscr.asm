// @VBXE_ClrScr

@FF_adr		.proc				; Form Feed clears the screen and sets cursor to the home position.

		jsr	@vbxe_cursor.off
		lda	#0			; home the cursor
		sta	rowcrs
		sta	colcrs
		sta	colcrs+1
		lda	<MAIN.SYSTEM.VBXE_WINDOW
		sta	savadr
		lda	>MAIN.SYSTEM.VBXE_WINDOW 
		sta	savadr + 1
		jsr	@vbxe_scroll.page	; clear the screen
		jmp	@vbxe_cursor.on

		.endp