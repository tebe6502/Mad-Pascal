program game;

{$librarypath 'blibs'}
uses atari, b_system, b_pmg, b_dl, b_crt, joystick, math, sysutils, rmt;

{$I config.inc}
{$R resources.rc}
{$I tiles.inc}

type Tobstacle = array [0..0] of byte;

type Tlevel = record
    goal1: byte;
    goal2: byte;
    goal3: byte;
    time: byte;
    moves: byte;
    wining: byte;
    colors: byte;
    bgColor: byte;
    blackProb: byte;
    bombProb: byte;
    voidsPtr: word;
    blocksPtr: word;
    shadowsPtr: word;
    marblesPtr: word;
end;

var

    board: array [0..9, 0..9] of byte;
    boardCopy: array [0..9, 0..9] of byte;
    triples: array [0..9, 0..9] of byte;
    moves: array [0..MOVES_STORE_SIZE-1] of word;
    possibleMovesCount: byte;
    movesFinder: byte;
    finderX, finderY: byte;
    movesCountFinished: boolean;
    movesCountUpdate: boolean;
    movesCountProgress: byte;

    triplesFound: boolean;
    ballsCanFall: boolean;
    swapped: boolean;
    animate: boolean;
    chainBomb: boolean;
    exploded: boolean;
    maxColors: byte;
    cursorX: ShortInt = 5;
    cursory: ShortInt = 5;
    dx,dy: ShortInt;
    cursorDelay: byte = 0;
    gameMode: byte = GAME_MODE_SURVIVAL;
    updateCursor: byte = 0;
    cursorShown: byte = 0;
    fadeDelay: byte = 0;
    comboBrightness: byte = $f;
    bgColor:byte = BOARD_COLOR4;
    boardCharset:byte;
    showHintTimer:byte;
    hint1pos:word;
    hint2pos:word;
    hint1ball1:word;
    hint1ball2:word;
    hint2ball1:word;
    hint2ball2:word;

    score:cardinal;
    scoreCounters: array [0..5] of byte;
    comboCounters: array [0..5] of byte;
    chainCounters: array [0..5] of byte;
    dropChain: byte;
    dropChainScore: cardinal;
    survivalHiscore: cardinal;

    level: ^Tlevel;
    levelShadowCount:byte;
    levelBlockCount:byte;
    levelMarbleCount:byte;
    levelMovesCount:byte;
    levelColors: array [0..5] of byte;
    obstacles: ^Tobstacle;
    levelNum:byte;
    levelMax:byte;
    levels:array [0..0] of pointer absolute LEVELS_ADDRESS;
    levelCursorX,levelCursorY:byte;
    levelsTrophies: array [0..LEVELS_MAX] of byte;
    levelsHiscores: array [0..LEVELS_MAX] of word;
    progressUpdateNeeded: boolean;
    trophiesCount:word;

    gameState:byte = GAME_STARTED;

    timerTicks:byte;
    progress:byte;
    progressTick:byte;

    progressMap:array [0..7] of byte = (%00000000, %10000000, %11000000, %11100000, %11110000, %11111000, %11111100, %11111110 );
    progressColors0:array [0..7] of byte = ($22, $12, $f2, $e2, $d2, $c2, $b2, $b2);
    progressColors1:array [0..7] of byte = ($28, $18, $f8, $e8, $d8, $c8, $b8, $b8);
    progressColor0, progressColor1: byte;

    x:byte;
    s:TString;

    musicOn: byte;



{$I interrupts.inc}

procedure initLevels;
begin
    levelMax:=0;
    while word(levels[levelMax])<>0 do Inc(levelMax);
end;

function getRandomBall(colorsOnly:boolean):byte;
begin
    result := levelColors[Random(maxColors)];
//    if gameMode = GAME_MODE_ENDLESS then
    if not colorsOnly then begin
        if level.blackProb > 0 then
            if random(100) < level.blackProb then result:=TILE_BLACK;
        if level.bombProb > 0 then
            if random(100) < level.bombProb then result:=TILE_BOMB;
    end;
end;

procedure CopyBoard;
begin
    move(board,boardCopy,100);
end;

procedure clearHint;
var b:array [0..0] of byte;
begin
    if showHintTimer > 0 then begin
        b:=board;
        dpoke(hint1pos,hint1ball1);
        dpoke(hint1pos+32,hint1ball2);
        dpoke(hint2pos,hint2ball1);
        dpoke(hint2pos+32,hint2ball2);
        showHintTimer:=0;
    end;
end;

procedure showHint;
var x1,x2,y1,y2:byte;
    move:word;
begin

    if movesCountFinished and (possibleMovesCount > 0) then begin
        clearHint;
        move:=moves[Random(possibleMovesCount)];
        x1:=Hi(move) shr 4;
        x2:=Lo(move) shr 4;
        y1:=Hi(move) and 15;
        y2:=Lo(move) and 15;
        hint1pos:= X_offsets[x1] + Y_offsets[y1] + VRAM_ADDRESS;
        hint2pos:= X_offsets[x2] + Y_offsets[y2] + VRAM_ADDRESS;
        hint1ball1:=Dpeek(hint1pos);
        hint1ball2:=Dpeek(hint1pos+32);
        hint2ball1:=Dpeek(hint2pos);
        hint2ball2:=Dpeek(hint2pos+32);
        showHintTimer:=31;
    end;
end;

procedure Write2Line(x:byte;s:string);
var i:byte;
begin
    WaitFrame;
    CRT_WriteXY(x,0,s);
    for i:=1 to length(s) do s[i]:= char(byte(s[i]) xor 64);
    CRT_WriteXY(x,1,s);
end;

procedure Write2Bottom(s:string);
var i:byte;
begin
    WaitFrame;
    CRT_ClearRow(3);
    CRT_ClearRow(2);
    CRT_WriteCentered(s);
    CRT_Gotoxy(0,3);
    for i := 1 to length(s) do s[i] := char(byte(s[i]) xor 64);
    CRT_WriteCentered(s);
    comboBrightness := $f;
    fadeDelay := FADE_DELAY;
end;

procedure updateSpritesRow(offset:word;p0,p1,p2,p3,m:byte);
begin
    FillByte(pointer(offset + M_OFFSET), 7, m);
    FillByte(pointer(offset + P0_OFFSET), 7, p0);
    FillByte(pointer(offset + P1_OFFSET), 7, p1);
    FillByte(pointer(offset + P2_OFFSET), 7, p2);
    FillByte(pointer(offset + P3_OFFSET), 7, p3);
end;

procedure putTile(x,y:byte;tile:TTile);
var offset: word;
begin
    offset := X_offsets[x] + Y_offsets[y] + VRAM_ADDRESS;
    Dpoke(offset,tile[0]);
    Dpoke(offset+32,tile[1]);
end;

function charToLvl(c:char):byte;
begin
    result:=byte(c);
    case result of
		65..79: Dec(result,29);
		80..90: Dec(result,12);
		48..57: Inc(result,48);
		32: result:=0;
		33: result:=79;
		42: result:=106;
		43: result:=81;
		45: result:=82;
		46: result:=108;
		63: result:=80;
		64: result:=107;
        58: result:=109;
        94: result:=8;
    end;
end;

function vramOffset(x,y:byte):word;
begin
	result := x + (y shl 5) + VRAM_ADDRESS;
end;

procedure writeBoard(x,y:byte;s:TString;inv:byte);
var c:byte;
    offset:word;
begin
    offset := vramOffset(x,y);
    for c:=1 to Length(s) do begin
        poke(offset,charToLvl(s[c])+inv);
        inc(offset);
    end;
end;

