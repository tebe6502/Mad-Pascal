
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
	jmp @movaBX_EAX
.endp


;---------------------------------------------------------------------------


.proc	@SMALLINT.DIV

A	= :EAX
B	= :ECX

	lda A+1
	eor B+1
	php

	lda A+1				; dividend sign
	bpl @+

	jsr @negAX

;	lda #$00
;	sub A
;	sta A
;
;	lda #$00
;	sbc A+1
;	sta A+1
@
	lda B+1				; divisor sign
	bpl @+

	jsr @negCX

;	lda #$00
;	sub B
;	sta B
;
;	lda #$00
;	sbc B+1
;	sta B+1
@
	jsr @WORD.DIV

	plp
	spl
	jmp @negAX

	rts
.endp


;---------------------------------------------------------------------------


.proc	@SMALLINT.MOD

A	= :EAX
B	= :ECX

RESULT	= :ZTMP

	lda A+1				; dividend sign
	php
	bpl @+

	jsr @negAX

;	lda #$00
;	sub A
;	sta A
;
;	lda #$00
;	sbc A+1
;	sta A+1
@
	lda B+1				; divisor sign
	bpl @+

	jsr @negCX

;	lda #$00
;	sub B
;	sta B
;
;	lda #$00
;	sbc B+1
;	sta B+1
@
	jsr @WORD.DIV

	plp
	bpl @+

	lda #$00
	sub RESULT
	sta RESULT

	lda #$00
	sbc RESULT+1
	sta RESULT+1
@
	rts
.endp
