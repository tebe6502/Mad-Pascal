unit Assembler;

{$i define.inc}

interface


function Hex(Value: cardinal; nibbles: shortint): string;
function HexByte(Value: byte): string;
function HexWord(Value: word): string;
function GetVAL(const a: String): Integer;


// ----------------------------------------------------------------------------

implementation

const

  HexHig: array [0..255] of char = '0000000000000000111111111111111122222222222222223333333333333333444444444444444455555555555555556666666666666666777777777777777788888888888888889999999999999999AAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCDDDDDDDDDDDDDDDDEEEEEEEEEEEEEEEEFFFFFFFFFFFFFFFF';

  HexLow: array [0..255] of char = '0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF';


// ----------------------------------------------------------------------------


function Hex(Value: cardinal; nibbles: shortint): string;
(*----------------------------------------------------------------------------*)
(*  zamiana na zapis hexadecymalny                                            *)
(*  'B' okresla maksymalna liczbe nibbli do zamiany                           *)
(*  jesli sa jeszcze jakies wartosci to kontynuuje zamiane                    *)
(*----------------------------------------------------------------------------*)
begin

 Result := '';

 while (nibbles > 0) or (Value <> 0) do begin

  Result := HexHig[byte(Value)] + HexLow[byte(Value)] + Result;

  Value := Value shr 8;

  dec(nibbles, 2);
 end;

 Result := '$' + Result;

end;


// ----------------------------------------------------------------------------


function HexByte(Value: byte): string;
begin

  SetLength(Result, 3);

  Result[1] := '$';

  Result[2] := HexHig[Value];
  Result[3] := HexLow[Value];

end;


// ----------------------------------------------------------------------------


function HexWord(Value: word): string;
begin

  SetLength(Result, 5);

  Result[1] := '$';

  Result[4] := HexHig[byte(Value)];
  Result[5] := HexLow[byte(Value)];

  Value := Value shr 8;

  Result[2] := HexHig[byte(Value)];
  Result[3] := HexLow[byte(Value)];

end;


// ----------------------------------------------------------------------------


function GetVAL(const a: String): Integer;
var
  err: Integer;
begin

  Result := -1;

  if a <> '' then
    if a[1] = '#' then
    begin
      val(copy(a, 2, length(a)), Result, err);

      if err > 0 then Result := -1;

    end;

end;

// ----------------------------------------------------------------------------


end.