procedure writeBoardSNum(x,y:byte;txt:TString;num:cardinal;inv:byte);
begin
	Str(num,s);
	txt:=Concat(txt,s);
	writeBoard(x,y,txt,inv);
end;

procedure clearBoardLine(y:byte);
var offset:word;
begin
    offset := vramOffset(4,y);
    fillByte(pointer(offset),24,0);
end;

procedure eraseBoard;
var line:byte;
    offset:word;
begin
    offset := VRAM_ADDRESS + 4;
    line := 0;
    repeat
        FillByte(pointer(offset),24,0);
        if animate then WaitFrames(3);
        Inc(offset,32);
        Inc(line);
    until line=20;
end;

function trophiesNeeded(lvl:byte):word;
begin
    result:=lvl;
    Inc(result,(lvl and %11110000));
end;

function levelLocked(lvl: byte):boolean;
begin
    result:= trophiesCount<trophiesNeeded(lvl);
end;

procedure putBall(x,y,c:byte);
var offset: word;
    mask: byte;
    player0, player1, player2, player3, missiles: byte;
    b:byte;
begin
    putTile(x, y, C_tiles[c]);
    offset:= PMG_ADDRESS + TOP_SPRITE_OFFSET + (y shl 3);
    b := C_sprites[c];
    player0 := peek(offset + P0_OFFSET);
    player1 := peek(offset + P1_OFFSET);
    player2 := peek(offset + P2_OFFSET);
    player3 := peek(offset + P3_OFFSET);
    missiles := peek(offset + M_OFFSET);

    if x<4 then begin
        mask := masks1[x];

        if b and 1 = 0 then player0 := player0 and not mask
        else player0 := player0 or mask;

        if b and 2 = 0 then player1 := player1 and not mask
        else player1 := player1 or mask;

    end else if x<8 then begin
        mask := masks2[x];

        if b and 1 = 0 then player2 := player2 and not mask
        else player2 := player2 or mask;

        if b and 2 = 0 then player3 := player3 and not mask
        else player3 := player3 or mask;

    end else begin
        mask := masks3[x];

        if b and 1 = 0 then missiles := missiles and not (%00110011 and mask)
        else missiles := missiles or (%00110011 and mask);

        if b and 2 = 0 then missiles := missiles and not (%11001100 and mask)
        else missiles := missiles or (%11001100 and mask);
    end;

    updateSpritesRow(offset, player0, player1, player2, player3, missiles);
end;

function isBottom(x,y:byte):boolean;
var b:byte;
begin
    result:=true;
    while (y < 9) do begin
        Inc(y);
        b:=board[x,y];
        if (b <> TILE_BLOCK) and (b <>TILE_VOID) then result:=false;
    end;
end;

procedure BallFall(x,y: byte;colorsOnly: boolean);
var originY,b:byte;
begin
    originY:=y;
    if y>0 then begin
        b:=board[x,y-1];
        while ((y > 0) and ((b = TILE_BLOCK) or (b = TILE_VOID))) do begin
            Dec(y);
            b:=board[x,y-1];
        end;
        if (y>0) then begin
            if (b <> TILE_EMPTY) then begin
                board[x,originY] := b;
                board[x,y-1] := TILE_EMPTY;
                if b = TILE_MARBLE then
                    if isBottom(x,originY) then begin
                        board[x,originY] := TILE_EMPTY;
                        ballsCanFall := true;
                    end;
            end else ballsCanFall := true;
        end;
    end;
    if (y=0) then board[x,originY] := getRandomBall(colorsOnly);
    if animate then putBall(x,originY,board[x,originY]);
end;

procedure FillBalls(colorsOnly: boolean);
var y,x:shortInt;
begin
    for y:=0 to 9 do
        for x:=0 to 9 do
            if board[x,y] = TILE_EMPTY then board[x,y] := getRandomBall(colorsOnly);
end;

procedure FallBalls(colorsOnly: boolean);
var y,x:shortInt;
begin
    y := 9;
    ballsCanFall := false;
    repeat
        for x:=0 to 9 do begin
            if board[x,y] = TILE_EMPTY then BallFall(x,y,colorsOnly);
        end;
        Dec(y);
    until y < 0;
end;

procedure Vdrop(x,y,samecount:byte);
var v:byte;
begin
    Dec(y);
    v:=samecount;
    Inc(scoreCounters[v-3]);
    repeat
        triples[x,y]:=v;
        Dec(samecount);
        Dec(y);
    until samecount=0;
    triplesFound := true;
end;

procedure Hdrop(x,y,samecount:byte);
var v:byte;
begin
    Dec(x);
    v:=samecount;
    Inc(scoreCounters[v-3]);
    repeat
        triples[x,y]:=v;
        Dec(samecount);
        Dec(x);
    until samecount=0;
    triplesFound := true;
end;

function isTriplet(len,tile:byte):boolean;
begin
    if len<3 then exit(false);
    if tile=TILE_VOID then exit(false);
    if tile=TILE_BLOCK then exit(false);
    if tile=TILE_MARBLE then exit(false);
    if tile=TILE_BLACK then exit(false);
    result:=true;
end;

procedure findTriples;
var x, y: byte;
    cv, ch, pch, pcv, vsamecount, hsamecount: byte;
begin
    clearHint;
    levelShadowCount:=0;
    levelBlockCount:=0;
    levelMarbleCount:=0;
    triplesFound := false;
    Fillchar(triples,100,0);
    for x:=0 to 9 do begin
        pch := NONE;
        pcv := NONE;
        vsamecount:=1;
        hsamecount:=1;
        for y:=0 to 9 do begin
            cv:=board[x,y];
            if (cv>6) and (cv<13) then cv:=cv-6;
            if (cv=pcv) then Inc(vsamecount)
            else begin
                if isTriplet(vsamecount,pcv) then Vdrop(x,y,vsamecount);
                vsamecount:=1;
                pcv:=cv;
            end;
            ch:=board[y,x];
            if (ch>6) and (ch<13) then begin
                ch:=ch-6;
                Inc(levelShadowCount);
            end;
            if (ch=TILE_BLOCK) then Inc(levelBlockCount);
            if (ch=TILE_MARBLE) then begin
                Inc(levelMarbleCount);
            end;
            if (ch=pch) then Inc(hsamecount)
            else begin
                if isTriplet(hsamecount,pch) then Hdrop(y,x,hsamecount);
                hsamecount:=1;
                pch:=ch;
            end;
        end;
        if isTriplet(vsamecount,pcv) then Vdrop(x,y,vsamecount);
        if isTriplet(hsamecount,pch) then Hdrop(y,x,hsamecount);
    end;
end;

procedure SwapTiles(sx,sy,dx,dy:byte);
var t:byte;
begin
    t:=board[sx,sy];
    board[sx,sy]:=board[dx,dy];
    board[dx,dy]:=t;
end;

procedure SwapCopyTiles(sx,sy,dx,dy:byte);
var t:byte;
begin
    t:=boardCopy[sx,sy];
    boardCopy[sx,sy]:=boardCopy[dx,dy];
    boardCopy[dx,dy]:=t;
end;

procedure putBallsRow(y: byte);
var offset: word;
    tile: ^TTile;
    mask1, mask2, mask3: byte;
    player0, player1, player2, player3, missiles: byte;
    c, b: byte;
