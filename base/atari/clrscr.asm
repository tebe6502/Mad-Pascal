
; unit CRT: TextMode
; unit VBXE: VBXEOff

.proc	@ClrScr

	mva #{bit*} @putchar.vbxe	; disable VBXE put char

	ldx #0
	lda #$0c
	jsr xcio

	mwa #ename icbufa,x

	mva #$0c icax1,x
	mva #$00 icax2,x

	lda #$03

xcio	sta iccmd,x

	m@call	ciov

	rts

ename	.byte 'E:',$9b

.endp
