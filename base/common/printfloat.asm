
/*
	@printSHORTREAL
	@printREAL
	@float
*/

.proc	@printSHORTREAL
	jsr @expandToCARD.SMALL
	jmp @printREAL
.endp


.proc	@printREAL

	stx @sp

	lda :STACKORIGIN+STACKWIDTH*3,x
	spl
	jsr @printMINUS
	
	sta :dx+2

	mva :STACKORIGIN,x :eax+2	; intpart := uvalue shr 8
	mva :STACKORIGIN+STACKWIDTH,x :dx; :eax := uvalue and $FF (dx)
	mva :STACKORIGIN+STACKWIDTH*2,x :dx+1
;	mva :STACKORIGIN+STACKWIDTH*3,x :dx+2
	mva #$00 :dx+3

	sta :eax
	sta :eax+1

	mva #4 @float.afterpoint	; wymagana liczba miejsc po przecinku
	@float #5000

	ldx #0
@sp	equ *-1
	rts
.endp


.proc	@float (.long axy) .reg

	sty cx
	stx cx+1
	sta cx+2

	lda @printVALUE.pout		; print integer part
	pha
	jsr @printVALUE
	pla
	sta @printVALUE.pout

	lda #0
	sta :dx
	sta :dx+1
	sta :dx+2
	sta :dx+3

loop	lda :eax+2
	bpl skp

	clc
;	lda cx
;	spl
;	sec

	lda :dx
	adc :cx
	sta :dx
	lda :dx+1
	adc :cx+1
	sta :dx+1
	lda :dx+2
	adc :cx+2
	sta :dx+2
;	lda :dx+3
;	adc #0
;	sta :dx+3

skp	lsr :cx+2
	ror :cx+1
	ror :cx

	asl :eax
	rol :eax+1
	rol :eax+2

	lda :cx
	ora :cx+1
	ora :cx+2

	bne loop

	ldy #'.'
	jsr @printVALUE.pout

	:4 mva :dx+# :eax+#

	lda @printVALUE.pout
	pha

	lda #{rts}
	sta @printVALUE.pout
	jsr @printVALUE			; floating part length

	sta cnt

	pla
	sta @printVALUE.pout

lp	lda #0
cnt	equ *-1
	cmp #4				; N miejsc po przecinku
afterpoint equ *-1
	bcs ok

	ldy #'0'
	jsr @printVALUE.pout

	inc cnt
	bne lp

ok	:4 mva :eax+# :dx+#
	jmp @printVALUE			; print floating part

.endp
