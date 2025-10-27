// https://github.com/pleumann/pasta80/blob/master/examples/gfx.pas

program Gfx;

uses crt, graph;

var
  I, J, K, L: smallint;

  gd, gm: smallint;

begin

  randomize;

  gd := VGA;
  gm := VGAHi;
  InitGraph(gd,gm,'');

  SetColor(15);

  for I := 0 to 1000 do
    PutPixel(Random(128), 48 + Random(128), 15);

  MoveTo(0, 48);
  LineRel(127, 0);
  LineRel(0, 127);
  LineRel(-127, 0);
  LineRel(0, -127);


  I := 128;
  while I <= 208 do
  begin
    MoveTo(I, 128);
    LineRel(47, 47);
    MoveTo(I, 175);
    LineRel(47, -47);
    Inc(I, 4);
  end;

  I := 63;
  while I > 0 do
  begin
    Circle(192, 63, I);
    Dec(I, 16);
  end;

  FloodFillH(135, 63, 15);
  FloodFillH(165, 63, 15);

//  OutTextXY(1,1, '*Pascal*');

  for I := 0 to 63 do
    for J := 0 to 7 do
      if GetPixel(I, J) <> 0 then
      begin
        K := 2 * I;
        L := 16 + 2 * J;

        PutPixel(K, L, 15);
        PutPixel(K + 1, L, 15);
        PutPixel(K, L + 1, 15);
        PutPixel(K + 1, L + 1, 15);
      end;

 repeat until keypressed;

end.
