//-----------------------------------------------------------------------------

procedure initPlayers(p: pointer; x, y, dir, brain, head, colour: byte; isDead: boolean);
begin
  ply := p;
  ply.brain := brain; ply.x := x; ply.y := y; ply.dir := dir;
  ply.head := head; ply.colour := colour; ply.isDead := isDead;
end;

//-----------------------------------------------------------------------------

procedure initPlayfield;
begin
  initPlayers(@player1, 10, 12, JOY_RIGHT, PLY_CTRL,    PLY_HEAD, PLY1_COLOUR, false);
  initPlayers(@player2, 30, 12, JOY_LEFT,  AI_MIRROR,   PLY_HEAD, PLY2_COLOUR, false);
  initPlayers(@player3, 20,  6, JOY_DOWN,  AI_STRAIGHT, PLY_HEAD, PLY3_COLOUR, false);
  initPlayers(@player4, 20, 18, JOY_UP,    AI_RANDOM,   PLY_HEAD, PLY4_COLOUR, false);

  BORDERCOLOR := $1f; BGCOLOR := 0;
  FillChar(pointer(SCREEN_ADDR), 24 * 40, EMPTY);

  for t0b := 39 downto 0 do begin
    Poke(SCREEN_ADDR + t0b, WALL);
    Poke((SCREEN_ADDR + 24 * 40) + t0b, WALL);
    Poke(ATTRIBUTE_ADDR + t0b, WALL_COLOUR);
    Poke((ATTRIBUTE_ADDR + 24 * 40) + t0b, WALL_COLOUR);
  end;

  for t0b := 24 downto 1 do begin
    DPoke((SCREEN_ADDR - 1) + mul40[t0b], WALL * 256 + WALL);
    DPoke((ATTRIBUTE_ADDR - 1) + mul40[t0b], WALL_COLOUR * 256 + WALL_COLOUR);
  end;

  putChar(player1.x, player1.y, player1.head, player1.colour);
  putChar(player2.x, player2.y, player2.head, player2.colour);
  putChar(player3.x, player3.y, player3.head, player3.colour);
  putChar(player4.x, player4.y, player4.head, player4.colour);

  showScore;
end;

//-----------------------------------------------------------------------------