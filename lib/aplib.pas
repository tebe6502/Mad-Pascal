unit aplib;
(*
* @type: unit
* @author: John Brandwood, Krzysztof 'XXL' Dudek, Tomasz 'Tebe' Biela
* @name: APL decompression unit
*
* @version: 1.0
*
* @description:
* apLib decompressor (compress with APULTRA)
*
* <http://ibsensoftware.com/products_aPLib.html>
*
* <https://github.com/emmanuel-marty/apultra>
*)

{

unAPL

}

interface

	procedure unAPL(inputPointer, outputPointer: pointer); assembler; overload;
	procedure unAPL(fnam: PString; outputPointer: pointer); overload;

implementation



procedure unAPL(fnam: PString; outputPointer: pointer); overload;
(*
@description:
aPLib I/O stream decompressor (John Brandwood, Krzysztof 'XXL' Dudek)

@param: inputPointer - source data address
@param: outputPointer - destination data address
*)
var f: file;
    buf: array [0..255] of byte absolute __buffer;


procedure READ_BUF;
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

// blockread(f, buf, $xx);		// skip $xx bytes from the beginning of the file

 READ_BUF;

asm
		stx @sp

		mwa outputPointer dest_ap

		mva #$00 GET_BYTE+1

aPL_depack	lda #$80
		sta token
literal		lsr bl
		jsr GET_BYTE
write		jsr store
nxt_token	jsr get_token_bit
		bcc literal		; literal  -> 0
		jsr get_token_bit
		bcc block		; block    -> 10
		jsr get_token_bit
		bcc short_block		; short block -> 110

single_byte	lsr bl			; single byte -> 111
		lda #$10
@		pha
		jsr get_token_bit
		pla
		rol @
		bcc @-
		beq write
		jmp len01

aPL_done	jmp to_exit

short_block	jsr GET_BYTE
		lsr @
		beq aPL_done
		sta EBPL
		ldx #0
		stx EBPH
		ldx #$02
		bcc @+
		inx
@		sec
		ror  bl
		jmp len0203

block		jsr getgamma
		dex
		lda #$ff
bl		equ *-1
		bmi normalcodepair
		dex
		bne normalcodepair
		jsr getgamma
		lda #$ff
EBPL		equ *-1
		sta offsetL
		lda #$ff
EBPH		equ *-1
		sta offsetH
		jmp lenffff

normalcodepair	dex
		stx    offsetH
		stx    EBPH
		jsr    GET_BYTE
		sta    offsetL
		sta    EBPL
		jsr    getgamma
		lda    offsetH
		beq    _ceck7f
		cmp    #$7d
		bcs	 plus2
		cmp    #$05
		bcs	 plus1
		bcc    normal1               ; zawsze
_ceck7f		lda	 offsetL
		bmi    normal1
plus2		inx
		bne    plus1
		iny
plus1		inx
normal1
lenffff		iny
		sec
		ror bl
		bne domatch	; zawsze

getgamma	lda #$00
		pha
		lda #$01
		pha
@		jsr get_token_bit
		tsx
		rol $101,x
		rol $102,x
		jsr get_token_bit
		bcs @-
		pla
		tax
		pla
		tay
		rts

get_token_bit	asl    token
		bne    @+
		php
		jsr    GET_BYTE
		plp
		rol    @
		sta    token
@		rts
token		.byte $00

store		sta $ffff
dest_ap		equ *-2
		inw dest_ap
		rts

len01		ldx    #$01
len0203		ldy    #$00
		sta    offsetL
		sty    offsetH
		iny

domatch		lda dest_ap
		sec
		sbc #$ff
offsetL		equ *-1
		sta src
		lda dest_ap+1
		sbc #$ff
offsetH		equ *-1
		sta src+1
source		lda $ffff
src		equ *-2
		inw src
		jsr store
		dex
		bne source
		dey
		bne source
		jmp nxt_token


GET_BYTE	lda adr.buf
		inc GET_BYTE+1
		bne @+

		php
		pha
		ldx @sp
		jsr READ_BUF
		pla
		plp
@
		rts

to_exit		lda #0
		tya
		sta:rne @buf,y+

		ldx @sp: #0
end;

 close(f);

end;


procedure unAPL(inputPointer, outputPointer: pointer); assembler; overload;
(*
@description:
apLib decompressor (John Brandwood, Krzysztof 'XXL' Dudek)

@param: inputPointer - source data address
@param: outputPointer - destination data address
*)

asm
		stx @sp

		mwa inputPointer	GET_BYTE+1
		mwa outputPointer	dest_ap

aPL_depack	lda #$80
		sta token
literal		lsr bl
		jsr GET_BYTE
write		jsr store
nxt_token	jsr get_token_bit
		bcc literal		; literal  -> 0
		jsr get_token_bit
		bcc block		; block    -> 10
		jsr get_token_bit
		bcc short_block		; short block -> 110

single_byte	lsr bl			; single byte -> 111
		lda #$10
@		pha
		jsr get_token_bit
		pla
		rol @
		bcc @-
		beq write
		jmp len01

aPL_done	ldx #0
@sp		equ *-1

		jmp @exit

short_block	jsr GET_BYTE
		lsr @
		beq aPL_done
		sta EBPL
		ldx #0
		stx EBPH
		ldx #$02
		bcc @+
		inx
@		sec
		ror  bl
		jmp len0203

block		jsr getgamma
		dex
		lda #$ff
bl		equ *-1
		bmi normalcodepair
		dex
		bne normalcodepair
		jsr getgamma
		lda #$ff
EBPL		equ *-1
		sta offsetL
		lda #$ff
EBPH		equ *-1
		sta offsetH
		jmp lenffff

normalcodepair	dex
		stx offsetH
		stx EBPH
		jsr GET_BYTE
		sta offsetL
		sta EBPL
		jsr getgamma
		lda offsetH
		beq _ceck7f
		cmp #$7d
		bcs  plus2
		cmp #$05
		bcs  plus1
		bcc normal1	; zawsze
_ceck7f		lda offsetL
		bmi normal1
plus2		inx
		bne plus1
		iny
plus1		inx
		bne normal1
		iny
normal1
lenffff		iny
		sec
		ror bl
		bne domatch	; zawsze

getgamma	lda #$00
		pha
		lda #$01
		pha
@		jsr get_token_bit
		tsx
		rol $101,x
		rol $102,x
		jsr get_token_bit
		bcs @-
		pla
		tax
		pla
		tay
		rts

get_token_bit	lda #$ff
token		equ *-1
		asl @
		bne @+
		php
		jsr GET_BYTE
		plp
		rol @
@		sta token
		rts

store		sta $ffff
dest_ap		equ *-2
		inw dest_ap
		rts

len01		ldx #$01
len0203		ldy #$01
		sta offsetL
		lda #0
		sta offsetH

domatch		lda dest_ap
		sec
		sbc #$ff
offsetL		equ *-1
		sta src
		lda dest_ap+1
		sbc #$ff
offsetH		equ *-1
		sta src+1
source		lda $ffff
src		equ *-2
		inw src
		jsr store
		dex
		bne source
		dey
		bne source
		jmp nxt_token

GET_BYTE	lda $ffff
		inw GET_BYTE+1
		rts
end;

end.
