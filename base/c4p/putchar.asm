
/*

  PUT CHAR

*/

.proc	@putchar (.byte a) .reg

chrout	= $ffd2                ;kernel character output sub

	cmp #64
	scc
	eor #%00100000

	jmp chrout

.endp
