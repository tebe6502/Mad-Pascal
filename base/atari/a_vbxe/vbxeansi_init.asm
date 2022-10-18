
		icl	'atarios.equ'		; atari OS equates,
		icl	'atarihardware.equ'	; general atari hardware equates,
		icl	'VBXE.equ'		; and VBXE equates


clear_ram_len	equ	clear_ram_end-clear_ram_bcb


.extrn	fxptr	.byte


	.RELOC

		jsr @vbxe_detect
		bcs no_vbxe

; check minor revision number.
core_fx
		and 	#$70			; masks the ram upgrade bit and the bugfix bits out (1.2xa/r)
		cmp	#$20			; make sure it is 2x since this is written for it
		beq	good_core

; print an error message in case of missing or non fx core VBXE
; just set the ICBA and call another routine since printing to E: will be used twice.
no_vbxe		lda	<no_vbxe_msg
		sta	ICBA
		lda	>no_vbxe_msg
		sta	ICBA + 1
		jmp	print_error

; print an error message in case of incompatible VBXE core
; just set the ICBA and call another routine since printing to E: is used twice.
		lda	<wrong_core
		sta	ICBA
		lda	>wrong_core
		sta	ICBA+1
		jmp	print_error

; core was good, so set
; shut off ANTIC DMA except instruction fetch
good_core	lda	#$20			; jump here if minor revision was good too
		sta	SDMCTL

; begin actually setting up the VBXE
		lda	#$00
		ldy	#memac_b_control	; disable memac b window
		sta	(fxptr),y

; vbxe_mem_base is the high address of what we want to use for our VBXE memory window
; the first 4 bits of memac_control are the high nibble of the base address of the window
; we OR vbxe_mem_base with $8 because that enables CPU access, disables ANTIC access,
; and makes window size 4K

		lda	#>vbxe_mem_base|$8
		ldy	#memac_control
		sta	(fxptr),y

; we are going to put a blitter list which clears the VBXE RAM into the first page of memory
; so we set the bank

		lda	#$80
		ldy	#memac_bank_sel
		sta	(fxptr),y

.local		; copy the screen clearing blitter
		ldx	#00
loop		lda	clear_ram_bcb,x
		sta	vbxe_mem_base,x
		inx
		cpx	#clear_ram_len
		bne	loop
.endl

; start the BCB

		lda	#0
		ldy	#blt_adr
		sta	(fxptr),y
		iny
		sta	(fxptr),y
		iny
		sta	(fxptr),y

		lda	#1
		ldy	#blt_start
		sta	(fxptr),y

.local		; wait until the blitter is done
loop		lda	(fxptr),y
		bne	loop
.endl


// ---------------------------------------------------------------------------------------------

; set bank to beginning of VBXE memory with bit 7 set to enable the window
; this is where we will load the font

		lda	#$80
		ldy	#memac_bank_sel
		sta	(fxptr),y

; load the entire (2K) font into the VBXE memory window

	ldx #8
	ldy #0

mv	lda src:font,y
	sta dst:vbxe_mem_base,y
	iny
	bne mv

	inc src+1
	inc dst+1
	dex
	bne mv

; read the pallette to a temporary location inside VBXE memory (which we know is free for now)

	ldy #48-1
	mva:rpl pallette,y vbxe_mem_base+$800,y-

; initialize csel and psel to start loading colors into the pallette

		lda	#$01		; pallette #1
		ldy	#psel
		sta	(fxptr),y

		lda	#$00
		ldy	#csel
		sta	(fxptr),y

.local		; load the foreground colors into the VBXE
; we use a nested loop here due to the design of the text mode colors
; we need to load the 16 foreground colors into the first 128 colors in order, and do that 8 times
; this order will be like:
; col 1, col 2, col 3, ..., col F, col 1, col 2 etc.

		lda	#$00			; initialize the outer loop counter
		sta	tmp

fore_outer_loop	ldx	#$00			; initialize the inner loop counter
fore_inner_loop	lda	vbxe_mem_base + $0800,x	; load the color values. use index x because of the order we need to load colors in
		ldy	#cr
		sta	(fxptr),y
		lda	vbxe_mem_base + $0801,x
		iny
		sta	(fxptr),y
		lda	vbxe_mem_base + $0802,x
		iny
		sta	(fxptr),y

		inx				; increment 3 times because each color is 3 bytes
		inx
		inx
		cpx	#$30			; once x is equal to $30, we have loaded all the colors
		bne	fore_inner_loop

		inc	tmp			; increment the outer loop counter

		lda	tmp
		cmp	#$08			; so we can do it for 8 times total
		bne	fore_outer_loop
.endl


.local		; load the background colors into the VBXE
; we use a nested loop here, but differently again due to the design of text mode colors
; we need to load the 8 background colors 16 times in a row each
; that is, load color 0 16 times, then load color 1 16 times, etc.

		ldy	#$00			; initialize the outer loop counter
		sty	tmp

back_outer_loop	ldx	#$00			; initialize the inner loop counter
back_inner_loop	ldy	tmp

		lda	vbxe_mem_base + $0802,y	; load the color values. use index y because we load each color repeatedly
		pha
		lda	vbxe_mem_base + $0801,y
		pha
		lda	vbxe_mem_base + $0800,y
		pha

		ldy	#cr
		pla
		sta	(fxptr),y
		iny
		pla
		sta	(fxptr),y
		iny
		pla
		sta	(fxptr),y		; B  ->  catch R-G-B !!! order is important

		inx				; increment the inner loop
		cpx	#$10			; stop after the color has been loaded 16 times
		bne	back_inner_loop

		inc	tmp			; increment 3 times because each color is 3 bytes
		inc	tmp
		inc	tmp

		ldy	tmp
		cpy	#$18			; when we get to $18, we have loaded all the background colors
		bne	back_outer_loop
.endl

; turn off the MEMAC_A window so that it doesn't conflict with the extended RAM window
; this was causing issues with SDX

		lda	#0
		ldy	#memac_bank_sel
		sta	(fxptr),y

; return from the init routine.

		rts

tmp		brk

// ---------------------------------------------------------------------------------------------

print_error	; prints the error message already set in ICBA
		lda	#$FF
		sta	ICBL
		lda	#09
		sta	ICCOM
		ldx	#$00
		jsr	CIOV


		lda	<press_return
		sta	ICBA
		lda	>press_return
		sta	ICBA + 1
		lda	#$FF
		sta	ICBL
		lda	#09
		sta	ICCOM
		ldx	#$00
		jsr	CIOV


; wait for return press

		lda	#$06
		sta	ICBA+1
		lda	#$00
		sta	ICBA
		sta	ICBL
		sta	ICBL+1
		lda	#$05
		sta	ICCOM
		jsr	CIOV

; go back to DOS

		pla				; remove return address from stack first.
		pla
		jmp	(DOSVEC)


no_vbxe_msg	; message to display for missing VBXE or non-fx core
		.byte	'No VBXE or non-fx core.',$9b

wrong_core	; message for incompatible core version
		.byte	'Incompatible VBXE core (requires 1.2x).',$9B

press_return	.byte	'Press return to continue',$9B


		icl 'detect_vbxe.asm'



clear_ram_bcb					; blitter routine to clear the whole VBXE RAM.
						; we can only work with a 512 byte wide and 256 line high portion, or 128K, so we do that four times.
		.long	0			; source doesn't matter, we're using a fill value
		.word	0			; source y step doesn't matter
		.byte	0			; source x step doesn't matter
		.long	clear_ram_len		; don't overwrite the blitter list
		.word	512			; one line is 512 bytes (no lines really though, we're just doing the whole 512K)
		.byte	1			; x step 1
		.word	512-1			; 512 bytes wide
		.byte	256-1			; 256 lines
		.byte	0			; AND mask ignores source
		.byte	0			; XOR mask fills with 0
		.byte	0			; don't worry about collisions
		.byte	0			; no zoom
		.byte	0			; don't worry about patterns
		.byte	%00001000		; there's 3 more of these BCB's, so next bit on, and mode 0 (copy mode)

		.long	0			; source doesn't matter, we're using a fill value
		.word	0			; source y step doesn't matter
		.byte	0			; source x step doesn't matter
		.long	$020000			; destination starts at 128K
		.word	512			; one line is 512 bytes (no lines really though, we're just doing the whole 512K)
		.byte	1			; x step 1
		.word	512-1			; 512 bytes wide
		.byte	256-1			; 256 lines
		.byte	0			; AND mask ignores source
		.byte	0			; XOR mask fills with 0
		.byte	0			; don't worry about collisions
		.byte	0			; no zoom
		.byte	0			; don't worry about patterns
		.byte	%00001000		; there's 2 more of these BCB's, so next bit on, and mode 0 (copy mode)

		.long	0			; source doesn't matter, we're using a fill value
		.word	0			; source y step doesn't matter
		.byte	0			; source x step doesn't matter
		.long	$040000			; destination starts at 256K
		.word	512			; one line is 512 bytes (no lines really though, we're just doing the whole 512K)
		.byte	1			; x step 1
		.word	512-1			; 512 bytes wide
		.byte	256-1			; 256 lines
		.byte	0			; AND mask ignores source
		.byte	0			; XOR mask fills with 0
		.byte	0			; don't worry about collisions
		.byte	0			; no zoom
		.byte	0			; don't worry about patterns
		.byte	%00001000		; there's 1 more of these BCB's, so next bit on, and mode 0 (copy mode)

		.long	0			; source doesn't matter, we're using a fill value
		.word	0			; source y step doesn't matter
		.byte	0			; source x step doesn't matter
		.long	$060000			; destination starts at 384K
		.word	512			; one line is 512 bytes (no lines really though, we're just doing the whole 512K)
		.byte	1			; x step 1
		.word	512-1			; 512 bytes wide
		.byte	256-1			; 256 lines
		.byte	0			; AND mask ignores source
		.byte	0			; XOR mask fills with 0
		.byte	0			; don't worry about collisions
		.byte	0			; no zoom
		.byte	0			; don't worry about patterns
		.byte	%00000000		; there's no more of these BCB's, so next bit off, and mode 0 (copy mode)
clear_ram_end

font		ins 'ibmpc.fnt'

pallette

;	VGA Colors

	dta $00,$00,$00		// black
	dta $AA,$00,$00		// red
	dta $00,$AA,$00		// green
	dta $AA,$55,$00		// yellow
	dta $00,$00,$AA		// blue
	dta $AA,$00,$AA		// magenta
	dta $00,$AA,$AA		// cyan
	dta $AA,$AA,$AA		// white
	dta $55,$55,$55		// bright black
	dta $FF,$55,$55		// bright red
	dta $55,$FF,$55		// bright green
	dta $FF,$FF,$55		// bright yellow
	dta $55,$55,$FF		// bright blue
	dta $FF,$55,$FF		// bright magenta
	dta $55,$FF,$FF		// bright cyan
	dta $FF,$FF,$FF		// bright white
