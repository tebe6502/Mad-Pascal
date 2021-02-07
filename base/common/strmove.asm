
; @move -> memmove.asm

/*
	@moveSTRING
	@moveSTRING_1
*/

.proc	@moveSTRING (.word @move.dst .word @move.cnt) .var

	@move

	dec @move.cnt

	ldy #$00
	lda @move.cnt
	cmp (@move.src),y
	scs
	sta (@move.dst),y

	rts
.endp


.proc	@moveSTRING_1 (.word ya) .reg

	sta @move.dst
	sty @move.dst+1

	ldy #$00
	lda (@move.src),y
;	add #1
	sta @move.cnt
	sty @move.cnt+1

	inw @move.src

	jmp @move
.endp
