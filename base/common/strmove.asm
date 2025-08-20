
; @move -> memmove.asm

/*
	@movePCHAR
	@moveSTRING
	@moveSTRING_P
	@buf2str
*/

.proc	@movePCHAR (.word @move.dst .byte @move.cnt) .var

	ldy #$00

lp	lda (@move.src),y
	beq skp

	iny

	sta (@move.dst),y
	
	cpy @move.cnt
	bne lp
skp	
	tya
	ldy #$00
	sta (@move.dst),y

	rts
.endp


.proc	@moveSTRING (.word @move.dst .byte len) .var

	ldy #$00
	sty @move.cnt+1
	lda (@move.src),y	; string[0]

	cmp len: #$00		; maximum availible destination string length
	bcc ok
	beq ok

	lda len

ok	sta (@move.dst),y

	sta @move.cnt

	inw @move.src
	inw @move.dst

	jmp @move
.endp


.proc	@moveSTRING_P (.word ya) .reg

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