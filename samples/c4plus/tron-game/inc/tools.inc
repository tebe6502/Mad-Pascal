//-----------------------------------------------------------------------------

function calcScrAddr(x, y: byte): word;
begin
  Result := SCREEN_ADDR + x + mul40[y];
end;

//-----------------------------------------------------------------------------

procedure putChar(x, y, v: byte); overload;
begin
  Poke(calcScrAddr(x, y), v);
end;

//-----------------------------------------------------------------------------

procedure putChar(x, y, v, c: byte); overload;
begin
  t0w := calcScrAddr(x, y);
  Poke(t0w, v); Poke(t0w - OFFSET, c);
end;

//-----------------------------------------------------------------------------

procedure printXY(s: string; x, y, c: byte);
begin
  t0w := calcScrAddr(x, y);
  Move(s[1], pointer(t0w), length(s));
  FillChar(pointer(t0w - OFFSET), length(s), c);
end;

//-----------------------------------------------------------------------------

procedure printBigCharXY(x, y, ch, c: byte);
begin
  t0w := calcScrAddr(x, y);
  t1w := CHARSET + (8 * ch);

  for i0b := 0 to 7 do begin
    t0b := Peek(t1w + i0b);
    for i1b := 7 downto 0 do begin
      if (t0b and 1) = 1 then begin
        poke(t0w + i1b, $a0);
        poke(t0w - OFFSET + i1b, c);
      end;
      t0b := t0b shr 1;
    end;
    Inc(t0w, 40);
  end;
end;

//-----------------------------------------------------------------------------

procedure printBigXY(x, y, c: byte; s: string);
var
  i0b : byte;
begin
  for i0b := 1 to length(s) do printBigCharXY(x + (8 * (i0b - 1)), y, ord(s[i0b]), c);
end;

//-----------------------------------------------------------------------------

function getChar(x, y: byte): byte;
begin
  Result := Peek(calcScrAddr(x, y));
end;

//-----------------------------------------------------------------------------

procedure showScore;
begin
  if player1.isAlive then putChar(30, 0, player1.score, PLY1_COLOUR);
  if player2.isAlive then putChar(32, 0, player2.score, PLY2_COLOUR);
  if player3.isAlive then putChar(34, 0, player3.score, PLY3_COLOUR);
  if player4.isAlive then putChar(36, 0, player4.score, PLY4_COLOUR);
end;

//-----------------------------------------------------------------------------

procedure updateScore;
begin
  t0b := 0;

  if player1.isAlive then begin Inc(player1.score); t0b := player1.colour end;
  if player2.isAlive then begin Inc(player2.score); t0b := player2.colour end;
  if player3.isAlive then begin Inc(player3.score); t0b := player3.colour end;
  if player4.isAlive then begin Inc(player4.score); t0b := player4.colour end;

  if t0b <> 0 then printBigCharXY(16,  8, PLY_HEAD_UP, t0b);
end;

//-----------------------------------------------------------------------------

procedure checkAvailDir;
begin
  availDir := 0;
  t0w := calcScrAddr(ply.x, ply.y);

  if Peek(t0w - 40) = EMPTY then availDir := availDir or JOY_UP;
  if Peek(t0w + 40) = EMPTY then availDir := availDir or JOY_DOWN;
  if Peek(t0w - 1)  = EMPTY then availDir := availDir or JOY_LEFT;
  if Peek(t0w + 1)  = EMPTY then availDir := availDir or JOY_RIGHT;
end;

//-----------------------------------------------------------------------------

procedure animateStuff;
var
  counter: byte;
  frame  : word;
begin
  //obstacles
  Inc(counter);
  if (counter and 1) <> 0 then
    frame := CHARSET + (8 * OBSTACLE_1)
  else
    frame := CHARSET + (8 * OBSTACLE_2);
  Move(pointer(frame), pointer(CHARSET + (8 * OBSTACLE)), 8);

  //background
  Poke(CHARSET + $2B3, Peek(CHARSET + $2B3) shl 1);
  Poke(CHARSET + $2B7, Peek(CHARSET + $2B7) shl 2);
  if Peek(CHARSET + $2B3) = 0 then Poke(CHARSET + $2B3, 1);
  if Peek(CHARSET + $2B7) = 0 then Poke(CHARSET + $2B7, 1);
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

  if ply.isAlive then ply.head := t0b else ply.head := t0b + 8;

  putChar(ply.x, ply.y, ply.head, ply.colour);
end;

//-----------------------------------------------------------------------------

procedure playerBusted;
begin
  ply.isAlive := false; Dec(alive);
  putChar(ply.x, ply.y, ply.head, ply.colour + $80);
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
  info: string = 'fire!'~;
begin
  printXY(info, 2, 0, $71 + $80);
  putChar(player1.x, player1.y, player1.head, player1.colour + $80);

  repeat until joyStatus = JOY_FIRE;

  FillChar(pointer(SCREEN_ADDR + 2), length(info), WALL);
  FillChar(pointer(ATTRIBUTE_ADDR + 2), length(info), WALL_COLOUR);
  putChar(player1.x, player1.y, player1.head, player1.colour);
end;

//-----------------------------------------------------------------------------

procedure endScreen;
var
  winner: string = 'winner!'~;
  loser : string = 'loser!'~;
begin
  pause;
  if player1.score = ZERO + VICTORIES then
    printXY(winner, 2, 0, $71 + $80)
  else begin
    printXY(loser, 2, 0, $71 + $80);
    printBigCharXY(12,  5, ROGER + 0, $71);
    printBigCharXY(20,  5, ROGER + 1, $71);
    printBigCharXY(12, 13, ROGER + 2, $71);
    printBigCharXY(20, 13, ROGER + 3, $71);
  end;

  pause(250);
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
