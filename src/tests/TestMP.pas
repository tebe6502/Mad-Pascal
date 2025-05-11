// Mad-Pascal Test Program
//
// Ensure that the new Mad-Pascal Version compiles correctly to .a65

program TestMP;

uses
  Crt, TestUnit;

{$I TestInclude.inc}

  procedure Assert(b: Boolean; s: String); overload;
  begin
    if (b) then
    begin
      Write('OK: ');
    end
    else
    begin
      Write('ERROR: ');
    end;
    Writeln(s);
  end;

  procedure AssertEquals(actual: String; expected: String); overload;
  begin
    if (actual = expected) then
    begin
      Writeln('OK: Got ''', actual, ''' = ''', expected, '''.');
    end
    else
    begin
      Writeln('ERROR: Got ''', actual, ''' but expected ''', expected, '''.');
    end;
  end;

  procedure TestExpressions;
  var
    i: Integer;
  begin
    i := 1;
    Writeln('i:=1 equals ', i);
    Inc(i);
    Writeln('Inc(i) equals ', i);
    Assert(i = 2, 'I=2');
    Assert(1 + 1 = 2, '1+1=2');
  end;

  procedure TestFloats;
  const
    FLOAT16_CONST: Float16 = 0.288675135;  { SQRT(3) / 6 }
    FLOAT16_CONST_STRING: String = '0.2890';

    REAL_CONST: Real = 0.288675135;  { SQRT(3) / 6 }
    REAL_CONST_STRING: String = '0.2890';

    SINGLE_CONST: Single = 0.288675135;  { SQRT(3) / 6 }
    SINGLE_CONST_STRING: String = '0.2890';

  begin
    AssertEquals(FloatToStr(FLOAT16_CONST), FLOAT16_CONST_STRING);
    AssertEquals(FloatToStr(REAL_CONST), REAL_CONST_STRING);
    AssertEquals(FloatToStr(SINGLE_CONST), SINGLE_CONST_STRING);
  end;

var
  i: Integer;
var
  s, msg: String;
begin
  TestExpressions;
  TestFloats;
  AssertEquals(TestUnit.TestUnitFunction, TestUnit.TestUnitString);
  AssertEquals(TestIncludeFunction, TestIncludeString);

  Writeln('Test completed. Press any key');
  repeat
  until KeyPressed;
end.
