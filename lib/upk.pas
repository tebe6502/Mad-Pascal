unit upk;
(*
* @type: unit
* @author: Piotr Fusik
* @name: UPK
*
* @version: 1.0
*
* @description:
* 6502 unpacker for Upkr
*
* upkr -9 --big-endian-bitstream --invert-new-offset-bit --invert-continue-value-bit --simplified-prob-update INPUT_FILE OUTPUT_FILE
*
* https://github.com/exoticorn/upkr
*
* https://github.com/pfusik/upkr6502
*)


{

unUPK

}

interface

procedure unUPK(inputPointer, outputPointer: pointer); assembler; register;


implementation


procedure unUPK(inputPointer, outputPointer: pointer); assembler; register;
(*
@description:
UPK decompressor

@param: inputPointer - source data address
@param: outputPointer - destination data address
*)
asm
; unupkr.asx - Upkr unpacker
;
; This code is licensed under the standard zlib license.
;
; Copyright (C) 2024 Piotr '0xF' Fusik
;
; This software is provided 'as-is', without any express or implied
; warranty.  In no event will the authors be held liable for any damages
; arising from the use of this software.
;
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must not
;    claim that you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation would be
;    appreciated but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must not be
;    misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.

unupkr_probs	= __BUFFER

OFFSET_BITS	equ	16
LENGTH_BITS	equ	16
OFFSET_PROBS	equ	OFFSET_BITS*2-1
LENGTH_PROBS	equ	LENGTH_BITS*2-1
PROBS_LEN	equ	1+255+1+OFFSET_PROBS+LENGTH_PROBS

src	equ	:EAX
dest	equ	:EAX+2
prev	equ	:EAX+4
len	equ	:EAX+6
probs	equ	:EAX+8
state	equ	:EAX+10
prob	equ	:EAX+12
bitBuf	equ	:EAX+13
wasLiteral	equ	:EAX+14

	mwa inputPointer src
	mwa outputPointer dest

	ldx	#[PROBS_LEN+1]/2
	lda	#$80
init
	sta	unupkr_probs-1,x
	sta	unupkr_probs+PROBS_LEN/2-1,x
	dex
	bne	init
	sta	bitBuf
	stx	state
	stx	state+1
	ift	<unupkr_probs==0
	stx	probs
	beq	loop	; jmp
	eli	<unupkr_probs==$80
	sta	probs
	beq	loop	; jmp
	els
	mva	#<unupkr_probs	probs
	bne	loop	; jmp
	eif

unpackCopy
	inc	probs+1
	lsr	wasLiteral
	bcc	getOffset
	dey
	jsr	getBit
	bcs	sameOffset	; --invert-new-offset-bit
getOffset
	sec
	jsr	getLen
	lda	#1
	sbc	len	; C=1
	sta	prev
	txa	; #0
	sbc	len+1
	bcs	eof
	adc	dest+1	; C=0
	sta	prev+1
	stx	len	; X=0
	stx	len+1
sameOffset
	ldy	#1+OFFSET_PROBS
	jsr	getLen	; C=1
	seq:inc	len+1
copy
	ldy	dest
	lda	(prev),y
store
	sta	(dest,x)	; X=0
	inc	dest
	bne	samePage
	inc	dest+1
	inc	prev+1
samePage
	dec	len
	bne	copy
	dec	len+1
	bne	copy

loop
	ldy	#0
	mva	#>unupkr_probs	probs+1
	jsr	getBit
	bcs	unpackCopy

	sty	len	; Y=1
	sty	len+1
	sty	wasLiteral
getLiteral
	jsr	getBit
	rol	@
	tay
	bcc	getLiteral
	bcs	store	; jmp

fetchLen
	jsr	getBit
getLen
	ror	len+1
	ror	len
	jsr	getBit
	bcc	fetchLen
; --invert-continue-value-bit
padLen
	ror	len+1
	ror	len
	bcc	padLen
eof
	rts

fetchBit
; --big-endian-bitstream
	asl	bitBuf
	bne	rolState
	lda	(src,x)	; X=0
	inw	src
	rol	@	; C=1
	sta	bitBuf
rolState
	rol	state
	rol	state+1
getBit
; -b
	lda	state+1
	bpl	fetchBit

	lda	(probs),y
	tax
	eor	#$ff
	dex
	cpx	state
	scs:tax
	stx	prob
	php

; --simplified-prob-update
	ror	@
:3	lsr	@
	adc	#$f0
	add:sta	(probs),y

	lda	#0
	ldx	#8
mul
	asl	state
	rol	@
	rol	state+1
	bcc	mulNot
	adc	prob	; C=1
	scc:inc	state+1
mulNot
	dex
	bne	mul
	plp
	bcs	bit1b
	sec
	adc	prob
	scs:dec	state+1
	clc
bit1b
	sta	state
	tya
	iny
	rts
end;


end.
