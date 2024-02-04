.proc	@GetKey

		@WriteCharacterInline		; control X (reverse at cursor)
		.byte 	24
_KRCWait:		
		@SendMessage 				; send command 2,1 read keyboard
		.byte 	2,1
		@WaitMessage
		lda 	DParameters 				; read result
		beq 	_KRCWait 					; no key, yet.
		@WriteCharacterInline		; control X (reverse at cursor)
		.byte 	24
		rts

.endp
