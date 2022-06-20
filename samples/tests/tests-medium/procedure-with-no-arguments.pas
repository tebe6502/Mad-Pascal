{ Test: Procedures with no arguments.
  This program computes the sum 1+2+...+10 = 55. }

program bar;
var
  sum,x: integer;

procedure f;
  begin
    if x<>0 then
       begin
         sum:=sum+x;
         x:=x-1;
         f;
       end;
  end;


begin
  sum:=0;
  x:=10;
  f;
  writeln(sum);

  while true do;
end.
