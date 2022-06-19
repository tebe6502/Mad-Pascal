{
 10
 20
}

uses crt;

type BytePtr = ^Byte;

var
  data: array [0 .. 1] of Byte;
  p: BytePtr;

procedure DoSomething(var p2: pointer);
begin
  p2 := p2 + 1;
end;

begin
  data[0] := 10;  data[1] := 20;

  p := @data;

  Write(p^);
  DoSomething(p);
  WriteLn(' ', p^);

  ReadKey();
end.

