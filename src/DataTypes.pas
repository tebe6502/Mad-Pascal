unit DataTypes;

interface

uses CommonTypes;

// TDataType uses the same constant names, but is a different enum type.
type
  TDataType = (
      {$I 'Tokens.inc'}
    );

const
  UnsignedOrdinalTypes = [TDataType.BYTETOK, TDataType.WORDTOK, TDataType.CARDINALTOK];
  SignedOrdinalTypes = [TDataType.SHORTINTTOK, TDataType.SMALLINTTOK, TDataType.INTEGERTOK];
  RealTypes = [TDataType.SHORTREALTOK, TDataType.REALTOK, TDataType.SINGLETOK, TDataType.HALFSINGLETOK];

  IntegerTypes = UnsignedOrdinalTypes + SignedOrdinalTypes;
  OrdinalTypes = IntegerTypes + [TDataType.CHARTOK, TDataType.BOOLEANTOK, TDataType.ENUMTOK];

  Pointers = [TDataType.POINTERTOK, TDataType.PROCVARTOK, TDataType.STRINGPOINTERTOK, TDataType.PCHARTOK];

  AllTypes = OrdinalTypes + RealTypes + Pointers;

  StringTypes = [TDataType.STRINGPOINTERTOK, TDataType.STRINGLITERALTOK, TDataType.PCHARTOK];

  FileTypes = [TDataType.FILETOK, TDataType.TEXTFILETOK];

  function GetDataTypeName(const dataType: TDataType): String;
  function GetDataSize(const dataType: TDataType): Byte;
  function GetValueType(const Value: TInteger): TDataType;

  function IsCommonConstType(const DstType: TDataType; const SrcType: TDataType): Boolean;

implementation


// Data type sizes
const
  _DataSize: array [Ord(TDataType.BYTETOK)..Ord(TDataType.FORWARDTYPE)] of Byte = (
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
    0,  // Size = 0 SUBRANGE
    2,  // Size = 2 DEREFERENCEARRAY
    2   // Size = 2 FORWARD
    );


  function GetDataTypeName(const dataType: TDataType): String;
  begin
    WriteStr(Result, dataType);
  end;

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
      Assert(False);  // TODO: Check why this still happens
    end;

end;



function GetValueType(const Value: TInteger): TDataType;
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

function IsCommonConstType(const DstType: TDataType; const SrcType: TDataType): Boolean;
begin

  Result := (GetDataSize(DstType) < GetDataSize(SrcType))
    // .
    or ((DstType = TDataType.REALTOK) and (SrcType <> TDataType.REALTOK))
    // .
    or ((DstType <> TDataType.REALTOK) and (SrcType = TDataType.REALTOK))
    // .
    or ((DstType = TDataType.SINGLETOK) and (SrcType <> TDataType.SINGLETOK))
    // .
    or ((DstType <> TDataType.SINGLETOK) and (SrcType = TDataType.SINGLETOK))
    // .
    or ((DstType = TDataType.HALFSINGLETOK) and (SrcType <> TDataType.HALFSINGLETOK))
    // .
    or ((DstType <> TDataType.HALFSINGLETOK) and (SrcType = TDataType.HALFSINGLETOK))
    // .
    or ((DstType = TDataType.SHORTREALTOK) and (SrcType <> TDataType.SHORTREALTOK))
    // .
    or ((DstType <> TDataType.SHORTREALTOK) and (SrcType = TDataType.SHORTREALTOK))
    // .
    or ((DstType in IntegerTypes) and (SrcType in [TDataType.CHARTOK, TDataType.BOOLEANTOK,
    TDataType.POINTERTOK, TDataType.DATAORIGINOFFSET, TDataType.CODEORIGINOFFSET, TDataType.STRINGPOINTERTOK]))
    // .
    or ((SrcType in IntegerTypes) and (DstType in [TDataType.CHARTOK, TDataType.BOOLEANTOK]));


end;

end.
