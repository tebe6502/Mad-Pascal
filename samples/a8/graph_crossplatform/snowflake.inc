(* Generic Koch Snowflake Include                *)
(* Defined TFloat as required before using this. *)

type
  FPoint = record
    x: TFloat;
    y: TFloat;
  end;

const
  cx = 160;
  cy = 115;

  ray0 = TFloat(70.0);
  ray1 = TFloat(ray0 / 2);

  sqrt3 = TFloat(1.7320580756);    // SQRT(3.0)

  iterations = 3;

  procedure LineTo2D(ax, ay: TFloat);
  begin

    LineTo(trunc(ax) + cx, trunc(ay) + cy);

  end;

  procedure MoveTo2D(ax, ay: TFloat);
  begin

    MoveTo(trunc(ax) + cx, trunc(ay) + cy);

  end;

  procedure NextSegments(ax, ay, bx, by: TFloat; n: Byte);
  const
    factor: TFloat = 0.288675135;  { SQRT(3) / 6 }
  var
    middle: FPoint;
    xDelta: TFloat;
    yDelta: TFloat;
    r, s, t: FPoint;
  begin

    if n > 0 then
    begin
      r.x := (ax + ax + bx) * (1 / 3);
      r.y := (ay + ay + by) * (1 / 3);

      t.x := (ax + bx + bx) * (1 / 3);
      t.y := (ay + by + by) * (1 / 3);

      middle.x := (ax + bx) * 0.5;
      middle.y := (ay + by) * 0.5;

      xDelta := bx - ax;
      yDelta := by - ay;

      s.x := middle.x + factor * yDelta;
      s.y := middle.y - factor * xDelta;

      SetColor(0);
      MoveTo2D(ax, ay);  {blank this line}
      LineTo2D(bx, by);

      SetColor(15);      {white color Atari/PC}
      MoveTo2D(ax, ay);  {add new lines}
      LineTo2D(r.x, r.y);
      LineTo2D(s.x, s.y);
      LineTo2D(t.x, t.y);
      LineTo2D(bx, by);

      NextSegments(ax, ay, r.x, r.y, n - 1);
      NextSegments(r.x, r.y, s.x, s.y, n - 1);
      NextSegments(s.x, s.y, t.x, t.y, n - 1);
      NextSegments(t.x, t.y, bx, by, n - 1);
    end;

  end;

  procedure KochSnowflake(a, b, c: FPoint; n: Byte);
  begin

    SetColor(1);
    MoveTo2D(a.x, a.y);
    LineTo2D(b.x, b.y);
    NextSegments(a.x, a.y, b.x, b.y, n);

    MoveTo2D(b.x, b.y);
    LineTo2D(c.x, c.y);
    NextSegments(b.x, b.y, c.x, c.y, n);

    MoveTo2D(c.x, c.y);
    LineTo2D(a.x, a.y);
    NextSegments(c.x, c.y, a.x, a.y, n);

  end {KochSnowflake};


var
  a, b, c: FPoint;

begin

  a.x := -ray0;
  a.y := -ray1 * SQRT3;

  b.x := ray0;
  b.y := -ray1 * SQRT3;

  c.x := 0;
  c.y := ray1 * SQRT3;

  KochSnowflake(a, b, c, iterations);

end;


