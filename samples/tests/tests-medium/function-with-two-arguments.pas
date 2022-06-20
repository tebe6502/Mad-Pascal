{ Test: Functions with two arguments.
  This program computes the sum 1+2+...+10 = 55. }

program bar;

uses crt;

function f(sum,x:integer):integer;
  begin
    if x<>0 then
       begin
         f(sum+x,x-1);
       end
    else
      f:=sum;
  end;
begin
  writeln(f(0,10));

  repeat until keypressed;
end.
