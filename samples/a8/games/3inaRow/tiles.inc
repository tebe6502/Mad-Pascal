const

    TILE_EMPTY = 0;
    TILE_DUST = 13;
    TILE_HOLE = 14;
    TILE_BLACK = 15;
    TILE_MARBLE = 16;
    TILE_BOMB = 17;
    TILE_BLOCK = 18;
    TILE_VOID = 19;
    TILE_XPLODE1 = 20;
    TILE_XPLODE2 = 21;
    TILE_SHADOW = 99;

    tileC2: TTile = ( $0201, $2221 );
    tileC2x: TTile = ( $0605, $2625 );
    tileB: TTile = ( $0403, $2423 );
    tileBx: TTile = ( $0807, $2827 );
    tileC4: TTile = ( $8281, $a2a1 );
    tileC4x: TTile = ( $8685, $a6a5 );
    tileDust: TTile = ( $0a09,$2a29);
    tileHole: TTile = ( $0c0b,$2c2b);
    tileEmpty: TTile = ( $0e0d,$2e2d);
    tileBlack: TTile = ( $100f,$302f);
    tileMarble: TTile = ( $1211,$b2b1);
    tileBomb: TTile = ( $1413,$3433);
    tileBlock: TTile = ( $1615,$3635);
    tileXplode1: TTile = ( $504f,$706f);
    tileXplode2: TTile = ( $5251,$7271);
    tileVoid: TTile = (0,0);

    tileCursorB: TTile = ( $4443,$6463);
    tileCursorBx: TTile = ( $5655,$7675);
    tileCursorC2: TTile = ( $4241,$6261);
    tileCursorC2x: TTile = ( $5453,$7473);
    tileCursorC4: TTile = ( $c2c1,$e2e1);
    tileCursorC4x: TTile = ( $d4d3,$f4f3);
    tileCursorBlack: TTile = ( $4645,$6665);
    tileCursorEmpty: TTile = ( $4847,$6867);
    tileCursorMarble: TTile = ( $4a49,$6a69);
    tileCursorBomb: TTile = ( $4c4b,$6c6b);
    tileCursorBlock: TTile = ( $4e4d,$6e6d);
    
    tileProgress0: TTile = ( $0003, 0);
    tileProgress1: TTile = ( $007e, 0);
    tileProgress2: TTile = ( $047e, 0);
    tileProgress3: TTile = ( $7f7e, 0);
    tileProgress4: TTile = ( $7f7e, $4400);
    tileProgress5: TTile = ( $7f7e, $0600);
    tileProgress6: TTile = ( $7f7e, $0643);
    tileProgress7: TTile = ( $7f7e, $0605);
    

    C_tiles: array [0..21] of pointer = (@tileEmpty,
                                                        @tileB, @tileB, @tileC2, @tileC4, @tileB, @tileB,
                                                        @tileBx, @tileBx, @tileC2x, @tileC4x, @tileBx, @tileBx,
                                                        @tileDust, @tileHole, @tileBlack, @tileMarble, @tileBomb, @tileBlock,
                                                        @tileVoid, @tileXplode1, @tileXplode2
                                        );

    TILE_COL_NONE = 0;
    TILE_COL_RED = 1;
    TILE_COL_BLUE = 2;
    TILE_COL_GREEN = 3;
                                        
    C_sprites: array [0..21] of byte = (0,
                                                        TILE_COL_BLUE, TILE_COL_GREEN, TILE_COL_NONE, TILE_COL_NONE, TILE_COL_RED, TILE_COL_NONE,
                                                        TILE_COL_BLUE, TILE_COL_GREEN, TILE_COL_NONE, TILE_COL_NONE, TILE_COL_RED, TILE_COL_NONE,
                                                        TILE_COL_NONE, TILE_COL_NONE, TILE_COL_NONE, TILE_COL_RED, TILE_COL_BLUE, TILE_COL_GREEN,
                                                        TILE_COL_NONE, TILE_COL_RED, TILE_COL_RED);

    C_cursor: array [0..21] of pointer = (@tileCursorEmpty,
                                                        @tileCursorB, @tileCursorB, @tileCursorC2, @tileCursorC4, @tileCursorB, @tileCursorB,
                                                        @tileCursorBx, @tileCursorBx, @tileCursorC2x, @tileCursorC4x, @tileCursorBx, @tileCursorBx,
                                                        @tileDust, @tileHole, @tileCursorBlack, @TileCursorMarble, @TileCursorBomb, @TileCursorBlock,
                                                        @tileVoid, @tileXplode1, @tileXplode2
                                        );

    C_progress: array [0..7] of pointer = (@tileProgress0, @tileProgress1, @tileProgress2, @tileProgress3, @tileProgress4, @tileProgress5, @tileProgress6, @tileProgress7);

