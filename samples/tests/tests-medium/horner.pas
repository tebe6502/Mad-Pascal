{ Tests whether a formal parameter shadows 
  a constant declaration in the body of a function,
  and that the constant is back in scope afterwards. }
{ Expected result: 17,17 }

program horner;
const
  n=2;
type
  natural=integer;
  ring=integer;
  coefs=array[0..n] of ring;
var
 poly:coefs;
 
function horner(a:coefs; x:ring; n:natural):ring;
  var y:ring; i:natural;
  begin
  y:=0;
  for i:=0 to n do
    y:=y*x+a[i];
  horner:=y;
  end;

begin
 { poly:=makearray(0,2,0); // For simple }
 poly[0]:=3; 
 poly[1]:=2;
 poly[2]:=1;
 writeln(horner(poly, 2, n));
 writeln(3*2*2 + 2*2 + 1);
 
 while true do;
end.
