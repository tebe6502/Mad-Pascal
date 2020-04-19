
/*
	shlEAX_CL.BYTE
	shlEAX_CL.WORD
	shlEAX_CL.CARD
*/

.proc	shlEAX_CL

;SHORT	jsr @expandToCARD1.SHORT
;	jmp CARD

;SMALL	jsr @expandToCARD1.SMALL
;	jmp CARD

BYTE	lda #0
	sta :STACKORIGIN-1+STACKWIDTH,x

WORD	lda #0
	sta :STACKORIGIN-1+STACKWIDTH*2,x
	sta :STACKORIGIN-1+STACKWIDTH*3,x

CARD	clc
	ldy :STACKORIGIN,x	; cl
	beq stop
@	asl :STACKORIGIN-1,x	; eax
	rol :STACKORIGIN-1+STACKWIDTH,x
	rol :STACKORIGIN-1+STACKWIDTH*2,x
	rol :STACKORIGIN-1+STACKWIDTH*3,x
	dey
	bne @-

stop	rts
.endp
