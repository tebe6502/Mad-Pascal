{$r 'res/gfx.rc'}

{$librarypath 'src/systems'}

uses sys_vic20;

const
  CRT_CHARS_ADR = CART_ADR + CART_SIZE - CHARSET_SIZE;
  CRT_TITLE_ADR = CRT_CHARS_ADR - SCREEN_SIZE;

const
  GAME_BLACK  = BLACK;
  GAME_WHITE  = WHITE;
  GAME_RED    = RED;
  GAME_CYAN   = CYAN;
  GAME_PURPLE = PURPLE;
  GAME_GREEN  = GREEN;
  GAME_BLUE   = BLUE;
  GAME_YELLOW = YELLOW;
  GAME_ORANGE = ORANGE;

  C_SPACE      = $20;
  C_FRUIT      = $40;

  C_WALL_H     = $41;
  C_WALL_VE    = $42;
  C_WALL_VW    = $43;

  C_TAIL_UP    = $44;
  C_TAIL_DOWN  = $45;
  C_TAIL_RIGHT = $46;
  C_TAIL_LEFT  = $47;

  C_HEAD_UP    = $48;
  C_HEAD_DOWN  = $49;
  C_HEAD_LEFT  = $4a;
  C_HEAD_RIGHT = $4b;


  C_BODY_V     = $4c;
  C_BODY_H     = $4d;

  C_BODY_SW    = $4e;
  C_BODY_SE    = $4f;
  C_BODY_NW    = $50;
  C_BODY_NE    = $51;

{$i 'src/game.inc'}
