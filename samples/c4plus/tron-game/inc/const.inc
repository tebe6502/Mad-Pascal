//-----------------------------------------------------------------------------

const
  TITLE_SCR_APL = $4000;
  MP_LOGO_APL   = $4a00;
  MUSIC_APL     = $5800;
  GFX           = $5800;
  MUSIC         = $8000;

  VBI_TRIGGER   = $e0;

//-----------------------------------------------------------------------------

const
  ATTRIBUTE_ADDR = $0800; SCREEN_ADDR = $0c00; OFFSET = SCREEN_ADDR - ATTRIBUTE_ADDR;
  CHARSET = $3c00; CHBASE = $50;

  BACKGROUND_COLOUR = $21; BORDER_COLOUR = 0; PLAYFIELD_COLOUR = $51;
  PLY1_COLOUR = $62; PLY2_COLOUR = $5d; PLY3_COLOUR = $71; PLY4_COLOUR = $55;
  WALL_COLOUR = $41; OBST_COLOUR = $65;

  JOY_UP = 1; JOY_DOWN = 2; JOY_LEFT = 4; JOY_RIGHT = 8; JOY_FIRE = 64;
  JOY_SELECT_1 = %00000010; JOY_SELECT_2 = %00000100;

  EMPTY = CHBASE + 6; WALL = $a0; ZERO = $30;
  OBSTACLE = CHBASE + 7; OBSTACLE_1 = CHBASE + 4; OBSTACLE_2 = CHBASE + 5;
  ROGER = CHBASE + 12;

  PLY_TAIL_UD = $42; PLY_TAIL_LR = $40;
  PLY_TAIL_RD = $7d; PLY_TAIL_RU = $6e; PLY_TAIL_LD = $6d; PLY_TAIL_LU = $70;
  PLY_HEAD_UP = CHBASE; PLY_HEAD_LEFT = CHBASE + 1;
  PLY_HEAD_RIGHT = CHBASE + 2; PLY_HEAD_DOWN = CHBASE + 3;

  VICTORIES = 9;     // possible values: 1-9

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

  fonts: array [0..(8 * 16 - 1)] of byte = (
    24,24,36,36,36,60,102,90,       // ship up
    0,3,62,197,197,62,3,0,          // ship left
    0,192,124,163,163,124,192,0,    // ship right
    90,102,60,36,36,36,24,24,       // ship down
    0,60,110,98,70,118,60,0,        // obstacle 1
    0,60,118,70,98,110,60,0,        // obstacle 2
    0,0,0,16,0,0,0,1,               // background
    0,0,0,0,0,0,0,0,                // obstacle
    24,24,52,36,44,60,231,153,      // ship crash up
    3,2,62,205,229,62,2,3,          // ship crash left
    192,64,124,179,167,124,64,192,  // ship crash right
    153,231,60,44,36,52,24,24,      // ship crash down
    0,7,15,25,81,115,95,14,         // roger up-left
    0,224,240,152,138,206,250,112,  // roger up-right
    6,6,3,0,0,0,0,0,                // roger down-left
    96,96,192,0,0,0,0,0             // roger down-right
  );

//-----------------------------------------------------------------------------