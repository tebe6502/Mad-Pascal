uses crt;

var
  t: array [0..1, 0..3] of Float16;

procedure Add(x, y, s: Float16);
var k: Byte = 0;
begin
  t[k,0] := x + s;
  t[k,1] := y + s;
  t[k,2] := t[k,0];
  t[k,3] := t[k,1];
end;

procedure Print;
var j: Byte;
begin
  for j := 0 to 3 do begin
    WriteLn(j, ' ', t[0,j]);
  end;
end;

begin
  Add(10, 20, 5);
  Print;

  ReadKey();
end.
