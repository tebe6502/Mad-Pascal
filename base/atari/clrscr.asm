
.proc	@ClrScr

	mva #$2c @putchar.vbxe	; bit*

	ldx @putchar.chn

	lda #$0c
	jsr xcio

	mwa #ename icbufa,x

	mva #$0c icax1,x
	mva #$00 icax2,x

	lda #$03

xcio	sta iccmd,x
	jmp ciov

ename	.byte 'E:',$9b

.endp
