
.proc	xorAL_CL

	lda :STACKORIGIN-1,x
	eor :STACKORIGIN,x
	sta :STACKORIGIN-1,x

	rts
.endp


.proc	xorAX_CX

	.rept 2
	lda :STACKORIGIN-1+#*STACKWIDTH,x
	eor :STACKORIGIN+#*STACKWIDTH,x
	sta :STACKORIGIN-1+#*STACKWIDTH,x
	.endr

	rts
.endp


.proc	xorEAX_ECX

	.rept MAXSIZE
	lda :STACKORIGIN-1+#*STACKWIDTH,x
	eor :STACKORIGIN+#*STACKWIDTH,x
	sta :STACKORIGIN-1+#*STACKWIDTH,x
	.endr

	rts
.endp
