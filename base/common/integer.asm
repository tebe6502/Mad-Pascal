
/*
	mulINTEGER
	divmulINT
*/

.proc	mulINTEGER

	jsr imulCARD

	jmp movaBX_EAX
.endp


/*
.proc	divmulINT

REAL	ldy <divREAL
	lda >divREAL
	bne skp

MOD	mva #{jsr} _mod

	lda :STACKORIGIN+STACKWIDTH*3,x		; divisor sign
	spl
	jsr negCARD

DIV	ldy <idivCARD
	lda >idivCARD

skp	sty addr
	sta addr+1

	ldy #0

	lda :STACKORIGIN-1+STACKWIDTH*3,x	; dividend sign
	bpl @+
	jsr negCARD1
	iny

@	lda :STACKORIGIN+STACKWIDTH*3,x		; divisor sign
	bpl @+
	jsr negCARD
	iny

@	tya
	and #1
	pha

	jsr $ffff				; idiv ecx
addr	equ *-2
	jsr movaBX_EAX

_mod	bit movZTMP_aBX				; mod
	mva #{bit} _mod

	pla
	seq
	jmp negCARD1

	rts
.endp
*/


;---------------------------------------------------------------------------


.proc	@INTEGER.DIV

A	= :EAX
B	= :ECX

	ldy #0

	lda A+3				; dividend sign
	bpl @+
	
	lda #$00
	sub A
	sta A

	lda #$00
	sbc A+1
	sta A+1

	lda #$00
	sbc A+2
	sta A+2

	lda #$00
	sbc A+3
	sta A+3

	iny
@
	lda B+3				; divisor sign
	bpl @+

	lda #$00
	sub B
	sta B

	lda #$00
	sbc B+1
	sta B+1

	lda #$00
	sbc B+2
	sta B+2

	lda #$00
	sbc B+3
	sta B+3

	iny
@
	tya
	and #1
	pha

	jsr @CARDINAL.DIV

	pla
	beq @+

	lda #$00
	sub :eax
	sta :eax

	lda #$00
	sbc :eax+1
	sta :eax+1

	lda #$00
	sbc :eax+2
	sta :eax+2

	lda #$00
	sbc :eax+3
	sta :eax+3
@
	rts
.endp


;---------------------------------------------------------------------------


.proc	@INTEGER.MOD

A	= :EAX
B	= :ECX

RESULT	= :ZTMP

	ldy #0

	lda A+3				; dividend sign
	bpl @+
	
	lda #$00
	sub A
	sta A

	lda #$00
	sbc A+1
	sta A+1

	lda #$00
	sbc A+2
	sta A+2

	lda #$00
	sbc A+3
	sta A+3

	iny
@
	lda B+3				; divisor sign
	bpl @+

	lda #$00
	sub B
	sta B

	lda #$00
	sbc B+1
	sta B+1

	lda #$00
	sbc B+2
	sta B+2

	lda #$00
	sbc B+3
	sta B+3
@
	tya
	pha

	jsr @CARDINAL.DIV

	pla
	beq @+

	lda #$00
	sub :ZTMP
	sta :ZTMP

	lda #$00
	sbc :ZTMP+1
	sta :ZTMP+1

	lda #$00
	sbc :ZTMP+2
	sta :ZTMP+2

	lda #$00
	sbc :ZTMP+3
	sta :ZTMP+3
@
	rts
.endp
