// Verification test for https://forums.atariage.com/topic/240919-mad-pascal/page/41/#findComment-5721582
// array_bracket.pas (14,38) Error: Syntax error, '[' expected but ')' found
TYPE
 TCHRIMAG = ARRAY[ 0..7] OF 0..255;

VAR
 CHARSET  : ARRAY[ 0..63] OF TCHRIMAG;

PROCEDURE PRGRCHR( VAR A1: TCHRIMAG); EXTERNAL;

PROCEDURE PRINTCHR( ACHAR: CHAR);

 BEGIN
  PRGRCHR( CHARSET[ ORD( ACHAR) - 32])
 END;

BEGIN
 PRINTCHR('A');
END.

