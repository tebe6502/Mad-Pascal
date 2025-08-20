
/*
	@moveu
	@move
*/

; Ullrich von Bassewitz, 2003-08-20
; Performance increase (about 20%) by
; Christian Krueger, 2009-09-13

.proc	@moveu			; assert Y = 0

ptr1	= :edx
ptr2	= :ecx
ptr3	= :eax

	stx @sp

	ldy	#0

	ldx     ptr3+1		; Get high byte of n
	beq     L2		; Jump if zero

L1:     .rept 2			; Unroll this a bit to make it faster...
	lda     (ptr1),Y	; copy a byte
	sta     (ptr2),Y
	iny
	.endr

	bne     L1
	inc     ptr1+1
	inc     ptr2+1
	dex			; Next 256 byte block
	bne	L1		; Repeat if any

	; the following section could be 10% faster if we were able to copy
	; back to front - unfortunately we are forced to copy strict from
	; low to high since this function is also used for
	; memmove and blocks could be overlapping!
	; {
L2:				; assert Y = 0
	ldx     ptr3		; Get the low byte of n
	beq     done		; something to copy

L3:     lda     (ptr1),Y	; copy a byte
	sta     (ptr2),Y
	iny
	dex
	bne     L3

	; }

done	ldx #0
@sp	equ *-1
	rts
.endp


@move	.proc (.word ptr1, ptr2, ptr3) .var

ptr1	= :edx
ptr2	= :ecx
ptr3	= :eax

src	= ptr1
dst	= ptr2
cnt	= ptr3

	cpw ptr2 ptr1
	scs
	jmp @moveu

	stx @sp

; Copy downwards. Adjust the pointers to the end of the memory regions.

	lda     ptr1+1
	add     ptr3+1
	sta     ptr1+1

	lda     ptr2+1
	add     ptr3+1
	sta     ptr2+1

; handle fractions of a page size first

	ldy     ptr3		; count, low byte
	bne     @entry		; something to copy?
	beq     PageSizeCopy	; here like bra...

@copyByte:
	lda     (ptr1),y
	sta     (ptr2),y
@entry:
	dey
	bne     @copyByte
	lda     (ptr1),y	; copy remaining byte
	sta     (ptr2),y

PageSizeCopy:			; assert Y = 0
	ldx     ptr3+1		; number of pages
	beq     done		; none? -> done

@initBase:
	dec     ptr1+1		; adjust base...
	dec     ptr2+1
	dey			; in entry case: 0 -> FF
	lda     (ptr1),y	; need to copy this 'intro byte'
	sta     (ptr2),y	; to 'land' later on Y=0! (as a result of the '.repeat'-block!)
	dey			; FF ->FE
@copyBytes:
	.rept 2			; Unroll this a bit to make it faster...
	lda     (ptr1),y
	sta     (ptr2),y
	dey
	.endr
@copyEntry:			; in entry case: 0 -> FF
	bne     @copyBytes
	lda     (ptr1),y	; Y = 0, copy last byte
	sta     (ptr2),y
	dex			; one page to copy less
	bne     @initBase	; still a page to copy?

done	ldx #0
@sp	equ *-1
	rts
.endp
