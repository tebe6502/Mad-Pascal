// Archimedean spiral
// https://rosettacode.org/wiki/Archimedean_spiral

uses graph, crt;

var
  gd, gm: smallint;


procedure spiral;
var r: word;
    x: word;
    y: byte;

    r_rad: single;

const
	turns = 5;		// number of turns

begin

SetColor(15);

MoveTo(160, 96);

For r := 0 To 360 * turns do begin

  r_rad := r * pi/180;

  x := 160 + round(r * Cos(r_rad)  / 20);
  y := 96 - round(r * Sin(r_rad)  / 20);

  LineTo(x, y);
end;

end;



begin

 gd := D8bit;
 gm := m640x400;

 InitGraph(gd,gm,'');

 spiral;

 repeat until keypressed;

end.