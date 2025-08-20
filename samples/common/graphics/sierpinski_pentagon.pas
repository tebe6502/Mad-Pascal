// https://rosettacode.org/wiki/Sierpinski_pentagon

uses crt, graph;

var
	xs: array [0..4] of byte = (249,200,96,80,175);
	ys: array [0..4] of byte = (82,176,159,55,7);

	gd, gm: smallint;


procedure sierp_pentagon;
var i: byte;
    x, y: smallint;
begin

  Randomize;

  x := 160 + Random(30);
  y := 96 + Random(30);

  repeat
    i := Random(5);

    x := x + (xs[i]-x) * 64 div 100;
    y := y + (ys[i]-y) * 64 div 100;

    PutPixel(x,y, 15);

  until keypressed;

end;


begin

 gd := D8bit;
 gm := m640x400;

 InitGraph(gd,gm,'');

 sierp_pentagon;

end.
