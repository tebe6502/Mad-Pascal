
/*
	@printCHAR
	@printEOL
	@print
	@printPCHAR
*/

.proc	@printCHAR
	ldy :STACKORIGIN,x
	jmp @print
.endp


.proc	@printEOL
	ldy #eol
	jmp @print
.endp


.proc	@print (.byte y) .reg
	txa:pha

	tya
	jsr @putchar

	pla:tax
	rts
.endp


.proc	@printPCHAR (.word ya) .reg

	cpy #0
	beq empty

	sta ztmp
	sty ztmp+1

	stx @sp

	lda #0
	sta loop+1

loop	ldy #0
	lda (ztmp),y
	beq stop

	inc loop+1
	sne
	inc ztmp+1

	jsr @putchar

	jmp loop

stop	ldx #0
@sp	equ *-1

empty	rts
.endp
