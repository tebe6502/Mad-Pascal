.proc @GetLine

		ldy #0								; Index into the buffer

_KRLLoop:
		@getkey
		cmp #$0D							; Check for <CR>
		bne _KRLCheckBS
		sty @buffer							; Enter pressed -> save string length
		@putchar							; Output line break
		rts

_KRLCheckBS:
		cmp #$08							; Check for <BS>
		bne _KRLChar
		cpy #0 								; Backspace pressed, check length
		beq _KRLLoop						; Length is 0, ignore backspace
		dey
		lda #$08							; Output backspace
		@putchar
		bra _KRLLoop

_KRLChar:
		cmp #$20							; Check if char is printable
		bcc _KRLLoop
		cmp #$7F
		bcs _KRLLoop
		cpy #$FF							; Check if there is space left
		beq _KRLLoop
		sta @buf+1, Y						; Save character into buffer
		@putchar							; Output character
		iny									; Increment buffer index
		bra _KRLLoop

.endp
