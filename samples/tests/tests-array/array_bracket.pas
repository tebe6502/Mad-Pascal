program array_bracket;

// Verification test for https://forums.atariage.com/topic/240919-mad-pascal/page/41/#findComment-5721582
// array_bracket.pas (14,38) Error: Syntax error, '[' expected but ')' found

type
  TCHRIMAG = array[0..7] of 0..255;

var
  CHARSET: array[0..63] of TCHRIMAG;

  procedure PRGRCHR(var A1: TCHRIMAG); external;

  procedure PRINTCHR(ACHAR: Char);

  begin
    PRGRCHR(CHARSET[Ord(ACHAR) - 32]);
  end;

begin
  PRINTCHR('A');
end.
