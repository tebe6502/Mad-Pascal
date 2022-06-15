type
	TRec = record a,b: word end;

var
	temp: ^TRec;
	
	a: TRec;
	
	x,w: word;



begin

a.b:=10;

temp:=@a;

// temp.b:=111;

w:=temp.b;

writeln(w);

while true do;


end.


