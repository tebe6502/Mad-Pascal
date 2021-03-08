//-----------------------------------------------------------------------------

procedure human; // brain = 0
begin
  newDir := ply.dir;
  case joyStatus of
    JOY_UP    : if ply.dir <> JOY_DOWN  then newDir := JOY_UP;
    JOY_DOWN  : if ply.dir <> JOY_UP    then newDir := JOY_DOWN;
    JOY_LEFT  : if ply.dir <> JOY_RIGHT then newDir := JOY_LEFT;
    JOY_RIGHT : if ply.dir <> JOY_LEFT  then newDir := JOY_RIGHT;
  end;

  if (newDir and availDir) = 0 then begin
    ply.isAlive := false; Dec(alive);
  end;
end;

//-----------------------------------------------------------------------------

procedure aiStraight; // brain = 1
begin
  if (availDir and ply.dir) <> 0 then newDir := ply.dir
  else begin
    if availDir = (JOY_UP or JOY_DOWN) then newDir := direction[Random(2)]
    else begin
      case availDir of
        JOY_UP    : newDir := JOY_UP;
        JOY_DOWN  : newDir := JOY_DOWN;
      end;
    end;
    if availDir = (JOY_LEFT or JOY_RIGHT) then newDir := direction[byte(Random(2) + 2)]
    else begin
      case availDir of
        JOY_LEFT   : newDir := JOY_LEFT;
        JOY_RIGHT  : newDir := JOY_RIGHT;
      end;
    end;
  end;
end;

//-----------------------------------------------------------------------------


procedure aiSapper; // brain = 2
const
  LOOK_AHEAD = 5;
var
  l, r, u, d: byte;
begin
  l := 0; r := 0; u := 0; d := 0;
  t0w := calcScrAddr(ply.x, ply.y);

  if (availDir and JOY_UP) <> 0 then begin
    for i0b := LOOK_AHEAD downto 1 do begin
      if Peek(t0w - mul40[i0b]) = EMPTY then Inc(u);
      if Peek(t0w - mul40[i0b] + 1) = EMPTY then Inc(u);
      if Peek(t0w - mul40[i0b] - 1) = EMPTY then Inc(u);
    end;
  end;

  if (availDir and JOY_DOWN) <> 0 then begin
      for i0b := LOOK_AHEAD downto 1 do begin
      if Peek(t0w + mul40[i0b]) = EMPTY then Inc(d);
      if Peek(t0w + mul40[i0b] + 1) = EMPTY then Inc(d);
      if Peek(t0w + mul40[i0b] - 1) = EMPTY then Inc(d);
    end;
  end;

  if (availDir and JOY_LEFT) <> 0 then begin
    for i0b := LOOK_AHEAD downto 1 do begin
      if Peek(t0w - i0b) = EMPTY then Inc(l);
      if Peek(t0w - i0b + 40) = EMPTY then Inc(l);
      if Peek(t0w - i0b - 40) = EMPTY then Inc(l);
    end;
  end;

  if (availDir and JOY_RIGHT) <> 0 then begin
    for i0b := LOOK_AHEAD downto 1 do begin
      if Peek(t0w + i0b) = EMPTY then Inc(r);
      if Peek(t0w + i0b + 40) = EMPTY then Inc(r);
      if Peek(t0w + i0b - 40) = EMPTY then Inc(r);
    end;
  end;

  t0b := d;
  if t0b < u then t0b := u;
  if t0b < l then t0b := l;
  if t0b < r then t0b := r;

  if t0b = d then t0b := JOY_DOWN;
  if t0b = u then t0b := JOY_UP;
  if t0b = l then t0b := JOY_LEFT;
  if t0b = r then t0b := JOY_RIGHT;

  if (availDir and t0b) <> 0 then newDir := t0b
  else aiStraight;
end;

//-----------------------------------------------------------------------------

procedure aiBully; // brain = 3
begin
  t0b := ply.dir;

  if player1.isAlive or player2.isAlive then begin

    if player1.isAlive then tmpPly := @player1 else tmpPly := @player2;

    if ply.y > tmpPly.y then t0b := JOY_UP else t0b := JOY_DOWN;
    if (ply.y = tmpPly.y) or ((availDir and t0b) = 0) then
      if ply.x > tmpPly.x then t0b := JOY_LEFT else t0b := JOY_RIGHT;

  end;

  if (availDir and t0b) <> 0 then newDir := t0b
  else aiSapper;

end;

//-----------------------------------------------------------------------------

procedure aiMirror; // brain = 4
begin
  t0b := ply.dir;

  if player1.isAlive then begin
    case player1.dir of
      JOY_UP    : t0b := JOY_DOWN;
      JOY_DOWN  : t0b := JOY_UP;
      JOY_LEFT  : t0b := JOY_RIGHT;
      JOY_RIGHT : t0b := JOY_LEFT;
    end;
  end;

  if (availDir and t0b) <> 0 then newDir := t0b
  else aiSapper;
end;

//-----------------------------------------------------------------------------