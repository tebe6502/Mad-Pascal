; https://github.com/cc65/cc65/blob/153bb295010e2dc75ffd544d7091870ff563338d/libsrc/common/memset.s
;
; Ullrich von Bassewitz, 29.05.1998
; Performance increase (about 20%) by
; Christian Krueger, 12.09.2009, slightly improved 12.01.2011

.proc	@fill (.word ptr1, ptr3 .byte ptr2) .var

ptr1 = :edx
ptr3 = :ecx
ptr2 = :eax

	txa:pha

	ldx ptr2

	ldy #0

        lsr	ptr3+1          ; divide number of
        ror	ptr3            ; bytes by two to increase
        bcc	evenCount       ; speed (ptr3 = ptr3/2)
oddCount:
				; y is still 0 here
        txa			; restore fill value
        sta	(ptr1),y	; save value and increase
        inc	ptr1		; dest. pointer
        bne	evenCount
        inc	ptr1+1
evenCount:
	lda	ptr1		; build second pointer section
	clc
	adc	ptr3		; ptr2 = ptr1 + (length/2) <- ptr3
	sta     ptr2
	lda     ptr1+1
	adc     ptr3+1
	sta     ptr2+1

        txa			; restore fill value
        ldx	ptr3+1		; Get high byte of n
        beq	L2		; Jump if zero

; Set 256/512 byte blocks
				; y is still 0 here
L1:	.rept 2			; Unroll this a bit to make it faster
	sta	(ptr1),y	; Set byte in lower section
	sta	(ptr2),y	; Set byte in upper section
	iny
	.endr
        bne	L1
        inc	ptr1+1
        inc	ptr2+1
        dex                     ; Next 256 byte block
        bne	L1              ; Repeat if any

; Set the remaining bytes if any

L2:	ldy	ptr3            ; Get the low byte of n
	beq	leave           ; something to set? No -> leave

L3:	dey
	sta	(ptr1),y	; set bytes in low
	sta	(ptr2),y	; and high section
	bne     L3		; flags still up to date from dey!

leave	pla:tax
	rts			; return
.endp
