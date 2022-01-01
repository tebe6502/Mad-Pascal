
/*
	andAL_CL
	andAX_CX
	andEAX_ECX
*/


.proc	andAL_CL

	lda :STACKORIGIN-1,x
	and :STACKORIGIN,x
	sta :STACKORIGIN-1,x

	rts
.endp


.proc	andAX_CX

	.rept 2
	lda :STACKORIGIN-1+#*STACKWIDTH,x
	and :STACKORIGIN+#*STACKWIDTH,x
	sta :STACKORIGIN-1+#*STACKWIDTH,x
	.endr

	rts
.endp


.proc	andEAX_ECX

	.rept MAXSIZE
	lda :STACKORIGIN-1+#*STACKWIDTH,x
	and :STACKORIGIN+#*STACKWIDTH,x
	sta :STACKORIGIN-1+#*STACKWIDTH,x
	.endr

	rts
.endp
