// BASIC OFF
// author: Michael Jaskula

	lda PORTB
	ora #$02
	sta PORTB

	lda #$C0
	sta $6a
	sta $2e4

	lda #$01
	sta $03F8

	rts
