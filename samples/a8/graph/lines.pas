
uses crt, fastgraph;

const maxLines     =16;
      maxDrawLines =500;

type  LineDescr  = array [0..3] of smallint;

var   Ball,
      Vel,
      max          : LineDescr;
      Lines        : array [0..maxLines, 0..3] of smallint;

      t : smallint;

      count: word;

      i, new, old: byte;

begin
  randomize;

  InitGraph(8 + 16);

  max[0]:=ScreenWidth;
  max[1]:=ScreenHeight;
  max[2]:=ScreenWidth;
  max[3]:=ScreenHeight;

  for i := 0 to 3 do begin
      Vel[i] :=random(5) shl 1 + 2;
      Ball[i]:=random(smallint(max[i])) - 160;
  end;

  new   := 0;
  old   := 0;
  count := 0;

  repeat

    pause;

    for i := 0 to 3 do begin

        t:=Ball[i]+Vel[i];

	if t >= max[i] then begin
            t := smallint(max[i] shl 1)  - Vel[i] - Ball[i];
            Vel[i] := -Vel[i];
	end;

	if t<0 then begin
            t := -t;
            Vel[i] := -Vel[i];
	end;

        Ball[i] := t;
    end;

    if (count >= maxLines) then begin
        SetColor(0);

        Line (lines[old, 0], lines[old, 1], lines[old, 2], lines[old, 3]);

        old:=(old+1) mod maxLines;
    end;

    Lines[new, 0] := Ball[0];
    Lines[new, 1] := Ball[1];
    Lines[new, 2] := Ball[2];
    Lines[new, 3] := Ball[3];

    new:=(new+1) mod maxLines;

    SetColor(1);
    Line (ball[0], ball[1], ball[2], ball[3]);

    inc(count);

    until (consol<>cn_none) or (count=MaxDrawLines);

  repeat until consol<>cn_none;

end.
