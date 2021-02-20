//-----------------------------------------------------------------------------

procedure initPlayfield;
begin
  BACKGROUND := BACKGROUND_COLOUR; BOREDER := BOREDER_COLOUR;
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

  for i0b := OBST_QUANTITY downto 0 do obstacles[i0b] := TRASH;
end;

//-----------------------------------------------------------------------------

procedure initPlayers;
begin
  alive := $ff;
  player1.isAlive := false; player2.isAlive := false;
  player3.isAlive := false; player4.isAlive := false;
end;

//-----------------------------------------------------------------------------

procedure initScore;
begin
  player1.score := ZERO; player2.score := ZERO;
  player3.score := ZERO; player4.score := ZERO;
end;

//-----------------------------------------------------------------------------

procedure initArena;
begin
  initPlayfield; initPlayers;

  case level of
    0 : setLevel00; // test
    1 : setLevel01; // easy
    2 : setLevel02; // easy
    3 : setLevel03; // easy
    4 : setLevel04; // moderate
    5 : setLevel05; // moderate
    6 : setLevel06; // hard
    7 : setLevel07; // very hard
    8 : setLevel08; // very hard
  end;

  saveObstacles; animateObstacles; showScore;
end;

//-----------------------------------------------------------------------------

procedure initFonts;
var fonts: array [0..(8 * 6 - 1)] of byte = (
  24,24,36,36,36,60,102,90,       // ship up
  0,3,62,197,197,62,3,0,          // ship left
  0,192,124,163,163,124,192,0,    // ship right
  90,102,60,36,36,36,24,24,       // ship down
  0,60,110,98,70,118,60,0,        // obstacle 1
  0,60,118,70,98,110,60,0         // obstacle 2
);
begin
  Move(pointer($d000), pointer($6000), $400);
  Move(fonts, pointer($6000 + (8 * $50)), 8 * 6);

  // set bit 2
  RAMROMSEL := RAMROMSEL and %11111011;

  // 24 = $6000 / $400 on 2-7 bits
  CHBAS := (CHBAS and %11) or 24 shl 2;
end;

//-----------------------------------------------------------------------------

