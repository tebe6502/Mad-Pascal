
.proc	shrAL_CL

;SHORT	jsr @expandToCARD1.SHORT
;	jmp shrEAX_CL

BYTE	ldy :STACKORIGIN,x	; cl
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


.proc	shrAX_CL

;SMALL	jsr @expandToCARD1.SMALL
;	jmp shrEAX_CL

WORD	ldy :STACKORIGIN,x	; cl
	beq stop
@	lsr :STACKORIGIN-1+STACKWIDTH,x
	ror :STACKORIGIN-1,x
	dey
	bne @-

stop	lda #0
	sta :STACKORIGIN-1+STACKWIDTH*2,x
	sta :STACKORIGIN-1+STACKWIDTH*3,x

	rts
.endp


.proc	shrEAX_CL

	ldy :STACKORIGIN,x	; cl
	beq stop
@	lsr :STACKORIGIN-1+STACKWIDTH*3,x
	ror :STACKORIGIN-1+STACKWIDTH*2,x
	ror :STACKORIGIN-1+STACKWIDTH,x
	ror :STACKORIGIN-1,x
	dey
	bne @-

stop	rts
.endp
