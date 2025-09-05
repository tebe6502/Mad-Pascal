
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
	ldy #EOL
	jmp @print
.endp


.proc	@print (.byte y) .reg
	txa:pha

	tya

	m@call	@putchar

	pla:tax
	rts
.endp


.proc	@printPCHAR (.word ya) .reg

	cpy #0
	beq empty

	sta pchar
	sty pchar+1

	stx @sp

	lda #0
	sta loop+1

loop	ldy #0
	lda pchar: $ffff,y
	beq stop

	inc loop+1
	sne
	inc pchar+1

	m@call	@putchar

	jmp loop

stop	ldx #0
@sp	equ *-1

empty	rts
.endp
