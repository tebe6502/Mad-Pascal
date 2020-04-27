// Fractal by Estece
// http://atariage.com/forums/topic/269132-bench-marking-fp-routines-with-fractal-zoom/#entry3834404

uses Crt,fastgraph;
const
	lngth:byte = 79;
	height:byte = 191;
	colors:array[0..100] of byte=(
	15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
	15,15,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,13,
	13,13,13,13,13,13,13,13,13,13,13,12,12,12,12,12,12,12,12,12,
	12,11,11,11,11,11,11,11,11,10,10,10,10,10,10, 9, 9, 9, 9, 9,
	 8, 8, 8, 8, 8, 7, 7, 7, 6, 6, 6, 5, 5, 5, 4, 4, 3, 3, 2, 2, 1);
	four:single=4.0;

var x,y,count,lastc,nowc: byte;

    ac,az,az2,bc,bz,bz2,xs,ys,size,
    acorner,bcorner,side,gapl,gaph: single;

begin
 lastc:=0;ys:=0;
 acorner:=-2;
 bcorner:=-1.145288;
 side:=0.253866;
 gapl:=10*(side/lngth);
 gaph:=10*(side/height);
 Initgraph(9);
 for y:=0 to height do
 begin
  bc:=ys*gaph+bcorner;
  xs:=0;
  for x:=0 to lngth do
  begin
   ac:=xs*gapl+acorner;
   az:=0;
   bz:=0;
   count:=0;
   repeat
    az2:=(az*az)-(bz*bz)+ac;
    bz2:=2*az*bz+bc;
    az:=az2;bz:=bz2;
    size:=az2*az2+bz2*bz2;
    inc(count);
   until ((size>four) or (count>99));
   nowc:=colors[count];
   if nowc<>lastc then
   begin
    lastc:=nowc;
    SetColor(lastc);
   end;
   PutPixel(x,y);
   xs:=xs+1;
  end;
  ys:=ys+1;
 end;
 repeat until keypressed;
end.
