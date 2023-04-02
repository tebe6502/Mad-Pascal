
; @move -> memmove.asm

/*
	@moveSTRING
	@moveSTRING_1
	@buf2str
*/

.proc	@moveSTRING (.word @move.dst .word @move.cnt) .var

.nowarn	@move

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


.proc	@buf2str (.word ya) .reg

	sta @move.dst
	sty @move.dst+1
	
	ldy #$00
	lda @buf,y
	sta (@move.dst),y
	
	inw @move.dst
	
lp	cpy @buf
	beq skp

	lda @buf+1,y
	sta (@move.dst),y
	iny
	jmp lp
	
skp	rts
.endp