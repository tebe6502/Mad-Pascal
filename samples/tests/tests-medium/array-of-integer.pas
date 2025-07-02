{ Test: The array A is filled with the numbers 1..10.
        The the numbers are summed. Expected result: 55}
program bar;
type 
  IntArray = array[0..10] of integer;
var
  A : IntArray;
  i,sum: integer;
begin
  {makerarray is only needed for "compiler-simple.rkt"}
  // A:=makearray(1,10,0);  
  {Fill array}
  i:=1;
  while i<11 do
    begin
      A[i]:=i;
      i:=i+1;
    end;
  {Sum elements in array}
  sum:=0;
  i:=1;
  while i<11 do
    begin
      sum:=sum+A[i];
      i:=i+1;
    end;
  {Print result}
  writeln(sum);
  
  while true do;
end.
