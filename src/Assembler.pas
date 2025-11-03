unit Assembler;

interface

// Conversion to hexadecimal notation
// The parameter 'nibbles' specifies the maximum number of nibbles to be converted.
// This must be an even number.
// if there are any values left, continue the conversion


// function Hex(Value: Cardinal; nibbles: Shortint): String;
function HexByte(Value: Byte): String;
function HexWord(Value: Cardinal): String;

implementation

// ----------------------------------------------------------------------------

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

  Result := '$' + Result;

end;

function HexByte(Value: Byte): String;
begin
  Result := Hex(Value, 2);
end;

function HexWord(Value: Cardinal): String;
begin
  Result := Hex(Value, 4);
end;

end.
