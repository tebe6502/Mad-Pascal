uses crt;

var
  n: byte;

begin
  randomize;
  writeln;
  for n:=0 to 5 do begin
    writeln;
    writeln('random(0) = ', Random(0));
    writeln('random(100) = ', Random(100));
  end;
  repeat until keypressed;

end.
