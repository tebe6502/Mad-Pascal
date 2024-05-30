// https://atariage.com/forums/topic/305526-fractals/?do=findComment&comment=4518410

uses crt, graph;

var i,j,c, cl: byte;
    x0,y0,x,y,x2,y2: shortreal;

    byt, bit, v, col: byte;

    s,t: shortreal;

    p: PByte register;
    k: PByte register;

    tcol: array [0..4] of byte = (0,$55,$aa,$ff,$00);
    tand: array [0..3] of byte = (%11000000, %00110000, %00001100, %00000011);

begin

 InitGraph(15+16);

 p:=Scanline(95);
 k:=Scanline(96);

 y0:=0;			// (i-95)*0.012

 for i:=95 downto 0 do begin

  x0:=59*0.024;		// (j-100)*0.024

  for j:=159 downto 0 do begin

   x:=x0;
   y:=y0;

   for c:=15 downto 1 do begin
    x2:=x*x;
    y2:=y*y;
    if x2+y2 > 4 then Break;
    y:=2*x*y+y0;
    x:=x2-y2+x0;
   end;

   cl:=(c-1) and 3 + 1;

   bit:=j and 3;

   v:=v or (tcol[cl] and tand[bit]);

   if bit=0 then begin
    byt:=j shr 2;

    p[byt]:=v;
    k[byt]:=v;

    v:=0;
   end;

   x0:=x0-0.024;
  end;

  dec(p, 40);
  inc(k, 40);

  y0:=y0+0.012;
 end;

  repeat until keypressed;

end.
