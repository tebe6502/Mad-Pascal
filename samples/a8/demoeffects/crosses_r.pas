
{$r crosses.rc}

uses crt;

const
	charset = $b800;
	data = $5400;

	size = 25600;

var
	s, p, k, m: ^byte;

	x: word;

begin
 Poke(756, hi(charset));

 p:=pointer(dpeek(88));
 k:=pointer(dpeek(88) + 10*40);
 m:=pointer(dpeek(88) + 20*40);

 repeat

	repeat

	pause;

	s:=pointer(data+x);

	move(s, p, 400);
	move(s, k, 400);
	move(s, m, 160);

	inc(x, 400);

	until x = size;

 x:=0;

 until keypressed;

end.
