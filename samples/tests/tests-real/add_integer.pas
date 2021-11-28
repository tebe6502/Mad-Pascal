{

444895.0000
444895.0000

-21359.0000
-21359.0000

35162.0000
35162.0000

-155466.0000
-155466.0000

}

uses crt;

var	z: integer;

	r: real;

begin

z:=412127;

r:= z + 32768.00;
writeln(r:4:4);

r:=32768.00 + z;
writeln(r:4:4);
writeln;


z:=-54127;

r:= z + 32768.00;
writeln(r:4:4);

r:=32768.00 + z;
writeln(r:4:4);
writeln;


z:=1197;

r:=integer(z*2) + 32768.00;
writeln(r:4:4);

r:=32768.00 + integer(z*2);
writeln(r:4:4);
writeln;

z:=-94117;

r:=integer(z*2) + 32768.00;
writeln(r:4:4);

r:=32768.00 + integer(z*2);
writeln(r:4:4);


repeat until keypressed;

end.

