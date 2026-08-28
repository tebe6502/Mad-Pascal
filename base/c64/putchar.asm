
/*

  PUT CHAR

  https://sta.c64.org/cbm64pet.html
  
  For letters (codes 64-90 and 97-122), the code exchanges A-Z <-> a-z
  (to convert ASCII -> PETSCII). It is required since Mad Pascal's source code
  encoding is ASCII, and such strings must be converted to use with C64 Kernal
  subroutines.
  (Other way could be doing it on compiler level - write strings in proper
  encoding in compiled code).

*/

; https://github.com/tebe6502/Mad-Pascal/issues/280

.proc   @putchar (.byte a) .reg

chrout  = $ffd2		;kernel character output sub

	cmp #64+1
	bcc putcharend	; below 'A'
	cmp #122+1
	bcs putcharend	; above 'z'
	cmp #91
	bcc putchareor	; 'A'..'Z'
	cmp #96
	bcc putcharend	; between 'Z' and 'a'
putchareor
	eor #%00100000
putcharend
        jmp chrout
.endp
