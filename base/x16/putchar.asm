
/*

  PUT CHAR

  https://sta.c64.org/cbm64pet.html
  
  Codes $00-$1F and $80-$9F are control codes. 
  
*/

.proc	@putchar (.byte a) .reg
	jmp CHROUT
.endp
