uses crt, siodisk;

var
	density: byte;

	buf: array [0..0] of byte;

	f: file;

	x: word;

begin

 writeln('Boot extractor');

 writeln(density);

 buf:=pointer($bc40);

 ReadBoot(2, buf);

 assign(f, 'D1:DOS.BOT'); rewrite(f, 1);
 blockwrite(f, buf, 384);
 close(f);

 repeat until keypressed;

end.