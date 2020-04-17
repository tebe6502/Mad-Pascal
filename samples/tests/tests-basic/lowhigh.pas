{Tests the array functions low and high}
program lowhigh;
type
  string_ = array [ 0 ..200] of char;
  counts = array [0..32] of integer;
var
  deadbeef: string_;
  i,n:integer;
  c:char;
  count:counts;
begin
  deadbeef:='deadbeef';
  write('low:  ', low(deadbeef));
  writeln;
  write('high: ', high(deadbeef));
  writeln;
  { count number of occurences of each letter }
  // count:=makearray('a','z',0); // for simple
  for i:=1 to high(deadbeef) do
    begin
    c:=deadbeef[i];
    count[ord(c)]:=count[ord(c)]+1;
    end;    
  { print counts }
  for c:='a' to 'f' do
    begin
    write(c,': ',count[ord(c)]);
    writeln;
    end;    
    
  while true do;  
end.
