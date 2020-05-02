
; unit GRAPH: InitGraph, PutPixel, LineTo
; unit S2: SetGraphMode


/*
  PUT CHAR

  Procedura wyprowadza znak na ekran na pozycji X/Y kursora okreslonej przez zmienne odpowiednio
  COLCRS ($55-$56) i ROWCRS ($54). Zaklada sie, ze obowiazuja przy tym domyslne ustawienia OS-u,
  to jest ekran jest w trybie Graphics 0, a kanal IOCB 0 jest otwarty dla edytora ekranowego.

  Wyprowadzenie znaku polega na zaladowaniu jego kodu ATASCII do akumulatora i wykonaniu rozkazu
  JSR PUTCHR.
*/

.proc	@putchar (.byte a) .reg

vbxe	bit *			; jsr vbxe_cmap

	ldx #$00		; $60 -> S2:
chn	equ *-1

	.ifdef MAIN.CRT.TextAttr
	ora MAIN.CRT.TextAttr
	.endif
main
	tay
	lda icputb+1,x
	pha
	lda icputb,x
	pha
	tya

	rts

.endp
