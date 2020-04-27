//
// ;*** define your project wide constants here
// 
// ;*** I like to keep memory locations at top of this file
//

FREE_BOTTOM = $6000;  // and sometimes I like to do some relative addressing
//CHARSET_ADDRESS = FREE_BOTTOM;
VIDEO_RAM_ADDRESS = FREE_BOTTOM; 
DISPLAY_LIST_ADDRESS = VIDEO_RAM_ADDRESS + $1000; 
//STRINGS_ADDRESS = VIDEO_RAM_ADDRESS + $400;

//RMT_PLAYER_ADDRESS = $8000;
//RMT_MODULE_ADDRESS = $8800;

// ;*** and here goes all other stuff

NONE = $ff;


