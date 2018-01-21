
/*
	mulINTEGER
	divmulINT
*/

.proc	mulINTEGER

	jsr imulCARD

	jmp movaBX_EAX
.endp


.proc	divmulINT

REAL	ldy <divREAL
	lda >divREAL
	bne skp

MOD	mva #{jsr} _mod

	lda STACKORIGIN+STACKWIDTH*3,x		; divisor sign
	spl
	jsr negCARD

DIV	ldy <idivEAX_ECX.CARD
	lda >idivEAX_ECX.CARD

skp	sty addr
	sta addr+1

	ldy #0

	lda STACKORIGIN-1+STACKWIDTH*3,x	; dividend sign
	bpl @+
	jsr negCARD1
	iny

@	lda STACKORIGIN+STACKWIDTH*3,x		; divisor sign
	bpl @+
	jsr negCARD
	iny

@	tya
	and #1
	pha

	jsr $ffff				; idiv ecx
addr	equ *-2
	jsr movaBX_EAX

_mod	bit movZTMP_aBX				; mod
	mva #{bit} _mod

	pla
	seq
	jmp negCARD1

	rts
.endp
