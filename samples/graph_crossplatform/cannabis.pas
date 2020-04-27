{ Cannabola plot program }

uses crt, graph;

const
  dt : single = 0.01;

  scale: single = 48;

  pi2: single = 2*pi;


var
  r, t, x, y: single;

  gd, gm: smallint;

begin

 gd := D8bit;
 gm := m640x400;

 InitGraph(gd,gm,'');

 t := 0.0;

 while t <= pi2 do begin

  r := (1 + sin(t)) * (1 + 0.9 * cos(8 * t)) * (1 + 0.1 * cos(24 * t)) * (0.5 + 0.05 * cos(200* t));

  x := r * cos(t);
  y := r * sin(t);

  PutPixel(160 + round(scale * x), 120 - round(scale * y), 15);

  t := t + dt;
 end;

 repeat until keypressed;

end.



