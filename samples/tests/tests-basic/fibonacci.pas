{ Expected: 3628800 }
program fib;
type 
 int_=integer;
function fib(n:int_):int_;
  begin
    if n=0 then
      fib:=1
    else
      fib:=n*fib(n-1)
  end;
begin
  writeln(fib(10));
  
  while true do;
end.

