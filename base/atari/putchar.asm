
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

vbxe	bit *			; jsr @vbxe_put

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


// mode 80 (VBXE)
.proc	@putchar_80

	cmp #eol
	beq _eol
	
	jsr @ata2int
	sta atachr

	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_OVRADR/$1000

	jsr @vbxe_setcursor

	jsr @vbxe_putbyte

	fxs FX_MEMS #$00		; disable VBXE BANK
	
	rts
	
_eol	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_OVRADR/$1000

	jsr @vbxe_cursor.off

	lda #79
	sta colcrs
	
	jsr @vbxe_putbyte.no_carry

	fxs FX_MEMS #$00		; disable VBXE BANK
	
	rts

.endp