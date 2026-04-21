unit snappy;
(*
 @type: unit
 @author: Xelitan, Norbert Orzechowicz, Tomasz Biela (Mad Pascal)
 @name: Snappy decompressor

 @version: 1.3

 @description:
 <https://github.com/Xelitan/Snappy-decompressor-in-Pure-Pascal>

 <https://github.com/google/snappy/blob/main/format_description.txt>
*)

{
MIT License

Copyright (c) 2025 Xelitan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
}

interface

const
  [striped] WORD_MASK: array[0..4] of Cardinal = (0, $FF, $FFFF, $FFFFFF, $FFFFFFFF);

  procedure SnappyDecode(InStream, OutStream: PByte); register;

implementation

procedure SnappyDecode(InStream, OutStream: PByte); register;
var Offset: Cardinal;
    OutPos: Word;
    UncompressedLength: Integer;

    Buf: array[0..3] of Byte;

    C, SmallLen: Byte;

    TempLen: Word;

    Len: Word register;

    i: Word register;

    OutPosition: PByte register;


  function ReadUncompressedLength: Integer;
  var Res, Val, Hlp: Word;
      C, Shift: Byte;
  begin
    Res := 0;
    Shift := 0;
    while Shift < 32 do begin
      C := InStream[0];

      inc(InStream);

      Val := C and $7F;
      Hlp := Val shl Shift;
      if (Hlp shr Shift) <> Val then Exit(-1);
      Res := Res or Hlp;
      if C < 128 then Exit(Res);
      Inc(Shift, 7);
    end;
    Result := -1;
  end;


begin

  UncompressedLength := ReadUncompressedLength;
  if UncompressedLength <= 0 then Exit;

  OutPos := 0;

  while OutPos < Word(UncompressedLength) do begin
    C := InStream[0];

    inc(InStream);

    if (C and $3) = 0 then begin
      // Handle literal
      Len := byte((C shr 2) + 1);

      if byte(Len) > 60 then begin
        SmallLen := Len - 60;

	for i:=0 to byte(SmallLen-1) do begin
	 Buf[i] := InStream[0];

	 inc(InStream);
	end;

        TempLen := Buf[0];
        //for i:=1 to SmallLen-1 do TempLen := TempLen or (Cardinal(Buf[i]) shl (i shl 3));

	case SmallLen of

	 2: TempLen := TempLen or (Buf[1] shl (1 shl 3));

	 3: TempLen := TempLen or (Buf[1] shl (1 shl 3)) or (Buf[2] shl (2 shl 3));

	 4: TempLen := TempLen or (Buf[1] shl (1 shl 3)) or (Buf[2] shl (2 shl 3)) or (Buf[3] shl (3 shl 3));

	end;

        Len := (TempLen and WORD_MASK[SmallLen]) + 1;
      end;

      //if InSize - InPosition < Len then Exit(False);

      for i:=Len-1 downto 0 do begin
       OutStream[0] := InStream[0];

       inc(InStream);
       inc(OutStream);
      end;

      Inc(OutPos, Len);
    end
    else begin
      // Handle copy
      case C and $3 of
       1: begin
            Len := byte(((C shr 2) and $7) + 4);

            Offset := InStream[0] or ((C shr 5) shl 8);

	    inc(InStream);
          end;
       2: begin
            Len := byte((C shr 2) + 1);

	    Offset := PWord(InStream)^;

	    inc(InStream, 2);
          end;
       3: begin
            Len := byte((C shr 2) + 1);

	    Offset := PCardinal(InStream)^;

	    inc(InStream, 4);
          end;
      end;

//      if (Offset = 0) or (Offset > OutPos) then Exit;

      OutPosition := OutStream - Offset;

      for i:=byte(Len-1) downto 0 do begin
	OutStream[0] := OutPosition[0];

	inc(OutPosition);
	inc(OutStream);
      end;

      Inc(OutPos, Len);
    end;
  end;

end;

end.
