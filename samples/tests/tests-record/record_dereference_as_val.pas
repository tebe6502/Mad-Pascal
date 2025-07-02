// https://github.com/tebe6502/Mad-Pascal/issues/78

{
  Expected result: 6
}


uses crt;

type
  TRecord = record x, y: Byte end;
  TRecordPtr = ^TRecord;

var
  r: TRecord;
  p: ^TRecord;

procedure PrintProduct(p1: TRecordPtr);
begin
  WriteLn(p1^.x * p1^.y);
end;

begin
  r.x := 2;
  r.y := 3;
  p := @r;

  PrintProduct(p);

  ReadKey();
end.
