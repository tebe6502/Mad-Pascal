{

32895.0000
32895.0000

32641.0000
32641.0000

32962.0000
32962.0000

32534.0000
32534.0000

}

uses crt;

var	z: shortint;

	r: real;

begin

z:=127;

r:= z + 32768.00;
writeln(r:4:4);

r:=32768.00 + z;
writeln(r:4:4);
writeln;


z:=-127;

r:= z + 32768.00;
writeln(r:4:4);

r:=32768.00 + z;
writeln(r:4:4);
writeln;


z:=97;

r:=smallint(z*2) + 32768.00;
writeln(r:4:4);

r:=32768.00 + smallint(z*2);
writeln(r:4:4);
writeln;

z:=-117;

r:=smallint(z*2) + 32768.00;
writeln(r:4:4);

r:=32768.00 + smallint(z*2);
writeln(r:4:4);


repeat until keypressed;

end.

