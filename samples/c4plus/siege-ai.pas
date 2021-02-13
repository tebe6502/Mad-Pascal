// set Z flag to 2

const
  ATTRIBUTE_ADDR = $0800; SCREEN_ADDR = $0c00;

  EMPTY = $20; WALL = $a0; WALL_COLOUR = $41;

  PLY_HEAD = $51; PLY_CRASH = $57; PLY_TAIl_UD = $42; PLY_TAIl_LR = $40;
  PLY_TAIl_RD = $7d; PLY_TAIl_RU = $6e; PLY_TAIl_LD = $6d; PLY_TAIl_LU = $70;
  PLY1_COLOUR = $5f; PLY2_COLOUR = $5d; PLY3_COLOUR = $71; PLY4_COLOUR = $55;

  JOY_UP = 1; JOY_DOWN = 2; JOY_LEFT = 4; JOY_RIGHT = 8; JOY_FIRE = 64;
  JOY_SELECT_1 = %00000010; JOY_SELECT_2 = %00000100;

//-----------------------------------------------------------------------------

const
  mul40: array [0..24] of word = (
     0 * 40,  1 * 40,  2 * 40,  3 * 40,  4 * 40,  5 * 40,
     6 * 40,  7 * 40,  8 * 40,  9 * 40, 10 * 40, 11 * 40,
    12 * 40, 13 * 40, 14 * 40, 15 * 40, 16 * 40, 17 * 40,
    18 * 40, 19 * 40, 20 * 40, 21 * 40, 22 * 40, 23 * 40,
    24 * 40
  );
  direction: array [0..3] of byte = (
    JOY_UP, JOY_DOWN, JOY_LEFT, JOY_RIGHT
  );

//-----------------------------------------------------------------------------

type
  Player = record
    x, y, head, colour, dir, brain : byte;
    isDead                   : boolean;
  end;

//-----------------------------------------------------------------------------

var
  KEY_PIO             : byte absolute $fd30;
  JOY                 : byte absolute $ff08;
  BORDERCOLOR         : byte absolute $ff15;
  BGCOLOR             : byte absolute $ff19;
  t0b                 : byte absolute $58;
  newDir              : byte absolute $59;
  t0n                 : boolean absolute $5a;
  t0w                 : word absolute $5b;

//-----------------------------------------------------------------------------

var
  gameOver            : boolean;
  availDir, alive     : byte;
  ply                 : ^Player;

//-----------------------------------------------------------------------------

var
  player1, player2, player3, player4 : Player;

//-----------------------------------------------------------------------------

procedure initPlayfield;
begin
  alive := 3;

  BORDERCOLOR := $1f; BGCOLOR := 0;
  FillChar(pointer(SCREEN_ADDR), 24 * 40, EMPTY);

  for t0b := 39 downto 0 do begin
    Poke(SCREEN_ADDR + t0b, WALL);
    Poke((SCREEN_ADDR + 24 * 40 ) + t0b, WALL);
    Poke(ATTRIBUTE_ADDR + t0b, WALL_COLOUR);
    Poke((ATTRIBUTE_ADDR + 24 * 40) + t0b, WALL_COLOUR);
  end;

  for t0b := 24 downto 1 do begin
    DPoke((SCREEN_ADDR - 1) + mul40[t0b], WALL * 256 + WALL);
    DPoke((ATTRIBUTE_ADDR - 1) + mul40[t0b], WALL_COLOUR * 256 + WALL_COLOUR);
  end;
end;

procedure initPlayers;
begin
  player1.brain := 1; player1.x := 10; player1.y := 10; player1.head := PLY_HEAD;
  player1.colour := PLY1_COLOUR; player1.isDead := false; player1.dir := JOY_RIGHT;

  player2.brain := 1; player2.x := 30; player2.y := 10; player2.head := PLY_HEAD;
  player2.colour := PLY2_COLOUR; player2.isDead := false; player2.dir := JOY_LEFT;

  player3.brain := 1; player3.x := 20; player3.y := 6;  player3.head := PLY_HEAD;
  player3.colour := PLY3_COLOUR; player3.isDead := false; player3.dir := JOY_DOWN;

  player4.brain := 1; player4.x := 20; player4.y := 18; player4.head := PLY_HEAD;
  player4.colour := PLY4_COLOUR; player4.isDead := false; player4.dir := JOY_UP;
end;

//-----------------------------------------------------------------------------

procedure putChar(x, y, v, c: byte);
begin
  t0w := ATTRIBUTE_ADDR + mul40[y] + x;
  Poke(t0w, c); Poke(t0w + (SCREEN_ADDR - ATTRIBUTE_ADDR), v);
end;

procedure checkAvailDir(x, y: byte);
begin
  availDir := 0;
  t0w := SCREEN_ADDR + mul40[y] + x;

  if Peek(t0w - 40) = EMPTY then availDir := availDir or JOY_UP;
  if Peek(t0w + 40) = EMPTY then availDir := availDir or JOY_DOWN;
  if Peek(t0w - 1)  = EMPTY then availDir := availDir or JOY_LEFT;
  if Peek(t0w + 1)  = EMPTY then availDir := availDir or JOY_RIGHT;
end;

//-----------------------------------------------------------------------------

// brain = 0
procedure human;
begin
  newDir := ply.dir;
  JOY := JOY_SELECT_1; KEY_PIO := $ff; t0b := JOY xor $ff;

  case t0b of
    JOY_UP    : newDir := t0b;
    JOY_DOWN  : newDir := t0b;
    JOY_LEFT  : newDir := t0b;
    JOY_RIGHT : newDir := t0b;
  end;

  if (newDir and availDir) = 0 then begin
    ply.isDead := true; alive := 0; ply.head := PLY_CRASH;
  end;
end;

// brain = 1
procedure ai_SimpleRandom;
begin
  t0n := false;
  repeat
    newDir := direction[Random(4)];
    if (availDir and newDir) <> 0 then t0n := true;
  until t0n;
end;

// brain = 2
procedure ai_Straightforward;
begin
  if (availDir and ply.dir) <> 0 then newDir := ply.dir
  else begin
    t0n := false;
    repeat
      newDir := direction[Random(4)];
      if (availDir and newDir) <> 0 then t0n := true;
    until t0n;
  end;
end;

// brain = 3
procedure ai_Swinger;
begin
  if ((availDir and ply.dir) <> 0) and (Random(3) = 0) then newDir := ply.dir
  else begin
    t0n := false;
    repeat
      newDir := direction[Random(4)];
      if (availDir and newDir) <> 0 then t0n := true;
    until t0n;
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
        0 : human;
        1 : ai_SimpleRandom;
        2 : ai_Straightforward;
        3 : ai_Swinger;
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

begin

  gameOver := false;

  repeat
    initPlayers;
    initPlayfield;

    player1.brain := 3; // ai_Swinger
    player2.brain := 1; // ai_SimpleRandom
    player3.brain := 2; // ai_Straightforward
    player4.brain := 0; // human

    repeat
      pause(1); playerMove(@player1);
      pause(1); playerMove(@player2);
      pause(1); playerMove(@player3);
      pause(1); playerMove(@player4);
    until alive = 0;

    pause(100);
  until gameOver;

end.
