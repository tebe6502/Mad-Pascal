unit objects;
(*
 @type: unit
 @author: Tomasz Biela (Tebe)
 @name: Standard base objects
 @version: 1.0

 @description:
 This unit implements Memory stream objects.
 
 *)


{

http://www.freepascal.org/docs-html/rtl/objects/index-4.html

+ TMemoryStream : Object

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

type	TMemoryStream = Object
	(*
	@description:

	*)

	Position: cardinal;
	Size: cardinal;

	procedure Create;
	procedure ReadBuffer(var Buffer; Count: word); register; assembler;
	procedure WriteBuffer(var Buffer; Count: word); register; assembler;

	function ReadByte: Byte; assembler;
	function ReadWord: Word; assembler;
	function ReadDWord: Cardinal; assembler;

	procedure WriteByte(b: Byte); assembler;
	procedure WriteWord(w: Word); assembler;
	procedure WriteDWord(d: Cardinal); assembler;

	end;


implementation

var bank: byte;


procedure TMemoryStream.Create;
(*
@description:
*)
begin

 Size := bank shl 14;	// * 16384
 Position := 0;

end;


procedure TMemoryStream.ReadBuffer(var Buffer; Count: word); register; assembler;
(*
@description:
*)
asm
{	lda Count
	ora Count+1
	beq skp

	mwa position cx+2
	jsr @xmsReadBuf
skp
};
end;


procedure TMemoryStream.WriteBuffer(var Buffer; Count: word); register; assembler;
(*
@description:
*)
asm
{	lda Count
	ora Count+1
	beq skp

	mwa position cx+2
	jsr @xmsWriteBuf
skp
};
end;


function TMemoryStream.ReadByte: Byte; assembler;
(*
@description:
*)
asm
{	mwa position cx+2
	@xmsReadBuf #Result #1
};
end;


function TMemoryStream.ReadWord: Word; assembler;
(*
@description:
*)
asm
{	mwa position cx+2
	@xmsReadBuf #Result #2
};
end;


function TMemoryStream.ReadDWord: Cardinal; assembler;
(*
@description:
*)
asm
{	mwa position cx+2
	@xmsReadBuf #Result #4
};
end;


procedure TMemoryStream.WriteByte(b: Byte); assembler;
(*
@description:
*)
asm
{	mwa position cx+2
	@xmsWriteBuf #b #1
};
end;


procedure TMemoryStream.WriteWord(w: Word); assembler;
(*
@description:
*)
asm
{	mwa position cx+2
	@xmsWriteBuf #w #2
};
end;


procedure TMemoryStream.WriteDWord(d: Cardinal); assembler;
(*
@description:
*)
asm
{	mwa position cx+2
	@xmsWriteBuf #d #4
};
end;


initialization

bank := DetectMem;

end.

