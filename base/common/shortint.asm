
/*
	mulSHORTINT

	@SHORTINT.DIV
	@SHORTINT.MOD
*/


.proc	mulSHORTINT

	jsr imulBYTE

	lda :STACKORIGIN-1,x
	bpl @+
		sec
		lda eax+1
		sbc :STACKORIGIN,x
		sta eax+1
@
	lda :STACKORIGIN,x
	bpl @+
		sec
		lda eax+1
		sbc :STACKORIGIN-1,x
		sta eax+1
@
	jmp movaBX_EAX
.endp



/*

.proc	divmulSHORTINT

MOD	mva #{jsr} _mod

	lda :STACKORIGIN,x		; divisor sign
	spl
	jsr negBYTE

DIV	ldy <idivBYTE
	lda >idivBYTE

skp	sty addr
	sta addr+1

	ldy #0

	lda :STACKORIGIN-1,x		; dividend sign
	bpl @+
	jsr negBYTE1
	iny

@	lda :STACKORIGIN,x		; divisor sign
	bpl @+
	jsr negBYTE
	iny

@	tya
	and #1
	pha

	jsr $ffff			; idiv ecx
addr	equ *-2

	jsr movaBX_EAX

_mod	bit movZTMP_aBX			; mod
	mva #{bit} _mod

	pla
	seq
	jmp negCARD1

	rts
.endp

*/


;---------------------------------------------------------------------------


.proc	@SHORTINT.DIV

A	= :EAX
B	= :ECX

	ldy #0

	lda A				; dividend sign
	bpl @+
	
	eor #$ff
	sec
	adc #$00
	sta A

	iny
@
	lda B				; divisor sign
	bpl @+

	eor #$ff
	sec
	adc #$00
	sta B

	iny
@
	tya
	and #1
	pha

	jsr @BYTE.DIV

	pla
	beq @+

	lda #$00
	sub :eax
	sta :eax
@
	rts
.endp


;---------------------------------------------------------------------------


.proc	@SHORTINT.MOD

A	= :EAX
B	= :ECX

RESULT	= :ZTMP

	ldy #0

	lda A				; dividend sign
	bpl @+
	
	eor #$ff
	sec
	adc #$00
	sta A

	iny
@
	lda B				; divisor sign
	bpl @+

	eor #$ff
	sec
	adc #$00
	sta B
@
	tya
	pha

	jsr @BYTE.DIV

	pla
	beq @+

	lda #$00
	sub :ZTMP
	sta :ZTMP
@
	rts
.endp
