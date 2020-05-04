
.proc	notaBX

	.rept MAXSIZE
	lda :STACKORIGIN+#*STACKWIDTH,x
	eor #$ff
	sta :STACKORIGIN+#*STACKWIDTH,x
	.endr

	rts
.endp


.proc	notBOOLEAN
	lda :STACKORIGIN,x
	eor #true
	sta :STACKORIGIN,x

	rts
.endp
