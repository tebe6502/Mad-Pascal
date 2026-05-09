unit NumbersTest;

interface

procedure Test;


implementation

uses Asserts, DataTypes, Numbers, SysUtils;

procedure AssertNumberEquals(actual, expected: TNumber);
begin
  Assert(actual = expected, Format('The actual number ''%x'' is not equal to the expected number ''%x''.',
    [actual, expected]));
end;


procedure Test;
const

  IntegerConstant1 = 87654320;
  IntegerConstant2 = 12345678;
var
  IntegerValue1: Int64;
  IntegerValue2: Int64;

  IntegerNumber1: TNumber;
  IntegerNumber2: TNumber;
  IntegerResult: TNumber;
  ExpectedIntegerResult: TNumber;

  SingleNumber1: TNumber;
  SingleNumber2: TNumber;
  RealNumber1: TNumber;
  RealNumber2: TNumber;

  HalfSingleNumber1: TNumber;

  SingleResult: TNumber;
  ExpectedSingleResult: TNumber;

  ResultDataType: TDataType;
begin
  IntegerValue1 := IntegerConstant1;
  IntegerValue2 := IntegerConstant2;

  IntegerNumber1 := FromInt64(IntegerConstant1);
  IntegerNumber2 := FromInt64(IntegerConstant2);

  SingleNumber1 := FromSingle(123.45678);
  RealNumber1 := CastToReal(SingleNumber1);
  HalfSingleNumber1 := CastToHalfSingle(SingleNumber1);


  ResultDataType:=TDataType.INTEGERTOK;
  IntegerResult := Add(ResultDataType, IntegerValue1, IntegerValue2);
  AssertNumberEquals(IntegerResult, IntegerValue1 + IntegerValue2);
  IntegerResult := Subtract(ResultDataType, IntegerValue1, IntegerValue2);
  AssertNumberEquals(IntegerResult, IntegerValue1 - IntegerValue2);
   IntegerResult := Multiply(ResultDataType, IntegerValue1, IntegerValue2);
  AssertNumberEquals(IntegerResult, IntegerValue1 * IntegerValue2);
  // IntegerResult := Divide(ResultDataType, IntegerValue1, IntegerValue2);
  // AssertNumberEquals(IntegerResult, System.Trunc(IntegerValue1 / IntegerValue2));

  IntegerNumber2 := FromInt64(IntegerConstant2);
  SingleNumber2 := FromSingle(876.54321);

  // SingleResult := Add(TDataType.SINGLETOK, IntegerNumber1, IntegerNumber2);
  // ExpectedSingleResult:=CastToReal(FromInt64(IntegerConstant1 + IntegerConstant2));
  //  AssertNumberEquals(SingleResult, ExpectedSingleResult);
  // function Subtract(const valType: TDataType; const a: TNumber; const b: TNumber): TNumber;

end;

end.
