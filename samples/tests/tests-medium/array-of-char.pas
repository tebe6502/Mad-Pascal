{ Test: The array A is filled with the 'a'..'e'.
        The the numbers are printed. 
        Expected result: abcde }
program bar;
type 
  CharArray = array[0..5] of char;
var
  A:CharArray;
  i:integer;
begin
  {makerarray is only needed for "compiler-simple.rkt"}
  // A:=makearray(1,5,'a');  
  {Fill array}
  A[1]:='a';
  A[2]:='b';
  A[3]:='c';
  A[4]:='d';
  A[5]:='e';  
  {Print elements in array}
  i:=1;
  while i<6 do
    begin
      write(A[i]);
      i:=i+1;
    end;
  writeln(' ');
  
  
  while true do;
end.
