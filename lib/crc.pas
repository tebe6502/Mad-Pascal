unit crc;
(*
* @type: unit
* @author: Piotr Fusik, Tomasz Biela
* @name: CRC
*
* @version: 1.0
*
* @description:
* compute the CRC-32 of a data stream
*
* <https://github.com/graemeg/freepascal/blob/master/packages/hash/src/crc.pas>
*
* <https://emn178.github.io/online-tools/crc32.html>
*)

{

crc32

}

interface

	function crc32(crc: cardinal; buf: Pbyte; len: word): cardinal; register;

implementation

var	table_0, table_1, table_2, table_3: array [0..255] of byte;


procedure make_table; assembler;
(*
@description:
*)
asm
POLYNOMIAL	=	$EDB88320

tmp1	= eax
tmp2	= eax+1
sreg	= eax+2

	txa:pha

	ldx	#0
@L1:    lda	#0
	sta	tmp2
	sta	sreg
	sta	sreg+1
	ldy	#8
	txa
@L2:    sta	tmp1
	lsr	@
	bcc	@L3
	lda	sreg+1
	lsr	@
	eor	#(POLYNOMIAL>>24)&$FF
	sta	sreg+1
	lda	sreg
	ror	@
	eor	#(POLYNOMIAL>>16)&$FF
	sta	sreg
	lda	tmp2
	ror	@
	eor	#(POLYNOMIAL>>8)&$FF
	sta	tmp2
	lda	tmp1
	ror	@
	eor	#POLYNOMIAL&$FF
	bcs	@L4	; branch always
@L3:    rol	@
	lsr	sreg+1
	ror	sreg
	ror	tmp2
	ror	@
@L4:    dey
	bne	@L2
	sta	adr.table_0,x
	lda	tmp2
	sta	adr.table_1,x
	lda	sreg
	sta	adr.table_2,x
	lda	sreg+1
	sta	adr.table_3,x
	inx
	bne	@L1
RET:
	pla:tax
end;


function crc32(crc: cardinal; buf: Pbyte; len: word): cardinal; register;
(*
@description:
*)
begin

  crc:=crc xor $ffffffff;

  while (len > 0) do
  begin

    asm
	ldy #$00
	lda CRC
	eor (buf),y
	tay

	lda adr.TABLE_0,y
	eor CRC+1
	sta CRC

	lda adr.TABLE_1,y
	eor CRC+2
	sta CRC+1

	lda adr.TABLE_2,y
	eor CRC+3
	sta CRC+2

	lda adr.TABLE_3,y
	sta CRC+3
    end;

    inc(buf);
    dec(len);
  end;

 Result:=crc xor $ffffffff;

end;


initialization

 make_table;

end.
