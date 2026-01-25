unit DataTypesTest;


interface

procedure Test;

implementation

uses SysUtils, Asserts, DataTypes;

procedure AssertEquals(const actual, expected: TDataType); overload;
begin
  Assert(actual = expected, Format('The actual value ''%s'' is not equal to the expected value ''%s''.',
    [GetDataTypeName(actual), GetDataTypeName(expected)]));
end;

procedure Test;
begin
  AssertEquals(DataTypes.GetDataSize(TDataType.UNTYPETOK), 0);
  AssertEquals(DataTypes.GetDataSize(TDataType.BYTETOK), 1);
  AssertEquals(DataTypes.GetDataSize(TDataType.WORDTOK), 2);

  AssertEquals(DataTypes.GetValueType(0), TDataType.BYTETOK);
  AssertEquals(DataTypes.GetValueType(255), TDataType.BYTETOK);
  AssertEquals(DataTypes.GetValueType($ffff), TDataType.WORDTOK);
  AssertEquals(DataTypes.GetValueType(-1), TDataType.SHORTINTTOK);
end;

end.
