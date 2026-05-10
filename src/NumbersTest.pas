unit NumbersTest;

interface

procedure Test;


implementation

uses Asserts, DataTypes, Numbers, SysUtils;

procedure AssertNumberEquals(const actual, expected: TNumber);
begin
  Assert(actual = expected, Format('The actual number ''%x'' is not equal to the expected number ''%x''.',
    [actual, expected]));
  WriteLn(Format('The actual number ''%x'' is equal to the expected number ''%x''.', [actual, expected]));
end;


procedure TestOperations(const ResultDataType: TDataType;
  const Number1, Number2, AddResult, SubtractResult, MultiplyResult, DivideResult: TNumber);
var
  Result: TNumber;
begin
  Result := Add(ResultDataType, Number1, Number2);
  AssertNumberEquals(Result, AddResult);
  Result := Subtract(ResultDataType, Number1, Number2);
  AssertNumberEquals(Result, SubtractResult);
  Result := Multiply(ResultDataType, Number1, Number2);
  AssertNumberEquals(Result, MultiplyResult);
  Result := Divide(ResultDataType, Number1, Number2);
  AssertNumberEquals(Result, DivideResult);
end;

procedure TestOperationsFor(const IntegerValue1, IntegerValue2: Int64);
begin

  TestOperations(TDataType.INTEGERTOK, IntegerValue1, IntegerValue2, IntegerValue1 + IntegerValue2,
    IntegerValue1 - IntegerValue2, IntegerValue1 * IntegerValue2, System.Trunc(IntegerValue1 / IntegerValue2));

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

  TestOperationsFor(4, 2);

  TestOperationsFor(IntegerValue1, IntegerValue2);


  IntegerNumber2 := FromInt64(IntegerConstant2);
  SingleNumber2 := FromSingle(876.54321);

  // SingleResult := Add(TDataType.SINGLETOK, IntegerNumber1, IntegerNumber2);
  // ExpectedSingleResult:=CastToReal(FromInt64(IntegerConstant1 + IntegerConstant2));
  //  AssertNumberEquals(SingleResult, ExpectedSingleResult);
  // function Subtract(const valType: TDataType; const a: TNumber; const b: TNumber): TNumber;

end;

end.
