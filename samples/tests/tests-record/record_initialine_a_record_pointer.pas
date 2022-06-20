// https://github.com/tebe6502/Mad-Pascal/issues/76

{

 8585
 2 3

}

uses crt;

type
  TRecord = record x, y: Byte end;

var
  a: array [0..1] of Byte = (2, 3);
  p: ^TRecord = @a;   // (1)

begin
  // p := @a;   // (2)

  WriteLn(Word(@a));
  WriteLn(a[0], ' ', a[1]);
  WriteLn;
  WriteLn(Word(p));
  WriteLn(p^.x, ' ', p^.y);

  ReadKey();
end.
