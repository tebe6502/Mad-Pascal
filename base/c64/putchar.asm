
/*

  PUT CHAR

*/

.proc	@putchar (.byte a) .reg

chrout	= $ffd2                ;kernel character output sub

	cmp #64
	scc
	eor #%00100000

	jsr chrout

;	lda #$00
;	sta $d4
	rts
.endp
