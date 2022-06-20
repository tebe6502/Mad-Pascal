uses crt;

type
  TRecord = record x, y: Byte end;

var
  a: array [0..1] of Byte = (2, 3);
  p: ^TRecord = @a;

begin
  WriteLn((p <> Nil) and (p = @a));

  writeln(hexStr(word(@a),4));

  writeln(hexStr(word(p),4));

  repeat until KeyPressed();
end.