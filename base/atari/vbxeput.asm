
; !!! do uzytku tylko razem z @putchar !!!

; VBXE put (screen 40x24)
; input:
;	A - char

.proc	@vbxe_put (.byte a) .reg

	pha

	cmp #eol
	beq stop

	cmp #$7d		; clrscr
	bne skp

	jsr @vbxe_init.cmapini
	jmp stop

skp
	jsr @vbxe_cmap


stop		pla

		tay

		cmp #eol
		bne skp_

		lda #39
		sta colcrs

skp_		lda	#38
		cmp	colcrs
		bcs	no_new_line		; if 38 >= col, no new line is needed
		lda	rowcrs
		cmp	#23			; if row is 23, then we need to scroll a line
		beq	scroll

no_new_line	tya
		rts

scroll
		jsr put

bcb_start						; start of blitter lists

		fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

		ldy #20
		mva:rpl bltCop,y MAIN.SYSTEM.VBXE_WINDOW+MAIN.SYSTEM.VBXE_BCBTMP,y-

		fxs FX_BL_ADR0 #MAIN.SYSTEM.VBXE_BCBTMP	; program blittera od adresu MAIN.SYSTEM.VBXE_BCBTMP
		fxs FX_BL_ADR1 #$00			; zaraz za programem VBXE Display List
		fxsa FX_BL_ADR2

		fxs FX_BLITTER_START #$01		; !!! start gdy 1 !!!

wait		fxla FX_BLITTER_BUSY
		bne wait

		fxs FX_MEMS #$00

		pla					; zdejmujemy adres @putchar, stamtad został wywołany @vbxe_put
		pla

		rts

put
		lda icputb+1
		pha
		lda icputb
		pha
		tya

		rts


bltCop		.long MAIN.SYSTEM.VBXE_MAPADR+256	; source address
		.word 256				; source step y
		.byte 1					; source step x
		.long MAIN.SYSTEM.VBXE_MAPADR		; destination address
		.word 256				; destination step y
		.byte 1					; destination step x
		.word 256-1				; width
		.byte 24-1				; height
blt_mask	dta 0xff				; and mask (and mask equal to 0, memory will be filled with xor mask)
		dta 0x00				; xor mask
		dta 0x00				; collision and mask
		dta 0x00				; zoom
		dta 0x00				; pattern feature
		dta 0x00				; control

.endp
