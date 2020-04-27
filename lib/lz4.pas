unit LZ4;
(*
* @type: unit
* @author: Krzysztof Dudek, Tomasz Biela
* @name: LZ4
*
* @version: 1.0
*
* @description:
* LZ4 decompressor
* 
* <https://lz4.github.io/lz4/>
* <https://github.com/emmanuel-marty/lz4ultra>
* <https://xxl.atari.pl/lz4-decompressor/>
*)

{

unLZ4

}

interface

	procedure unLZ4(inputPointer, outputPointer: pointer); assembler; register;

implementation


procedure unLZ4(inputPointer, outputPointer: pointer); assembler; register;
(*
@description:
LZ4 decompressor

@param: inputPointer - source data address
@param: outputPointer - destination data address
*)
asm
{
.macro	GET_BYTE
		lda	(inputPointer,x)

		inw	inputPointer
.endm


.macro	PUT_BYTE
		sta	(outputPointer,x)

		inw	outputPointer

		dec	length
		sne
		dec	length+1
.endm


source	= edx+2
length	= ecx+2

		stx @sp

		ldx	#$00
unlz4
		GET_BYTE			; length of literals
		sta    token
		:4 lsr
		beq    read_offset		; there is no literal
		cmp    #$0f
		jsr    getlength
literals	GET_BYTE
		PUT_BYTE
		bne    literals
read_offset	GET_BYTE
		tay
		sec
		eor    #$ff
		adc    outputPointer
		sta    source
		tya
		php
		GET_BYTE
		plp
		bne    not_done
		tay
		beq    unlz4_end
not_done	eor    #$ff
		adc    outputPointer+1
		sta    source+1
		; c=1
		lda    #$ff
token		equ    *-1
		and    #$0f
		adc    #$03			; 3+1=4
		cmp    #$13
		jsr    getLength

@		lda    (source,x)

		inw    source

		PUT_BYTE

		bne    @-
		beq    unlz4			; zawsze

unlz4_end	ldx #0
@sp		equ *-1
		rts

getLength_next  GET_BYTE
		tay
		clc
		adc    length
		bcc    @+
		inc    length+1
@		iny
getLength       sta    length
		beq    getLength_next
		tay
		beq    @+
		inc    length+1
@		rts

};
end;


end.
