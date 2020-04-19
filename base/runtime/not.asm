
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
	bne _0

	lda #true
	sne

_0	lda #false
	sta :STACKORIGIN,x

	rts
.endp