begin
    offset := X_offsets[0] + Y_offsets[y] + VRAM_ADDRESS;
    player0 := 0;
    player1 := 0;
    player2 := 0;
    player3 := 0;
    missiles := 0;

    for b:=0 to 9 do begin
        c:=board[b,y];
        tile := C_tiles[c];
        Dpoke(offset,tile[0]);
        Dpoke(offset+32,tile[1]);
        Inc(offset,2);

        mask1 := masks1[b];
        mask2 := masks2[b];
        mask3 := masks3[b];

        c:= C_sprites[c];

        if c and 1 <> 0 then begin
            player0 := player0 or mask1;
            player2 := player2 or mask2;
            missiles := missiles or (%00110011 and mask3);
        end;
        if c and 2 <> 0  then begin
            player1 := player1 or mask1;
            player3 := player3 or mask2;
            missiles := missiles or (%11001100 and mask3);
        end;
    end;

    offset:= PMG_ADDRESS + TOP_SPRITE_OFFSET + (y shl 3);
    updateSpritesRow(offset, player0, player1, player2, player3, missiles);
end;

procedure DLset;
begin
    DL_Init(DLIST_ADDRESS);
    DL_Push(DL_BLANK8);
    DL_Push(DL_BLANK8 + DL_DLI);
    DL_Push(DL_MODE_40x24T2 + DL_LMS, TXTRAM_ADDRESS);
    DL_Push(DL_MODE_40x24T2);
    DL_Push(DL_BLANK4);
    DL_Push(DL_MODE_320x192G2 + DL_LMS, PROGRESS_ADDRESS);
    DL_Push(DL_MODE_320x192G2,2);
    DL_Push(DL_BLANK4);
    DL_Push(DL_MODE_40x24T5 + DL_LMS, VRAM_ADDRESS);
    DL_Push(DL_MODE_40x24T5, 19);
    DL_Push(DL_BLANK4);
    DL_Push(DL_MODE_40x24T2 + DL_LMS, TXTRAM_ADDRESS+64);
    DL_Push(DL_MODE_40x24T2);

    DL_Push(DL_JVB, DLIST_ADDRESS);
    DL_Start;
    savmsc:=TXTRAM_ADDRESS;
end;

procedure pmgGameSetup;
begin
    PMG_Clear;
    PMG_hpos0 := LEFT_SPRITE_OFFSET;
    PMG_hpos1 := LEFT_SPRITE_OFFSET;
    PMG_hpos2 := LEFT_SPRITE_OFFSET+32;
    PMG_hpos3 := LEFT_SPRITE_OFFSET+32;
    PMG_hposm0 := LEFT_SPRITE_OFFSET+64;
    PMG_hposm1 := LEFT_SPRITE_OFFSET+64;
    PMG_hposm2 := LEFT_SPRITE_OFFSET+64+8;
    PMG_hposm3 := LEFT_SPRITE_OFFSET+64+8;
    PMG_pcolr0_S := PMG_COLOR0;
    PMG_pcolr1_S := PMG_COLOR1;
    PMG_pcolr2_S := PMG_COLOR0;
    PMG_pcolr3_S := PMG_COLOR1;
    PMG_sizep0 := PMG_SIZE_x4;
    PMG_sizep1 := PMG_SIZE_x4;
    PMG_sizep2 := PMG_SIZE_x4;
    PMG_sizep3 := PMG_SIZE_x4;
    PMG_sizem := $ff;
    PMG_gprior_S := PMG_overlap + 4;
end;

procedure pmgMenuSetup;
begin
    PMG_Clear;
    PMG_pcolr0_S := $0f;
    PMG_pcolr1_S := $0f;
    PMG_pcolr2_S := $0f;
    PMG_sizep0 := PMG_SIZE_x4;
    PMG_sizep1 := PMG_SIZE_x4;
    PMG_sizep2 := PMG_SIZE_x4;
    PMG_gprior_S := 4;
end;

procedure paintBoard;
var y:byte;
begin
    for y:=0 to 9 do begin
        putBallsRow(y);
    end;
end;

procedure putProgressTile(tile:TTile);
begin
    Dpoke(TXTRAM_ADDRESS+30,tile[0]);
    Dpoke(TXTRAM_ADDRESS+30+32,tile[1]);
end;

procedure updatePossibleMovesProgress;
var m:byte;
begin
    m := movesFinder div 12;
    if movesCountProgress <> m then begin
        if m<8 then begin
            putProgressTile(C_progress[m]);
            movesCountProgress := m;
        end;
    end;
end;

procedure NoMoreMoves;
begin
    gameState := NO_MORE_MOVES;
end;

procedure updatePossibleMoves;
begin
    if gameMode <> GAME_MODE_ARCADE then begin
        if possibleMovesCount<10 then Write2Line(30,Atascii2Antic(Concat('0',IntToStr(possibleMovesCount))))
        else Write2Line(30,Atascii2Antic(IntToStr(possibleMovesCount)));
    end;
    if possibleMovesCount = 0 then NoMoreMoves;
end;

procedure updateScore;
begin
    Write2Line(7,Atascii2Antic(IntToStr(score)));
end;

function GetTuple(num:byte):TString;
begin
    case num of
        0: result := 'TRIPLE';
        1: result := 'QUADRIPLE';
        2: result := 'QUINTIPLE';
        3: result := 'SEXTUPLE';
        4: result := 'SEPTUPLE';
        5: result := 'OCTUPLE';
    end;
end;

procedure countScore;
var i, mcombo, mchain:byte;
    bestCombo, bestComboMul, bestChain, bestChainMul:byte;
    scr:cardinal;
    txt:TString;
begin
    scr:=0;
    bestComboMul:=2;
    bestChainMul:=1;
    bestChain:=NONE;
    bestCombo:=NONE;
    txt:='';
    for i:=0 to 5 do begin // 0=tiples, 1=quadriples...
        //txt:=concat(txt,intToStr(scoreCounters[i]));
        mcombo:=1;
        mchain:=1;
        // multi lines same length
        if scoreCounters[i] > 1 then Inc(comboCounters[i])
            else comboCounters[i] := 0;
        Inc(mcombo,comboCounters[i]);
        if mcombo > bestComboMul then begin
            bestCombo := i;
            bestComboMul := mcombo;
        end;

        if i > 0 then // chains only above 3
            if scoreCounters[i] > 0 then Inc(chainCounters[i])
                else chainCounters[i] := 0;
        if chainCounters[i]>1 then mchain:=chainCounters[i] shl 1;
        if mchain > bestChainMul then begin
            bestChainMul := chainCounters[i];
            bestChain := i;
        end;

        scr := scr + (scoreBase[i] * scoreCounters[i] * (i+3) * mcombo * mchain);
        scoreCounters[i]:=0;
    end;
    //Write2Bottom(Atascii2Antic(txt));
    //waitFrames(50);

    if bestChain <> NONE then begin
        txt:=Concat(' ',GetTuple(bestChain));
        txt:=Concat(txt,' CHAIN X ');
        txt:=Concat(txt,IntToStr(bestChainMul));
        txt:=Concat(txt,' COMBO');
        Write2Bottom(Atascii2Antic(txt));
    end else if (bestCombo <> NONE) then begin
        txt:=Concat(' MULTI ',GetTuple(bestCombo));
        txt:=Concat(txt,' X ');
        txt:=Concat(txt,IntToStr(bestComboMul));
        txt:=Concat(txt,' COMBO');
        Write2Bottom(Atascii2Antic(txt));
    end;
    score:=score + scr;
    Inc(dropChain);
    Inc(dropChainScore,scr);
    UpdateScore;
end;

procedure ChangeDropTiles(val:byte);
var x,y,b:byte;
begin
    for x:=0 to 9 do
        for y:=0 to 9 do
            if triples[x,y] > 0 then begin
                b:=board[x,y];
                if (b>6) and (b<13) then begin
                    board[x,y] := b - 6;
                    triples[x,y] := 0;
                end else begin
                    board[x,y] := val;
                end;
                if animate then putBall(x,y,board[x,y]);
            end;
