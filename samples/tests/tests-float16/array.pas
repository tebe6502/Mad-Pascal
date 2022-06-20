uses crt;

type
	TFloat = float16;

var
  t: array [0..1, 0..2] of TFloat;

  f: TFloat;

procedure Add(x, y: TFloat);
  var k: SmallInt = 0;
begin
  t[k,0] := x;
  t[k,1] := y;
  t[k,2] := t[k,0] + t[k,1];
end;

procedure Print;
begin
  WriteLn(t[0,0], ' ', t[0,1], ' ', t[0,2]);
end;

begin

  Add(1, 2);
  Print;

  ReadKey();
end.
