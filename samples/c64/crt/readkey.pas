uses crt;

var
	k: byte;

begin

 repeat until keypressed;

 k:=ord(readkey) and $7f;

 writeln(k);

end.
