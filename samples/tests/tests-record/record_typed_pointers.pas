{

 2000
 3217

}

uses crt;

var
	x,y: smallint;

	w: cardinal;

	s: string;

	temp : record
		r: word;
		a: ^word;
		q: cardinal;
		b: ^word;
	end;

begin

 x:=100;
 y:=2000;

 temp.a:=@x;
 temp.b:=@y;

 temp.a^:=3217;

 w:=temp.b^;

 writeln(w);

 w:=temp.a^;

 writeln(w);

 repeat until keypressed;

 end.