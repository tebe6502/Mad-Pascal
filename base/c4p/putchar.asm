
/*

  PUT CHAR

*/

; https://github.com/tebe6502/Mad-Pascal/issues/280 

.proc	@putchar (.byte a) .reg

chrout	= $ffd2                ;kernel character output sub

	cmp #64+1
	scc
	eor #%00100000

	jmp chrout

.endp
