{ Tests type definitions equivalent to array of base type.}
{ Expected result: 42 }
program types;
type
 int_=integer;
 arr = array[0..10] of int_;
 ints = arr;
var 
  a:ints;
begin
  a[3]:=42;
  writeln(a[3]);
  
  while true do;
end.

