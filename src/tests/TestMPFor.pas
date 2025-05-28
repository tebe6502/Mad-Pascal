// Mad-Pascal Test Program

// Ensure that the new Mad-Pascal Version compiles correctly to .a65

program TestMPFor;

uses
  Crt;

  procedure AssertEquals(actual, expected: Integer); overload;
  begin
    if (actual = expected) then
    begin
      Writeln('OK: ');
    end
    else
    begin

      WriteLn('The actual value ''', actual, ''' is not equal to the expected value ''',
        expected, '''.');
    end;
  end;

var
  i, j: Integer;

begin

  j := 1;
  for i := 1 to 10 do
  begin
    AssertEquals(i, j);
    j := j + 1;
  end;
  AssertEquals(i, 10);
end.
