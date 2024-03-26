
/*
	mulINTEGER
	divmulINT
*/

.proc	mulINTEGER

	jsr imulCARD

	jmp movaBX_EAX
.endp


;---------------------------------------------------------------------------


.proc	@INTEGER.DIV

A	= :EAX
B	= :ECX

	lda A+3
	eor B+3
	php	

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
	jsr @CARDINAL.DIV

	plp
	bpl @+

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

RESULT	= :EAX+4

	lda A+3				; dividend sign
	php
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
	jsr @CARDINAL.DIV

	plp
	bpl @+

	lda #$00
	sub RESULT
	sta RESULT

	lda #$00
	sbc RESULT+1
	sta RESULT+1

	lda #$00
	sbc RESULT+2
	sta RESULT+2

	lda #$00
	sbc RESULT+3
	sta RESULT+3
@
	rts
.endp
