
; unit CRT: TextMode

.proc	@ClrScr

	lda #PETSCII_CLEAR	; Clear PETSCII code
	jmp CHROUT

.endp
