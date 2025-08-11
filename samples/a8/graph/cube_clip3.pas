program cube_clip3;

uses
  crt,
  fastgraph;

type
  sineType = ShortReal;

const
  mode = 7 + 16;
  Ecken = 8;
  distanz: sineType = 4;

  Laenge = 1;

  face: array [0..23] of Byte =
    (0, 1, 2, 3, 5, 4, 7, 6, 4, 5, 1, 0, 1, 5, 6, 2, 6, 7, 3, 2, 4, 0, 3, 7);

const
  {$i sin256.pas}

  {$f $40} // fastmul at page $40 ($4000)

var
  x, y, z, x2d, y2d: array [0..Ecken] of Shortint;

  Add_X, Add_Y, angle1, angle2: Byte;

  buf1, buf2: TDisplayBuffer;


  procedure Draw_Cube;
  var
    i, x, a, b, c, d: Byte;
    s0, s1, s2, s3: Boolean;
    x1, y1, x2, y2, x3, y3, x4, y4, tst: Smallint;
    Visible: Byte;
    pnt: array [0..7] of Boolean;
  begin

    pnt[0] := True;
    pnt[1] := True;
    pnt[2] := True;
    pnt[3] := True;
    pnt[4] := True;
    pnt[5] := True;
    pnt[6] := True;
    pnt[7] := True;

    Visible := 0;

    for i := 0 to 5 do
    begin

      x := i shl 2;

      a := face[x];
      x1 := x2d[a] + Add_X;
      y1 := y2d[a] + Add_Y;

      Inc(x);
      b := face[x];
      x2 := x2d[b] + Add_X;
      y2 := y2d[b] + Add_Y;

      Inc(x);
      c := face[x];
      x3 := x2d[c] + Add_X;
      y3 := y2d[c] + Add_Y;

      Inc(x);
      d := face[x];
      x4 := x2d[d] + Add_X;
      y4 := y2d[d] + Add_Y;

      tst := Smallint(x4 - x1) * Smallint(y2 - y1) - Smallint(x2 - x1) * Smallint(y4 - y1);

      if tst >= 0 then
      begin

        s0 := False;
        s1 := False;
        s2 := False;
        s3 := False;

        if pnt[a] or pnt[b] then
        begin
          ClipLine(x1, y1, x2, y2);
          s0 := True;
        end;

        if pnt[b] or pnt[c] then
        begin
          ClipLine(x2, y2, x3, y3);
          s1 := True;
        end;

        if pnt[c] or pnt[d] then
        begin
          ClipLine(x3, y3, x4, y4);
          s2 := True;
        end;

        if pnt[d] or pnt[a] then
        begin
          ClipLine(x4, y4, x1, y1);
          s3 := True;
        end;

        if s0 then
        begin
          pnt[a] := False;
          pnt[b] := False;
        end;

        if s1 then
        begin
          pnt[b] := False;
          pnt[c] := False;
        end;

        if s2 then
        begin
          pnt[c] := False;
          pnt[d] := False;
        end;

        if s3 then
        begin
          pnt[d] := False;
          pnt[a] := False;
        end;

        Inc(Visible);    // max 3 visible faces
        if Visible = 3 then Break;

      end;

    end;

  end;

  procedure Projection_3D_2D;
  var
    i: Byte;
    rx, ry, rz: sineType;
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
    cosa := tsin[Byte(angle1 + 64)];

    sinb := tsin[angle2];
    cosb := tsin[Byte(angle2 + 64)];

    for i := 0 to Ecken - 1 do
    begin

      rx := x[i];
      ry := y[i];
      rz := z[i];

      rxCosa := rx * Cosa;
      rySina := ry * Sina;

      tempX := (rx * Sina) + (ry * Cosa);
      tempY := (rxCosa * Sinb) - ((rySina * Sinb) + (rz * Cosb));
      tempZ := (rxCosa * Cosb) - ((rySina * Cosb) - (rz * Sinb)) + distanz;

      temp := 127 / tempZ;
      x2d[i] := hi(Word(tempX * temp));// + Add_X;
      y2d[i] := hi(Word(tempY * temp));// + Add_Y;

    end;

  end;

  procedure SetzePunkte;
  begin
    x[0] := -Laenge;
    y[0] := Laenge;
    z[0] := Laenge;
    x[1] := Laenge;
    y[1] := Laenge;
    z[1] := Laenge;
    x[2] := Laenge;
    y[2] := -Laenge;
    z[2] := Laenge;
    x[3] := -Laenge;
    y[3] := -Laenge;
    z[3] := Laenge;
    x[4] := -Laenge;
    y[4] := Laenge;
    z[4] := -Laenge;
    x[5] := Laenge;
    y[5] := Laenge;
    z[5] := -Laenge;
    x[6] := Laenge;
    y[6] := -Laenge;
    z[6] := -Laenge;
    x[7] := -Laenge;
    y[7] := -Laenge;
    z[7] := -Laenge;
  end;


begin

  NewDisplayBuffer(buf1, mode, $60);
  NewDisplayBuffer(buf2, mode, $80);

  SetColor(1);

  SetClipRect(0, 0, ScreenWidth - 1, ScreenHeight - 1);

  Add_X := ScreenWidth shr 1;
  Add_Y := ScreenHeight shr 1;

  SetzePunkte;

  angle1 := 16;
  angle2 := 77;

  repeat
    //  FRAME #1

    pause;

    SetDisplayBuffer(buf2);
    SetActiveBuffer(buf1);
    buf1.Clr;

    Projection_3D_2D;

    Draw_Cube;

    Inc(angle1);
    Inc(angle2);

    //  FRAME #2

    pause;

    SetDisplayBuffer(buf1);
    SetActiveBuffer(buf2);
    buf2.Clr;

    Projection_3D_2D;


    Draw_Cube;

    Inc(angle1);
    Inc(angle2);

  until keypressed;

end.
