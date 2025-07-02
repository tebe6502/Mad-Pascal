{ Test: Procedures with two arguments. 
  This program computes the sum 1+2+...+10 = 55. }
program bar;
var
  result:integer;

procedure f(sum,x:integer);
  begin
    if x<>0 then
       begin         
         f(sum+x,x-1);
       end
    else
      result:=sum;
  end;
  
begin
  result:=0;
  f(0,10);
  writeln(result);
  
  while true do;
end.
