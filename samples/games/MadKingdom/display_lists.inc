const DL_game: array [0..73] of byte =
    (
    112,
    128 + 112,
    112,
    128 + 64 + 2, Lo(TXT_RAM), Hi(TXT_RAM),   // first status line
    64,     // gap
    2,      // second status line
    128 + 80,     // gap
    2,      // card name line
    128 + 64,
    64 + $0D, Lo(GFX_RAM), Hi(GFX_RAM),
    $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D,
    $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D,
    $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, // 48 lines
    128+64,
    64 + 2, Lo(TXT_RAM)+120, Hi(TXT_RAM),   // card description
    48, // gap
    2, // card sentence
    128 + 64,
    2, 2, 2,
    64 + 1, Lo(word(@DL_game)), Hi(word(@DL_game))
    );

const DL_title: array [0..73] of byte =
    (
    112, // 8 blank lines
    112, // 8 blank lines
    128 + 112, // 8 blank lines
    64 + $0D, Lo(GFX_RAM), Hi(GFX_RAM), // logo
    $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D,
    128 + $0D,
    $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D,
    128 + $0D, // 40 lines
    0,
    64 + 2, Lo(TXT_RAM), Hi(TXT_RAM),  // first line of text
    16 , 2, 16, 2, 16, 2, 16, 2, 16, 2, 16, 2, 16, 2, 16, 2, 16, 2, 16, 2, 16, 2,
    64 + 1, lo(word(@DL_title)), hi(word(@DL_title)) // jump to start
    );

// dli ingame colors
const dliCol1: array[0..5] of byte = ( 12, 12, 8, 10, 8, 10 );
var dliColbg: array[0..5] of byte = ( 0, 0, COLOR_CARDNAME, 6, 0, COLOR_NEUTRAL );

