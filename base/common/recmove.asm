
; Record move

/*
	@moveRECORD
*/

.proc	@moveRECORD (.word ya) .reg

	sta :bp2
	sty :bp2+1

	ldy #1
lop	lda @buf-1,y
	cmp #eol
	beq exit

	sta (:bp2),y

	iny
	bne lop

exit	dey
	tya
	ldy #0
	sta (:bp2),y

	rts
.endp
