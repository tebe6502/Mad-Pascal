
.proc	@sio

	stx dbufa		;< adres bufora
	sty dbufa+1		;> adres bufora
	sta dcmnd		; 'R' read sector / 'P' write sector

	ldy dunit
	lda lsector-1,y
	ldx hsector-1,y
skip
	sta dsctln		; < dlugosc sektora
	stx dsctln+1		; > dlugosc sektora

	lda #$c0		; $40 read / $80 write
	sta dstats

	lda #0
	sta casflg		; = 00 to indicate that it isn't a cassette operation

	jmp jdskint

boot	stx dbufa		;< adres bufora
	sty dbufa+1		;> adres bufora
	sta dcmnd		; 'R' read sector / 'P' write sector

	lda <$80
	ldx >$80
	jmp skip


// A = [1..8]
devnrm	tax

	CLC			; clear carry for add
	ADC #$FF-8		; make m = $FF
	ADC #8-1+1		; carry set if in range n to m
	bcs ok

	ldy #-123		; kod bledu "DEVICE OR FILE NOT OPEN"
	rts

ok	txa
	sta dunit		; nr stacji
	ora #$30
	sta ddevic		; nr stacji + $30

;	lda #7
;	sta dtimlo		; timeout

	ldy #1
	rts

devsec	tya			; zapisz rozmiar sektora
	ldy dunit
	sta hsector-1,y
	txa
	sta lsector-1,y
	rts

lsector	:8 dta l(256)
hsector	:8 dta h(256)

.endp
