//-----------------------------------------------------------------------------

const
  ATTRIBUTE_ADDR = $0800; SCREEN_ADDR = $0c00; OFFSET = SCREEN_ADDR - ATTRIBUTE_ADDR;

  BACKGROUND_COLOUR = $1f; BOREDER_COLOUR = 0;
  PLY1_COLOUR = $62; PLY2_COLOUR = $5d; PLY3_COLOUR = $71; PLY4_COLOUR = $55;
  OBST_COLOUR = $65;

  JOY_UP = 1; JOY_DOWN = 2; JOY_LEFT = 4; JOY_RIGHT = 8; JOY_FIRE = 64;
  JOY_SELECT_1 = %00000010; JOY_SELECT_2 = %00000100;

  EMPTY = $20; WALL = $a0; WALL_COLOUR = $41; ZERO = $30;
  OBSTACLE_1 = $54; OBSTACLE_2 = $55;

  PLY_CRASH = $2a; PLY_BUSTED = $57;
  PLY_TAIL_UD = $42; PLY_TAIL_LR = $40;
  PLY_TAIL_RD = $7d; PLY_TAIL_RU = $6e; PLY_TAIL_LD = $6d; PLY_TAIL_LU = $70;
  PLY_HEAD_UP = $50; PLY_HEAD_LEFT = $51; PLY_HEAD_RIGHT = $52; PLY_HEAD_DOWN = $53;

  OBST_QUANTITY = 7; // means 8 (fixed value)
  VICTORIES = 9;     // possible values: 1-9
  TRASH = $5e;       // t0w -> this dirty trick make me sick ;)
  LOOK_AHEAD = 5;

  PLY_CTRL = 0; AI_STRAIGHT = 1; AI_SAPPER = 2; AI_BULLY = 3; AI_MIRROR = 4;

//-----------------------------------------------------------------------------

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

  fonts: array [0..(8 * 6 - 1)] of byte = (
    24,24,36,36,36,60,102,90,       // ship up
    0,3,62,197,197,62,3,0,          // ship left
    0,192,124,163,163,124,192,0,    // ship right
    90,102,60,36,36,36,24,24,       // ship down
    0,60,110,98,70,118,60,0,        // obstacle 1
    0,60,118,70,98,110,60,0         // obstacle 2
  );

//-----------------------------------------------------------------------------