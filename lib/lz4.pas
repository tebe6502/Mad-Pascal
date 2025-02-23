unit lz4;
(*
* @type: unit
* @author: Krzysztof Dudek, Tomasz Biela
* @name: LZ4 decompression unit
*
* @version: 1.0
*
* @description:
* LZ4 decompressor (memory and stream)
*
* <https://lz4.github.io/lz4/>
*
* <https://github.com/emmanuel-marty/lz4ultra>
*
* <https://xxl.atari.pl/lz4-decompressor/>
*)

{

unLZ4

}

interface

	procedure unLZ4(inputPointer, outputPointer: pointer); assembler; register; overload;
	procedure unLZ4(fnam: PString; outputPointer: pointer); overload;

implementation



procedure unLZ4(fnam: PString; outputPointer: pointer); overload;
(*
@description:
LZ4 I/O stream decompressor

@param: inputPointer - source data address
@param: outputPointer - destination data address
*)
var f: file;
    buf: array [0..255] of byte absolute __buffer;


procedure read_buf;
begin

 {$I-}

 blockread(f, buf, 256);

 {$I+}

end;


begin

 assign(f, fnam); reset(f,1);

 if IOResult > 127 then begin
  close(f);
  Exit;
 end;

 blockread(f, buf, 11);		// skip 11 bytes from the beginning of the file

 READ_BUF;

asm
		mwa outputPointer dest

		mva #0 GET_BYTE+1

unlz4		jsr    GET_BYTE			; length of literals
		sta    token
		:4 lsr @
		beq    read_offset		; there is no literal
		cmp    #$0f
		jsr    getlength
literals	jsr    GET_BYTE
		jsr    store
		bne    literals
read_offset	jsr    GET_BYTE
		tay
		sec
		eor    #$ff
		adc    dest
		sta    src
		tya
		php
		jsr    GET_BYTE
		plp
		bne    not_done
		tay
		beq    unlz4_done
not_done	eor    #$ff
		adc    dest+1
		sta    src+1
		; c=1
		lda    #$ff
token		equ    *-1
		and    #$0f
		adc    #$03			; 3+1=4
		cmp    #$13
		jsr    getLength

@		lda    $ffff
src		equ    *-2
		inw    src
		jsr    store
		bne    @-
		beq    unlz4			; always

store		sta    $ffff
dest		equ    *-2

		inw    dest
		dec    lenL
		sne
		dec    lenH
		rts

unlz4_done	jmp to_exit

getLength_next	jsr    GET_BYTE
		tay
		clc
		adc    #$00
lenL		equ    *-1
		bcc    @+
		inc    lenH
@		iny
getLength	sta    lenL
		beq    getLength_next
		tay
		beq    @+
		inc    lenH
@		rts

lenH		.byte    $00

GET_BYTE	lda adr.buf
		pha

		inc GET_BYTE+1
		sne
		jsr READ_BUF

		pla
		rts

to_exit		lda #0
		tya
		sta:rne @buf,y+
end;

 close(f);

end;


procedure unLZ4(inputPointer, outputPointer: pointer); assembler; register; overload;
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

		adw inputPointer #11		; skip 11 bytes from the beginning of the file

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

		jmp @exit

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
