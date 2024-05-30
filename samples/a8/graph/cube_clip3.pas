// changes 2019-01-15

program cube;

uses crt, fastgraph;

type
	sineType = ShortReal;

const
	Ecken        = 8;
	distanz      : sineType = 4;

	Laenge = 1;

	face: array [0..23] of byte =
	(0,1,2,3, 5,4,7,6, 4,5,1,0, 1,5,6,2, 6,7,3,2, 4,0,3,7);

const
	{$i sin256.pas}

	{$f $70}	// fastmul at page $70 ($7000)

var   x, y, z,
      x2d, y2d     : array [0..Ecken] of shortint;

      buf1	   : array [0..0] of byte absolute $5000;
      buf2	   : array [0..0] of byte absolute $6000;

      Add_X, Add_Y,
      angle1,
      angle2       : byte;

      dl           : word;


procedure Draw_Cube;
var i,x,a,b,c,d: byte;
    s0,s1,s2,s3: Boolean;
    x1,y1,x2,y2,x3,y3,x4,y4, tst: smallint;
    visible: byte;
    pnt: array [0..7] of Boolean;
begin

 pnt[0]:=true;
 pnt[1]:=true;
 pnt[2]:=true;
 pnt[3]:=true;
 pnt[4]:=true;
 pnt[5]:=true;
 pnt[6]:=true;
 pnt[7]:=true;

 visible:=0;

 for i:=0 to 5 do begin

  x:=i shl 2;

  a:=face[x];
  x1:=x2d[a] + Add_X;
  y1:=y2d[a] + Add_Y;

  inc(x);
  b:=face[x];
  x2:=x2d[b] + Add_X;
  y2:=y2d[b] + Add_Y;

  inc(x);
  c:=face[x];
  x3:=x2d[c] + Add_X;
  y3:=y2d[c] + Add_Y;

  inc(x);
  d:=face[x];
  x4:=x2d[d] + Add_X;
  y4:=y2d[d] + Add_Y;

  tst:=smallint(x4-x1)*smallint(y2-y1)-smallint(x2-x1)*smallint(y4-y1);

  if tst>=0 then begin

   s0:=false;
   s1:=false;
   s2:=false;
   s3:=false;

   if pnt[a] or pnt[b] then begin
    ClipLine(x1,y1,x2,y2);
    s0:=true;
   end;

   if pnt[b] or pnt[c] then begin
    ClipLine(x2,y2,x3,y3);
    s1:=true;
   end;

   if pnt[c] or pnt[d] then begin
    ClipLine(x3,y3,x4,y4);
    s2:=true;
   end;

   if pnt[d] or pnt[a] then begin
    ClipLine(x4,y4,x1,y1);
    s3:=true;
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

   inc(visible);		// max 3 visible faces
   if visible=3 then Break;

  end;

 end;

end;

procedure Projection_3D_2D;
var i: byte;
    rx,ry,rz: sineType;
    tempX, tempY, tempZ, temp: sineType;
    sina, cosa, sinb, cosb, rxCosa, rySina: sineType;
begin

{
 SinRotX = Sin(RotX)
 SinRotY = Sin(RotY)
 CosRotX = Cos(RotX)
 CosRotY = Cos(RotY)

 rX = (x * SinRotX) + (y * CosRotX)
 rY = (x * CosRotX * SinRotY) - ((y * SinRotX * SinRotY) + (z * CosRotY))
 rZ = (x * CosRotX * CosRotY) - ((y * SinRotX * CosRotY) - (z * SinRotY))
}

 sina := tsin[angle1];
 cosa := tsin[byte(angle1+64)];

 sinb := tsin[angle2];
 cosb := tsin[byte(angle2+64)];

 for i := 0 to Ecken-1 do begin

  rx := x[i];
  ry := y[i];
  rz := z[i];
  
  rxCosa:=rx*Cosa;
  rySina:=ry*Sina;

  tempX := (rx * Sina) + (ry * Cosa);
  tempY := (rxCosa * Sinb) - ((rySina * Sinb) + (rz * Cosb));
  tempZ := (rxCosa * Cosb) - ((rySina * Cosb) - (rz * Sinb)) + distanz;

  temp := 127 / tempZ;
  x2d[i] := hi(word(tempX * temp));// + Add_X;
  y2d[i] := hi(word(tempY * temp));// + Add_Y;

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

  SetColor(1);

  SetClipRect(0,0, ScreenWidth-1, ScreenHeight-1);

  Add_X :=ScreenWidth shr 1;
  Add_Y :=ScreenHeight shr 1;

  SetzePunkte;

  dl:=dpeek($230);

  angle1 := 16;
  angle2 := 77;

  repeat
//	FRAME #1

	pause;

  	dpoke(dl+4, word(@buf2));
	FrameBuffer(word(@buf1));

	Projection_3D_2D;

	fillchar(buf1, 40*96, 0);	// clear buf1

	Draw_Cube;

	inc(angle1);
	inc(angle2);

//	FRAME #2

	pause;

	dpoke(dl+4, word(@buf1));
	FrameBuffer(word(@buf2));

	Projection_3D_2D;

	fillchar(buf2, 40*96, 0);	// clear buf2

	Draw_Cube;

	inc(angle1);
	inc(angle2);

  until keypressed;

end.
