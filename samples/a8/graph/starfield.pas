{ smallint Math Starfield }
{ Jack Mott - (C) 1996 }
{ free to use for noncommercial purposes }
{ Give credit where credit is due }
{ Contact: thecrow@iconn.net }
PROGRAM StarFieldCoolness;

USES
 crt, fastgraph;
CONST
 MAX = 128;
VAR
  xv :array[0..MAX-1] of smallint;
  yv :array[0..MAX-1] of smallint;
  x,y:array[0..MAX-1] of smallint;
  c:array[0..MAX-1] of smallint;

  x2,y2:smallint;
  xyS: cardinal;
  i,count:byte;
  speed:byte;
  k:char;


PROCEDURE ResetStar(star:smallint);
VAR
  r:smallint;
BEGIN
  x[star] := random(320)+1;
  y[star] := random(192)+1;
  x[star] := x[star] - 250;
  y[star] := y[star] - 100;

if speed <> 0 then
  begin
  xv[star] := x[star] div speed;
  yv[star] := y[star] div speed;
  end
else
  begin
  xv[star] := x[star];
  yv[star] := y[star];
  end;

if (xv[star] = 0) and (yv[star] = 0) then
  begin
    xv[star] := 1;
    yv[star] := 1;
  end;

END;


PROCEDURE MoveRight;
VAR
  i:byte;
BEGIN
  FOR i := MAX-1 DOWNTO 0 DO xv[i] := xv[i] - 1;
END;


PROCEDURE MoveLeft;
VAR
  i:byte;
BEGIN
  FOR i := MAX-1 DOWNTO 0 DO xv[i] := xv[i] + 1;
END;


PROCEDURE MoveUp;
VAR
  i:byte;
BEGIN
  FOR i := MAX-1 DOWNTO 0 DO yv[i] := yv[i] + 1;
END;


PROCEDURE MoveDown;
VAR
  i:byte;
BEGIN
  FOR i := MAX-1 DOWNTO 0 DO yv[i] := yv[i] - 1;
END;


PROCEDURE MoveUpLeft;
VAR
  i:byte;
BEGIN
  FOR i := MAX-1 DOWNTO 0 DO
    begin
      yv[i] := yv[i] + 1;
      xv[i] := xv[i] + 1;
    end;
END;


PROCEDURE MoveUpRight;
VAR
  i:byte;
BEGIN
  FOR i := MAX-1 DOWNTO 0 DO
    begin
      yv[i] := yv[i] + 1;
      xv[i] := xv[i] - 1;
    end;
END;


PROCEDURE MoveDownRight;
VAR
  i:byte;
BEGIN
  FOR i := MAX-1 DOWNTO 0 DO
    begin
      yv[i] := yv[i] - 1;
      xv[i] := xv[i] - 1;
    end;
END;


PROCEDURE MoveDownLeft;
VAR
  i:byte;
BEGIN
  FOR i := MAX-1 DOWNTO 0 DO
    begin
      yv[i] := yv[i] - 1;
      xv[i] := xv[i] + 1;
    end;
END;


BEGIN

InitGraph(8+16);

randomize;
speed := 15;

FOR i := MAX-1 DOWNTO 0 DO ResetStar(i);
count := 0;

REPEAT
inc(count);

SetColor(15);

FOR i := MAX-1 DOWNTO 0 DO
  BEGIN

    {Optional, makes stars move faster as they get closer}
    { Havent gotten this to look very good yet }
{
    if count mod 15 = 0 then
      begin
        if xv[i] > 0 then xv[i] := xv[i] + 1
        else if xv[i] < 0 then xv[i] := xv[i] - 1;

        if yv[i] > 0 then yv[i] := yv[i] + 1
        else if yv[i] < 0 then yv[i] := yv[i] - 1;
      end;
 }
    x[i] := x[i] + xv[i];
    y[i] := y[i] + yv[i];

    IF (x[i] > 160) or (x[i] < -160) or (y[i] > 96) or (y[i] < -96) THEN ResetStar(i);

    x2 := x[i];
    y2 := y[i];
    xyS := x2*x2+y2*y2;
    { x^2+y^2 = d^2 (distance from origin) would work better but slower}
    if xyS > 40000 then c[i] := 15
    else if xyS > 10000 then c[i] :=7
    else c[i] := 8;

    putpixel(x[i]+160, y[i]+96);//c[i]);

  END;


    if keypressed then
      begin
        k := readkey;
        if k = 'q' then halt;
        if k = '6' then MoveRight;
        if k = '4' then MoveLeft;
        if k = '8' then MoveUp;
        if k = '2' then MoveDown;
        if k = '7' then MoveUpLeft;
        if k = '9' then MoveUpRight;
        if k = '1' then MoveDownLeft;
        if k = '3' then MoveDownRight;
        if k = '=' then dec(speed);
        if k = '-' then inc(speed);
      end;

pause;

SetColor(0);

FOR i := MAX-1 DOWNTO 0 DO
  putpixel(x[i]+160,y[i]+96);

UNTIL 1 = 2;

END.
