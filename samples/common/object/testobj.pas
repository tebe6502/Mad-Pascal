// 1023

program testobj;

type
  TFoo = object
    X,Y: Byte;
    P: Word;
    procedure Test;
  end;

procedure TFoo.Test;
begin
  if P < 4 then
    WriteLn('Wrong');

  WriteLn(P);
end;

var
  R: TFoo;

begin
  R.P := 1023;
  R.Test;
  ReadLn;
end.

