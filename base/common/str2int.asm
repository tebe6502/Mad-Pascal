
/*
	@strToInt
	fmul10
*/

; ecx	isSign
; edx	Result

.proc	@StrToInt (.word ya) .reg

	sta bp2
	sty bp2+1

	ldy #0
	sty MAIN.SYSTEM.IOResult
	sty edx
	sty edx+1
	sty edx+2
	sty edx+3

	lda (bp2),y
	beq stop
	sta len

	inw bp2

	lda (bp2),y
	cmp #'-'
	sne
	iny

	sty ecx

l1	lda (bp2),y

	CLC
	ADC #$FF-'9'	; make m = $FF
	ADC #'9'-'0'+1	; carry set if in range n to m
	bcs ok

	lda #106	; Invalid numeric format
	sta MAIN.SYSTEM.IOResult
	
	bne stop	; reg Y+1 contains the index of the character in S which prevented the conversion

ok	jsr fmul10

	lda (bp2),y
	sub #$30
	sta ztmp

	lda #$00
	sta ztmp+1
	sta ztmp+2
	sta ztmp+3

	jsr fmul10.add32bit

	iny
	cpy #0
len	equ *-1
	bne l1
	
	ldy #$ff

	lda ecx
	beq stop

	jsr @negEDX
	
stop	iny		; reg Y = 0 conversion successful
	rts
.endp


.proc	fmul10
	asl edx		;multiply by 2
	rol edx+1	;temp store in ZTMP
	rol edx+2
	rol edx+3

	lda edx
	sta ztmp
	lda edx+1
	sta ztmp+1
	lda edx+2
	sta ztmp+2
	lda edx+3
	sta ztmp+3

	asl edx
	rol edx+1
	rol edx+2
	rol edx+3

	asl edx
	rol edx+1
	rol edx+2
	rol edx+3

add32bit
	lda edx
	add ztmp
	sta edx
	lda edx+1
	adc ztmp+1
	sta edx+1
	lda edx+2
	adc ztmp+2
	sta edx+2
	lda edx+3
	adc ztmp+3
	sta edx+3

	rts
.endp
