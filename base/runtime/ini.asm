
.proc	@iniEAX_ECX_WORD

	mva :STACKORIGIN,x :ecx
	mva :STACKORIGIN+STACKWIDTH,x :ecx+1

	mva :STACKORIGIN-1,x :eax
	mva :STACKORIGIN-1+STACKWIDTH,x :eax+1

	mva #$00 :ecx+2
	sta :ecx+3

	sta :eax+2
	sta :eax+3

	rts
.endp


.proc	@iniEAX_ECX_CARD
	mva :STACKORIGIN,x :ecx
	mva :STACKORIGIN+STACKWIDTH,x :ecx+1
	mva :STACKORIGIN+STACKWIDTH*2,x :ecx+2
	mva :STACKORIGIN+STACKWIDTH*3,x :ecx+3

	mva :STACKORIGIN-1,x :eax
	mva :STACKORIGIN-1+STACKWIDTH,x :eax+1
	mva :STACKORIGIN-1+STACKWIDTH*2,x :eax+2
	mva :STACKORIGIN-1+STACKWIDTH*3,x :eax+3

	rts
.endp
