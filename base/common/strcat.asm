
; add strings
; result -> @buf

.proc	@addString(.word ya) .reg

	sta ztmp
	sty ztmp+1

	stx @sp

	ldx @buf
	inx
	beq stop

	ldy #0
	lda (ztmp),y
	sta ile
	beq stop

	iny

load	lda (ztmp),y
	sta @buf,x

	iny
	inx
	beq stop
	dec ile
	bne load

stop	dex
	stx @buf

	ldx #0
@sp	equ *-1
	rts

ile	brk
.endp
