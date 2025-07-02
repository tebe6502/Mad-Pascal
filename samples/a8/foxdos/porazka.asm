_sin	equ	$8200
_line	equ	$840c

erusux	equ	$f0
timer	equ	$f1
hlp2	equ	$f2

	org	$8000

	ldx	#0
	ldy	#$1f+1
_1	lda	_SIN,x
	sta	_SIN+32-1,y
	eor	#$3f
	sta	_SIN+64,x
	sta	_SIN+96-1,y
	inx
	dey
	bne	_1
_2	lda	_SIN,y
	sta	_SIN+$080,y
	sta	_SIN+$100,y
	sta	_SIN+$180,y
	iny
	bpl	_2

	mwa	#dl0	$230

	ldy	#0
frame
	lda $d01f
	cmp #6
	sne
	rts


	tya 	;#0
	inc	timer
	smi:lda	#$11
	sta	erusux

	clc
	ldx	#$0f
	tya
_0	sta	_LINE,y
	sta	_LINE+16,x
	sta	_LINE+32,y
	sta	_LINE+48,x
	sta	_LINE+64,y
	adc	erusux
	iny
	dex
	bpl	_0

	lda	#4
	adc:sta	hlp2
	tax

	inc	j+1
	lda	#11
	sta	_DL+1
	cmp:rne	$d40b
	ldy	#112
	sty	$d01b

line	sta	$d40a
:3	inx
j	lda	_SIN,y
	adc	_SIN,x
	lsr	@
	bit	timer
	sta	$d40a
	bmi	kefr

; PLAZMA
	sta	_DL+1
	lda	#$e
	scc:lda	#$c
	sta	$d404
	txa
	adc	$d40b
	and	#$f0
	sne:lda	#$10
	sta	$d01a
	bne	_SRU_

; KEFRENKI
kefr	sta	_XXX_+1
	sta	_YYY_+1
_XXX_	lda	_LINE

	bcs skip
	adc	#$1f
skip	adc	#1

_YYY_	sta	_LINE

_SRU_	equ	*
	dey
	bne	line
	jmp	frame

dl0 dta b($47),a(scr)
_DL	dta	b($5f),a(_LINE)
	dta	b(1),a(_DL)

scr dta d' porazka'*,d' BY taquart '

	org	_SIN
	dta	b(sin(32,19,128,0,31))

	run	$8000
