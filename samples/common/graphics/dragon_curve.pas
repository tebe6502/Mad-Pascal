
{ Dragon }

uses crt, graph;

type
	TFloat = real;

const
  s = 0.7071;	// sqrt(2) / 2;

  _sin: array [0..7] of TFloat = (0, s, 1, s, 0, -s, -1, -s);
  _cos: array [0..7] of TFloat = (1.0, s, 0.0, -s, -1.0, -s, 0.0, s);

  sep = 160;

var
	gd, gm: smallint;


procedure Dragon(n, a, t: byte; d, x, y: TFloat);
var a1, a2: byte;
begin
  if n <= 1 then
  begin
      MoveTo(Trunc(x + 0.5), Trunc(y + 0.5));
      LineTo(Trunc(x + d * _cos[a] + 0.5), Trunc(y + d * _sin[a] + 0.5));
      exit;
  end;

  d := d * s;
  a1 := (a - t) and 7;
  a2 := (a + t) and 7;

  dragon(n - 1, a1, 1, d, x, y);
  dragon(n - 1, a2, -1, d, x + d * _cos[a1], y + d * _sin[a1]);
end;


begin

gd := D8bit;
gm := m640x480;

InitGraph(gd,gm,'');

SetColor(15);

dragon(14, 0, 1, sep, sep / 2, sep * 5 / 6);

repeat until keypressed;

end.

