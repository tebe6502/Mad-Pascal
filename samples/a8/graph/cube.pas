
program cube;

uses crt, fastgraph;


const Linien       =12;
      Ecken        =8;
      distanz      =2000.0;
      sinphi       =0.195090322016;
      cosphi       =0.980785280411;

var   start,
      Ende         : array [0..Linien] of smallint;
      x, y, z      : array [0..Ecken]  of real;
      x2d, y2d     : array [0..Ecken]  of smallint;
      Alt          : array [0..Linien*4] of smallint;
      Laenge       : real;
      Add_X        ,
      Add_Y        : word ;

      tempX, tempY, tempZ: real;

procedure XRotation;
var i: byte;
begin
    for i := 0 to Ecken-1 do
      begin
        tempY:=y[i];
        tempZ:=z[i];
        y[i] :=tempY*cosphi - tempZ*sinphi;
        z[i] :=tempZ*cosphi + tempY*sinphi;
      end;
end;

procedure YRotation;
var i: byte;
begin
    for i := 0 to Ecken-1 do
      begin
        tempX:=x[i];
        tempZ:=z[i];
        x[i] :=tempX*cosphi - tempZ*sinphi;
        z[i] :=tempZ*cosphi + tempX*sinphi;
      end;
end;

procedure ZRotation;
var i: byte;
begin
    for i := 0 to Ecken-1 do
      begin
        tempX:=x[i];
        tempY:=y[i];
        x[i] :=tempX*cosphi - tempY*sinphi;
        y[i] :=tempY*cosphi + tempX*sinphi;
      end;
end;

procedure Zeichne_Wuerfel;
var i,x : byte;
begin

    SetColor(0);

    for i := 0 to Linien-1 do
      begin
	x:=i shl 2;

        MoveTo (Alt[x],Alt[x+1]);
        LineTo (Alt[x+2],Alt[x+3]);

      end;

    SetColor(1);

    for i := 0 to Linien-1 do
      begin
	x:=i shl 2;

        Alt[x]:=x2d[start[i]];
        Alt[x+1]:=y2d[start[i]];
        Alt[x+2]:=x2d[Ende[i]];
        Alt[x+3]:=y2d[Ende[i]];

        MoveTo (Alt[x],Alt[x+1]);
        LineTo (Alt[x+2],Alt[x+3]);
      end;
end;

procedure Wandle_3D_2D;
var i:byte;
    f:real;
begin
    for i := 0 to Ecken-1 do
      begin
        f := 1000.0 / (distanz-z[i]);
        x2d[i]:=TRUNC(x[i]*f) + Add_X;
        y2d[i]:=TRUNC(y[i]*f) + Add_Y;
      end;
end;

procedure SetzePunkte;
begin
    x[0]:=-Laenge;
    y[0]:= Laenge;
    z[0]:= Laenge;
    x[1]:= Laenge;
    y[1]:= Laenge;
    z[1]:= Laenge;
    x[2]:= Laenge;
    y[2]:=-Laenge;
    z[2]:= Laenge;
    x[3]:=-Laenge;
    y[3]:=-Laenge;
    z[3]:= Laenge;
    x[4]:=-Laenge;
    y[4]:= Laenge;
    z[4]:=-Laenge;
    x[5]:= Laenge;
    y[5]:= Laenge;
    z[5]:=-Laenge;
    x[6]:= Laenge;
    y[6]:=-Laenge;
    z[6]:=-Laenge;
    x[7]:=-Laenge;
    y[7]:=-Laenge;
    z[7]:=-Laenge;
end;

procedure SetzeLinien;
begin
    start[ 0]:=0;  Ende[ 0]:=1;
    start[ 1]:=1;  Ende[ 1]:=2;
    start[ 2]:=2;  Ende[ 2]:=3;
    start[ 3]:=3;  Ende[ 3]:=0;
    start[ 4]:=0;  Ende[ 4]:=4;
    start[ 5]:=1;  Ende[ 5]:=5;
    start[ 6]:=2;  Ende[ 6]:=6;
    start[ 7]:=3;  Ende[ 7]:=7;
    start[ 8]:=4;  Ende[ 8]:=5;
    start[ 9]:=5;  Ende[ 9]:=6;
    start[10]:=6;  Ende[10]:=7;
    start[11]:=7;  Ende[11]:=4;
end;

begin

  InitGraph(8);

  Laenge:=ScreenHeight shr 1 - 10;
  Add_X :=ScreenWidth shr 1;
  Add_Y :=ScreenHeight shr 1;

  fillchar(Alt, sizeof(Alt), 0);

  SetzePunkte;
  SetzeLinien;

  YRotation;
  ZRotation;

  repeat
   XRotation;
//   YRotation;
//   ZRotation;

   Wandle_3D_2D;
   Zeichne_Wuerfel;
  until keypressed;

end.
