
var
	temp: record a,b: ^word end;
	
	x,w: word;



begin

x:=111;

temp.b:=@x;


w:= temp.b^;

writeln(w);

while true do;


end.


