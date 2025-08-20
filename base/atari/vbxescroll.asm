
.proc	@vbxe_scroll					; scroll one down routine.

one
; copy row #0 to buffer

		lda #1
		sta logcol

		ldy #79					; @buf = scrollback_buffer
cpRow		lda MAIN.SYSTEM.VBXE_WINDOW,y
		sta MAIN.VBXE.adr.scrollback_buffer,y
		lda MAIN.SYSTEM.VBXE_WINDOW+80,y
		sta MAIN.VBXE.adr.scrollback_buffer+80,y
		dey
		bpl cpRow

; uses the blitter to move everything up just one line.

		lda #$ff
		
		bne bcb_start
page							; scroll one page

; used for FF and also to initialize the screen so the color is not all $00

		lda #$00

bcb_start						; start of blitter lists
		sta blt_mask

		fxla FX_MEMS				; get the old bank number (should be the last bank, but we can't assume)
		pha
		
		fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

		ldy #20
		mva:rpl bltCop,y MAIN.SYSTEM.VBXE_WINDOW+MAIN.SYSTEM.VBXE_BCBTMP,y-

		fxs FX_BL_ADR0 #MAIN.SYSTEM.VBXE_BCBTMP	; program blittera od adresu MAIN.SYSTEM.VBXE_BCBTMP
		fxs FX_BL_ADR1 #$00			; zaraz za programem VBXE Display List
		fxsa FX_BL_ADR2

		fxs FX_BLITTER_START #$01		; !!! start gdy 1 !!!

wait		fxla FX_BLITTER_BUSY
		bne wait

		pla
		fxsa FX_MEMS				; restore FX_MEMS

		rts

bltCop		.long MAIN.SYSTEM.VBXE_OVRADR+160	; source address
		.word 160				; source step y
		.byte 1					; source step x
		.long MAIN.SYSTEM.VBXE_OVRADR		; destination address
		.word 160				; destination step y
		.byte 1					; destination step x
		.word 160-1				; width
		.byte 24-1				; height
blt_mask	dta 0xff				; and mask (and mask equal to 0, memory will be filled with xor mask)
		dta 0x00				; xor mask
		dta 0x00				; collision and mask
		dta 0x00				; zoom
		dta 0x00				; pattern feature
		dta 0x00				; control

.endp
