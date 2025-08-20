
; print STRING
; [0]: length
; [1..255] text

.proc	@printSTRING (.word ya) .reg

	cpy #0
	beq empty

	sta ztmp
	sty ztmp+1

	stx @sp

	ldy #0
	sty loop+1
	lda (ztmp),y
	sta ln

	inw ztmp

loop	ldy #0
	lda (ztmp),y
;	beq stop

	cpy #0
ln	equ *-1
	beq stop

	inc loop+1

	m@call	@putchar

	jmp loop

stop	ldx #0
@sp	equ *-1

empty	rts
.endp
