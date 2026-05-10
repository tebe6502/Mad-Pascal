unit NumbersTest;

interface

procedure Test;


implementation

uses Asserts, DataTypes, Numbers, SysUtils, UnitTests;

procedure AssertNumberEquals(const actual, expected: TNumber; const expression: String);
begin
  Assert(actual = expected, Format('The actual number ''%x'' is not equal to the expected number ''%x'' in %s.',
    [actual, expected, expression]));
  // WriteLn(Format('The actual number ''%x'' is equal to the expected number ''%x'' in %s.',
  //  [actual, expected, expression]));
end;


procedure TestOperations(const NumberString1, NumberString2, Context: String;
  const ResultDataType: TDataType; const Number1, Number2, AddResult, SubtractResult,
  MultiplyResult, DivideResult: TNumber);
var
  Result: TNumber;
begin
  Result := Add(ResultDataType, Number1, Number2);
  AssertNumberEquals(Result, AddResult, Format('Add(%s,%s) in %s', [NumberString1, NumberString2, Context]));
  Result := Subtract(ResultDataType, Number1, Number2);
  AssertNumberEquals(Result, SubtractResult, Format('Subtract(%s,%s) in %s', [NumberString1, NumberString2, Context]));
  Result := Multiply(ResultDataType, Number1, Number2);
  AssertNumberEquals(Result, MultiplyResult, Format('Multiply(%s,%s) in %s', [NumberString1, NumberString2, Context]));
  Result := Divide(ResultDataType, Number1, Number2);
  AssertNumberEquals(Result, DivideResult, Format('Divide(%s,%s) in %s', [NumberString1, NumberString2, Context]));
end;

procedure TestOperationsForIntegerValue(const IntegerValue1, IntegerValue2: Int64);
begin

  TestOperations(IntToStr(IntegerValue1), IntToStr(IntegerValue2), 'Integer Value as INTEGERTOK',
    TDataType.INTEGERTOK, IntegerValue1,
    IntegerValue2, IntegerValue1 + IntegerValue2,
    IntegerValue1 - IntegerValue2, IntegerValue1 * IntegerValue2, IntegerValue1 div IntegerValue2);

  TestOperations(IntToStr(IntegerValue1), IntToStr(IntegerValue2), 'Integer Value as REALTOK',
    TDataType.REALTOK, FromInt64(IntegerValue1), FromInt64(IntegerValue2),
    FromInt64(IntegerValue1 + IntegerValue2), FromInt64(IntegerValue1 - IntegerValue2),
    FromInt64(IntegerValue1 * IntegerValue2), FromSingle(IntegerValue1 / IntegerValue2));
end;


procedure TestOperationsForSingleValue(const SingleValue1, SingleValue2: Single);
begin

  TestOperations(FloatToStr(SingleValue1), FloatToStr(SingleValue2), 'Single Value as SINGLETOK',
    TDataType.SINGLETOK, FromSingle(SingleValue1), FromSingle(SingleValue2),
    FromSingle(SingleValue1 + SingleValue2), FromSingle(SingleValue1 - SingleValue2),
    FromSingle(SingleValue1 * SingleValue2), FromSingle(SingleValue1 / SingleValue2));
end;

procedure Test;
const
  IntegerConstant1 = 87654; //320;
  IntegerConstant2 = 12345; //678;
var
  IntegerValue1: Int64;
  IntegerValue2: Int64;

  SingleNumber1: TNumber;
  RealNumber1: TNumber;
  HalfSingleNumber1: TNumber;
begin
  StartTest('NumbersTest.Test');

  IntegerValue1 := IntegerConstant1;
  IntegerValue2 := IntegerConstant2;

  TestOperationsForIntegerValue(4, 2);
  TestOperationsForIntegerValue(IntegerValue1, IntegerValue2);

  TestOperationsForSingleValue(4.0, 2.0);

  // https://www.h-schmidt.net/FloatConverter/IEEE754.html
  SingleNumber1 := FromSingle(123.45678);
  AssertEquals(SingleNumber1, $42F6E9DF00007B75);
  RealNumber1 := CastToReal(SingleNumber1);
  AssertEquals(RealNumber1, $00007B75);
  HalfSingleNumber1 := CastToHalfSingle(SingleNumber1);
  AssertEquals(HalfSingleNumber1, $57B8);

  EndTest('NumbersTest.Test');
end;

end.
