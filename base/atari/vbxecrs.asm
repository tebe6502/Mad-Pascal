; @VBXE_Cursor

.proc	@vbxe_Cursor

on		.local				; turn on the cursor
; but ONLY if the cursor isn't already on
		lda	crsinh
		bne	_rts

		bit	cursor_flg
		bpl	cursor_toggle
_rts		rts
		.endl

off		.local				; turn off the cursor
; but ONLY if the cursor isn't already off
		lda	crsinh
		bne	_rts

		bit	cursor_flg
		bmi	cursor_toggle
_rts		rts
		.endl

cursor_toggle					; inverts the color of the current character to show the cursor
		ldy	#1
		lda	(savadr),y
		eor	#$f7			; invert the color, but not bit 7 (transparency bit) or bit 3 (foreground intensity)
		sta	(savadr),y	

		lda	cursor_flg: #$00	; bit 7 indicates whether or not the cursor is currently visible
						; that is, if it's a 1, then the color of the current character
						; has been inverted to show the cursor.
						
		eor	#$80			; flip the cursor flag
		sta	cursor_flg
		rts		
.endp