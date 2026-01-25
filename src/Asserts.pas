unit Asserts;

interface

uses SysUtils;

procedure AssertEquals(actual, expected: String); overload;
procedure AssertEquals(actual, expected: Longint); overload;
procedure AssertEquals(actual, expected: TStringArray); overload;

implementation

procedure AssertEquals(actual, expected: String); overload;
begin
  Assert(actual = expected, Format('The actual string ''%s'' is not equal to the expected string ''%s''.',
    [actual, expected]));
end;


procedure AssertEquals(actual, expected: Longint); overload;
begin
  Assert(actual = expected, Format('The actual value ''%d'' is not equal to the expected value ''%d''.',
    [actual, expected]));
end;


procedure AssertEquals(actual, expected: TStringArray); overload;
var
  i: Integer;
begin
  Assert(Length(actual) = Length(expected),
    Format('The actual array length ''%d'' is not equal to the expected array length ''%d''.',
    [Length(actual), Length(expected)]));
  for i := Low(actual) to High(actual) do
  begin
    if (actual[i] <> expected[i]) then
    begin
      Assert(False, Format(
        'Arrays differ at index %d of [%d..%d]. The actual string ''%s'' is not equal to the expected string ''%s''.',
        [
        i, Low(actual), High(actual), actual[i], expected[i]]));
    end;
  end;
end;

end.