end;

procedure WipeBoard(val:byte);
var x,y:byte;
begin
    for x:=0 to 9 do
        for y:=0 to 9 do
            if board[x,y]<>TILE_VOID then board[x,y]:=val;
end;

procedure XplodeBoard;
begin
    WipeBoard(TILE_DUST);
    paintBoard;
    WaitFrames(DROP_SPEED);
    WipeBoard(TILE_HOLE);
    paintBoard;
    WaitFrames(DROP_SPEED);
    WipeBoard(TILE_EMPTY);
    paintBoard;
    WaitFrames(DROP_SPEED);
end;

procedure explodeBomb(x,y:shortInt);forward;

procedure tryToExplode(x,y:shortInt);
var b:byte;
begin
    if (x>=0) and (x<=9) and (y>=0) and (y<=9) then begin
        b:=board[x,y];
        if b = TILE_BOMB then begin
            triples[x,y] := 1;
            chainBomb:=true;
        end
        else begin
            if (b <> TILE_VOID) and (b <> TILE_MARBLE) then begin
                board[x,y] := TILE_XPLODE2;
                triples[x,y] := 3;
                if animate then putBall(x,y,board[x,y]);
            end
        end;
    end;
end;

procedure explodeBomb(x,y:shortInt);
begin
    exploded:=true;
    board[x,y] := TILE_XPLODE1;
    if animate then putBall(x,y,TILE_XPLODE1);
    tryToExplode(x-1,y-1);
    tryToExplode(x,y-1);
    tryToExplode(x+1,y-1);
    tryToExplode(x-1,y);
    tryToExplode(x+1,y);
    tryToExplode(x-1,y+1);
    tryToExplode(x,y+1);
    tryToExplode(x+1,y+1);

end;

procedure explodeTiles;
var x,y:byte;
begin
    chainBomb:=false;
    for x:=0 to 9 do
        for y:=0 to 9 do
            if (triples[x,y] > 0) and (board[x,y] = TILE_BOMB) then begin
                explodeBomb(x,y);
            end;
end;

procedure removeTriples;
begin
    exploded:=false;
    repeat explodeTiles until chainBomb=false;
    if (exploded and animate) then WaitFrames(3);

    if animate then begin
        WaitFrames(DROP_SPEED);
        ChangeDropTiles(TILE_DUST);
        WaitFrames(DROP_SPEED);
        ChangeDropTiles(TILE_HOLE);
        WaitFrames(DROP_SPEED);
        ChangeDropTiles(TILE_EMPTY);
        WaitFrames(DROP_SPEED);
    end else
        ChangeDropTiles(TILE_EMPTY);
    ballsCanFall := true;
end;

procedure DropAndScore;
var bonus:word;
begin
    dropChain:=0;
    dropChainScore:=0;
    paintBoard;
    WaitFrames(DROP_SPEED);
    while triplesFound do begin
        removeTriples;
        countScore;
        while (ballsCanFall) do begin
            FallBalls(false);
            cursorShown:=0;
        end;
        fillByte(@scoreCounters,6,0);
        findTriples;
    end;
    paintBoard;
    cursorShown:=0;
    bonus:=0;
    if dropChain>5 then begin
        bonus:=100*dropChain;
        str(bonus,s);
        s:=Concat('+',s);
        Write2Bottom(Atascii2Antic(Concat(s,' CHAIN BONUS')));
        score:=score + bonus;
        UpdateScore;
        Inc(dropChainScore,bonus);
    end;

    str(dropChainScore,s);
    s:=Concat('+',s);
    if dropChainScore > 3000 then Write2Bottom(Atascii2Antic(Concat(s,'  AWESOME SCORE !!!')))
    else if dropChainScore > 2000 then Write2Bottom(Atascii2Antic(Concat(s,'  GOOD SCORE !!')))
    else if dropChainScore > 1000 then Write2Bottom(Atascii2Antic(Concat(s,'  NICE SCORE !')));

end;

procedure UpdateMoves;
var m:byte;
begin
    m:=Abs(level.moves-levelMovesCount);
    if m<10 then Write2Line(30,Atascii2Antic(Concat('0',IntToStr(m))))
        else Write2Line(30,Atascii2Antic(IntToStr(m)));
end;

procedure SwapOnBoard(cx,cy,dx,dy:shortInt);
var vmin,vmax:byte;
    offset:word;
begin
    WaitFrame;
    Inc(levelMovesCount);
    if gameMode = GAME_MODE_ARCADE then UpdateMoves;
    cursorDelay:=CURSOR_SPEED;
    cursorX:=cursorX+dx;
    cursorY:=cursorY+dy;
    WaitFrame;
    updateCursor:=0;
    if dx<>0 then begin
        vmin := Min(cx + dx,cx);
        vmax := Max(cx + dx,cx);
        offset := X_offsets[vmin] + Y_offsets[cy] + VRAM_ADDRESS;
        poke(offset+1,peek(offset));
        poke(offset+2,peek(offset+3));
        poke(offset,$d);
        poke(offset+3,$e);
        poke(offset+33,peek(offset+32));
        poke(offset+34,peek(offset+35));
        poke(offset+32,$2d);
        poke(offset+35,$2e);
    end;
    if dy<>0 then begin
        vmin := Min(cy + dy,cy);
        vmax := Max(cy + dy,cy);
        offset := X_offsets[cx] + Y_offsets[vmin] + VRAM_ADDRESS;
        Dpoke(offset+32,Dpeek(offset));
        Dpoke(offset,$0e0d);
        Dpoke(offset+64,Dpeek(offset+96));
        Dpoke(offset+96,$2e2d);
    end;
    if board[cx,cy]=TILE_MARBLE then
        if isBottom(cx,cy) then board[cx,cy]:=TILE_EMPTY;
    if board[cursorX,cursorY]=TILE_MARBLE then
        if isBottom(cursorX,cursorY) then board[cursorX,cursorY]:=TILE_EMPTY;

    WaitFrames(DROP_SPEED);
    updateCursor:=1;
    cursorShown:=0;
end;

function isSwapable(t:byte):boolean;
begin
    result:=(t <> TILE_BLOCK) and (t <> TILE_BLACK) and (t <> TILE_VOID);
end;

procedure TryToSwap(dx,dy:shortInt);
var sx,sy,cx,cy:shortInt;
    b:byte;
begin
    cx:=cursorX;
    cy:=cursorY;
    b:=board[cx, cy];
    if isSwapable(b) then begin
        fillByte(@scoreCounters,6,0);
        updateCursor:=0;
        triplesFound:=false;
        if dx<>0 then begin
            sx := cx + dx;
            b:=board[sx, cy];
            if (sx>=0) and (sx<10) and isSwapable(b) then begin
                SwapTiles(sx,cy,cx,cy);
                findTriples;
                if not triplesFound then SwapTiles(sx,cy,cx,cy)
                else SwapOnBoard(cx,cy,dx,dy);
            end;
        end;
        if dy<>0 then begin
            sy := cy + dy;
            b:=board[cx, sy];
            if (sy>=0) and (sy<10) and isSwapable(b) then begin
                SwapTiles(cx,sy,cx,cy);
                findTriples;
                if not triplesFound then SwapTiles(cx,sy,cx,cy)
                else SwapOnBoard(cx,cy,dx,dy);
            end;
        end;
        updateCursor:=1;
        if triplesFound then begin
            DropAndScore;
            swapped := true;
        end;
    end;
end;

