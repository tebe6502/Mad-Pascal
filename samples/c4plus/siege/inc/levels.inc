//-----------------------------------------------------------------------------

procedure setObstacles;
begin
  //SCREEN_ADDR + x + mul40[y];
  Poke(SCREEN_ADDR + 10 + (40 *  6), OBSTACLE);
  Poke(SCREEN_ADDR + 30 + (40 *  6), OBSTACLE);
  Poke(SCREEN_ADDR + 10 + (40 * 18), OBSTACLE);
  Poke(SCREEN_ADDR + 30 + (40 * 18), OBSTACLE);
  Poke(SCREEN_ADDR + 20 + (40 *  2), OBSTACLE);
  Poke(SCREEN_ADDR + 20 + (40 * 22), OBSTACLE);
end;

//-----------------------------------------------------------------------------

procedure setLevel01;
begin
  setPlayer(@player1, 10, 12, JOY_RIGHT, PLY_CTRL,    PLY1_COLOUR, true);
  setPlayer(@player2, 30, 12, JOY_LEFT,  AI_STRAIGHT, PLY2_COLOUR, true);

  setObstacles;
end;

//-----------------------------------------------------------------------------

procedure setLevel02;
begin
  setPlayer(@player1, 10, 12, JOY_RIGHT, PLY_CTRL,  PLY1_COLOUR, true);
  setPlayer(@player2, 30, 12, JOY_LEFT,  AI_BULLY,  PLY2_COLOUR, true);

  setObstacles;
end;

//-----------------------------------------------------------------------------

procedure setLevel03;
begin
  setPlayer(@player1, 10, 12, JOY_RIGHT, PLY_CTRL,  PLY1_COLOUR, true);
  setPlayer(@player2, 30, 12, JOY_LEFT,  AI_SAPPER, PLY2_COLOUR, true);

  setObstacles;
  Poke(SCREEN_ADDR + 1 + (40 * 12), OBSTACLE);
end;

//-----------------------------------------------------------------------------

procedure setLevel04;
begin
  setPlayer(@player1, 18, 12, JOY_LEFT,  PLY_CTRL,  PLY1_COLOUR, true);
  setPlayer(@player2, 22, 12, JOY_RIGHT, AI_MIRROR, PLY2_COLOUR, true);

  setObstacles;
  Poke(SCREEN_ADDR +  1 + (40 * 12), OBSTACLE);
  Poke(SCREEN_ADDR + 20 + (40 * 12), OBSTACLE);
end;

//-----------------------------------------------------------------------------

procedure setLevel05;
begin
  setPlayer(@player1, 10, 12, JOY_RIGHT, PLY_CTRL,  PLY1_COLOUR, true);
  setPlayer(@player2, 30, 12, JOY_LEFT,  AI_MIRROR, PLY2_COLOUR, true);
  setPlayer(@player3, 20,  4, JOY_DOWN,  AI_BULLY,  PLY3_COLOUR, true);
  setPlayer(@player4, 20, 18, JOY_UP,    AI_SAPPER, PLY4_COLOUR, true);

  setObstacles;
  Poke(SCREEN_ADDR + 1 + (40 * 12), OBSTACLE);
end;

//-----------------------------------------------------------------------------

procedure setLevel06;
begin
  setPlayer(@player1, 18, 12, JOY_LEFT,  PLY_CTRL,  PLY1_COLOUR, true);
  setPlayer(@player2, 22, 12, JOY_RIGHT, AI_SAPPER, PLY2_COLOUR, true);
  setPlayer(@player3,  6,  6, JOY_DOWN,  AI_SAPPER, PLY3_COLOUR, true);
  setPlayer(@player4, 36, 18, JOY_RIGHT, AI_BULLY,  PLY4_COLOUR, true);

  setObstacles;
  Poke(SCREEN_ADDR +  1 + (40 * 12), OBSTACLE);
  Poke(SCREEN_ADDR + 20 + (40 * 12), OBSTACLE);
end;

//-----------------------------------------------------------------------------

procedure setLevel07;
begin
  setPlayer(@player1, 18, 12, JOY_LEFT,  PLY_CTRL,  PLY1_COLOUR, true);
  setPlayer(@player2,  1, 23, JOY_RIGHT, AI_BULLY,  PLY2_COLOUR, true);
  setPlayer(@player3, 30,  4, JOY_DOWN,  AI_BULLY,  PLY3_COLOUR, true);
  setPlayer(@player4, 36, 21, JOY_UP,    AI_SAPPER, PLY4_COLOUR, true);

  setObstacles;
  Poke(SCREEN_ADDR +  1 + (40 * 12), OBSTACLE);
  Poke(SCREEN_ADDR + 20 + (40 * 12), OBSTACLE);
end;

//-----------------------------------------------------------------------------

procedure setLevel08;
begin
  setPlayer(@player1,  1, 23, JOY_RIGHT, PLY_CTRL,  PLY1_COLOUR, true);
  setPlayer(@player2, 38, 23, JOY_LEFT,  AI_BULLY,  PLY2_COLOUR, true);
  setPlayer(@player3, 10,  1, JOY_DOWN,  AI_SAPPER, PLY3_COLOUR, true);
  setPlayer(@player4, 38,  1, JOY_LEFT,  AI_MIRROR, PLY4_COLOUR, true);

  setObstacles;
  Poke(SCREEN_ADDR +  1 + (40 * 12), OBSTACLE);
  Poke(SCREEN_ADDR + 20 + (40 * 12), OBSTACLE);
end;

//-----------------------------------------------------------------------------