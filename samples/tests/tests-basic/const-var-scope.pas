{ Tests: Global constants and variables are in the same scope}
{ Expected: A duplicate binding error }
program scopetest;
const 
  n=42;
var 
  n:integer;  
begin
  writeln(n); 
end.
