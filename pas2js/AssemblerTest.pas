unit AssemblerTest;

interface

procedure Test;

implementation

uses Assembler, Asserts, Common, Tokens;

procedure Test;


  procedure TestGetVAL(const s: String; const ExpectedValue: Integer);
  var
    ActualValue: Integer;
  begin
    ActualValue := Assembler.GetVAL(s);
    AssertEquals(ActualValue, ExpectedValue);
  end;

begin

  AssertEquals(Assembler.HexByte(Byte($00)), '$00');
  AssertEquals(Assembler.HexByte(Byte($0f)), '$0F');
  AssertEquals(Assembler.HexByte(Byte($80)), '$80');
  AssertEquals(Assembler.HexByte(Byte($ff)), '$FF');


  AssertEquals(Assembler.HexWord(Word($0000)), '$0000');
  AssertEquals(Assembler.HexWord(Word($000f)), '$000F');
  AssertEquals(Assembler.HexWord(Word($8000)), '$8000');
  AssertEquals(Assembler.HexWord(Word($ffee)), '$FFEE');


  AssertEquals(Assembler.HexLongWord($00), '$00000000');
  AssertEquals(Assembler.HexLongWord($ffeeddcc), '$FFEEDDCC');


  AssertEquals(HexLongWord($00123456), '$00123456');

  TestGetVAL('', -1);
  TestGetVAL('1234', -1);
  TestGetVAL('$1234', -1);
  TestGetVAL('#1234', 1234);
  TestGetVAL('#$1234', $1234);
  TestGetVAL('#-1234', -1234);
  TestGetVAL('#-$1234', -$1234);

end;

end.
