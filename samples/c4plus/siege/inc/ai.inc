//---------------------- GLOBALS ----------------------------------------------
// t0b                 : byte absolute $58;
// newDir              : byte absolute $59;
// t0n                 : boolean absolute $5a;
// t0w                 : word absolute $5b;
// availDir            : byte;
// ply                 : ^Player;
// player1, player2, player3, player4 : Player;
//----------------------- CONST -----------------------------------------------
// JOY_UP = 1; JOY_DOWN = 2; JOY_LEFT = 4; JOY_RIGHT = 8; JOY_FIRE = 64;
// direction: array [0..3] of byte = (
//   JOY_UP, JOY_DOWN, JOY_LEFT, JOY_RIGHT
// );
//-----------------------------------------------------------------------------

procedure aiStraight; // brain = 1
begin
  if (availDir and ply.dir) <> 0 then newDir := ply.dir
  else begin
    if availDir = (JOY_UP or JOY_DOWN) then newDir := direction[Random(0) and 1]
    else begin
      case availDir of
        JOY_UP    : newDir := JOY_UP;
        JOY_DOWN  : newDir := JOY_DOWN;
      end;
    end;
    if availDir = (JOY_LEFT or JOY_RIGHT) then newDir := direction[(Random(0) and 1) + 2]
    else begin
      case availDir of
        JOY_LEFT   : newDir := JOY_LEFT;
        JOY_RIGHT  : newDir := JOY_RIGHT;
      end;
    end;
  end;
end;

//-----------------------------------------------------------------------------

procedure aiMirror; // brain = 2
begin
  case player1.dir of
    JOY_UP    : t0b := JOY_DOWN;
    JOY_DOWN  : t0b := JOY_UP;
    JOY_LEFT  : t0b := JOY_RIGHT;
    JOY_RIGHT : t0b := JOY_LEFT;
  end;

  if (availDir and t0b) <> 0 then newDir := t0b
  else aiStraight;
end;

//-----------------------------------------------------------------------------

procedure aiRandom; // brain = 3
begin
  t0b := ply.dir;
  if (Random(0) and 3) = 0 then t0b := direction[Random(4)];

  if (availDir and t0b) <> 0 then newDir := t0b
  else aiStraight;
end;

//-----------------------------------------------------------------------------