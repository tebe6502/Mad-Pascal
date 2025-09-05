
.proc	@GetKey

getk	lda kbcodes		; odczytaj kbcodes
	cmp #255		; czy jest znak?
	beq getk		; nie: czekaj
	ldy #255		; daj znac, ze klawisz
	sty kbcodes		; zostal odebrany
	tay			; kod klawisza jako indeks
	lda (keydef),y		; do tablicy w ROM-ie

	rts
.endp
