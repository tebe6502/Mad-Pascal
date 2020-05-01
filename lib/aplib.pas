unit apLib;
(*
* @type: unit
* @author: John Brandwood
* @name: APL
*
* @version: 1.0
*
* @description:
* apLib decompressor
*
* <http://ibsensoftware.com/products_aPLib.html>
*
* <https://github.com/emmanuel-marty/apultra>
*)

{

unAPL

}

interface

	procedure unAPL(inputPointer, outputPointer: pointer); assembler; register;

implementation
	
	
procedure unAPL(inputPointer, outputPointer: pointer); assembler; register;
(*
@description:
apLib decompressor

@param: inputPointer - source data address
@param: outputPointer - destination data address
*)
asm
{
; ***************************************************************************
; ***************************************************************************
;
; aplib_6502.s
;
; NMOS 6502 decompressor for data stored in Jorgen Ibsen's aPLib format.
;
; This code is written for the Atari MADS assembler.
;
; Copyright John Brandwood 2019.
;
; Distributed under the Boost Software License, Version 1.0.
; (See accompanying file LICENSE_1_0.txt or copy at
;  http://www.boost.org/LICENSE_1_0.txt)
;
; ***************************************************************************
; ***************************************************************************
;
; Decompression Options & Macros
;
		;
		; Assume that we're decompessing from a large multi-bank
		; compressed data file, and that the next bank may need to
		; paged in when a page-boundary is crossed.
		;

APL_FROM_BANK	=	0

		;
		; Use a function in zero-page for the copy loop?
		;
		; If selected, then apl_initdecomp must be called before
		; apl_decompress in order to set up the code in zero-page.
		;
		; This doesn't really make things much faster in practice
		; because most copies are small, and the subroutine call
		; overhead eats up the savings from the faster copy loop.
		;

APL_ZP_COPY	=	0

		;
		; Macro to increment the source pointer to the next page.
		;

		.IF	APL_FROM_BANK
APL_INC_PAGE	.MACRO
		jsr	.next_page
		.ENDM
		.ELSE
APL_INC_PAGE	.MACRO
		inc	apl_srcptr + 1
		.ENDM
		.ENDIF

		;
		; Macro to read a byte from the compressed source data.
		;

APL_GET_SRC	.MACRO
		lda	(apl_srcptr),y
		inc	apl_srcptr + 0
		bne	@+
		APL_INC_PAGE
@
		.ENDM


; ***************************************************************************
; ***************************************************************************
;
; Data usage is last 11 bytes of zero-page.
;
apl_bitbuf	= :eax+1		; 1 byte
apl_offset	= apl_bitbuf+1		; 1 word
apl_srcptr	= apl_offset+2		; 1 word	; edx -> inputPointer
apl_copy_loop	= apl_srcptr+2		; 6 bytes

apl_dstptr	=	apl_copy_loop + 2		; ecx -> outputPointer
apl_winptr	=	apl_copy_loop + 5
apl_length	=	apl_winptr


		; This 10-byte loop gets copied to zero-page, and overlaps
		; the bottom 4-bytes of stack memory to use less ZP space.

		.IF	APL_ZP_COPY

apl_initdecomp: ldy	#$F6			; Initialize source index.
apl_init_loop:	lda	apl_init_loop - $F6,y
		sta	apl_copy_loop - $F6,y
		iny
		bne	apl_init_loop
		rts

		.ENDIF



; ***************************************************************************
; ***************************************************************************
;
; apl_decompress - Decompress data stored in Jorgen Ibsen's aPLib format.
;
; Args: apl_srcptr = ptr to compessed data
; Args: apl_dstptr = ptr to output buffer
; Uses: lots!
;
; If compiled with APL_FROM_BANK, then apl_srcptr should be within the bank
; window range.
;
; As an optimization, the code to handle window offsets > 64768 bytes has
; been removed, since these don't occur with a 16-bit address range.
;
; As an optimization, the code to handle window offsets > 32000 bytes can
; be commented-out, since these don't occur in typical 8-bit computer usage.
;

aPL_depack:		
		stx @sp

		lda	#$80			; Initialize an empty
		sta	apl_bitbuf		; bit-buffer.

		ldy	#0			; Initialize source index.

		;
		; 0 bbbbbbbb - One byte from compressed data, i.e. a "literal".
		;

apl_literal:	APL_GET_SRC

apl_write_byte: ldx	#0			; LWM=0.

		sta	(apl_dstptr),y		; Write the byte directly to
		inc	apl_dstptr + 0		; the output.
		bne	apl_next_tag
		inc	apl_dstptr + 1

apl_next_tag:	asl	apl_bitbuf		; 0 bbbbbbbb

		.IF	1
		bne	apl_skip0
		jsr	apl_load_bit
apl_skip0:	bcc	apl_literal
		.ELSE
		bcc	apl_literal
		bne	apl_skip1
		jsr	apl_load_bit
		bcc	apl_literal
		.ENDIF

apl_skip1:	asl	apl_bitbuf		; 1 0 <offset> <length>
		bne	apl_skip2
		jsr	apl_load_bit
apl_skip2:	bcc	apl_code_pair

		asl	apl_bitbuf		; 1 1 0 dddddddn
		bne	apl_skip3
		jsr	apl_load_bit
apl_skip3:	bcc	apl_two_three

		; 1 1 1 dddd - Copy 1 byte within 15 bytes (or zero).

apl_copy_one:	lda	#$10
apl_nibl_loop:	asl	apl_bitbuf
		bne	apl_skip4
		pha
		jsr	apl_load_bit
		pla
apl_skip4:	rol
		bcc	apl_nibl_loop
		beq	apl_write_byte		; Offset=0 means write zero.

		eor	#$FF			; CS from previous ROL.
		adc	apl_dstptr + 0
		sta	apl_winptr + 0
		lda	#$FF
		adc	apl_dstptr + 1
		sta	apl_winptr + 1

		lda	(apl_winptr),y		; If must be NZ, or else we'd
		bne	apl_write_byte		; have used the other coding.

		;
		; 1 1 0 dddddddn - Copy 2 or 3 within 128 bytes.
		;

apl_two_three:	APL_GET_SRC			; 1 1 0 dddddddn
		lsr
		beq	apl_finished		; Offset 0 == EOF.

		sta	apl_offset + 0		; Preserve offset.
		sty	apl_offset + 1
		tya				; Y == 0.
		tax				; Bits 8..15 of length.
		adc	#2			; Bits 0...7 of length.
		bne	apl_do_match		; NZ from previous ADC.

apl_finished:	ldx #0
@sp		equ *-1

		rts				; All decompressed!

		;
		; 1 0 <offset> <length> - gamma-coded LZSS pair.
		;

apl_code_pair:	jsr	apl_get_gamma		; Bits 8..15 of offset (min 2).

		sty	apl_length + 1		; Clear hi-byte of length.

		cpx	#1			; CC if LWM==0, CS if LWM==1.
		sbc	#2			; -3 if LWM==0, -2 if LWM==1.
		bcs	apl_new_offset		; CC if LWM==0 && offset==2.

apl_old_offset: jsr	apl_get_gamma		; Get length (A=lo-byte & CC).
		ldx	apl_length + 1
		bcc	apl_do_match		; Use previous Offset.

apl_new_offset: sta	apl_offset + 1		; Save bits 8..15 of offset.

		APL_GET_SRC
		sta	apl_offset + 0		; Save bits 0...7 of offset.

		jsr	apl_get_gamma		; Get length (A=lo-byte & CC).
		ldx	apl_length + 1

		ldy	apl_offset + 1		; If offset < 256.
		beq	apl_lt256
		cpy	#$7D			; If offset >= 32000, length += 2.
		bcs	apl_plus2
		cpy	#$05			; If offset >=	1280, length += 1.
		bcs	apl_plus1
		bcc	apl_do_match
apl_lt256:	ldy	apl_offset + 0		; If offset <	 128, length += 2.
		bmi	apl_do_match

		sec
apl_plus2:	adc	#1			; CS, so ADC #2.
		bcs	apl_plus256

apl_plus1:	adc	#0			; CS, so ADC #1, or CC if fall
		bcc	apl_do_match		; through from .match_plus2apl_

apl_plus256:	inx

apl_do_match:	eor	#$FF			; Negate the lo-byte of length
		tay				; and check for zero.
		iny
		beq	apl_calc_addr
		eor	#$FF

		inx				; Increment # of pages to copy.

		clc				; Calc destination for partial
		adc	apl_dstptr + 0		; page.
		sta	apl_dstptr + 0
		bcs	apl_calc_addr
		dec	apl_dstptr + 1

apl_calc_addr:	sec				; Calc address of match.
		lda	apl_dstptr + 0
		sbc	apl_offset + 0
		sta	apl_winptr + 0
		lda	apl_dstptr + 1
		sbc	apl_offset + 1
		sta	apl_winptr + 1

		.IF	APL_ZP_COPY
apl_copy_page:	jsr	apl_copy_loop		; Execute copy loop in ZP.
		.ELSE
apl_copy_page:	lda	(apl_winptr),y
		sta	(apl_dstptr),y
		iny
		bne	apl_copy_page
		.ENDIF

		inc	apl_winptr + 1
		inc	apl_dstptr + 1
		dex				; Any full pages left to copy?
		bne	apl_copy_page

		ldx	#1			; LWM=1.
		jmp	apl_next_tag

		;
		; Subroutines for byte & bit handling.
		;

apl_load_bit:	APL_GET_SRC			; Reload an empty bit-buffer
		rol				; from the compressed source.
		sta	apl_bitbuf
		rts

apl_get_gamma:	lda	#1			; Get a gamma-coded value.
apl_gamma_loop: asl	apl_bitbuf
		bne	apl_skip5
		pha
		jsr	apl_load_bit
		pla
apl_skip5:	rol
		rol	apl_length + 1
		asl	apl_bitbuf
		bne	apl_skip6
		pha
		jsr	apl_load_bit
		pla
apl_skip6:	bcs	apl_gamma_loop
		rts				; Always returns CC.

		.IF	APL_FROM_BANK
apl_next_page:	inc	apl_srcptr + 1		; Placeholder for a function
		rts				; to detect bank overflow.
		.ENDIF
};
end;


end.
