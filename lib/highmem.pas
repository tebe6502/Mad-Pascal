unit highmem;

{

http://www.freepascal.org/docs-html/rtl/objects/index-4.html

+ THighMemoryStream : Object

Create
ReadBuffer
ReadByte
ReadDWord
ReadWord
WriteBuffer
WriteByte
WriteDWord
WriteWord

}


interface

uses misc;

type
	THighMemoryStream = Object

	Position: cardinal;
	Size: cardinal;

	procedure Create;
	procedure ReadBuffer(var Buffer; Count: word);
	procedure WriteBuffer(var Buffer; Count: word);

	function ReadByte: Byte;
	function ReadWord: Word;
	function ReadDWord: Cardinal;

	procedure WriteByte(b: Byte);
	procedure WriteWord(w: Word);
	procedure WriteDWord(d: Cardinal);

	end;



implementation

var	bank: byte;


procedure THighMemoryStream.Create;
begin

 Size := bank shl 16;	// * 65536
 Position := 0;

end;


procedure ReadWriteHighMem; assembler;
// src = edx
// dst = ecx
// len = eax
asm
{	stx @sp

	opt c+

	ldx #0
	ldy #0

loop	lda [edx],y
	sta [ecx],y

	iny
	bne skp

	inw edx+1
	inw ecx+1

	inx

skp	cpx eax+1
	bne loop
	cpy eax
	bne loop

	opt c-

	ldx #0
@sp	equ *-1
};
end;


procedure THighMemoryStream.ReadBuffer(var Buffer; Count: word);
begin

if Count > 0 then begin

asm
{
	mwa Buffer ecx	; dst
	mva #0 ecx+2

	mwa Position eax

	ldy #0		; src
	lda (eax),y
	sta edx
	iny
	lda (eax),y
	sta edx+1
	iny
	lda (eax),y
	sta edx+2

	mwa Count eax
};
	ReadWriteHighMem;

	inc(Position, Count);
end;

end;


procedure THighMemoryStream.WriteBuffer(var Buffer; Count: word);
begin

if Count > 0 then begin

asm
{	mwa Buffer edx	; src
	mva #0 edx+2

	mwa Position eax

	ldy #0		; dst
	lda (eax),y
	sta ecx
	iny
	lda (eax),y
	sta ecx+1
	iny
	lda (eax),y
	sta ecx+2

	mwa Count eax
};
	ReadWriteHighMem;

	inc(Position, Count);
end;

end;


function THighMemoryStream.ReadByte: Byte;
begin

asm
{	opt c+
	mwa Position eax

	ldy #0
	lda (eax),y
	sta edx
	iny
	lda (eax),y
	sta edx+1
	iny
	lda (eax),y
	sta edx+2

	lda [edx]
	sta Result
	opt c-
};
	inc(Position);
end;


function THighMemoryStream.ReadWord: Word;
begin

asm
{	opt c+
	mwa position eax

	ldy #0
	lda (eax),y
	sta edx
	iny
	lda (eax),y
	sta edx+1
	iny
	lda (eax),y
	sta edx+2

	lda [edx]
	sta Result
	ldy #1
	lda [edx],y
	sta Result+1
	opt c-
};
	inc(Position, 2);
end;


function THighMemoryStream.ReadDWord: Cardinal;
begin

asm
{	opt c+
	mwa position eax

	ldy #0
	lda (eax),y
	sta edx
	iny
	lda (eax),y
	sta edx+1
	iny
	lda (eax),y
	sta edx+2

	lda [edx]
	sta Result
	ldy #1
	lda [edx],y
	sta Result+1
	ldy #2
	lda [edx],y
	sta Result+2
	ldy #3
	lda [edx],y
	sta Result+3
	opt c-
};
	inc(Position, 4);
end;


procedure THighMemoryStream.WriteByte(b: Byte);
begin

asm
{	opt c+
	mwa position eax

	ldy #0
	lda (eax),y
	sta edx
	iny
	lda (eax),y
	sta edx+1
	iny
	lda (eax),y
	sta edx+2

	lda b
	sta [edx]
	opt c-
};
	inc(Position);
end;


procedure THighMemoryStream.WriteWord(w: Word);
begin

asm
{	opt c+
	mwa position eax

	ldy #0
	lda (eax),y
	sta edx
	iny
	lda (eax),y
	sta edx+1
	iny
	lda (eax),y
	sta edx+2

	lda w
	sta [edx]
	ldy #1
	lda w+1
	sta [edx],y
	opt c-
};
	inc(Position, 2);
end;


procedure THighMemoryStream.WriteDWord(d: Cardinal);
begin

asm
{	opt c+
	mwa position eax

	ldy #0
	lda (eax),y
	sta edx
	iny
	lda (eax),y
	sta edx+1
	iny
	lda (eax),y
	sta edx+2

	lda d
	sta [edx]
	ldy #1
	lda d+1
	sta [edx],y
	iny
	lda d+2
	sta [edx],y
	iny
	lda d+3
	sta [edx],y
	opt c-
};
	inc(Position, 4);
end;


initialization

if DetectCPU = $80 then
 bank := DetectHighMem
else
 bank := 0;

end.

