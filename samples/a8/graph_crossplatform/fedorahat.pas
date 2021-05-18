// archimedes spiral

program fedora_hat;

uses crt, graph, sysutils;

const
 sx: single = 144;
 sx_2 : single = 144 * 144;
 sy: single = 56;
 half: single = 0.5;
 sz = 64;
 cx = 320;
 cy = 192;


var
 c1, c2, scx, scy, xf, zt, zs, fx, fy, fz, zx, zy, a, ifz: single;

 i: word;

 gd, gm,
 xl, xi, x1, y1: smallint;

 zi: shortint;

 tim: cardinal;

 rr: array [0..cx-1] of smallint;

begin

gd := D8bit;
gm := m640x480;

InitGraph(gd,gm,'');

tim:=GetTickCount;

c1:=2.2*sy;
c2:=1.6*sy;

for i:=0 to cx-1 do rr[i] := cy;

scx:=cx * 0.5;
scy:=cy * 0.46875;
fx:=sx/64;
fz:=sz/64;

zt:=fx*64;
ifz:=fz*64;

xf:=4.71238905/sx;

for zi:=64 downto -64 do begin

 zs:=zt*zt;
 xl:=trunc(sqrt(sx_2-zs)+half);

 zx:=ifz+scx;
 zy:=ifz+scy;

 for xi:=0 to xl do begin
  a:=sin(sqrt(xi*xi+zs)*xf);

  y1:=trunc(zy-a*(c1-c2*a*a));

  x1:=trunc(xi+zx);
  if rr[x1] > y1 then begin rr[x1]:=y1; PutPixel(x1,y1, 15) end;

  x1:=trunc(zx-xi);
  if rr[x1] > y1 then begin rr[x1]:=y1; PutPixel(x1,y1, 15) end;

 end;

 zt:=zt-fx;
 ifz:=ifz-fz;

end;

writeln(GetTickCount - tim,' tick');

repeat until keypressed;

end.