function CountSameLeft(x,y:byte):byte;
begin
    result:=0;
    while (x>0) and (boardCopy[x-1,y]=boardCopy[x,y]) do begin
        dec(x);
        inc(result);
    end;
end;

function CountSameRight(x,y:byte):byte;
begin
    result:=0;
    while (x<9) and (boardCopy[x+1,y]=boardCopy[x,y]) do begin
        inc(x);
        inc(result);
    end;
end;

function CountSameUp(x,y:byte):byte;
begin
    result:=0;
    while (y>0) and (boardCopy[x,y-1]=boardCopy[x,y]) do begin
        dec(y);
        inc(result);
    end;
end;

function CountSameDown(x,y:byte):byte;
begin
    result:=0;
    while (y<9) and (boardCopy[x,y+1]=boardCopy[x,y]) do begin
        inc(y);
        inc(result);
    end;
end;

function CanMoveRight(x1,y1:byte):boolean;
begin
    Result:=false;
    SwapCopyTiles(x1,y1,x1+1,y1);
    if CountSameLeft(x1,y1)>1 then result:=true;
    if not result and (CountSameRight(x1+1,y1)>1) then result:=true;
    if not result and (CountSameUp(x1,y1)+CountSameDown(x1,y1)>1) then result:=true;
    if not result and (CountSameUp(x1+1,y1)+CountSameDown(x1+1,y1)>1) then result:=true;
    SwapCopyTiles(x1,y1,x1+1,y1);
end;

function CanMoveDown(x1,y1:byte):boolean;
begin
    Result:=false;
    SwapCopyTiles(x1,y1,x1,y1+1);
    if CountSameUp(x1,y1)>1 then result:=true;
    if not result and (CountSameDown(x1,y1+1)>1) then result:=true;
    if not result and (CountSameLeft(x1,y1)+CountSameRight(x1,y1)>1) then result:=true;
    if not result and (CountSameLeft(x1,y1+1)+CountSameRight(x1,y1+1)>1) then result:=true;
    SwapCopyTiles(x1,y1,x1,y1+1);
end;

procedure addMove(x1,y1,x2,y2:byte);
begin
    if possibleMovesCount<MOVES_STORE_SIZE then
        moves[possibleMovesCount]:= ((x1 shl 4) or y1) + ((x2 shl 4) or y2) shl 8;
    inc(possibleMovesCount);
end;

procedure findMoves;
var c:byte;
begin
    if movesCountUpdate then begin
        movesFinder:=0;
        possibleMovesCount := 0;
        movesCountFinished:=false;
        movesCountUpdate:=false;
        movesCountProgress:=$ff;
        CopyBoard;
        finderX:=0;
        finderY:=0;
    end;
    if not movesCountFinished then begin
        c:=MOVES_FINDER_SPEED;
        repeat
            if isSwapable(boardCopy[finderX,finderY]) then begin
                if (finderX<9) and (boardCopy[finderX,finderY]<>boardCopy[finderX+1,finderY]) and isSwapable(boardCopy[finderX+1,finderY]) then
                    if CanMoveRight(finderX,finderY) then addMove(finderX,finderY,finderX+1,finderY);
                if (finderY<9) and (boardCopy[finderX,finderY]<>boardCopy[finderX,finderY+1]) and isSwapable(boardCopy[finderX,finderY+1]) then
                    if CanMoveDown(finderX,finderY) then addMove(finderX,finderY,finderX,finderY+1);
            end;
            dec(c);
            inc(movesFinder);
            inc(finderX);
            if finderX = 10 then begin
                finderX:=0;
                inc(finderY);
            end;
        until (c=0) or (movesFinder=100);
        if movesFinder=100 then begin
            movesCountFinished:=true;
            updatePossibleMoves;
        end else if gameMode<>GAME_MODE_ARCADE then updatePossibleMovesProgress;
    end;
end;

procedure PaintSides;
var off,i,j:byte;
    voff:word;
begin
    off:=$1c;
    voff:=VRAM_ADDRESS;
    for j:=0 to 19 do begin
        for i:=0 to 3 do begin
            poke(voff+i,off+i);
            poke(voff+31-i,off+127-i);
        end;
        voff:=voff+32;
        off:=off+32;
    end;
end;

procedure PutObstacle(o,t:byte);
begin
    if (t = TILE_SHADOW) then begin
		if (board[o shr 4, o and 15]<7) then board[o shr 4, o and 15] := board[o shr 4, o and 15] + 6;
    end else board[o shr 4, o and 15] := t;
end;

procedure PutObstacleLineRight(r:shortInt;x,y,t:byte);
begin
    repeat
        if (t = TILE_SHADOW) then begin
            if (board[x, y]<7) then board[x, y] := board[x, y] + 6;
        end else board[x, y] := t;
        inc(x);
        dec(r);
    until r=0;

end;

procedure PutObstacleLineDown(r:shortInt;x,y,t:byte);
begin
    repeat
        if (t = TILE_SHADOW) then begin
			if (board[x, y]<7) then board[x, y] := board[x, y] + 6;
        end else board[x, y] := t;
        inc(y);
        dec(r)
    until r=0;
end;

procedure putObstacleBox(x1,y1,x2,y2,t:byte);
begin
    PutObstacleLineRight(x2-x1+1,x1,y1,t);
    PutObstacleLineRight(x2-x1+1,x1,y2,t);
    PutObstacleLineDown(y2-y1+1,x1,y1,t);
    PutObstacleLineDown(y2-y1+1,x2,y1,t);
end;

procedure PutObstacles(t:byte);
var ptr,c,x,y:byte;
begin
    ptr := 0;
    while obstacles[ptr] <> NONE do begin
        c := obstacles[ptr] shr 4;
        // single block
        if c<10 then PutObstacle(obstacles[ptr], t);
        // line right
        if c=10 then begin
            c := obstacles[ptr] and %1111;
            inc(ptr);
            x := obstacles[ptr] shr 4;
            y := obstacles[ptr] and %1111;
            PutObstacleLineRight(c, x, y, t);
        end;
        if c=11 then begin
            c := obstacles[ptr] and %1111;
            inc(ptr);
            x := obstacles[ptr] shr 4;
            y := obstacles[ptr] and %1111;
            PutObstacleLineDown(c, x, y, t);
        end;
        if c=12 then begin
            inc(ptr);
            x := obstacles[ptr] shr 4;
            y := obstacles[ptr] and %1111;
            inc(ptr);
            PutObstacleBox(x, y, obstacles[ptr] shr 4, obstacles[ptr] and %1111, t);
        end;
        inc(ptr);
    end;
end;

procedure DrawObstacles;
begin
    obstacles := pointer(level.blocksPtr);
    PutObstacles(TILE_BLOCK);
    obstacles := pointer(level.voidsPtr);
    PutObstacles(TILE_VOID);
end;

procedure DrawShadows;
begin
    obstacles := pointer(level.shadowsPtr);
    PutObstacles(TILE_SHADOW);
    obstacles := pointer(level.marblesPtr);
    PutObstacles(TILE_MARBLE);
end;

procedure clearTimer;
begin
    fillByte(pointer(PROGRESS_ADDRESS),96,0);
    fillByte(pointer(PROGRESS_ADDRESS+32),32,$ff);
    progressColor0:=2;
    progressColor1:=8;
end;

procedure InitializeBoard;
begin
    FillByte(@board,100,0);
end;

procedure showTrophies(x,y:byte);
var i:byte;
begin
    writeBoard(x,y,'^^^',128);
    s:='@';
    if levelsTrophies[levelNum]>0 then
        for i:=x to x-1+levelsTrophies[levelNum] do
            writeBoard(i,y,s,0);
