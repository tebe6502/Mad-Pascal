
; print BOOLEAN

.proc	@printBOOLEAN
	lda :STACKORIGIN,x
	beq _0

_1	lda <_true
	ldy >_true
	jmp @printSTRING

_0	lda <_false
	ldy >_false
	jmp @printSTRING

_true	dta 4,c'TRUE'
_false	dta 5,c'FALSE'
.endp
