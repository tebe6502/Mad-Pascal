
type	TVBXEMemoryStream = Object
	(*
	@description:

	*)

	Position: cardinal;
	Size: cardinal;			// 0..Size-1

	procedure Create;

	procedure Clear;
	procedure SetBank;

	procedure ReadBuffer(var Buffer; Count: word);
	procedure WriteBuffer(var Buffer; Count: word);

	function ReadByte: Byte;
	function ReadWord: Word;
	function ReadDWord: Cardinal;

	procedure WriteByte(b: Byte);
	procedure WriteWord(w: Word);
	procedure WriteDWord(d: Cardinal);

	end;
