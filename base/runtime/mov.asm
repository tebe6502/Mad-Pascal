
.proc	movaBX_EAX		; mov [BX], EAX
	:MAXSIZE mva :eax+# :STACKORIGIN-1+#*STACKWIDTH,x
	rts
.endp


.proc	movZTMP_aBX
	mva :ZTMP8 :STACKORIGIN-1,x
	mva :ZTMP9 :STACKORIGIN-1+STACKWIDTH,x
	mva :ZTMP10 :STACKORIGIN-1+STACKWIDTH*2,x
	mva :ZTMP11 :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp
