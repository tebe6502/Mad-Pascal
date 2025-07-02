{ Test: Functions with no arguments.
  This program computes the sum 1+2+...+10 = 55. }

program bar;
var
  x:integer;

function f:integer;
  begin
    if x<>0 then
       begin
         x:=x-1;
         f:=x+f;
       end
    else
      f:=x;
  end;

begin
  x:=11;

  writeln(f);

  while true do;
end.
