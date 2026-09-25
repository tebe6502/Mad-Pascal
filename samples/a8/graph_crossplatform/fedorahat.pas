// archimedes spiral

// 14254	single		5028 bytes
// 9092		float16		5082 bytes
// 5587		real		3864 bytes

program fedora_hat;

uses crt, graph, sysutils;

//{$f $40}

type
 TFloat = float16;

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

 x1, ml, delta: word;
 y1: byte;

 zi, xi, xl, hlp: byte;

 tim: cardinal;

 rr: array [0..cx-1] of byte;


begin

gd := D8bit;
gm := m640x480;

InitGraph(gd,gm,'');


tim:=GetTickCount;

c1 := sy * 2.2;
c2 := sy * 1.6;

for i:=cx-1 downto 0 do rr[i] := cy;

scx:=cx * 0.5;
scy:=cy * 0.46875;
fx:=sx / 64;
fz:=sz / 64;

zt := fx * 64;
ifz := fz * 64;

xf := 4.71238905 / sx;

for zi:=127 downto 0 do begin		// -64 .. 64

 zs:=zt*zt;
 xl:=trunc(sqrt(sx_2-zs) + half);

 zx:=ifz+scx;
 zy:=ifz+scy;
 
 ml:=0;		// ml -> xi*xi
 delta:=1;

 for xi:=0 to xl do begin

  a:=sin(xf * sqrt(ml + zs));

  y1:=trunc(zy-a*(c1-a*a*c2));

  hlp:=trunc(zx);
  
  x1:=hlp + xi;
  if rr[x1] > y1 then begin rr[x1]:=y1; PutPixel(x1,y1, 15) end;

  x1:=hlp - xi;
  if rr[x1] > y1 then begin rr[x1]:=y1; PutPixel(x1,y1, 15) end;

  ml:=ml+delta;
  delta:=delta+2;
 end;

 zt:=zt-fx;
 ifz:=ifz-fz;

end;

tim:=GetTickCount - tim;

writeln(tim,' tick');

repeat until keypressed;

end.
