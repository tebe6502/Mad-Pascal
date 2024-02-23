
; unit CRT: TextMode

.proc	@ClrScr

	lda #$93	; Clear PETSCII code
	jmp CHROUT

.endp
