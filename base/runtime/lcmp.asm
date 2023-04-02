
; long unsigned compare

.proc	cmpEAX_ECX
	lda :STACKORIGIN-1+STACKWIDTH*3,x
	cmp :STACKORIGIN+STACKWIDTH*3,x
	bne _done
	lda :STACKORIGIN-1+STACKWIDTH*2,x
	cmp :STACKORIGIN+STACKWIDTH*2,x
	bne _done
AX_CX
	lda :STACKORIGIN-1+STACKWIDTH,x
	cmp :STACKORIGIN+STACKWIDTH,x
	bne _done
	lda :STACKORIGIN-1,x
	cmp :STACKORIGIN,x

_done	rts
.endp
