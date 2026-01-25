unit StringUtilitiesTest;

interface

procedure Test;

implementation

uses Asserts, StringUtilities;

procedure Test;
var
  s: String;
  i: Integer;
begin

  s := '   12345 67890';
  i := 1;
  AssertEquals(StringUtilities.GetNumber(s, i), '12345');

  s := 'danaBank extmem ''dana_bank.obx''';
  i := 32;
  AssertEquals(StringUtilities.GetNumber(s, i), '');
end;


end.