end;

procedure trophiesList(y:byte);
var i:byte;
begin
    i:=128;
    if levelsTrophies[levelNum]>2 then i:=0;
    writeBoardSNum(8,y+2,'@@@ - ',level.goal3*1000,i);
    if levelsTrophies[levelNum]>1 then i:=0;
    writeBoardSNum(8,y+1,'@@  - ',level.goal2*1000,i);
    if levelsTrophies[levelNum]>0 then i:=0;
    writeBoardSNum(8,y,'@   - ',level.goal1*1000,i);
end;

procedure drawBorder(x,y,w,h:byte);
var offset:word;
begin
    offset := vramOffset(x,y);
    poke(offset,$01);
    FillByte(pointer(offset+1),w,$02);
    poke(offset+w+1,$03);
    Inc(offset,32);
    repeat
        poke(offset,$21);
        poke(offset+w+1,$23);
        Dec(h);
        Inc(offset,32);
    until h=0;
    poke(offset,$41);
    FillByte(pointer(offset+1),w,$42);
    poke(offset+w+1,$43);
end;

procedure putLevelTile(lvl:byte);
var c,x:byte;
    y,offset:word;
    s:TString;
    inv:byte;
begin
    x:=((lvl and %11)*6)+4;
    y:=((lvl div 4) and %11)*4+2;
    drawBorder(x,y,4,2);
    offset := vramOffset(x,y);
    Inc(offset,32);
    Str(lvl+1,s);
    c:=1;
    x:=5-Length(s);
    inv:=0;
    if levelLocked(lvl) then inv:=128;
    repeat
        poke(offset+x,byte(s[c])+48+inv);
        inc(c);
        inc(x);
    until c>Length(s);
    Inc(offset,32);
    for x:=0 to 2 do begin
        c:=7;
        if levelsTrophies[lvl]>x then c:=$22;
        poke(offset+2+x,c+inv);
    end;
end;

procedure showLevelsPage(page:byte);
var lvl:byte;
begin
    eraseBoard;
    writeBoardSNum(13,0,'PAGE ',page,0);
    bgColor:= (page shl 5)+4;
    page:=(page-1)*16;
    for lvl:=page to page+15 do
        if lvl<levelMax then putLevelTile(lvl);
end;

procedure loadProgress;
var lvl:byte;
begin
    for lvl:=0 to LEVELS_MAX do begin
        levelsHiscores[lvl]:=0;
        levelsTrophies[lvl]:=0;
    end;
end;

procedure setTrophies(level,trophies:byte);
var lvl:byte;
begin
    if levelsTrophies[level]<trophies then
        levelsTrophies[level]:=trophies;
    trophiesCount:=0;
    for lvl:=0 to LEVELS_MAX do
        Inc(trophiesCount, levelsTrophies[lvl])
end;

procedure showLevelCursor(levelNum:byte);
var offset:word;
begin
    levelCursorX:= levelNum mod 4;
    levelCursorY:= (levelNum div 4) mod 4;
    PMG_Clear;
    offset:= PMG_ADDRESS + TOP_CURSOR_OFFSET + (levelCursorY shl 4);
    FillByte(pointer(offset + P0_OFFSET),15,%11111000);
    PMG_hpos0 := LEFT_CURSOR_OFFSET + (levelCursorX * 24);
end;

procedure showMenuCursor(topPos,row:byte);
var offset:word;
begin
    PMG_Clear;
    offset:= PMG_ADDRESS + TOP_MENU_OFFSET + topPos + (row shl 4);
    FillByte(pointer(offset + P0_OFFSET),15,%11111111);
    FillByte(pointer(offset + P1_OFFSET),15,%11111111);
    FillByte(pointer(offset + P2_OFFSET),15,%11111111);
    PMG_hpos0 := LEFT_MENU_OFFSET;
    PMG_hpos1 := LEFT_MENU_OFFSET+32;
    PMG_hpos2 := LEFT_MENU_OFFSET+64;
end;

procedure updateLevelInfo(levelNum:byte);
var need:word;off:byte;
begin
    if levelLocked(levelNum) then begin
        need:=trophiesNeeded(levelNum)-trophiesCount;
        Str(need,s);
        off:=Length(s) shr 1;
        if need = 1 then s:=Concat(s,' TROPHIE NEEDED')
        else s:=Concat(s,' TROPHIES NEEDED');
        clearBoardLine(19);
        writeBoard(8-off,19,s,0);
        Write2Bottom(' LEVEL LOCKED'~);
    end else begin
        if levelsHiscores[levelNum]<>0 then begin
            Str(levelsHiscores[levelNum]*10,s);
            s:=Concat('HISCORE - ',s);
        end else s:='  NO HISCORE';
        clearBoardLine(19);
        writeBoard(9,19,s,0);
        Write2Bottom('PRESS FIRE TO START'~);
    end;
 end;

function getMenuElement(topPos,menumax:byte):byte;
var menupos:byte;
begin
    topPos:=topPos shl 2;
    menupos:=0;
    result:=NONE;
    showMenuCursor(topPos,menupos);
    repeat
        if stick0 <> joy_none then begin

            if stick0 = joy_down then begin
                inc(menupos);
                if menupos=menumax then menupos:=0;
            end;
            if stick0 = joy_up then begin
                if menupos=0 then menupos:=menumax;
                dec(menupos);
            end;
            showMenuCursor(topPos,menupos);

            repeat
                WaitFrame;
                PMG_pcolr0_S:=(peek(20) shl 4) or 15;
                PMG_pcolr1_S:=PMG_pcolr0_S;
                PMG_pcolr2_S:=PMG_pcolr0_S
            until (stick0 = joy_none);
        end;
        if strig0 = 0 then begin
            result:=menupos
        end;
        WaitFrame;
        PMG_pcolr0_S:=(peek(20) shl 4) or 15;
        PMG_pcolr1_S:=PMG_pcolr0_S;
        PMG_pcolr2_S:=PMG_pcolr0_S
    until result<>NONE;
    PMG_Clear;
end;

procedure DrawButton(by,tx:byte;s:string);
begin
    drawBorder(7,by,16,2);
    writeBoard(tx,by+1,s,0);
end;



procedure initLevelScreen;
begin
    if musicOn=0 then begin
        //msx.Init(0);
        musicOn:=1;
    end;
    updateCursor:=0;
    eraseBoard;
    PMG_Clear;
    CRT_Clear;
    pmgMenuSetup;
    boardCharset:=Hi(CHARSET_LEVELS_ADDRESS);
end;

procedure initGameScreen;
begin
    //msx.Stop;
    musicOn:=0;
    CRT_Clear;
    eraseBoard;
    PMG_Clear;
    color3:=BOARD_COLOR3;
    pmgGameSetup;
    boardCharset:=Hi(CHARSET_TILE_ADDRESS);
    Write2Line(0,'SCORE:                 MOVES:   '~);
    updateScore;
    if gameMode <> GAME_MODE_ARCADE then updatePossibleMoves
    else updateMoves;
    PaintBoard;
    updateCursor:=1;
	cursorShown:=0;
	animate := true;
    //msx.Init($13);
    //musicOn:=1;
end;

function GameModeSelect:byte;
var off:byte;
    menu:array[0..2] of byte = (GAME_MODE_ARCADE, GAME_MODE_SURVIVAL, GAME_MODE_ENDLESS);
