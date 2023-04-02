
.proc	orAL_CL

	lda :STACKORIGIN-1,x
	ora :STACKORIGIN,x
	sta :STACKORIGIN-1,x

	rts
.endp


.proc	orAX_CX

	.rept 2
	lda :STACKORIGIN-1+#*STACKWIDTH,x
	ora :STACKORIGIN+#*STACKWIDTH,x
	sta :STACKORIGIN-1+#*STACKWIDTH,x
	.endr

	rts
.endp


.proc	orEAX_ECX

	.rept MAXSIZE
	lda :STACKORIGIN-1+#*STACKWIDTH,x
	ora :STACKORIGIN+#*STACKWIDTH,x
	sta :STACKORIGIN-1+#*STACKWIDTH,x
	.endr

	rts
.endp
