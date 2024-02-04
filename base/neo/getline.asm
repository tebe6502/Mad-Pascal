
.proc @GetLine

_KRLLoop:
		@getkey 							; read and echo character
		cmp 	#13 						; exit if CR pressed
		beq 	_KRLExit
		@putchar
		bra 	_KRLLoop
_KRLExit:
		ldy		>@buf
		ldx     <@buf
		stx 	DParameters 				; where the string goes.
		sty 	DParameters+1
		@SendMessage 				; send the 'get line' message.
		.byte 	2,3
		@WaitMessage
		rts				

.endp
