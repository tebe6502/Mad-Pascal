uses crt;

var
  t: array [0..3] of Float16;

procedure Add(x, y, s: Float16);
var k: Byte = 0;
begin
  t[k] := x + s;
  t[k+1] := y + s;
  t[k+2] := t[0];
  t[k+3] := t[1];
end;

procedure Print;
var j: Byte;
begin
  for j := 0 to 3 do begin
    WriteLn(j, ' ', t[j]);
  end;
end;

begin
  Add(10, 20, 5);
  Print;

  ReadKey();
end.
