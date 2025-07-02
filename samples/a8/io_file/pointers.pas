uses crt, sysutils;

type
	ta = array [0..15] of byte;

var	pb: ^byte;
	pw: ^word;
	pc: ^cardinal;

	pa: ^ta;

	a: ^char;
	s: string;

	x: char;

begin

 a:=@x;

 s:='atari';

 a^:='A';

 writeln(s, '/',ord(a^));

 inc(pb);
 inc(pw);
 inc(pc);

 writeln(word(pb),',',word(pw),',',word(pc));

 pb:=pointer(0);
 pw:=pointer(0);
 pc:=pointer(0);

 inc(pb, 1);
 inc(pw, 1);
 inc(pc, 1);

 writeln(word(pb),',',word(pw),',',word(pc));

 repeat until keypressed;

end.
