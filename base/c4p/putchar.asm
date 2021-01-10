
/*

  PUT CHAR

*/

.proc	@putchar (.byte a) .reg

chrout	= $ffd2                ;kernel character output sub

	jsr chrout

	lda #$00
	sta $d4
	rts
.endp
