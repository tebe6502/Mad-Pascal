{http://stackoverflow.com/questions/14673601/
 how-to-write-numbers-separated-with-commas-in-a-loop-on-one-line }
program prime;
var
  P:integer;
  I:integer;
  J:integer;
  A:integer;
  
function mod_(x,y:integer):integer;
begin
  mod_:= x- (x div y)*y;
end;

begin
  writeln('Prime number program');
  writeln;
  writeln('Insert number');
  readln(P);

  for I:=2 to P-1 do
  begin
      J:=Mod_(P, I);
      if (J=0) then
      begin
        writeln(P,' divides with ',I);
        a:=a+1
      end;
  end;

  if a=0 then
  begin
  writeln(P,' is prime number');
  end;
  
  while true do;
end.