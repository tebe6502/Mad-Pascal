
uses crt;

var
	a: byte;
	b: word;
	c: cardinal;
	
	i: shortint;
	j: smallint;
	k: integer;
	
begin

 while (a < 4) and not odd(b) do begin

  writeln(a);

  inc(a);
  inc(b);
 end;
 
 repeat until keypressed;

end.
