//-----------------------------------------------------------------------------

procedure setLevel00; // test
begin
  setPlayer(@player1, 10, 12, JOY_RIGHT, PLY_CTRL   , PLY1_COLOUR, true);
  setPlayer(@player2, 30, 12, JOY_LEFT,  AI_STRAIGHT, PLY2_COLOUR, true);

  obstacles[0] := calcScrAddr(10,  6); obstacles[1] := calcScrAddr(30,  6);
  obstacles[2] := calcScrAddr(10, 18); obstacles[3] := calcScrAddr(30, 18);
  obstacles[4] := calcScrAddr(20,  2); obstacles[5] := calcScrAddr(20, 22);
end;

//-----------------------------------------------------------------------------

procedure setLevel01;
begin
  setPlayer(@player1, 10, 12, JOY_RIGHT, PLY_CTRL,    PLY1_COLOUR, true);
  setPlayer(@player2, 30, 12, JOY_LEFT,  AI_STRAIGHT, PLY2_COLOUR, true);

  obstacles[0] := calcScrAddr(10,  6); obstacles[1] := calcScrAddr(30,  6);
  obstacles[2] := calcScrAddr(10, 18); obstacles[3] := calcScrAddr(30, 18);
  obstacles[4] := calcScrAddr(20,  2); obstacles[5] := calcScrAddr(20, 22);
end;

//-----------------------------------------------------------------------------

procedure setLevel02;
begin
  setPlayer(@player1, 10, 12, JOY_RIGHT, PLY_CTRL,  PLY1_COLOUR, true);
  setPlayer(@player2, 30, 12, JOY_LEFT,  AI_BULLY,  PLY2_COLOUR, true);

  obstacles[0] := calcScrAddr(10,  6); obstacles[1] := calcScrAddr(30,  6);
  obstacles[2] := calcScrAddr(10, 18); obstacles[3] := calcScrAddr(30, 18);
  obstacles[4] := calcScrAddr(20,  2); obstacles[5] := calcScrAddr(20, 22);
end;

//-----------------------------------------------------------------------------

procedure setLevel03;
begin
  setPlayer(@player1, 10, 12, JOY_RIGHT, PLY_CTRL,  PLY1_COLOUR, true);
  setPlayer(@player2, 30, 12, JOY_LEFT,  AI_SAPPER, PLY2_COLOUR, true);

  obstacles[0] := calcScrAddr(10,  6); obstacles[1] := calcScrAddr(30,  6);
  obstacles[2] := calcScrAddr(10, 18); obstacles[3] := calcScrAddr(30, 18);
  obstacles[4] := calcScrAddr( 1, 12); obstacles[5] := calcScrAddr(20,  2);
  obstacles[6] := calcScrAddr(20, 22);
end;

//-----------------------------------------------------------------------------

procedure setLevel04;
begin
  setPlayer(@player1, 18, 12, JOY_LEFT,  PLY_CTRL,  PLY1_COLOUR, true);
  setPlayer(@player2, 22, 12, JOY_RIGHT, AI_MIRROR, PLY2_COLOUR, true);

  obstacles[0] := calcScrAddr(10,  6); obstacles[1] := calcScrAddr(30,  6);
  obstacles[2] := calcScrAddr(10, 18); obstacles[3] := calcScrAddr(30, 18);
  obstacles[4] := calcScrAddr( 1, 12); obstacles[5] := calcScrAddr(20,  2);
  obstacles[6] := calcScrAddr(20, 22); obstacles[7] := calcScrAddr(20, 12);
end;

//-----------------------------------------------------------------------------

procedure setLevel05;
begin
  setPlayer(@player1, 10, 12, JOY_RIGHT, PLY_CTRL,  PLY1_COLOUR, true);
  setPlayer(@player2, 30, 12, JOY_LEFT,  AI_MIRROR, PLY2_COLOUR, true);
  setPlayer(@player3, 20,  4, JOY_DOWN,  AI_BULLY,  PLY3_COLOUR, true);
  setPlayer(@player4, 20, 18, JOY_UP,    AI_SAPPER, PLY4_COLOUR, true);

  obstacles[0] := calcScrAddr(10,  6); obstacles[1] := calcScrAddr(30,  6);
  obstacles[2] := calcScrAddr(10, 18); obstacles[3] := calcScrAddr(30, 18);
  obstacles[4] := calcScrAddr( 1, 12); obstacles[5] := calcScrAddr(20,  2);
  obstacles[6] := calcScrAddr(20, 22);
end;

//-----------------------------------------------------------------------------

procedure setLevel06;
begin
  setPlayer(@player1, 18, 12, JOY_LEFT,  PLY_CTRL,  PLY1_COLOUR, true);
  setPlayer(@player2, 22, 12, JOY_RIGHT, AI_SAPPER, PLY2_COLOUR, true);
  setPlayer(@player3,  6,  6, JOY_DOWN,  AI_SAPPER, PLY3_COLOUR, true);
  setPlayer(@player4, 36, 18, JOY_RIGHT, AI_BULLY,  PLY4_COLOUR, true);

  obstacles[0] := calcScrAddr(10,  6); obstacles[1] := calcScrAddr(30,  6);
  obstacles[2] := calcScrAddr(10, 18); obstacles[3] := calcScrAddr(30, 18);
  obstacles[4] := calcScrAddr( 1, 12); obstacles[5] := calcScrAddr(20,  2);
  obstacles[6] := calcScrAddr(20, 22); obstacles[7] := calcScrAddr(20, 12);
end;

//-----------------------------------------------------------------------------

procedure setLevel07;
begin
  setPlayer(@player1, 18, 12, JOY_LEFT,  PLY_CTRL,  PLY1_COLOUR, true);
  setPlayer(@player2,  1, 23, JOY_RIGHT, AI_BULLY,  PLY2_COLOUR, true);
  setPlayer(@player3, 30,  4, JOY_DOWN,  AI_BULLY,  PLY3_COLOUR, true);
  setPlayer(@player4, 36, 21, JOY_UP,    AI_SAPPER, PLY4_COLOUR, true);

  obstacles[0] := calcScrAddr(10,  6); obstacles[1] := calcScrAddr(30,  6);
  obstacles[2] := calcScrAddr(10, 18); obstacles[3] := calcScrAddr(30, 18);
  obstacles[4] := calcScrAddr( 1, 12); obstacles[5] := calcScrAddr(20,  2);
  obstacles[6] := calcScrAddr(20, 22); obstacles[7] := calcScrAddr(20, 12);
end;

//-----------------------------------------------------------------------------

procedure setLevel08;
begin
  setPlayer(@player1,  1, 23, JOY_RIGHT, PLY_CTRL,  PLY1_COLOUR, true);
  setPlayer(@player2, 38, 23, JOY_LEFT,  AI_BULLY,  PLY2_COLOUR, true);
  setPlayer(@player3, 10,  1, JOY_DOWN,  AI_SAPPER, PLY3_COLOUR, true);
  setPlayer(@player4, 38,  1, JOY_LEFT,  AI_MIRROR, PLY4_COLOUR, true);

  obstacles[0] := calcScrAddr(10,  6); obstacles[1] := calcScrAddr(30,  6);
  obstacles[2] := calcScrAddr(10, 18); obstacles[3] := calcScrAddr(30, 18);
  obstacles[4] := calcScrAddr( 1, 12); obstacles[5] := calcScrAddr(20,  2);
  obstacles[6] := calcScrAddr(20, 22); obstacles[7] := calcScrAddr(20, 12);
end;

//-----------------------------------------------------------------------------