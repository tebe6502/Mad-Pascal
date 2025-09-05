
procedure VBXEMemoryBank(b: byte); assembler;
(*
@description:

*)
asm
	fxs FX_MEMS b
end;


function ReadVBXEMemoryByte(var Position: cardinal): byte;
(*
@description:

*)
var bnk: byte;
    adr: word;
begin
	bnk:=Position shr 12 or $80;
	adr:=Position and $0fff or VBXE_WINDOW;

	VBXEMemoryBank(bnk);

	Result:=peek(adr);

	inc(Position);
end;


procedure WriteVBXEMemoryByte(var Position: cardinal; a: byte);
(*
@description:

*)
var bnk: byte;
    adr: word;
begin
	bnk:=Position shr 12 or $80;
	adr:=Position and $0fff or VBXE_WINDOW;

	VBXEMemoryBank(bnk);

	poke(adr, a);

	inc(Position);
end;


procedure TVBXEMemoryStream.Create;
(*
@description:

*)
begin

 Position := 0;
 Size:= 512*1024;

end;


procedure TVBXEMemoryStream.SetBank;
(*
@description:

*)
var bnk: byte;
    adr: word;
begin
	bnk:=Position shr 12 or $80;
	adr:=Position and $0fff or VBXE_WINDOW;

	VBXEMemoryBank(bnk);
end;


procedure TVBXEMemoryStream.ReadBuffer(var Buffer; Count: word);
(*
@description:

*)
var bnk: byte;
    i: word;
    src: PByte register;
    dst: PByte register;
begin
	bnk:=Position shr 12 or $80;
	src:=pointer(Position and $0fff or VBXE_WINDOW);

	VBXEMemoryBank(bnk);

	dst:=@Buffer;

	for i:=Count-1 downto 0 do begin

	 dst[0]:=src[0];

	 inc(src);
	 inc(dst);

	 if word(src)>=VBXE_WINDOW+$1000 then begin
	  inc(bnk);
	  VBXEMemoryBank(bnk);
	  src:=pointer(VBXE_WINDOW);
	 end;

	end;

	VBXEMemoryBank(0);

	inc(Position, Count);
end;


procedure TVBXEMemoryStream.WriteBuffer(var Buffer; Count: word);
(*
@description:

*)
var bnk: byte;
    i: word;
    dst: PByte register;
    src: PByte register;
begin
	bnk:=Position shr 12 or $80;
	dst:=pointer(Position and $0fff or VBXE_WINDOW);

	VBXEMemoryBank(bnk);

	src:=@Buffer;

	for i:=Count-1 downto 0 do begin

	 dst[0]:=src[0];

	 inc(dst);
	 inc(src);

	 if word(dst) >= VBXE_WINDOW+$1000 then begin
	  inc(bnk);
	  VBXEMemoryBank(bnk);
	  dst:=pointer(VBXE_WINDOW);
	 end;

	end;

	VBXEMemoryBank(0);

	inc(Position, Count);
end;


function TVBXEMemoryStream.ReadByte: Byte;
(*
@description:

*)
begin
	Result := ReadVBXEMemoryByte(Position);

	VBXEMemoryBank(0);
end;


function TVBXEMemoryStream.ReadWord: Word;
(*
@description:

*)
begin
	Result := ReadVBXEMemoryByte(Position);
	Result := Result + ReadVBXEMemoryByte(Position) shl 8;

	VBXEMemoryBank(0);
end;


function TVBXEMemoryStream.ReadDWord: Cardinal;
(*
@description:

*)
begin
	Result := ReadVBXEMemoryByte(Position);
	Result := Result + ReadVBXEMemoryByte(Position) shl 8;
	Result := Result + ReadVBXEMemoryByte(Position) shl 16;
	Result := Result + ReadVBXEMemoryByte(Position) shl 24;

	VBXEMemoryBank(0);
end;


procedure TVBXEMemoryStream.WriteByte(b: Byte);
(*
@description:

*)
begin
	WriteVBXEMemoryByte(Position, b);

	VBXEMemoryBank(0);
end;


procedure TVBXEMemoryStream.WriteWord(w: Word);
(*
@description:

*)
begin
	WriteVBXEMemoryByte(Position, w);
	WriteVBXEMemoryByte(Position, w shr 8);

	VBXEMemoryBank(0);
end;


procedure TVBXEMemoryStream.WriteDWord(d: Cardinal);
(*
@description:

*)
begin
	WriteVBXEMemoryByte(Position, d);
	WriteVBXEMemoryByte(Position, d shr 8);
	WriteVBXEMemoryByte(Position, d shr 16);
	WriteVBXEMemoryByte(Position, d shr 24);

	VBXEMemoryBank(0);
end;


procedure TVBXEMemoryStream.Clear;
(*
@description:

*)
var adr, siz: cardinal;
begin
	adr:=Position;
	siz:=Size;
asm
	txa:pha

	mva adr _adr
	mva adr+1 _adr+1
	mva adr+2 _adr+2

	fxs FX_MEMS #$80+MAIN.SYSTEM.VBXE_XDLADR/$1000

loop	cpw _adr+1 siz+1
	bcs skp

	ldy #20
	mva:rpl bltClr,y MAIN.SYSTEM.VBXE_WINDOW+MAIN.SYSTEM.VBXE_BCBTMP,y-

	fxs FX_BL_ADR0 #MAIN.SYSTEM.VBXE_BCBTMP	; program blittera od adresu MAIN.SYSTEM.VBXE_BCBTMP
	fxs FX_BL_ADR1 #$00			; zaraz za programem VBXE Display List
	fxsa FX_BL_ADR2

	fxs FX_BLITTER_START #$01	; !!! start gdy 1 !!!

wait	fxla FX_BLITTER_BUSY
	bne wait

	lda #$00
	sta _adr
	inw _adr+1

	jmp loop

skp	fxs FX_MEMS #$00		; disable VBXE bank

	jmp stop

bltClr	.long 0x00	; source address
	.word 0x00	; source step y
	.byte 0x00	; source step x
_adr	.long 0x00	; destination address
	.word 0x0100	; destination step y
	.byte 0x01	; destination step x
_siz	.word 0xff	; width
	.byte 0x00	; height
	dta 0x00	; and mask (and mask equal to 0, memory will be filled with xor mask)
	dta 0x00	; xor mask
	dta 0x00	; collision and mask
	dta 0x00	; zoom
	dta 0x00	; pattern feature
	dta 0x00	; control

stop	pla:tax
end;
	Position:=0;
	Size:=512*1024;
end;
