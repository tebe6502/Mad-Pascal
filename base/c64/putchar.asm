
/*

  PUT CHAR

*/

.proc	@putchar (.byte a) .reg

bsout    = $ffd2                ;kernel character output sub

	jmp bsout
.endp
