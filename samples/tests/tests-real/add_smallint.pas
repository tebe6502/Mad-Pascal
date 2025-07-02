{

35895.0000
35895.0000

31641.0000
31641.0000

13626.0000
13626.0000

24534.0000
24534.0000

}

uses crt;


var	z: smallint;

	r: real;

begin

z:=3127;

r:= z + 32768.00;
writeln(r:4:4);

r:=32768.00 + z;
writeln(r:4:4);
writeln;


z:=-1127;

r:= z + 32768.00;
writeln(r:4:4);

r:=32768.00 + z;
writeln(r:4:4);
writeln;


z:=23197;

r:=smallint(z*2) + 32768.00;
writeln(r:4:4);

r:=32768.00 + smallint(z*2);
writeln(r:4:4);
writeln;

z:=-4117;

r:=smallint(z*2) + 32768.00;
writeln(r:4:4);

r:=32768.00 + smallint(z*2);
writeln(r:4:4);

repeat until keypressed;

end.