begin
    clearTimer;
    initLevelScreen;
    color3:= $1a;
    Write2Line(11,'POP''N''DROP'~);
    writeBoard(8,0,'CODED BY BOCIANU',0);
    writeBoard(9,2,'SOUNDS BY LISU',128);

	DrawButton(6,13,'ARCADE');
    Str(trophiesCount,s);
    off := (Length(s)-1) shr 1;
    if trophiesCount=1 then begin
        s:=Concat(s,' TROPHY');
        writeBoard(12-off,8,s,128);
    end else begin
        s:=Concat(s,' TROPHIES');
        writeBoard(11-off,8,s,128);
    end;

	DrawButton(10,12,'SURVIVAL');
    Str(survivalHiscore,s);
    off := Length(s) shr 1;
    s:=Concat('SCORE  ',s);
    writeBoard(12-off,12,s,128);

	DrawButton(14,12,'CHILLOUT');
    writeBoard(14,16,'ZONE',0);

    Write2Bottom(' SILLY VENTURE 2K18 VERSION'~);

    result:=menu[getMenuElement(6,3)];
end;

function LevelSelect:byte;
var last,page,delay:byte;
begin
    clearTimer;
    animate := false;
    initLevelScreen;
    color3:= $02;
    Write2Line(8,'SELECT THE LEVEL'~);
    result:=NONE;
    last := (levelNum div 16) + 1;
    showLevelsPage(last);
    showLevelCursor(levelNum);
    updateLevelInfo(levelNum);
    repeat
        delay:=5;
        if stick0 <> joy_none then begin
            if stick0 = joy_right then begin
                inc(levelNum);
                if levelNum=levelMax then levelNum:=0;
            end;
            if stick0 = joy_left then begin
                if levelNum=0 then levelNum:=levelMax;
                dec(levelNum);
            end;
            if stick0 = joy_down then begin
                inc(levelNum,4);
                if levelNum>=levelMax then levelNum:=levelNum mod 4;
            end;
            if stick0 = joy_up then begin
                if levelNum<4 then levelNum:=levelMax+levelNum;
                dec(levelNum,4);
            end;
            showLevelCursor(levelNum);
            page := ((levelNum div 16) + 1);
            if page <> last then showLevelsPage(page);
            last := page;
            updateLevelInfo(levelNum);
            repeat
                WaitFrame;
                PMG_pcolr0_S:=(peek(20) shl 4) or 15;
                dec(delay);
            until (stick0 = joy_none) or (delay=0);
        end;
        if strig0 = 0 then begin
            if not levelLocked(levelNum) then result:=levelNum
            else Write2Bottom(' LEVEL LOCKED'~);
        end;
        WaitFrame;
        PMG_pcolr0_S:=(peek(20) shl 4) or 15;
        if CRT_KeyPressed then
            if kbcode = 28 then begin
                gameState := GAME_TITLE;
                result:=levelNum;
            end

    until result<>NONE;
    eraseBoard;
end;

procedure LoadLevel(num:byte);
var mask,i:byte;
begin
    clearTimer;
    animate := false;
    initLevelScreen;
    if num = LEVEL_SURVIVAL then num:=levelMax+1;
    if num = LEVEL_ENDLESS then num:=levelMax+2;
    level:=levels[num];
    bgColor:= level.bgColor;
    color3:= $1a;

    writeBoard(8,0,'PLEASE WAIT...',128);

    if gameMode = GAME_MODE_ARCADE then begin
        writeBoardSNum(8,2,'LEVEL: ',levelNum+1,0);
        showTrophies(21,2);

        if level.wining = REACH_GOAL then
            writeBoard(8,4,'GET ANY TROPHY',128);
        if level.wining and NO_SHADOWS <> 0 then
            writeBoard(8,4,'NO SHADED TILES',128);
        if level.wining and NO_BLOCKS <> 0 then
            writeBoard(8,4,'BLOW ALL BLOCKS',128);
        if level.wining and NO_MARBLES <> 0 then
            writeBoard(8,4,'DROP ALL MARBLES',128);

        writeBoard(8,6,'TROPHIES:',0);
        trophiesList(8);

        if level.time > 0 then
            writeBoardSNum(8,12,'TIME LIMIT: ',(((level.time+1) * 256) div 500) * 10,0);
        if level.moves > 0 then
            writeBoardSNum(8,12,'MOVES LIMIT: ',level.moves,0);

        if levelsHiscores[levelNum]<>0 then begin
            Str(levelsHiscores[levelNum]*10,s);
            s:=Concat('HISCORE - ',s);
        end else s:='  NO HISCORE';
        clearBoardLine(19);
        writeBoard(8,19,s,128);


    end;
    if gameMode = GAME_MODE_SURVIVAL then begin
        writeBoard(8,2,'LEVEL SURVIVAL',0);
        writeBoardSNum(8,4,'HISCORE ',survivalHiscore,0);
    end;


    if gameMode = GAME_MODE_ENDLESS then writeBoard(8,0,'LEVEL CHILLOUT',0);
    Write2Line(7,'INITIALIZING BOARD '~);

    mask := 1;
    maxColors := 0;
    for i:=1 to 6 do begin
        if (mask and level.colors) <> 0 then begin
            levelColors[maxColors]:=i;
            inc(maxColors);
        end;
        mask:= mask shl 1;
    end;
    fillbyte(@board,100,TILE_EMPTY);
    InitializeBoard;
    DrawObstacles;
    FillBalls(true);

    findTriples;
    while triplesFound do begin
        CRT_Write(':'~);
        removeTriples;
        while (ballsCanFall) do begin
            FallBalls(true);
        end;
        findTriples;
    end;

    CRT_Clear;
    Write2Line(8,'READY TO RUMBLE!'~);
    clearBoardLine(0);

    DrawButton(14,11,'START GAME');
    i:=getMenuElement(14,1);

    DrawShadows;
    movesCountUpdate := true;
    fillByte(@comboCounters,6,0);
    fillByte(@chainCounters,6,0);
    score:=0;
    levelMovesCount:=0;
    timerTicks := level.time;
    progress := $ff;
    findTriples; // just to update goal counters
end;

function goalReached: boolean;
begin
    if level.wining = REACH_GOAL then exit(false);
    result:=true;
    if level.wining and NO_SHADOWS <> 0 then result:=levelShadowCount=0;
    if level.wining and NO_BLOCKS <> 0 then result:=levelBlockCount=0;
    if level.wining and NO_MARBLES <> 0 then result:=levelMarbleCount=0;
end;

function isShufflable(b:byte):boolean;
begin
	result := (b > 0) and (b < 7);
end;

function findShufflable:word;
var x,y,b:byte;
begin
	repeat
		x:=Random(10);
		y:=Random(10);
		b:=board[x,y]
	until isShufflable(b);
	result:=(x shl 8) + y;
end;

procedure shuffleBoard;
var x,y,b,dx,dy:byte;
	dest:word;
begin
	for x:=0 to 9 do
		for y:=0 to 9 do begin
			b:=board[x,y];
			if isShufflable(b) then begin
				dest:=findShufflable;
				dx:=Hi(dest);
				dy:=Lo(dest);
				SwapTiles(x,y,dx,dy);
			end;
		end;
	PaintBoard;
	FindTriples;
	if triplesFound then DropAndScore;
end;

function GameOverArcadeMenu: byte;
var menu:array [0..2] of byte = (GAME_NEXT, GAME_RESTART, GAME_LEVEL_SELECT);
    won:boolean;
    bonus:cardinal;
