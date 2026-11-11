.proc @GetLine

		ldy #0

_KRLLoop:
		@getkey
		cmp #$0D							; Check for <CR>
		bne _KRLCheckBS
		sty @buf
		@putchar
		rts

_KRLCheckBS:
		cmp #$08							; Check for <BS>
		bne _KRLChar
		cpy #0 								; Backspace pressed, check length
		beq _KRLLoop
		dey
		lda #$08
		@putchar
		bra _KRLLoop

_KRLChar:
		cmp #$20
		bcc _KRLLoop
		cmp #$7F
		bcs _KRLLoop
		sta @buf+1, Y
		@putchar
		iny
		bra _KRLLoop

.endp
