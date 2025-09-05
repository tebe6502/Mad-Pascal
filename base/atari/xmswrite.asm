
; unit MISC: DetectMem
; by Tebe

.proc	@xmsWriteBuf (.word ptr1, ptr2) .var

ptr1 =	:edx	; buffer	(2)

ptr2 =	:ecx	; count		(2)
pos  =	:ecx+2	; position	(2) pointer

ptr3 =	:eax	; position	(4)

	txa:pha

	ldy #0			; przepisz POSITION spod wskaznika
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

;-------------------------

lp1	lda portb		; wylacz dodatkowe banki
	and #1
	ora #$fe
	sta portb

	ldy #0			; przepisz 256b z BUFFER do @BUF
	mva:rne (ptr1),y @buf,y+
				; Y = 0
	lda ptr2+1
	beq lp2

	jsr @xmsBank		; wlacz dodatkowy bank, ustaw :ZTMP, :ZTMP+1

;	lda :ztmp+1		; jesli przekraczamy granice banku $7FFF
	cmp #$7f
	bne skp

	lda :ztmp
	beq skp

	lda #0			; to realizuj wyjatek NEXTBANK, kopiuj 256b
	jsr nextBank
	jmp skp2

skp	mva:rne @buf,y (:ztmp),y+

skp2	inc ptr1+1		// inc(buffer, $100)

	inl ptr3+1		// inc(position, $100)

	dec ptr2+1		// dec(count, $100)
	bne lp1

;-------------------------

lp2	lda ptr2
	beq quit

	lda portb		; wylacz dodatkowe banki
	and #1
	ora #$fe
	sta portb

	ldy #0			; przepisz PTR2 z BUFFER do @BUF
cp	lda (ptr1),y 
	sta @buf,y
	iny
	cpy ptr2
	bne cp

	jsr @xmsBank		; wlacz dodatkowy bank, ustaw :ZTMP, :ZTMP+1

;	lda :ztmp+1		; zakonczenie kopiowania
	cmp #$7f		; jesli przekraczamy granice banku $7FFF
	bne skp_

	lda :ztmp
	add ptr2
	bcc skp_

	lda ptr2		; to realizuj wyjatek NEXTBANK, kopiuj PTR2 bajtow
	jsr nextBank
	jmp quit

skp_	ldy #0
lp3	lda @buf,y
	sta (:ztmp),y
	iny
	cpy ptr2
	bne lp3

quit	lda portb
	and #1
	ora #$fe
	sta portb

	jmp @xmsUpdatePosition

.local	nextBank

	sta max

	mwa :ztmp dst

	ldy #0
mv0	lda @buf,y
	sta dst: $ffff,y
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

	lda @buf,y
	sta $4000,x
	inx
	iny
	bne mv1
stp
	rts
.endl

.endp
