const
    BOARDWIDTH = 21;
    BOARDHEIGHT = 100;
    SCREEN_WIDTH = 40;
    BOARDSIZE = BOARDWIDTH * BOARDHEIGHT;

    DM_SIZE = 24;

    LOGO_ADDRESS = $8000;
    LEVELS_ADDRESS = LOGO_ADDRESS + 1080;

    DL = $AE00;
    DLG = $AE80;

    STRINGS_ADDRESS = $AF00;

    rmt_player = $b400;
    rmt_modul = $B800;

    PMGBASE = $C000;
    CHARSET_GAME_ADDRESS = PMGBASE + $400;
    CHARSET_TITLE_ADDRESS = CHARSET_GAME_ADDRESS + $400;
    TXT_RAM = CHARSET_TITLE_ADDRESS + $400;
    BOARDBASE = $D800;
    DM_DATA = BOARDBASE;
    GFX_RAM = $E040;


    DIR_UP = 0;
    DIR_RIGHT = 1;
    DIR_DOWN = 2;
    DIR_LEFT = 3;
    DIR_NONE = 4;

    JOY_UP = %0001;
    JOY_DOWN = %0010;
    JOY_LEFT = %0100;
    JOY_RIGHT = %1000;

    BOARD_TOP = 18;
    BOARD_BOTTOM = 102;
    SPRITE_HEIGHT = 12;
    PMG_LEFT_OFFSET = 44;

    GAME_LIVES = 3;
    LIFE_BONUS = 10000;
    GHOST_NUM = 4;
    GHOST_DESPAWN_DISTANCE = 16;
    GHOST_DESPAWN_DELAY = 100;

    BONUS_DELAY = 20;
    BONUS_COUNTDOWN = 5;

    COLOR_G1 = $26;
    COLOR_G2 = $4A;
    COLOR_G3 = $8C;
    COLOR_G4 = $18;
    COLOR_ESCAPE = $76;
    COLOR_ESCAPE_BLINK = $0F;

	// ai helper tables
    joy2dir : array [0..15] of byte = (8,2,0,8,1,8,8,8,3,8,8,8,8,8,8,8);
    n2dir : array [0..15] of byte   = (8,0,2,8,3,8,8,8,1,8,8,8,8,8,8,8);
    dirs : array [0..3] of byte = (1,2,4,8);

    // max number of board features (can be increased)
    SPAWNERS_NUM = 10;
    HSC_URI = 'http://atari.pl/hsc/?x=104';


    // LETTERS
    _A = $0605;
    _C = $120b;
    _D = $0807;
    _E = $0403;
    _G = $0c0b;
    _H = $1615;
    _I = $1817;
    _L = $201f;
    _M = $0e0d;
    _O = $0f0b;
    _R = $0201;
    _S = $1110;
    _U = $1a19;
    _V = $1c1b;
    _Y = $0a09;
    _QSIGN = $1e1d;
    _SPACE = 0;

    _0 = $3433;
    _1 = $2221;
    _2 = $2423;
    _3 = $2625;
    _4 = $2827;
    _5 = $2a29;
    _6 = $2c2b;
    _7 = $2e2d;
    _8 = $302f;
    _9 = $3231;

    txt_numbers:array [0..9] of word = (_0,_1,_2,_3,_4,_5,_6,_7,_8,_9);

    txt_level:array [0..4] of word = (_L,_E,_V,_E,_L);
    txt_score:array [0..4] of word = (_S,_C,_O,_R,_E);
    txt_your:array [0..3] of word = (_Y,_O,_U,_R);
    txt_high:array [0..3] of word = (_H,_I,_G,_H);
    txt_game:array [0..3] of word = (_G,_A,_M,_E);
    txt_over:array [0..3] of word = (_O,_V,_E,_R);
    txt_ready_q:array [0..6] of word = (_R,_E,_A,_D,_Y,_SPACE,_QSIGN);

	keycodes: array [0..63] of byte = (
		108,106, 59, 0, 0, 107, 43, 42, 111, 0, 112, 117, 155, 105, 45, 61, 118, 0, 99, 0, 0, 98, 120, 122, 52, 0, 51, 54, 27, 53, 50, 49, 44, 32, 46, 110, 0, 109, 47, 0, 114, 0, 101, 121, 127, 116, 116, 113, 57, 0, 48, 55, 126, 56, 60, 62, 102, 104, 100, 0, 0, 103, 115, 97
	);

    SONG_TITLE = 8;
    SONG_READY = 0;
    SONG_GAME = 6;
    SONG_OVER = 2;
    SONG_DIED = 4;
    SONG_WIN = 9;
    SONG_SILENCE = 11;
    SONG_PILL = 13;
    
    SECRET_LEN = 4;

type
    boardT = array [0..BOARDSIZE] of byte;

    gameStateT = (
        TITLE_SCREEN,
        GAME_START,
        GAME_NORMAL,
        GAME_ESCAPE,
        GAME_WIN,
        GAME_DEAD,
        GAME_OVER
    );

    ghostT = record
        x,y:byte;
        step:shortInt;
        dir:byte;
        level:byte;     // 1:always random    2:1/2 random     3:1/3 random...
        sx,sy:smallInt;
        spriteOffset:byte;
        spriteHeight:byte;
        dx,dy,deadCount,reward, despawn:byte;
    end;

    pacT = record
        x,y:byte;
        step:shortInt;
        frame:byte;
        dir:byte;
        sx,sy:word;
        sprite: array[0..0] of pointer;
    end;

    levelT = record
        startX,startY: byte;
        exitX, exitY: byte;
        ai: array [0..3] of byte;
        delay: byte;
        pillTime: byte;
        dotLimit: word;
        colors: array [0..4] of byte;
    end;

