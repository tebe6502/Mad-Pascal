program bounce; { BOUNCE.PAS }

{ "How to generate 'realistic' bounce", by Bas van Gaalen }

uses crt, fastgraph;

const idiv = 2;

var
    i, pi: byte;
    px,py,x,y:smallint;
    dir:shortint;

    j: shortreal;

    [striped] tsqrt: array [0..255] of shortreal;

begin

for i:=0 to 255 do tsqrt[i] := sqrt(shortreal(i));


while true do begin

  InitGraph(8+16);

  x:=10; y:=0; dir:=1;

  i:=60 + Rnd and $7f;		// random [60..187]

  while i>0 do begin

    j := -tsqrt[i];

  while j < tsqrt[i] do begin

      y:=round(j*j);

      px:=x; py:=y; pi:=i;

      SetColor(15);
      Circle(x,y+(180-i), 7);

      inc(x,dir); if (x>310) or (x<10) then dir:=-dir;
      j:=j+0.2;

      pause;

      SetColor(0);
      Circle(px,y+(180-pi), 7);

    end;

    if (i div idiv) = 0 then i:=0 else dec(i,i div idiv);

  end;

end;

end.
