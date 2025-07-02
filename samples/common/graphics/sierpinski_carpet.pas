uses crt, graph;

var
    gd, gm: smallint;


function InCarpet(x,y: byte): Boolean;
begin

  repeat

    IF (x MOD 3=1) AND (y MOD 3=1) THEN exit(false);

    x:=x div 3;
    y:=y div 3;

  until (x=0) AND (y=0);

 Result:=true;

end;


procedure DrawCarpet(x0, y0,depth: byte);
var i,x,y,size: byte;
begin

  size:=1;
  FOR i:=1 TO depth do size:=size*3;

  FOR y:=0 TO size-1 do
    FOR x:=0 TO size-1 do
      IF InCarpet(x,y) THEN begin
        PutPixel(x0+2*x,y0+2*y, 15);
        PutPixel(x0+2*x+1,y0+2*y, 15);
        PutPixel(x0+2*x+1,y0+2*y+1, 15);
        PutPixel(x0+2*x,y0+2*y+1, 15);
      end;

end;


begin

 gd := D8bit;
 gm := m640x400;

 InitGraph(gd,gm,'');

 DrawCarpet(79,15,4);

 repeat until keypressed;

end.

