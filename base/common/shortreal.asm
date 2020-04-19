; SHORTREAL	fixed-point Q8.8, 16bit
; https://en.wikipedia.org/wiki/Q_(number_format)

/*
	mulSHORTREAL
	divSHORTREAL
*/


.proc	mulSHORTREAL

	jsr imulWORD

	mva #0 eax+3
	mva eax+1 eax
	mva eax+2 eax+1

	ldy eax+3

	lda :STACKORIGIN-1+STACKWIDTH,x	; t1
	bpl @+
	sec
	lda eax+1
	sbc :STACKORIGIN,x
	sta eax+1
	tya
	sbc :STACKORIGIN+STACKWIDTH,x
	tay
@
	lda :STACKORIGIN+STACKWIDTH,x	; t2
	bpl @+
	sec
	lda eax+1
	sbc :STACKORIGIN-1,x
	sta eax+1
	tya
	sbc :STACKORIGIN-1+STACKWIDTH,x
	tay
@
	sty eax+2

	jmp movaBX_EAX
.endp



.proc	divSHORTREAL
	jsr iniEAX_ECX_WORD

	mva eax+1 eax+2
	mva eax eax+1
	lda #0
	sta eax
	sta eax+3
	sta ecx+3

	jmp idivEAX_ECX.main
.endp
