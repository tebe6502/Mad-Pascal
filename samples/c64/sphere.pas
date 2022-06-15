uses crt, graph;

var cx, cy, x, y, x2, y2: byte;
    sx, sy, tmp, size, sinx, cosx, siny: real;

    GraphDriver, GraphMode : smallint;


procedure Sphere(time: byte);
begin

 if time=1 then
  MoveTo(cx+round(size), cy)
 else
  MoveTo(cx, cy+round(size));

 sy:=-11.5*8.0;
 for y:=7 downto 0 do begin

  siny:=size*sin(sy*pi/180);

  sx:=0.0;
  for x:=0 to 32 do begin

    tmp:=sx*pi/180.0;

    sinx:=sin(tmp);
    cosx:=size*cos(tmp);

    if time=1 then begin
      x2:=cx+round(cosx);
      y2:=cy-round(sinx*siny);
    end else begin
      x2:=cx-round(sinx*siny);
      y2:=cy+round(cosx);
    end;

    LineTo(x2,y2);

    sx:=sx-12.0;
  end;

 sy:=sy+12.0;
 end;

end;


begin

 GraphDriver := VGA;			// InitGraph(24);
 GraphMode := VGAHi;
 InitGraph(GraphDriver,GraphMode,'');


 size:=90.0;

 cx:=160; cy:=96;


 SetColor(15);

 Sphere(1);
 Sphere(2);

repeat until keypressed;

end.
