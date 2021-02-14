// set Z flag to 2

{$i 'inc/const.inc'}
{$i 'inc/types.inc'}
{$i 'inc/globals.inc'}
{$i 'inc/tools.inc'}
{$i 'inc/init.inc'}
{$i 'inc/ai.inc'}

//-----------------------------------------------------------------------------

procedure human; // brain = 0
begin
  newDir := ply.dir;
  JOY := JOY_SELECT_1; KEY_PIO := $ff; t0b := JOY xor $ff;

  case t0b of
    JOY_UP    : if ply.dir <> JOY_DOWN  then newDir := JOY_UP;
    JOY_DOWN  : if ply.dir <> JOY_UP    then newDir := JOY_DOWN;
    JOY_LEFT  : if ply.dir <> JOY_RIGHT then newDir := JOY_LEFT;
    JOY_RIGHT : if ply.dir <> JOY_LEFT  then newDir := JOY_RIGHT;
  end;

  if (newDir and availDir) = 0 then begin
    ply.isDead := true; ply.head := PLY_CRASH; Dec(alive);
  end;
end;

//-----------------------------------------------------------------------------

procedure playerMove(p: pointer);
begin
  ply := p;

  if not ply.isDead then begin

    checkAvailDir(ply.x, ply.y);

    if availDir = 0 then begin
      ply.isDead := true; Dec(alive);
      putChar(ply.x, ply.y, PLY_CRASH, ply.colour + $80);
    end else begin

      case ply.brain of
        PLY_CTRL    : human;
        AI_STRAIGHT : aiStraight;
        AI_MIRROR   : aiMirror;
        AI_RANDOM   : aiRandom;
      end;

      if ply.dir = newDir then begin
        if (newDir and %1100) <> 0 then t0b := PLY_TAIl_LR else t0b := PLY_TAIl_UD;
      end else begin
        if ((ply.dir and %1010) <> 0) and ((newDir and %0101) <> 0) then t0b := PLY_TAIl_RD;
        if ((ply.dir and %1001) <> 0) and ((newDir and %0110) <> 0) then t0b := PLY_TAIl_RU;
        if ((ply.dir and %0110) <> 0) and ((newDir and %1001) <> 0) then t0b := PLY_TAIl_LD;
        if ((ply.dir and %0101) <> 0) and ((newDir and %1010) <> 0) then t0b := PLY_TAIl_LU;
      end;
      putChar(ply.x, ply.y, t0b, ply.colour);

      ply.dir := newDir;

      case newDir of
        JOY_UP    : Dec(ply.y);
        JOY_DOWN  : Inc(ply.y);
        JOY_LEFT  : Dec(ply.x);
        JOY_RIGHT : Inc(ply.x);
      end;

      putChar(ply.x, ply.y, ply.head, ply.colour);
    end;

  end;

end;

//-----------------------------------------------------------------------------

procedure startScreen;
begin
  repeat
    JOY := JOY_SELECT_1; KEY_PIO := $ff; t0b := JOY xor $ff;
  until t0b = JOY_FIRE;
end;

//-----------------------------------------------------------------------------

procedure mainLoop;
begin
  initPlayfield;
  startScreen;

  alive := 3;
  repeat
    pause(3); // 2 fast; 3 normal; 4 slow
    playerMove(@player1); playerMove(@player2);
    playerMove(@player3); playerMove(@player4);
  until (alive = 0) or (alive = $ff);

  if not player1.isDead then Inc(player1.score);
  if not player2.isDead then Inc(player2.score);
  if not player3.isDead then Inc(player3.score);
  if not player4.isDead then Inc(player4.score);

  pause(100);
end;

//-----------------------------------------------------------------------------

begin
  repeat
    player1.score := ZERO; player2.score := ZERO;
    player3.score := ZERO; player4.score := ZERO;

    gameOver := false;
    repeat
      mainLoop;
      if player1.score = ZERO + 9 then gameOver := true;
      if player2.score = ZERO + 9 then gameOver := true;
      if player3.score = ZERO + 9 then gameOver := true;
      if player4.score = ZERO + 9 then gameOver := true;
    until gameOver;
    showScore;

    pause(200);
  until false;
end.
