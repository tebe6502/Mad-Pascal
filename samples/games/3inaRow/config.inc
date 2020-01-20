type
    TTile = array[0..1] of word;

const
    PMG_ADDRESS = $e000;
    CHARSET_TILE_ADDRESS = $e400;
    VRAM_ADDRESS = $e800;
    TXTRAM_ADDRESS = $eb00;
    PROGRESS_ADDRESS = $ee00;
    DLIST_ADDRESS = $ef00;
    CHARSET_TXT_ADDRESS = $f000;
    CHARSET_LEVELS_ADDRESS = $f400;
    LEVELS_ADDRESS = $b800;
    
    
    RMT_MODULE = $c000;
    RMT_PLAYER = $b800;    
    
    MOVES_STORE_SIZE = 100;
    MOVES_FINDER_SPEED = 1; // possible moves tested per frame (out of 81)
    

    M_OFFSET = 384;
    P0_OFFSET = 512;
    P1_OFFSET = 640;
    P2_OFFSET = 768;
    P3_OFFSET = 896;

    LEFT_SPRITE_OFFSET = 88;
    TOP_SPRITE_OFFSET = 26;

    LEFT_CURSOR_OFFSET = 82;
    TOP_CURSOR_OFFSET = 34;

    LEFT_MENU_OFFSET = 80;
    TOP_MENU_OFFSET = 26;


    PMG_COLOR0 = $38;
    PMG_COLOR1 = $9a;

    BOARD_COLOR0 = $04;
    BOARD_COLOR1 = $0;
    BOARD_COLOR2 = $ef;
    BOARD_COLOR3 = $1a;
    BOARD_COLOR4 = $66;
    TXT_BG_COLOR = $0;
    TXT_FG_COLOR = $0c;

    NONE = $ff;
    CURSOR_SPEED = 8;
    DROP_SPEED = 1;
    FADE_DELAY = 120;

    GAME_MODE_ARCADE = 0;
    GAME_MODE_SURVIVAL = 1;
    GAME_MODE_ENDLESS = 2;

    BLACK_BALL_INTERVAL = 10;

    Y_offsets: array [0..9] of word = (0, 64, 128, 192, 256, 320, 384, 448, 512, 576);
    X_pad = 6;
    X_offsets: array [0..9] of byte = (X_pad, X_pad+2, X_pad+4, X_pad+6, X_pad+8, X_pad+10, X_pad+12, X_pad+14, X_pad+16, X_pad+18);
    masks1: array [0..9] of byte = (%11000000,%00110000,%00001100,%00000011,0,0,0,0,0,0);
    masks2: array [0..9] of byte = (0,0,0,0,%11000000,%00110000,%00001100,%00000011,0,0);
    masks3: array [0..9] of byte = (0,0,0,0,0,0,0,0,%00001111,%11110000);

    scoreBase: array [0..5] of byte = (10, 15, 30, 60, 120, 240);

    GAME_TITLE = 0;
    GAME_LEVEL_SELECT = 1;
    GAME_STARTED = 2;
    GAME_INGAME_MENU = 3;
    GAME_RESTART = 4;
    GAME_NEXT = 5;
    GAME_OVER_GOALREACHED = 6;
    GAME_OVER_OUTOFMOVES = 7;
    GAME_OVER_OUTOFTIME = 8;
    NO_MORE_MOVES = 9;

    LEVELS_MAX = 64;
    LEVEL_SURVIVAL = $fe;
    LEVEL_ENDLESS = $ff;
    
    REACH_GOAL = %0;
    NO_SHADOWS = %1;
    NO_BLOCKS = %10;
    NO_MARBLES = %100;
