
program cube;

uses crt, fastgraph;


const
	Ecken        =8;
	distanz      = 4.0;

	Laenge : real = 1.0;

	buf1 = $6000;
	buf2 = $7000;

	face: array [0..23] of byte =
	(0,1,2,3, 5,4,7,6, 4,5,1,0, 1,5,6,2, 6,7,3,2, 4,0,3,7);

type
	tLine = array [0..43] of smallint;
	sineType = real;

const
	{$i sin256.pas}

var   x, y, z      : array [0..Ecken]  of real;
      x2d, y2d     : array [0..Ecken]  of smallint;
      Alt, Alt1,
      Alt2         : tLine;
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
    x1,y1,x2,y2: smallint;
begin

    SetColor(0);

    for i := 0 to tmp[0]-1 do
      begin
	x:=i shl 2+1;

	x1:=tmp[x];
	y1:=tmp[x+1];
	x2:=tmp[x+2];
	y2:=tmp[x+3];

	ClipLine(x1,y1,x2,y2);

      end;

end;


procedure Draw_Cube;
var i,x, cnt : byte;
    a,b,c,d: byte;
    s0,s1,s2,s3: Boolean;
    x1,y1,x2,y2,x3,y3,x4,y4, tst: smallint;
    p: ^smallint;
    pnt: array [0..7] of Boolean;
begin

 SetColor(1);

 p:=@Alt[1];
 cnt:=0;

 fillchar(pnt, sizeof(pnt), ord(true));

 for i:=0 to 5 do begin

  x:=i shl 2;

  a:=face[x];
  x1:=x2d[a];
  y1:=y2d[a];

  inc(x);
  b:=face[x];
  x2:=x2d[b];
  y2:=y2d[b];

  inc(x);
  c:=face[x];
  x3:=x2d[c];
  y3:=y2d[c];

  inc(x);
  d:=face[x];
  x4:=x2d[d];
  y4:=y2d[d];

  tst:=(x4-x1)*(y2-y1)-(x2-x1)*(y4-y1);

  if tst>=0 then begin

   s0:=false;
   s1:=false;
   s2:=false;
   s3:=false;

   if pnt[a] or pnt[b] then begin
    ClipLine(x1,y1,x2,y2);

    p^:=x1; inc(p);
    p^:=y1; inc(p);
    p^:=x2; inc(p);
    p^:=y2; inc(p);

    s0:=true;

    inc(cnt);
   end;


   if pnt[b] or pnt[c] then begin
    ClipLine(x2,y2,x3,y3);

    p^:=x2; inc(p);
    p^:=y2; inc(p);
    p^:=x3; inc(p);
    p^:=y3; inc(p);

    s1:=true;

    inc(cnt);
   end;

   if pnt[c] or pnt[d] then begin
    ClipLine(x3,y3,x4,y4);

    p^:=x3; inc(p);
    p^:=y3; inc(p);
    p^:=x4; inc(p);
    p^:=y4; inc(p);

    s2:=true;

    inc(cnt);
   end;

   if pnt[d] or pnt[a] then begin
    ClipLine(x4,y4,x1,y1);

    p^:=x4; inc(p);
    p^:=y4; inc(p);
    p^:=x1; inc(p);
    p^:=y1; inc(p);

    s3:=true;

    inc(cnt);
   end;

   if s0 then begin
    pnt[a]:=false;
    pnt[b]:=false;
   end;

   if s1 then begin
    pnt[b]:=false;
    pnt[c]:=false;
   end;

   if s2 then begin
    pnt[c]:=false;
    pnt[d]:=false;
   end;

   if s3 then begin
    pnt[d]:=false;
    pnt[a]:=false;
   end;

  end;

 end;

 Alt[0]:=cnt;

end;

procedure Projection_3D_2D;
var i: byte;
    f: real;

begin

 sina := tsin[angle1];
 i:=angle1 + 64;
 cosa := tsin[i];

 sinb := tsin[angle2];
 i:=angle2+64;
 cosb := tsin[i];

 sinc := tsin[angle3];
 i:=angle3+64;
 cosc := tsin[i];

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

  f := 120.0 / (distanz-tempz);
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

  Add_X :=ScreenWidth shr 1;
  Add_Y :=ScreenHeight shr 1;

  fillchar(Alt, sizeof(Alt), 0);
  Alt[0]:=1;

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
