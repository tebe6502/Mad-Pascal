

uses crt;

type
  Box = record x: Byte end;
  BoxPtr = ^Box;

var data: array [0 .. 1] of Byte;

procedure DoSomething(p: Pointer);
begin
  BoxPtr(p)^.x := BoxPtr(p)^.x + 1;
end;

begin
  data[0] := 10;  data[1] := 20;

  DoSomething(@data);
  WriteLn(data[0], ' ', data[1]);

  ReadKey();
end.
