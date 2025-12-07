program dots2; { DOTS2.PAS }

{ Good ol' pc effect ;-) by Bas van Gaalen }

uses crt, fastgraph;

const
  dots=256;

  slen1=511; samp1=49; sofs1=50;
  slen2=511; samp2=39; sofs2=50;

  dx1=3; dy1=5; xspd1=4; yspd1=2;
  dx2=4; dy2=3; xspd2=2; yspd2=3;

var
  stab1:array[0..255] of byte;
  stab2:array[0..255] of byte;


procedure init;
var i: word;

const
    c_pi: single = pi;

begin

  for i:=0 to 255 do stab1[i]:=round(sin(i*(4*c_pi)/slen1)*samp1)+sofs1;
  for i:=0 to 255 do stab2[i]:=round(sin(i*(4*c_pi)/slen2)*samp2)+sofs2;

end;


procedure plotter;
var i: byte;

    xst1,xst2,yst1,yst2: byte;

    offset_x, onset_x,
    offset_y, onset_y: byte;

    i_dy1, i_dx1, i_dy2, i_dx2,
    i_dy1_, i_dx1_, i_dy2_, i_dx2_: byte;

begin

  xst1:=100; xst2:=800; yst1:=300; yst2:=700;

  repeat

    i_dy1 := yst1;
    i_dx1 := xst1;
    i_dy2 := yst2;
    i_dx2 := xst2;

    xst1:=(xst1+xspd1);
    yst1:=(yst1+yspd1);

    xst2:=(xst2+xspd2);
    yst2:=(yst2+yspd2);

    i_dy1_ := yst1;
    i_dx1_ := xst1;
    i_dy2_ := yst2;
    i_dx2_ := xst2;

    for i:=0 to dots-1 do begin

      offset_y := stab1[i_dy1] + stab2[i_dy2];
      offset_x := stab1[i_dx1] + stab2[i_dx2] + 60;

      onset_y := stab1[i_dy1_] + stab2[i_dy2_];
      onset_x := stab1[i_dx1_] + stab2[i_dx2_] + 60;

      SetColor(0);
      PutPixel(offset_x, offset_y);

      SetColor(15);
      PutPixel(onset_x, onset_y); //32+i mod 32);

      i_dy1 := (i_dy1 + dy1);
      i_dx1 := (i_dx1 + dx1);
      i_dy2 := (i_dy2 + dy2);
      i_dx2 := (i_dx2 + dx2);

      i_dy1_ := (i_dy1_ + dy1);
      i_dx1_ := (i_dx1_ + dx1);
      i_dy2_ := (i_dy2_ + dy2);
      i_dx2_ := (i_dx2_ + dx2);

    end;

  until keypressed;
end;

var i:word;
    gd, gm: smallint;
begin

  InitGraph(8+16);

  init;

  plotter;

end.
