uses crt, graph;

type
     TFloat = single;

var
     gd, gm: smallint;

     a, e, c, d, z, t: TFloat;

     x1, y1: smallint;

     x,y: byte;

     tb: array [0..2650] of byte;

const
     cPi : TFloat = pi;

begin

 gd := D8bit;
 gm := m640x400;

 InitGraph(gd,gm,'');

 SetColor(15);

 a := cos(cpi/4);

 y:=1;
 while y < 141 do begin

  e:=a*y;
  c:=y-70;
  c:=c*c;

  for x:=1 to 141 do begin
   d:=x-70;
   t:=-0.001 * (c+d*d);
   z:=80*exp(t);

   x1:=round(x+e);
   y1:=round(z+e);

   if y1 >= tb[x1] then begin
    tb[x1] := y1;
    PutPixel(20+x1, 160-y1);
   end;

  end;

  inc(y, 5);
 end;

 repeat until keypressed;

end.
