
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
	jmp @movaBX_EAX
.endp


;---------------------------------------------------------------------------


.proc	@SHORTINT.DIV

A	= :EAX
B	= :ECX

	lda A
	eor B
	php

	lda A				; dividend sign
	bpl @+
	
	eor #$ff
	sec
	adc #$00
	sta A
@
	lda B				; divisor sign
	bpl @+

	eor #$ff
	sec
	adc #$00
	sta B
@
	jsr @BYTE.DIV

	plp
	bpl @+

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

	lda A				; dividend sign
	php
	bpl @+
	
	eor #$ff
	sec
	adc #$00
	sta A
@
	lda B				; divisor sign
	bpl @+

	eor #$ff
	sec
	adc #$00
	sta B
@
	jsr @BYTE.DIV

	plp
	bpl @+

	lda #$00
	sub :ZTMP
	sta :ZTMP
@
	rts
.endp
