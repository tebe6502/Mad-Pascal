{

 1 3

}

uses crt;

var t: array [0..1] of Byte;

procedure DoSomething(k: Byte);
var x1, x2: Byte;
begin
  x1 := t[k];
  // WriteLn('');   // (1)
  k := k + 1;
  x2 := t[k];

  WriteLn(x1, ' ', x2);
end;

begin
  t[0] := 1;
  t[1] := 3;

  DoSomething(0);

  repeat until keypressed;
end.
