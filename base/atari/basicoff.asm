// BASIC OFF
// author: Michael Jaskula

	lda PORTB
	ora #$02
	sta PORTB
	
	lda #$70		; disable BREAK
	sta $10
	sta $D20E

	lda #$C0
	sta $6A
	sta $2E4

	lda #$01
	sta $03F8

	rts
