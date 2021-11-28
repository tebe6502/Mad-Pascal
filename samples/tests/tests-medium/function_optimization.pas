// 503

uses crt, math;

var
	c, i, x, y: byte;

	w: word;

	bs: array [0..0] of byte;


begin

c:=peek($d20a);

bs[i]:=peek($d20a);

Poke($d000 + c, bs[x]); // hpos

w:=Random(c) + Min(x,y);

Poke(w+i, $9b);

repeat until keypressed;

end.
