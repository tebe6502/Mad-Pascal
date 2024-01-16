
/*

  PUT CHAR

  https://sta.c64.org/cbm64pet.html
  
  Codes $00-$1F and $80-$9F are control codes. 
  
*/

.proc	@putchar (.byte a) .reg

chrout	= $ffd2			;kernel character output sub

	tay

	cmp #$20
	bcc @+

	tya
	clc			; clear carry for add
	adc #$FF-$9F		; make m = $FF
	adc #$9F-$80+1		; carry set if in range n to m
	jcc skp
@
	tya
	jmp chrout

skp	tya

	cmp #64
	scc
	eor #%00100000

	jmp chrout
.endp
