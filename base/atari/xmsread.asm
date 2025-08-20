
; unit MISC: DetectMem
; by Tebe

.proc	@xmsReadBuf (.word ptr1, ptr2) .var

ptr1 =	:edx	; buffer	(2)

ptr2 =	:ecx	; count		(2)
pos  =	:ecx+2	; position	(2) pointer

ptr3 =	:eax	; position	(4)

	txa:pha

	ldy #0
	lda (pos),y
	sta ptr3
	iny
	lda (pos),y
	sta ptr3+1
	iny
	lda (pos),y
	sta ptr3+2
	iny
	lda (pos),y
	sta ptr3+3

	lda ptr2+1
	beq lp2

lp1	jsr @xmsBank		; ZTMP+1

;	lda :ztmp+1
	cmp #$7f
	bne skp

	lda :ztmp
	beq skp

	lda #0
	jsr nextBank
	jmp skp2

skp	ldy #0
	mva:rne (:ztmp),y @buf,y+

skp2	lda portb
	and #1
	ora #$fe
	sta portb

	ldy #0
	mva:rne @buf,y (ptr1),y+

	inc ptr1+1		; inc(buffer, $100)

	inl ptr3+1		; inc(position, $100)

	dec ptr2+1
	bne lp1

lp2	jsr @xmsBank		; ZTMP+1

;	lda :ztmp+1		; zakonczenie kopiowania
	cmp #$7f		; jesli przekraczamy granice banku $7FFF
	bne skp_

	lda :ztmp
	add ptr2
	bcc skp_

	lda ptr2		; to realizuj wyjatek NEXTBANK, kopiuj PTR2 bajtow
	jsr nextBank
	jmp skp3

skp_	ldy #0
mv	lda (:ztmp),y
	sta @buf,y
	iny
	cpy ptr2
	bne mv

skp3	lda portb
	and #1
	ora #$fe
	sta portb

	lda ptr2
	beq quit

	ldy #0
lp3	lda @buf,y
	sta (ptr1),y
	iny
	cpy ptr2
	bne lp3
quit
	jmp @xmsUpdatePosition

.local	nextBank

	sta max

	mwa :ztmp src

	ldy #0
mv0	lda $ffff,y
src	equ *-2
	sta @buf,y
	iny
	inc :ztmp
	bne mv0

	lda portb
	and #1
	ora MAIN.SYSTEM.__PORTB_BANKS+1,x
	sta portb

	ldx #0
mv1	cpy #0
max	equ *-1
	beq stp
	lda $4000,x
	sta @buf,y
	inx
	iny
	bne mv1
stp	
	rts
.endl

.endp
