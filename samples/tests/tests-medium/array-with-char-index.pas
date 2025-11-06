{ Test: The array A is filled with the 'a'..'e'.
        The the numbers are printed. 
        Expected result: abcde }
program bar;
type 
  CharArray = array['f'..'j'] of char;
var
  A:CharArray;
begin
  {makerarray is only needed for "compiler-simple.rkt"}
  { A:=makearray('f','j','a'); }
  {Fill array}
  A['f']:='a';
  A['g']:='b';
  A['h']:='c';
  A['i']:='d';
  A['j']:='e';  
  {Print elements in array}
  write(A['f']);
  write(A['g']);
  write(A['h']);
  write(A['i']);
  write(A['j']);
  writeln;
  
  while true do;
end.
