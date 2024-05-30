
uses crt, graph;

var	k: byte;
	x,y, x0, y0: byte;

const
	n = 8;
	scale = 64.0;

begin

 InitGraph(8 + 16);

 SetColor(1);

 for k:=1 to n do begin

  x := trunc(cos(2*k*pi / n)*scale)+160;
  y := trunc(sin(2*k*pi / n)*scale)+96;

  if k=1 then begin
   x0:=x;
   y0:=y;
   MoveTo(x,y);
  end else
   LineTo(x,y);

 end;

 LineTo(x0,y0);


repeat until keypressed;

end.


