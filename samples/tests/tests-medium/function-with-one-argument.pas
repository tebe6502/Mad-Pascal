{ Test: Functions with one arguments.
  This program computes the sum 1+2+...+10 = 55. }
program bar;
var
  sum:integer;

function f(x:integer):integer;
  begin
    if x<>0 then
       begin
         sum:=sum+x;
         f(x-1);
       end
    else
      f:=sum;
  end;


begin
  sum:=0;
  writeln(f(10));
end.
