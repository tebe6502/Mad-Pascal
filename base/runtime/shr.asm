
/*
	@sshrAL_CL
	@shrAX_CL
	@shrEAX_CL
*/

.proc	@shrAL_CL

	ldy :STACKORIGIN,x	; cl
	beq stop
@	lsr :STACKORIGIN-1,x
	dey
	bne @-

stop	lda #0
	sta :STACKORIGIN-1+STACKWIDTH,x
	sta :STACKORIGIN-1+STACKWIDTH*2,x
	sta :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp


.proc	@shrAX_CL

	ldy :STACKORIGIN,x	; cl
	beq stop

	lda :STACKORIGIN-1,x

@	lsr :STACKORIGIN-1+STACKWIDTH,x
	ror @
	dey
	bne @-

	sta :STACKORIGIN-1,x

stop	lda #0
	sta :STACKORIGIN-1+STACKWIDTH*2,x
	sta :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp


.proc	@shrEAX_CL

	ldy :STACKORIGIN,x	; cl
	beq stop

	lda :STACKORIGIN-1,x

@	lsr :STACKORIGIN-1+STACKWIDTH*3,x
	ror :STACKORIGIN-1+STACKWIDTH*2,x
	ror :STACKORIGIN-1+STACKWIDTH,x
	ror @
	dey
	bne @-

	sta :STACKORIGIN-1,x

stop	rts
.endp
