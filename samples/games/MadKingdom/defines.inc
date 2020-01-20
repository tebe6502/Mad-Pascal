const

// ******************************************  DATA MEMORY LOCATIONS

        CARDS_ADDRESS = $6600;
        STRINGS_ADDRESS = CARDS_ADDRESS + $100;
        IMG_ADDRESS = CARDS_ADDRESS + $180;

        // free space


        rmt_player = $9600; // physicaly it is $9240
        rmt_modul = $9a48;

        GFX_RAM = $A800;
        GFX_RAM_SIZE = 48 * 40; // $780
        RLE_BUFFER = GFX_RAM + GFX_RAM_SIZE; // $1E0

        // $B160 -> $2A0 bytes free (672)

        CHARSET_ADDRESS = $B400;
        PMG_BASE = $B800;   // size $400
        TXT_RAM = $BC00;
        TXT_RAM_SIZE = 24 * 40; // $3C0

// ****************************************** DECK/GAME SETTINGS

        VERSION = '0.07';
        CARD_MAX_NUM = 32;
        USER_DECK_SIZE = CARD_MAX_NUM;
        CARD_HEADER_DATA_SIZE = 11;
        REQ_MAX_NUM = 2;

// ****************************************** CONSTS / ENUMS

        CHOICE_NO = 0;
        CHOICE_YES = 1;

        ICON_DELIMITER = 0;
        ICON_MONEY = 36;
        ICON_POPULATION = 2;
        ICON_ARMY = 6;
        ICON_HEALTH = 8;
        ICON_HAPPINES = 10;
        ICON_CHURCH = 7;

        SEASON_SPRING = 0;
        SEASON_SUMMER = 1;
        SEASON_AUTUMN = 2;
        SEASON_WINTER = 3;

        FLAG_MONEY      = %10000000;
        FLAG_POPULATION = %01000000;
        FLAG_ARMY       = %00100000;
        FLAG_HEALTH     = %00010000;
        FLAG_HAPPINES   = %00001000;
        FLAG_CHURCH     = %00000100;

        EMPTY_TABLE_SLOT = 1234;

        SCREEN_TITLE = 0;
        SCREEN_INGAME = 1;

// ****************************************** COLORS / GUI

        COLOR_CARDNAME = $F0;
        COLOR_NEUTRAL = $90;
        COLOR_YES = $B8;
        COLOR_NO = $26;
        COLOR_CURSOR_SELECT = COLOR_NEUTRAL;
        COLOR_YEAR_END = $50;
        COLOR_GAME_OVER = $22;

        YESNO_X_POS = 96;

// ****************************************** COLORS / GUI

        MSX_INGAME = 0;
        MSX_GAMEOVER = $0D;
        MSX_INTERLUDE = $11;
        MSX_TITLE = $14;

// ****************************************** DATA TYPES

type
        deckT = array [0..0] of word;
        cardDataT = array[0..0] of byte;

        resourceChangeT = record
            moneyMin: smallInt;
            moneyMax: smallInt;
            populationMin: smallInt;
            populationMax: smallInt;
            armyMin: smallInt;
            armyMax: smallInt;
            healthMin: shortint;
            healthMax: shortint;
            happinesMin: shortint;
            happinesMax: shortint;
            churchMin: shortint;
            churchMax: shortint;
        end;
        resourceChangePtr = ^resourceChangeT;

        resourceT = record
            money: integer;
            population: integer;
            army: integer;
            health: shortint;
            happines: shortint;
            church: shortint;
        end;

        requirementT = record
            required: byte;
            how: byte;
            amount: integer;
        end;

        cardT = record
            cardtype: byte;             // 1 byte
            actorPtr : word;
            descPtr : word;
            sentPtr : word;
            yesPtr : word;
            noPtr : word;
            imgPtr : word;
            changeYesFlags: byte;
            changeNoFlags: byte;            // 15 bytes
            resourceYes: resourceChangeT;   // 18 bytes
            resourceNo:  resourceChangeT;   // 18 bytes  // 51 b
            reqCount: byte;
            requirement1: requirementT;  // 6 bytes
            requirement2: requirementT;  // 6 bytes
            actorNamePtr: word;
        end;

        labelT = array [0..16] of char;

        kingdomT = record
            // player
            kingdomName: labelT;
            kingAlive : boolean;
            child: shortInt;
            // time
            time: smallInt;
            // resources
            resources: resourceT;
            tax: shortInt;
            salary: shortInt;
            income : string[40];
            ending: byte;
        end;

        smallintPtr = ^smallInt;
        shortIntPtr = ^shortInt;
