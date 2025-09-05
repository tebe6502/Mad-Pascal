// BASIC OFF
// author: Michael Jaskula
// changes: 2023-03-28

//	lda #$01		; OSS cart disabled
//	sta $d508

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

	ldx #0			; reset E:
	lda #$0c
	jsr xcio

	mwa #ename icbufa,x

	mva #$0c icax1,x
	mva #$00 icax2,x

	lda #$03

xcio	sta iccmd,x

	jmp	ciov

ename	.byte 'E:',$9b
