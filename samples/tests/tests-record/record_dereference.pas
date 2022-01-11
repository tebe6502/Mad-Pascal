// https://github.com/tebe6502/Mad-Pascal/issues/77

uses crt;

type
  TRecord = record x, y: Byte end;

var
  r: TRecord;
  p: ^TRecord;

procedure PrintRecord(var r1: TRecord);
begin
  WriteLn(r1.x, ' ', r1.y);
end;

begin
  r.x := 2;
  r.y := 3;
  p := @r;

  WriteLn(Word(@r));
  PrintRecord(r);
  WriteLn;
  WriteLn(Word(p));
  PrintRecord(p^);  // (1)

  ReadKey();
end.
