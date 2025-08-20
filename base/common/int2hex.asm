
; IntToHex

.proc	@hexStr

Value	= edx
Digits	= ecx

	txa:pha
	
	ldx Digits
	lda #'0'
	sta:rne @buf,x-

	ldx Digits
	cpx #32
	scc
	ldx #32

	stx Digits

	lda Value
	jsr hex
	lda Value+1
	jsr hex
	lda Value+2
	jsr hex
	lda Value+3
	jsr hex

	lda Digits
	sta @buf

	pla:tax
	rts

hex	pha
	and #$f
	jsr put
	pla
	:4 lsr @
put	tay
	lda thex,y
	sta @buf,x
	dex
	rts

thex	dta c'0123456789ABCDEF'
.endp
