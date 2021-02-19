//-----------------------------------------------------------------------------

function calcScreenAddr(x, y: byte): word;
begin
  Result := SCREEN_ADDR + x + mul40[y];
end;

//-----------------------------------------------------------------------------

procedure putChar(x, y, v: byte); overload;
begin
  Poke(calcScreenAddr(x, y), v);
end;

//-----------------------------------------------------------------------------

procedure putChar(x, y, v, c: byte); overload;
begin
  t0w := calcScreenAddr(x, y);
  Poke(t0w, v); Poke(t0w - OFFSET, c);
end;

//-----------------------------------------------------------------------------

procedure printXY(s: string; x, y, c: byte);
begin
  t0w := calcScreenAddr(x, y);
  Move(s[1], pointer(t0w), length(s));
  FillChar(pointer(t0w - OFFSET), length(s), c);
end;


//-----------------------------------------------------------------------------

function getChar(x, y: byte): byte;
begin
  Result := Peek(calcScreenAddr(x, y));
end;

//-----------------------------------------------------------------------------

procedure showScore;
begin
  if player1.isAlive then putChar(30, 0, player1.score, player1.colour);
  if player2.isAlive then putChar(32, 0, player2.score, player2.colour);
  if player3.isAlive then putChar(34, 0, player3.score, player3.colour);
  if player4.isAlive then putChar(36, 0, player4.score, player4.colour);
end;

//-----------------------------------------------------------------------------

procedure updateScore;
begin
  if player1.isAlive then Inc(player1.score);
  if player2.isAlive then Inc(player2.score);
  if player3.isAlive then Inc(player3.score);
  if player4.isAlive then Inc(player4.score);
end;

//-----------------------------------------------------------------------------

procedure checkAvailDir;
begin
  availDir := 0;
  t0w := calcScreenAddr(ply.x, ply.y);

  if Peek(t0w - 40) = EMPTY then availDir := availDir or JOY_UP;
  if Peek(t0w + 40) = EMPTY then availDir := availDir or JOY_DOWN;
  if Peek(t0w - 1)  = EMPTY then availDir := availDir or JOY_LEFT;
  if Peek(t0w + 1)  = EMPTY then availDir := availDir or JOY_RIGHT;
end;

//-----------------------------------------------------------------------------

procedure animateObstacles;
var
  counter, obst: byte;
begin
  Inc(counter);
  if (counter and 1) <> 0 then obst := OBSTACLE_1 else obst := OBSTACLE_2;
  for i0b := OBST_QUANTITY downto 0 do Poke(obstacles[i0b], obst);
end;

//-----------------------------------------------------------------------------

procedure saveObstacles;
begin
  for i0b := OBST_QUANTITY downto 0 do begin
    if obstacles[i0b] <> TRASH then begin
      Poke(obstacles[i0b], OBSTACLE_1);
      Poke(obstacles[i0b] - OFFSET, OBST_COLOUR);
    end;
  end;
end;

//-----------------------------------------------------------------------------

procedure drawPlayer;
begin
  if ply.dir = newDir then begin
    if (newDir and %1100) <> 0 then t0b := PLY_TAIL_LR else t0b := PLY_TAIL_UD;
  end else begin
    if ((ply.dir and %1010) <> 0) and ((newDir and %0101) <> 0) then t0b := PLY_TAIL_RD;
    if ((ply.dir and %1001) <> 0) and ((newDir and %0110) <> 0) then t0b := PLY_TAIL_RU;
    if ((ply.dir and %0110) <> 0) and ((newDir and %1001) <> 0) then t0b := PLY_TAIL_LD;
    if ((ply.dir and %0101) <> 0) and ((newDir and %1010) <> 0) then t0b := PLY_TAIL_LU;
  end;
  putChar(ply.x, ply.y, t0b);

  ply.dir := newDir;

  case newDir of
    JOY_UP    : begin Dec(ply.y); t0b := PLY_HEAD_UP    end;
    JOY_DOWN  : begin Inc(ply.y); t0b := PLY_HEAD_DOWN  end;
    JOY_LEFT  : begin Dec(ply.x); t0b := PLY_HEAD_LEFT  end;
    JOY_RIGHT : begin Inc(ply.x); t0b := PLY_HEAD_RIGHT end;
  end;

  ply.head := t0b;

  putChar(ply.x, ply.y, ply.head, ply.colour);
end;

//-----------------------------------------------------------------------------

procedure playerBusted;
begin
  ply.isAlive := false; Dec(alive);
  putChar(ply.x, ply.y, ply.head, byte(ply.colour + $80));
end;

//-----------------------------------------------------------------------------

procedure checkJoyStatus;
begin
  JOY := JOY_SELECT_1; KEYSCAN := $ff;
  joyStatus := JOY xor $ff;
end;

//-----------------------------------------------------------------------------

procedure setPlayer(p: pointer; x, y, dir, brain, colour: byte; isAlive: boolean);
begin
  ply := p;

  case dir of
    JOY_UP    : t0b := PLY_HEAD_UP;
    JOY_DOWN  : t0b := PLY_HEAD_DOWN;
    JOY_LEFT  : t0b := PLY_HEAD_LEFT;
    JOY_RIGHT : t0b := PLY_HEAD_RIGHT;
  end;

  ply.brain := brain; ply.x := x; ply.y := y; ply.dir := dir;
  ply.head := t0b; ply.colour := colour; ply.isAlive := isAlive;
  if isAlive then begin
    Inc(alive); putChar(x, y, t0b, colour);
  end;
end;

//-----------------------------------------------------------------------------

procedure nextLevel;
begin
  Inc(level); if level = 8 then level := 5;
end;

//-----------------------------------------------------------------------------

procedure startScreen;
var
  info: string = #6#9#18#5#33;
begin
  printXY(info, 2, 0, $71 + $80);
  putChar(player1.x, player1.y, player1.head, byte(player1.colour + $80));

  repeat checkJoyStatus until joyStatus = JOY_FIRE;

  FillChar(pointer(SCREEN_ADDR + 2), length(info), WALL);
  FillChar(pointer(ATTRIBUTE_ADDR + 2), length(info), WALL_COLOUR);
  putChar(player1.x, player1.y, player1.head, player1.colour);
end;

//-----------------------------------------------------------------------------

procedure endScreen;
var
  winner: string = #23#9#14#14#5#18#33;
  loser : string = #12#15#19#5#18#33;
begin
  if player1.score = ZERO + VICTORIES then printXY(winner, 2, 0, $71 + $80)
  else printXY(loser, 2, 0, $71 + $80);
end;

//-----------------------------------------------------------------------------

function isGameOver: boolean;
begin
  if player1.score = ZERO + VICTORIES then gameOver := true;
  if player2.score = ZERO + VICTORIES then gameOver := true;
  if player3.score = ZERO + VICTORIES then gameOver := true;
  if player4.score = ZERO + VICTORIES then gameOver := true;
  Result := gameOver;
end;

//-----------------------------------------------------------------------------

function isOneLeft: boolean;
begin
  Result := (alive = 0) or (alive = $ff);
end;

//-----------------------------------------------------------------------------
