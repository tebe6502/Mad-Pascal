
/*
	addAL_CL
	addAX_CX
	addEAX_ECX
*/


; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; wynik operacji ADD zostanie potraktowany jako INTEGER / CARDINAL
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

.proc	addAL_CL

	ldy #0

	sty :STACKORIGIN-1+STACKWIDTH*2,x
	sty :STACKORIGIN-1+STACKWIDTH*3,x

	lda :STACKORIGIN-1,x
	add :STACKORIGIN,x
	sta :STACKORIGIN-1,x
	scc
	iny

	sty :STACKORIGIN-1+STACKWIDTH,x

	rts
.endp


.proc	addAX_CX

	ldy #0

	sty :STACKORIGIN-1+STACKWIDTH*3,x

	lda :STACKORIGIN-1,x
	add :STACKORIGIN,x
	sta :STACKORIGIN-1,x

	lda :STACKORIGIN-1+STACKWIDTH,x
	adc :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN-1+STACKWIDTH,x
	scc
	iny

	sty :STACKORIGIN-1+STACKWIDTH*2,x

	rts
.endp


.proc	addEAX_ECX
/*
SHORT	jsr @expandToCARD.SHORT
	jsr @expandToCARD1.SHORT
	jmp CARD

SMALL	jsr @expandToCARD.SMALL
	jsr @expandToCARD1.SMALL
*/
CARD	lda :STACKORIGIN-1,x
	add :STACKORIGIN,x
	sta :STACKORIGIN-1,x

	lda :STACKORIGIN-1+STACKWIDTH,x
	adc :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN-1+STACKWIDTH,x

	lda :STACKORIGIN-1+STACKWIDTH*2,x
	adc :STACKORIGIN+STACKWIDTH*2,x
	sta :STACKORIGIN-1+STACKWIDTH*2,x

	lda :STACKORIGIN-1+STACKWIDTH*3,x
	adc :STACKORIGIN+STACKWIDTH*3,x
	sta :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp
