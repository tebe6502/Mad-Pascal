unit efast;
(*
 @type: unit
 @author: Daniel Serpell (DMSC), Tomasz Biela (Tebe)
 @name: E: accelerator
 @version: 1.0

 @description:
 E: accelerator for Atari 8-bit OS

 <https://github.com/dmsc/e-accelerator>
*)


{


}

interface


implementation

uses crt;


initialization


asm
{

;
; Fast E: accelerator
; -------------------
;
; Written by DMSC, loosely based on HYP.COM by Doug Wokoun and John Harris.
;

EDITRV	= $E400

ATCLR	= $7d
ATESC	= $1b

	txa:pha

	.ifdef MAIN.@DEFINES.ROMOFF
		inc portb
	.endif

	; Search E: handler in HATABS
	ldy	#<HATABS+1-3
	lda	#'E'
search_e:
	iny
	iny
	iny
	cmp	-1+(HATABS & $FF00),y
	bne	search_e

	; Check high-part of HATABS address
	lda	1+(HATABS & $FF00),y
	cmp	#>$C000
	bcs	install_ok

	ldy #130

	jmp handler_end

install_ok

	; copy EDITOR handler to new HATABS
	ldx	#$0F
copy_e: lda	EDITRV,x
	sta	handler_hatab,x
	dex
	bpl	copy_e

	; Patch E: HATABS position in out handler
	sty	hatabs_l+3
	iny
	sty	hatabs_h+3

	; Also patch real DOSINI and EDITOR PUT
	lda	DOSINI
	lda	DOSINI+1
	ldy	EDITRV+6
	ldx	EDITRV+7
	iny
	sne
	inx
	sty	jhand+1
	stx	jhand+2

	; Patch new HATABS, stored in current MEMLO
	lda	<EFAST
	ldx	>EFAST

	sta	hatabs_l+1
	stx	hatabs_h+1

	; And store our new PUT
	; (note, C is set here, so adds 1 less)
	adc	#(handler_put-1 - handler_hatab) - 1
	scc
	inx
	sta	handler_hatab+6
	stx	handler_hatab+7

hatabs_l:
	lda	#$00
	sta	HATABS+1
hatabs_h:
	ldx	#$00
	stx	HATABS+2

	ldy #1

	jmp handler_end

EFAST

handler_hatab	.ds 16


	; Handler PUT function
handler_put:
	; Don't handle wrap at last column!
	ldx	COLCRS
	cpx	RMARGN
	bcs	jhand

	; And don't handle in graphics modes
	ldx	DINDEX
	bne	jhand

	; Check for control character:
	;  $1B, $1C, $1D, $1E, $1F, $7D, $7E, $7F
	;  $9B, $9C, $9D, $9E, $9F, $FD, $FE, $FF
	;
	; To ignore high bit, store in X the shifted character
	asl
	tay
	; Restore full value in A
	ror

	cpy	#2*ATCLR	; chars >= $7D are special chars
	bcs	jhand
	cpy	#$C0		; chars >= $60 don't need conversion
	bcs	conv_ok
	cpy	#$40		; chars >= $20 needs -$20 (upper case and numbers)
	bcs	normal_char
	cpy	#2*ATESC	; chars <= $1B needs +$40 (control chars)
	bcc	ctrl_char

	; Special character jump to old handler
jhand:  jmp	$FFFF

	; Convert ATASCII to screen codes
ctrl_char:
	adc	#$61		; Chars from $00 to $1F, add $40 (+$21, subtracted bellow)
normal_char:
	sbc	#$20		; Chars from $20 to $5F, subtract $20
conv_ok:

	; Check break and stop on START/STOP flag
wait_stop:
	ldy	BRKKEY
	beq	jhand
	ldy	SSFLAG
	bne	wait_stop
	; From here onwards, Y = 0 always!

	; Check if we need to recalculate cursor position
	cpx	OLDCOL
	bne	calc_adr
	ldx	ROWCRS
	cpx	OLDROW
	beq	skip_adr

	; Clear current cursor position and calculate new cursor address
calc_adr:
	tax			; Save character in X

	lda	OLDCHR		; Clear cursor
	sta	(OLDADR),y

	sty	OLDADR+1	; set OLDADR+1 to 0

	lda	ROWCRS		; max =  23
	sta	OLDROW

	asl			; max = 46
	asl			; max = 92
	adc	ROWCRS		; max = 115
	asl			; max = 230
	asl			; max = 460
	rol	OLDADR+1
	asl			; max = 920
	rol	OLDADR+1

	adc	COLCRS		; max = 959
	bcc	@+
	inc	OLDADR+1
	clc
@
	adc	SAVMSC
	sta	OLDADR
	lda	OLDADR+1
	adc	SAVMSC+1
	sta	OLDADR+1

	txa

skip_adr:
	; Store new character
	sta	(OLDADR),y
	; Go to next column
	inc	OLDADR
	sne
	inc	OLDADR+1

	; Read new character under cursor
	lda	(OLDADR),y
	sta	OLDCHR

	ldx	CRSINH
	bne	no_cursor
	; Draw cursor
	eor	#$80
	sta	(OLDADR),y
no_cursor:

	; Update column
	ldx	COLCRS
	inx
	stx	COLCRS
	stx	OLDCOL
	inc	LOGCOL

	; Reset ESC flag
	sty	ESCFLG

	; Return with Y = 1 (no error)
	iny
	rts

; End of resident handler
handler_end:

	.ifdef MAIN.@DEFINES.ROMOFF
		dec portb
	.endif

	pla:tax
};

 TextMode(0);

end.
