// archimedes spiral

// 16529	single		4925 bytes
// 10361	float16		5090 bytes
// 11881	real		4176 bytes


program fedora_hat;

uses crt, graph, sysutils;

//{$f $40}

type
 TFloat = real;

const
 sx: TFloat = 144;
 sx_2 : TFloat = 144 * 144;
 sy: TFloat = 56;
 half: TFloat = 0.5;
 sz = 64;
 cx = 320;
 cy = 192;


var
 c1, c2, scx, scy, xf, zt, zs, fx, fy, fz, zx, zy, a, ifz: TFloat;

 i: word;

 gd, gm: smallint;

 x1: word;
 y1: byte;

 xi, xl: byte;

 zi: byte;

 tim: cardinal;

 rr: array [0..cx-1] of byte;

begin

gd := D8bit;
gm := m640x480;

InitGraph(gd,gm,'');

tim:=GetTickCount;

c1:=2.2*sy;
c2:=1.6*sy;

for i:=cx-1 downto 0 do rr[i] := cy;

scx:=cx * 0.5;
scy:=cy * 0.46875;
fx:=sx / 64;
fz:=sz / 64;

zt:=fx*64;
ifz:=fz*64;

xf:=4.71238905/sx;

for zi:=127 downto 0 do begin		// -64 .. 64

 zs:=zt*zt;
 xl:=trunc(sqrt(sx_2-zs) + half);

 zx:=ifz+scx;
 zy:=ifz+scy;

 for xi:=xl downto 0 do begin

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

tim:=GetTickCount - tim;

writeln(tim,' tick');

repeat until keypressed;

end.