begin
    timerTicks := 0;
    XplodeBoard;
    initLevelScreen;
    animate := false;

    color3:= $1a;

    writeBoardSNum(8,0,'LEVEL ',levelNum+1,0);

    won:=goalReached;

    if won then begin
        bonus:=0;
        if level.moves>0 then begin
            bonus := 1000 * (level.moves - levelMovesCount);
            writeBoardSNum(8,2,'MOVES BONUS ',bonus,128);
        end;
        if level.time>0 then begin
            bonus := 100 * progress;
            writeBoardSNum(8,2,'TIME BONUS ', bonus,128);
        end;
        score:=score+bonus;
    end;

    if levelsHiscores[levelNum]<score div 10 then
		levelsHiscores[levelNum] := score div 10;

    writeBoardSNum(8,4,'SCORE ',score,128);

    if (level.wining = REACH_GOAL) or won then begin
        if score >= (level.goal1 * 1000) then begin
            Write2Line(10,'LEVEL BEATEN'~);
            setTrophies(levelNum,1);
            won:=true;
        end else begin
            Write2Line(10,'LEVEL FAILED'~);
            won:=false;
        end;
        if score >= (level.goal2 * 1000) then setTrophies(levelNum,2);
        if score >= (level.goal3 * 1000) then setTrophies(levelNum,3);
    end else begin
        Write2Line(10,'LEVEL FAILED'~);
        won:=false;
    end;
    showTrophies(21,0);

    DrawButton(10,10,'RESTART LEVEL');
    DrawButton(14,10,'EXIT TO MENU');

    //WaitFrames(50);

    if (not levelLocked(levelNum+1)) and (levelNum<levelMax-1) then begin
		DrawButton(6,11,'NEXT LEVEL');
        result:=menu[getMenuElement(6,3)];
    end else result:=menu[getMenuElement(10,2)+1];

    if result = GAME_NEXT then begin
        Inc(levelNum);
        result:=GAME_RESTART;
    end;
end;

function InGameMenu:byte;
var menu:array [0..2] of byte = (GAME_STARTED, GAME_RESTART, GAME_TITLE);
begin
    timerTicks := 0;
    animate := false;
    updateCursor:=0;
    initLevelScreen;

    color3:= $1a;
    Write2Line(10,'GAME  PAUSED'~);

    if gameMode = GAME_MODE_ARCADE then begin
        writeBoardSNum(8,0,'LEVEL ',levelNum+1,0);
        showTrophies(21,0);
        trophiesList(17);
        menu[2]:=GAME_LEVEL_SELECT;
    end;
    if gameMode = GAME_MODE_SURVIVAL then begin
        writeBoard(8,0,'LEVEL SURVIVAL',0);
        writeBoardSNum(8,18,'HISCORE ',survivalHiscore,0);
    end;
    if gameMode = GAME_MODE_ENDLESS then writeBoard(8,0,'LEVEL CHILLOUT',0);
    writeBoardSNum(8,2,'SCORE ',score,128);

    DrawButton(4,11,'RESUME GAME');
    DrawButton(8,10,'RESTART LEVEL');
    DrawButton(12,10,'EXIT TO MENU');


    result:=menu[getMenuElement(4,3)];

    if result=GAME_STARTED then begin
        initGameScreen;
		paintBoard;
        updateCursor:=1;
		cursorShown:=0;
        timerTicks := level.time;
    end;
end;


(*******************************************************************************)
(********************************* MAIN ****************************************)
(*******************************************************************************)

begin
    musicOn:=0;
    SystemOff($fe);
    initLevels;
    loadProgress;
    levelNum:=0;
    //setTrophies(0,3);
    trophiesCount:=666;

    Randomize;
    //msx.player := pointer(RMT_PLAYER);
    //msx.modul := pointer(RMT_MODULE);
    //msx.Init(0);
    //musicOn:=1;

    //if false then msx.Play;
    EnableVBLI(@vbli);
    EnableDLI(@dliInGame);
    DLset;
	PMG_Init(Hi(PMG_ADDRESS), (PMG_sdmctl_default and %11111100) or 1);
    CRT_Init(TXTRAM_ADDRESS, 32, 4);
    nmien:=$c0;

    color0:=2;
    color1:=TXT_FG_COLOR;
    color2:=TXT_BG_COLOR; //BOARD_COLOR2;
    color3:=BOARD_COLOR3;
    color4:=0;

    eraseBoard;
    PaintSides;
    gameState := GAME_TITLE;

    repeat
        bgColor:= $b4;

        gameMode := GameModeSelect;
        if gameMode = GAME_MODE_ARCADE then gameState := GAME_LEVEL_SELECT
            else gameState := GAME_STARTED;
        repeat
            if gameState = GAME_LEVEL_SELECT then levelNum := LevelSelect;

            if gameState <> GAME_TITLE then begin

                if gameMode = GAME_MODE_SURVIVAL then LoadLevel(LEVEL_SURVIVAL);
                if gameMode = GAME_MODE_ENDLESS then LoadLevel(LEVEL_ENDLESS);
                if gameMode = GAME_MODE_ARCADE then LoadLevel(levelNum);

                initGameScreen;
                gameState := GAME_STARTED;

                repeat

                    findMoves;
                    if gameState = NO_MORE_MOVES then begin
                        if gameMode <> GAME_MODE_SURVIVAL then begin
                            s:='NO MORE MOVES. SHUFFLING...'~;
                            Write2Bottom(s);
                            gameState := GAME_STARTED;
                            shuffleBoard;
                        end else begin // SURVIVAL
                            s:='NO MORE MOVES. GAME OVER...'~;
                            Write2Bottom(s);
                        end;
                    end;

                    swapped := false;
                    if strig0 = 0 then begin
                        if stick0 = joy_left then TryToSwap(-1,0);
                        if stick0 = joy_right then TryToSwap(1,0);
                        if stick0 = joy_down then TryToSwap(0,1);
                        if stick0 = joy_up then TryToSwap(0,-1);
                    end;

                    if swapped then begin
                        movesCountUpdate := true;
                        if (level.moves>0) and (level.moves <= levelMovesCount) then begin
                            Write2Bottom(' END OF MOVES'~);
                            gameState:=GAME_OVER_OUTOFMOVES
                        end;
                        if gameMode = GAME_MODE_SURVIVAL then begin
							level.blackProb:=levelMovesCount div 10;
							level.bombProb:=levelMovesCount div 20;

                        end;
                    end;

                    if (gameMode = GAME_MODE_ARCADE) and goalReached then begin
						s:=' GOAL REACHED'~;
						Write2Bottom(s);
						gameState:=GAME_OVER_GOALREACHED
					end;

                    if (timerTicks <> 0) and (progress = 0) then begin
                         Write2Bottom('END OF TIME'~);
                         gameState:=GAME_OVER_OUTOFTIME
                    end;

                    // key handler
                    if CRT_KeyPressed then begin
                        if kbcode = 28 then gameState := InGameMenu;
                       //  if kbcode = 62 then shuffleBoard;
                       if kbcode = 62 then Write2Bottom(Atascii2Antic(IntToStr(timerTicks)));
                        if kbcode = 57 then showHint;
                        if kbcode = 45 then trophiesCount:=666;
						//Write2Bottom(Atascii2Antic(IntToStr(kbcode)));
                    end;

                    WaitFrame;

                until gameState <> GAME_STARTED;

                if (gameState = GAME_OVER_OUTOFMOVES) or (gameState = GAME_OVER_OUTOFTIME) or (gameState = GAME_OVER_GOALREACHED) then begin
                    gameState := GameOverArcadeMenu;
                end;

                if gameState = NO_MORE_MOVES then begin
                    WaitFrames(100);
                    if survivalHiscore<score then survivalHiscore:=score;
                    gameState := GAME_TITLE
                end;
            end;
        until gameState = GAME_TITLE;
    until false;

end.
