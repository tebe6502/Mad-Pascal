
; unit: VBXE
; @VBXE_PutByte (80 columns)

.proc	@vbxe_putbyte				; put the byte on the screen

		jsr	@vbxe_cursor.off
		ldy	#$00

		lda	atachr
		sta	(savadr),y

		iny

		lda	fildat			; get the current text color
		sta	(savadr),y

		adw	savadr #2

no_carry	inc	colcrs			; move the cursor forward
		lda	#79
		cmp	colcrs
		bcs	no_new_line		; if 79 >= col, no new line is needed
		lda	rowcrs
		cmp	#23			; if row is 23, then we need to scroll a line
		beq	scroll
		inc	rowcrs			; otherwise (when col > 79) go to the next line
		lda	#00
		sta	colcrs			; set column back to 0

no_new_line	jmp	@vbxe_setcursor

scroll		lda	#<(MAIN.SYSTEM.VBXE_WINDOW + 23 * 160)
		sta	savadr
		lda	#>(MAIN.SYSTEM.VBXE_WINDOW + 23 * 160)
		sta	savadr + 1

no_carry_1	lda	#0			; otherwise, don't
		sta	colcrs			; set column to 0. row stays 23
		jsr	@vbxe_scroll.one	; run the blitter routine to scroll one line down.
		jmp	@vbxe_setcursor
.endp