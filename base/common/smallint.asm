
/*
	mulSMALLINT
	@SMALLINT_DIV
	@SMALLINT_MOD
*/


.proc	mulSMALLINT

	jsr imulWORD

	lda :STACKORIGIN-1+STACKWIDTH,x	; t1
	bpl @+
		sec
		lda :eax+2
		sbc :STACKORIGIN,x
		sta :eax+2
		lda :eax+3
		sbc :STACKORIGIN+STACKWIDTH,x
		sta :eax+3
@
	lda :STACKORIGIN+STACKWIDTH,x	; t2
	bpl @+
		sec
		lda :eax+2
		sbc :STACKORIGIN-1,x
		sta :eax+2
		lda :eax+3
		sbc :STACKORIGIN-1+STACKWIDTH,x
		sta :eax+3
@
	jmp movaBX_EAX
.endp


;---------------------------------------------------------------------------


.proc	@SMALLINT.DIV

A	= :EAX
B	= :ECX

	ldy #0

	lda A+1				; dividend sign
	bpl @+
	
	lda #$00
	sub A
	sta A

	lda #$00
	sbc A+1
	sta A+1

	iny
@
	lda B+1				; divisor sign
	bpl @+

	lda #$00
	sub B
	sta B

	lda #$00
	sbc B+1
	sta B+1

	iny
@
	tya
	and #1
	pha

	jsr @WORD.DIV

	pla
	beq @+

	lda #$00
	sub :eax
	sta :eax

	lda #$00
	sbc :eax+1
	sta :eax+1
@
	rts
.endp


;---------------------------------------------------------------------------


.proc	@SMALLINT.MOD

A	= :EAX
B	= :ECX

RESULT	= :ZTMP

	ldy #0

	lda A+1				; dividend sign
	bpl @+
	
	lda #$00
	sub A
	sta A

	lda #$00
	sbc A+1
	sta A+1

	iny
@
	lda B+1				; divisor sign
	bpl @+

	lda #$00
	sub B
	sta B

	lda #$00
	sbc B+1
	sta B+1
@
	tya
	pha

	jsr @WORD.DIV

	pla
	beq @+

	lda #$00
	sub :ZTMP
	sta :ZTMP

	lda #$00
	sbc :ZTMP+1
	sta :ZTMP+1
@
	rts
.endp
