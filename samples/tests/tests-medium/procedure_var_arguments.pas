{
 5
 8
 12
 17
}

uses crt;

procedure SetValue(var a,b,c,d: byte);
begin
{ próba nadania nowej wartości dla parametru }
  a := a  + 2;
  b := a  + 3;
  c := b  + 4;
  d := c  + 5;
end;

var a,b,c,d: byte;

begin
 a:=3;

 SetValue(a,b,c,d);

 writeln(a);
 writeln(b);
 writeln(c);
 writeln(d);

 repeat until keypressed;

end.