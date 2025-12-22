const

PLANE_MASK_TRANSPARENT        = %00000001;
PLANE_MASK_BORDER_TRANSPARENT = %00001000;
PLANE_MASK_DOUBLE_WIDTH       = %00010000;

//-------------------------------------

SCR_W       = 48;
SCR_H       = 30;
SCR_SIZE    = SCR_W * SCR_H;

MAX_X   = SCR_W shr 1;
MAX_Y   = SCR_H shr 1;

//-------------------------------------

{$i 'inc/scanners_addr.inc'}

DL: array of byte = [                     // Display List memory address
  $f3,                                    // LMS + LFS + LBS + LCG
  lo(LMS),hi(LMS),                        // Memory address for character data (first text row)
  lo(LFS),hi(LFS),                        // Memory address for character color data (first text row)
  lo(LBS),hi(LBS),                        // Memory address for background color data (first text row)
  lo(LCG),hi(LCG),                        // Character generator memory address (8x8 font)
  $3a, $3a, $3a, $3a, $3a, $3a, $3a, $3a, $3a, $3a, // MODE2 + MULTICOLOR_BIT + DOUBLE_WIDTH_BIT
  $3a, $3a, $3a, $3a, $3a, $3a, $3a, $3a, $3a, $3a, // MODE2 + MULTICOLOR_BIT + DOUBLE_WIDTH_BIT
  $3a, $3a, $3a, $3a, $3a, $3a, $3a, $3a, $3a, $3a, // MODE2 + MULTICOLOR_BIT + DOUBLE_WIDTH_BIT
  $82,lo(word(@DL)),hi(word(@DL))         // JMP to begin of DL and wait for Vertical BLank
];

//-------------------------------------

COL_WIHTE   = %11111111;
COL_BLACK   = %00000000;
COL_GROUND  = %01111001;

COL_HAIR    = COL_BLACK;  // black hair (shared)
COL_SKIN    = COL_WIHTE;  // white skin (shared)
COL_HERO1   = %10101010;  // LFS t-shirt
COL_HERO2   = COL_GROUND; // LBS backgr

//-------------------------------------

JOY_UP      = %11111110;
JOY_DOWN    = %11111101;
JOY_LEFT    = %11111011;
JOY_RIGHT   = %11110111;
JOY_SPACE   = %11011111;

JOY_DELAY   = 7;

//-------------------------------------

TXT_INFO_1  = 'sokoban x65'~;
TXT_INFO_2  = 'enable controller 1'~;
TXT_INFO_3  = 'fire + left/right change level'~;
TXT_INFO_4  = 'fire + up/down reset level'~;
TXT_INFO_5  = 'press fire (space on emu)'~;