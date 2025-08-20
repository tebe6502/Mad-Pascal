
.proc	@AllocMem	;(.word ztmp .byte ztmp+2) .var

	sta :ztmp+1
	sty :ztmp+2

loop	lda (:psptr),y
	sta :ztmp+3

	lda (:ztmp),y
	sta (:psptr),y

	lda :ztmp+3
	sta (:ztmp),y

	dey
	bpl loop

	lda :psptr
	sec
	adc :ztmp+2
	sta :psptr
	scc
	inc :psptr+1

	rts
.endp


.proc	@FreeMem	;(.word ztmp .byte ztmp+2) .var

	sta :ztmp+1

	tya
	eor #$ff
	clc
	adc :psptr
	sta :psptr
	scs
	dec :psptr+1

loop	lda (:psptr),y
	sta :ztmp+3

	lda (:ztmp),y
	sta (:psptr),y

	lda :ztmp+3
	sta (:ztmp),y

	dey
	bpl loop

	rts
.endp
