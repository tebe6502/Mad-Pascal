
uses crt;

const
	charset = $b800;
	data = $5400;

	size = 25600;

var
	f: file;
	s, p, k, m: ^byte;

	x: word;

begin

 p:=pointer(charset);
 assign(f, 'D:CHDEF.BIN'); reset(f, 1);
 blockread(f, p, 680);
 close(f);

 p:=pointer(data);
 assign(f, 'D:DATA.BIN'); reset(f, 1);
 blockread(f, p, size);
 close(f);

 Poke(756, hi(charset));
 
 p:=pointer(dpeek(88));
 k:=pointer(dpeek(88) + 10*40);
 m:=pointer(dpeek(88) + 20*40);

 repeat
 
	repeat
 
	delay(1);

	s:=pointer(data+x);

	move(s, p, 400);
	move(s, k, 400);
	move(s, m, 160);

	inc(x, 400);
	
	until x = size;

 x:=0;
 
 until keypressed;

end.
