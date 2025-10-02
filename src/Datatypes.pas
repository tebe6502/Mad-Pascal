unit Datatypes;

interface

uses CommonTypes, Tokens;

type
  TDataType = TTokenKind;

const
  UnsignedOrdinalTypes = [TTokenKind.BYTETOK, TTokenKind.WORDTOK, TTokenKind.CARDINALTOK];
  SignedOrdinalTypes = [TTokenKind.SHORTINTTOK, TTokenKind.SMALLINTTOK, TTokenKind.INTEGERTOK];
  RealTypes = [TTokenKind.SHORTREALTOK, TTokenKind.REALTOK, TTokenKind.SINGLETOK, TTokenKind.HALFSINGLETOK];

  IntegerTypes = UnsignedOrdinalTypes + SignedOrdinalTypes;
  OrdinalTypes = IntegerTypes + [TTokenKind.CHARTOK, TTokenKind.BOOLEANTOK, TTokenKind.ENUMTOK];

  Pointers = [TTokenKind.POINTERTOK, TTokenKind.PROCVARTOK, TTokenKind.STRINGPOINTERTOK, TTokenKind.PCHARTOK];

  AllTypes = OrdinalTypes + RealTypes + Pointers;

  StringTypes = [TTokenKind.STRINGPOINTERTOK, TTokenKind.STRINGLITERALTOK, TTokenKind.PCHARTOK];

function GetDataSize(const dataType: TDataType): Byte;
function GetValueType(Value: TInteger): TDataType;


implementation


// Data type sizes
const
  _DataSize: array [Ord(TTokenKind.BYTETOK)..Ord(TTokenKind.FORWARDTYPE)] of Byte = (
    1,  // Size = 1 BYTE
    2,  // Size = 2 WORD
    4,  // Size = 4 CARDINAL
    1,  // Size = 1 SHORTINT
    2,  // Size = 2 SMALLINT
    4,  // Size = 4 INTEGER
    1,  // Size = 1 CHAR
    1,  // Size = 1 BOOLEAN
    2,  // Size = 2 POINTER
    2,  // Size = 2 POINTER to STRING
    2,  // Size = 2 FILE
    2,  // Size = 2 RECORD
    2,  // Size = 2 OBJECT
    2,  // Size = 2 SHORTREAL
    4,  // Size = 4 REAL
    4,  // Size = 4 SINGLE / FLOAT
    2,  // Size = 2 HALFSINGLE / FLOAT16
    2,  // Size = 2 PCHAR
    4,  // Size = 4 ENUM
    2,  // Size = 2 PROCVAR
    2,  // Size = 2 TEXTFILE
    2   // Size = 2 FORWARD
    );


function GetDataSize(const dataType: TDataType): Byte;
var
  index: Byte;
begin
  index := Ord(dataType);
  if dataType = TDataType.UNTYPETOK then
  begin
    Result := 0;
  end
  else if ((index >= Low(_DataSize)) and (index <= High(_DataSize))) then
    begin
      Result := _DataSize[index];
    end
    else
    begin
      Result := 0;
      Assert(False);
    end;

end;



function GetValueType(Value: TInteger): TDataType;
begin

  if Value < 0 then
  begin

    if Value >= Low(Shortint) then Result := TDataType.SHORTINTTOK
    else
      if Value >= Low(Smallint) then Result := TDataType.SMALLINTTOK
      else
        Result := TDataType.INTEGERTOK;

  end
  else

    case Value of
      0..255: Result := TDataType.BYTETOK;
      256..$FFFF: Result := TDataType.WORDTOK;
      else
        Result := TDataType.CARDINALTOK
    end;

end;

end.
