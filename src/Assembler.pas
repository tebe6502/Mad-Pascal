unit Assembler;

// TODO Check other locations that still use IntToHex/IntToStr

interface

// Hexadecimal output of 8-Bit with '$' prefix, 2 digits
function HexByte(const Value: Byte): String; overload;
function HexByte(const Value: Int64): String; overload; // For detecting missing downcasts

// Hexadecimal output of 16-Bit with '$' prefix, 4 digits
function HexWord(const Value: Word): String; overload;
function HexWord(const Value: Int64): String; overload; // For detecting missing downcasts
function HexWord2(const Value: Word): String;

// Hexadecimal output of 32/64-Bit with '$' prefix, minimum lenght 8 digit
function HexLongWord(const Value: Int64): String;


// ----------------------------------------------------------------------------

implementation

uses SysUtils;

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

function HexByte(const Value: Byte): String; overload;
begin
  Result := '$' + HexBytes[Value];
end;


function HexByte(const Value: Int64): String; overload;
const
  msg = 'HexByte() called with argument datatype larger than Byte';
begin
  Writeln('ERROR: ', msg);
  Assert(False, msg);
  Result := '$??';
end;

function HexWord(const Value: Word): String;
begin
  Result := '$' + HexBytes[(Value shr 8) and $ff] + HexBytes[Value and $ff];
  if value = 2 then
    begin
      // WriteLn;
      end
  // DoCount;
end;


// TODO: Temporary compatibility with Origin
function HexWord2(const Value: Word): String;
begin
  if value<$100 then Result:=HexByte(Byte(value)) else Result:=HexWord(value);
end;

function HexWord(const Value: Int64): String; overload;
const
  msg = 'HexWord() called with argument datatype larger than Word';
begin
  Writeln('ERROR: ', msg);
  Assert(False, msg);
  Result := '$????';
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
  for i := Low(HexBytes) to High(HexBytes) do
  begin
    HexBytes[i] := Hex(i, 2);
  end;
  Count := 0;
end;


initialization

  InitializeStrings;

end.
