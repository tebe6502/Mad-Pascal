program chess_board;

(* source: CLSN PASCAL              *)
(* This program generates an image  *)
(* of what a three-man chessboard   *)
(* would look like.                 *)

uses crt, graph;

const
  scalex=100;
  scaley=90;
  cx=160;
  cy=100;

  ONESEC: single = 0.5;
  D_PI_180: single = pi/180;

var
  dst: single;

procedure init;
var gd, gm: smallint;
begin
  dst:=sqrt(1-sqr(ONESEC));

  gd := VGA;
  gm := VGAHi;

  InitGraph(gd,gm,'');

  SetColor(15);
end;

procedure draw_line(side,line: shortint);
var
  scf,ang,lndiv4: single;
  sx,sy,tx,ty: smallint;

begin
  lndiv4:=line/4;

  scf:=sqrt(sqr(dst)+sqr(ONESEC*lndiv4));

  ang:=((side*60)+(30*lndiv4)+30)*D_PI_180;
  sx:=cx+round(cos(ang)*scf*scalex);
  sy:=cy-round(sin(ang)*scf*scaley);

  ang:=(side*60+150-60*ord(line>0))*D_PI_180;
  tx:=cx+round(cos(ang)*(dst*lndiv4)*scalex);
  ty:=cy-round(sin(ang)*(dst*lndiv4)*scaley);

  MoveTo(sx,sy); LineTo(tx,ty);
  MoveTo(sx+1,sy); LineTo(tx+1,ty);
end;

procedure frame;
var
  side,line: shortint;

begin
  for side:=0 to 5 do
    for line:=-4 to 4 do
      draw_line(side,line);
end;

begin
  init;
  frame;

  repeat until keypressed;

  TextColor(0);
end.
