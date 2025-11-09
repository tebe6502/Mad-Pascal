unit Assembler;

// TODO Check other locations that still use IntToHex

interface

// 8 Bit
function HexByte(const Value: Byte): String;
// 16 bit
function HexWord(const Value: Word): String;
// 32 bit
function HexLongWord(const Value: Longword): String;

implementation

// ----------------------------------------------------------------------------

var
  HexBytes: array[0..255] of String;
  Count: Longint;

// Conversion to hexadecimal notation
// The parameter 'nibbles' specifies the maximum number of nibbles to be converted.
// This must be an even number.
// if there are any values left, continue the conversion
function Hex(Value: Cardinal; nibbles: Shortint): String;
var
  v: Byte;
const
  tHex: array [0..15] of Char =
    ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
begin
  Result := '';

  while (nibbles > 0) or (Value <> 0) do
  begin

    v := Byte(Value);
    Result := tHex[v shr 4] + tHex[v and $0f] + Result;

    Value := Value shr 8;

    Dec(nibbles, 2);
  end;

end;


// TODO JAC! Disable after optimization
procedure DoCount;
begin
  Inc(Count);
  WriteLn('DoCount: ', Count);
end;

function HexByte(const Value: Byte): String;
begin
  Result := '$' + HexBytes[Value];
end;

function HexWord(const Value: Word): String;
begin
  Result := '$' + HexBytes[(Value shr 8) and $ff] + HexBytes[Value and $ff];
  // DoCount;
end;

function HexLongWord(const Value: Longword): String;
begin
  Result := '$' + HexBytes[(Value shr 24) and $ff] + HexBytes[(Value shr 16) and $ff] +
    HexBytes[(Value shr 8) and $ff] + HexBytes[Value and $ff];
  // DoCount;
end;

procedure InitializeStrings;
var
  i: Byte;
begin
  for i := 0 to 255 do HexBytes[i] := Hex(i, 2);
  Count := 0;
end;


initialization

  InitializeStrings;

end.
