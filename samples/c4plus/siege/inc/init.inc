//-----------------------------------------------------------------------------

procedure initPlayfield;
begin
  //restore 7 custom char
  Poke(CHARSET + $2B3, 16); Poke(CHARSET + $2B7, 1);

  BACKGROUND := BACKGROUND_COLOUR; BOREDER := BOREDER_COLOUR;
  FillChar(pointer(SCREEN_ADDR), 24 * 40, EMPTY);
  FillChar(pointer(ATTRIBUTE_ADDR), 24 * 40, PLAYFIELD_COLOUR);

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
    1 : setLevel01; // easy
    2 : setLevel02; // easy
    3 : setLevel03; // easy
    4 : setLevel04; // moderate
    5 : setLevel05; // moderate
    6 : setLevel06; // hard
    7 : setLevel07; // very hard
    8 : setLevel08; // very hard
  end;

  animateObstacles; showScore;
end;

//-----------------------------------------------------------------------------

procedure initFonts;
begin
  Move(pointer($d000), pointer(CHARSET), $400);
  Move(fonts, pointer(CHARSET + (8 * $50)), SizeOf(fonts));

  // set bit 2
  RAMROMSEL := RAMROMSEL and %11111011;

  // 12 = $3000 / $400 on 2-7 bits
  CHBAS := (CHBAS and %11) or 12 shl 2;
end;

//-----------------------------------------------------------------------------

