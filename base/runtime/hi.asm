
.proc	hiBYTE
	lda :STACKORIGIN,x
	:4 lsr @
	sta :STACKORIGIN,x
	rts
.endp


.proc	hiWORD
	lda :STACKORIGIN+STACKWIDTH,x
	sta :STACKORIGIN,x
	rts
.endp


.proc	hiCARD
	lda :STACKORIGIN+STACKWIDTH*3,x
	sta :STACKORIGIN+STACKWIDTH,x

	lda :STACKORIGIN+STACKWIDTH*2,x
	sta :STACKORIGIN,x
	rts
.endp
