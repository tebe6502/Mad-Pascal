unit Assembler;

// TODO Check other locations that still use IntToHex/IntToStr

interface


// Decimal output of signed integer.
function IntToDec(const Value: Int64): String;

// Hexadecimal output of 8-Bit with '$' prefix, 2 digits
function HexByte(const Value: Byte): String;

// Hexadecimal output of 16-Bit with '$' prefix, 4 digits
function HexWord(const Value: Word): String;

// Hexadecimal output of 32/64-Bit with '$' prefix, minimum lenght 8 digit
function HexLongWord(const Value: Int64): String;


// ----------------------------------------------------------------------------

implementation

uses SysUtils;

const
  MAX_DECIMAL_VALUE = 1023;

var
  DecimalStringArray: array[0..MAX_DECIMAL_VALUE] of String;

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

function IntToDec(const Value: Int64): String;
begin
  if (Value >= Low(DecimalStringArray)) and (Value <= High(DecimalStringArray)) then
  begin
    Result := DecimalStringArray[Value];
  end
  else
  begin
    Result := IntToStr(Value);
  end;
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

function HexLongWord(const Value: Int64): String;
begin
  if Value < $100000000 then
    Result := '$' + HexBytes[(Value shr 24) and $ff] + HexBytes[(Value shr 16) and $ff] +
      HexBytes[(Value shr 8) and $ff] + HexBytes[Value and $ff]
  else
    Result := IntToHex(Value, 8);
  // DoCount;
end;

procedure InitializeStrings;
var
  i: Integer;
begin
  for i := Low(DecimalStringArray) to High(DecimalStringArray) do
  begin
    DecimalStringArray[i] := IntToStr(i);
  end;

  for i := Low(HexBytes) to High(HexBytes) do
  begin
    HexBytes[i] := Hex(i, 2);
  end;
  Count := 0;
end;


initialization

  InitializeStrings;

end.
