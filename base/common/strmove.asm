
; @move -> memmove.asm

/*
	@moveSTRING
	@moveSTRING_1
*/

.proc	@moveSTRING (.word ya) .reg

	sta @move.dst
	sty @move.dst+1

	mva :STACKORIGIN,x @move.src
	mva :STACKORIGIN+STACKWIDTH,x @move.src+1

	ldy #$00
	lda (@move.src),y
	add #1
	sta @move.cnt
	scc
	iny
	sty @move.cnt+1

	jmp @move
.endp


.proc	@moveSTRING_1 (.word ya) .reg

	sta @move.dst
	sty @move.dst+1

	mva :STACKORIGIN,x @move.src
	mva :STACKORIGIN+STACKWIDTH,x @move.src+1

	ldy #$00
	lda (@move.src),y
;	add #1
	sta @move.cnt
	sty @move.cnt+1

	inw @move.src

	jmp @move
.endp
