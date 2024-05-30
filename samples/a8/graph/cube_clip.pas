
program cube;

uses crt, fastgraph;


const
	Linien       =12;
	Ecken        =8;
	distanz      = 1500.0;

	buf1 = $5000;
	buf2 = $6000;

	start: array [0..Linien-1] of byte = (0,1,2,3,0,1,2,3,4,5,6,7);
	ende: array [0..Linien-1] of byte = (1,2,3,0,4,5,6,7,5,6,7,4);

type
	tLine = array [0..Linien*4] of smallint;
	sineType = real;

const
	{$i sin256.pas}

var   x, y, z      : array [0..Ecken]  of real;
      x2d, y2d     : array [0..Ecken]  of smallint;
      Alt, Alt1,
      Alt2         : tLine;
      Laenge,
      sina, cosa,
      sinb, cosb,
      sinc, cosc   : real;
      Add_X, Add_Y : word;

      tempX, tempY,
      tempZ, temp1,
      temp2        : real;

      angle1,
      angle2,
      angle3       : byte;
      dl           : word;


procedure Clear_Cube(var tmp: tLine);
var i, x : byte;
begin

    SetColor(0);

    for i := 0 to Linien-1 do
      begin
	x:=i shl 2;

	ClipLine(tmp[x], tmp[x+1], tmp[x+2], tmp[x+3]);
      end;

end;


procedure Draw_Cube;
var i,x : byte;
begin

    SetColor(1);

    for i := 0 to Linien-1 do
      begin

	x:=i shl 2;

        Alt[x]:=x2d[start[i]];
        Alt[x+1]:=y2d[start[i]];
        Alt[x+2]:=x2d[Ende[i]];
        Alt[x+3]:=y2d[Ende[i]];

        ClipLine (Alt[x], Alt[x+1], Alt[x+2], Alt[x+3]);
      end;
end;

procedure Projection_3D_2D;
var i: byte;
    f: real;

begin

 sina := tsin[angle1];
 cosa := tsin[byte(angle1 + 64)];

 sinb := tsin[angle2];
 cosb := tsin[byte(angle2 + 64)];

 sinc := tsin[angle3];
 cosc := tsin[byte(angle3 + 64)];

 for i := 0 to Ecken-1 do begin

  { Aby nie "zamazal" zrodlowych danych, przepisujemy je do "temp" }

  tempx := x[i];
  tempy := y[i];
  tempz := z[i];

  {Obrot  X}

  temp1 := tempy*cosa - tempz*sina; { wzor na obrot punktu}
  temp2 := tempz*cosa + tempy*sina;
  tempy := temp1;
  tempz := temp2;

  { Obrot Y}

  temp1 := tempz*cosb - tempx*sinb;
  temp2 := tempx*cosb + tempz*sinb;
  tempz := temp1;
  tempx := temp2;

  { Obrot Z}

  temp1 := tempx*cosc - tempy*sinc;
  temp2 := tempy*cosc + tempx*sinc;
  tempx := temp1;
  tempy := temp2;

  f := 1500.0 / (distanz-tempz);
  x2d[i] := round(tempx*f) + Add_X;
  y2d[i] := round(tempy*f) + Add_Y;

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


begin

  InitGraph(7 + 16);

  SetClipRect(0,0, ScreenWidth-1, ScreenHeight-1);

  Laenge:=ScreenHeight shr 1 - 10;
  Add_X :=ScreenWidth shr 1;
  Add_Y :=ScreenHeight shr 1;

  fillchar(Alt, sizeof(Alt), 0);

  Alt1:=Alt;
  Alt2:=Alt;

  SetzePunkte;

  dl:=dpeek($230);

  angle1 := 16;
  angle2 := 77;
  angle3 := 111;

  repeat
//	FRAME #1

	pause;

  	dpoke(dl+4, buf2);
	FrameBuffer(buf1);

	Projection_3D_2D;

	Clear_Cube(Alt1);
	Draw_Cube;

	Alt1:=Alt;

	inc(angle1);
	inc(angle2);
	inc(angle3);

//	FRAME #2

	pause;
	dpoke(dl+4, buf1);
	FrameBuffer(buf2);

	Projection_3D_2D;

	Clear_Cube(Alt2);
	Draw_Cube;

	Alt2:=Alt;

	inc(angle1);
	inc(angle2);
	inc(angle3);

  until keypressed;

end.
