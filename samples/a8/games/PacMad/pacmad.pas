program pacmad;

uses datamatrix, _atari, mypmg, dlist, rmt;

{$I globals.inc}
{$I assets/sprites.inc}

var
    pac: pacT;
    dir: byte;
    joy: byte;
    frame: byte absolute 20;

    board: boardT absolute BOARDBASE;
    boardOffset: array [0..BOARDHEIGHT] of word;
    boardLastLine: byte;

    dlOffset: array [0..BOARDHEIGHT] of word;
    dltop: word;
    viewportTop: byte;
    viewportMoveDir: shortint;
    vscrollstep: shortint;
    vOffset: smallInt;
    bOffset: smallInt;

    strings: array [0..0] of pointer absolute STRINGS_ADDRESS;
    levels: array [0..0] of word absolute LEVELS_ADDRESS;
    levelData: array [0..0] of byte;
    level: levelT;
    levelCount: byte;
    currentLevel: byte;

    ghost1, ghost2, ghost3, ghost4: ghostT;
    g: ^ghostT;
    ghosts: array [0..3] of pointer;
    ghostCount: byte;
    ghostFrame: byte;
    ghostSpritesheets: array [0..3] of pointer;

    pillTime: word;
    pillCounter: word;
    pillBonus: word;

    collider: byte;
    titleStage: byte;
    gameState: gameStateT;

    spawners: array [0..SPAWNERS_NUM - 1] of smallInt;
    spawnerCount: byte;
    spawnerActive: byte;
    spawnDelay: word;
    spawnCounter: word;

    bonusPosPicked:boolean;
    bonusX:byte;
    bonusY:byte;
    bonusCountdown:word;
    bonusDelay:word;

    score: cardinal;
    hiscore: cardinal;
    liveBonus: word;
    lives: byte;
    dotCount: word;

    s: TString;
    i: byte;
    flag:boolean;

    secret:array [0..SECRET_LEN-1] of byte;
	secret_id:byte;
	cheat_mode:boolean;

	startingLevel:byte;

    msx: TRMT;
    music: boolean;

    vblVector, dliVector: pointer;

{$R assets/chars.rc}
{$R assets/logo.rc}
{$R assets/asm_assets.rc}
{$r assets/rmt_play.rc}

{$I interrupts.inc}
{$I dlist.inc}


(********************************************** GUI ROUTINES ******************************************)


procedure SystemOff;
begin
asm
{
    txa:pha
    lda:cmp:req 20
    sei
    mva #0 _ATARI._NMIEN
    sta _atari._sdmctl_
    mva #$fe _ATARI._PORTB
    mva >CHARSET_TITLE_ADDRESS _ATARI._CHBASE
    mwa #nmi _ATARI._NMIVEC
    mwa vblVector vblvec
    mva #scr40 _atari._sdmctl_
    mva #$c0 _ATARI._NMIEN
    bne stop
nmi
    bit _ATARI._NMIST
    bpl vbl
    jmp (_ATARI._VDSLST)
    rti

vbl
    jmp $ffff
vblvec  equ *-2
stop
    pla:tax
};
end;

procedure setDli(dliptr: pointer);
begin
    dliVector := dliptr;
    _VDSLST := word(dliptr);
end;

procedure ClearTxT;
begin
    FillByte(pointer(TXT_RAM),$400,0);
end;

procedure UpdateScore;
begin
    Str(score, s);
    asm {
        ldy #1
@       lda adr.s,y
        sub #32
        sta TXT_RAM+6,y
        iny
        dec adr.s
        bne @-
        lda #0
        sta TXT_RAM+6,y
    };
end;

procedure UpdateHiscore;
begin
    Str(hiscore, s);
    asm {
        ldy #1
@       lda adr.s,y
        sub #32
        sta TXT_RAM+21,y
        iny
        dec adr.s
        bne @-
        lda #0
        sta TXT_RAM+6,y
    };
end;

procedure UpdateFood;
begin
    Str(dotCount, s);
    asm {
        ldy #1
@       lda adr.s,y
        sub #32
        sta TXT_RAM+21,y
        iny
        dec adr.s
        bne @-
        lda #0
        sta TXT_RAM+21,y
    };
end;

procedure UpdateLives;
begin
    Str(lives, s);
    asm {
        ldy #1
@       lda adr.s,y
        sub #32
        sta TXT_RAM+36,y
        iny
        dec adr.s
        bne @-
        lda #0
        sta TXT_RAM+36,y
    };
end;

procedure UpdateEndLevel;
begin
    Str(currentLevel+1, s);
    asm {
        ldy #1
@       lda adr.s,y
        sub #32
        sta TXT_RAM+36,y
        iny
        dec adr.s
        bne @-
        lda #0
        sta TXT_RAM+36,y
    };
end;

procedure UpdateLevel;
begin
    Str(startingLevel+1, s);
    asm {
        ldy #1
@       lda adr.s,y
        sub #32
        sta TXT_RAM+40*15+30,y
        iny
        dec adr.s
        bne @-
        lda #0
        sta TXT_RAM+40*15+30,y
    };
end;

procedure SongStart(pattern:byte);
begin
    msx.Init(pattern);
    music := true;
end;

procedure SongStop;
begin
    msx.Init(SONG_SILENCE);
    music := false;
end;

procedure GhostColorsDefault;
begin
    _PCOLR0_ := COLOR_G1;
    _PCOLR1_ := COLOR_G2;
    _PCOLR2_ := COLOR_G3;
    _PCOLR3_ := COLOR_G4;
end;

procedure GhostColorsEscape(color: byte);
begin
    _PCOLR0_ := color;
    _PCOLR1_ := color;
    _PCOLR2_ := color;
    _PCOLR3_ := color;
end;

procedure putChar(dest:word;letter:word);
var src1,src2:word;
    x:byte;
begin
    src1:=CHARSET_GAME_ADDRESS+Lo(letter)*8;
    src2:=CHARSET_GAME_ADDRESS+Hi(letter)*8;
    for x:=0 to 7 do begin
        Poke(dest,Peek(src1));
        Poke(dest+1,Peek(src2));
        Inc(src1);
        Inc(src2);
        Inc(dest,10);
    end;
end;

procedure putArray(x,y,size:byte;a:word);
var dest:word;
begin
    dest:=TXT_RAM+(y*10)+x;
    for i:=0 to size-1 do begin
        putChar(dest,Dpeek(a));
        Inc(dest,2);
        Inc(a,2);
    end;
end;

procedure putNumber(x,y:byte;num:TString);
var dest:word;
begin
    dest:=TXT_RAM+(y*10)+x;
    for i:=1 to byte(num[0]) do begin
        putChar(dest,txt_numbers[byte(num[i])-48]);
        Inc(dest,2);
    end
end;

procedure putNumber2(x,y:byte;num:TString);
var dest:word;
begin
    dest:=GFX_RAM+(y*40)+x;
    for i:=1 to byte(num[0]) do begin
        Dpoke(dest,txt_numbers[byte(num[i])-48]);
        Inc(dest,2);
    end
end;


(********************************************** BOARD ROUTINES ******************************************)


procedure PaintOnBoard(x, y, t: byte);
begin
    vOffset := dlOffset[y] + byte(x shl 1) - 1;
    Dpoke(vOffset, tiles[t]);
end;

function GetBoard(x, y: byte): byte;
var pos: word;
begin
    pos := boardOffset[y] + x;
    result := board[pos];
end;

procedure SetBoard(x, y, v: byte);
var pos: word;
begin
    pos := boardOffset[y] + x;
    board[pos] := v;
    PaintOnBoard(x, y, v);
end;

function CanMoveTo(x, y: byte): boolean;
begin
    Result := true;
    if GetBoard(x, y) = TILE_VOID then exit(false);
    if x >= BOARDWIDTH then exit(false);
    if y >= BOARDHEIGHT then exit(false);
    if GetBoard(x, y) = TILE_SPAWNER then exit(false);
end;

function GetNeighbours(x, y: byte): byte;
var counter: byte;
begin
    counter := 0;
    result := 0;
    if canMoveTo(x-1, y) then begin  // left
        Inc(result, %0100);
        Inc(counter);
    end;
    if canMoveTo(x+1, y) then begin
        Inc(result, %1000);    // right
        Inc(counter);
    end;
    if canMoveTo(x, y+1) then begin
        Inc(result, %0010);    // down
        Inc(counter);
    end;
    if canMoveTo(x, y-1) then begin
        Inc(result, %0001);    // up
        Inc(counter);
    end;
    counter := counter shl 4;
    result := result or counter;
end;

procedure AddScore(val:word);
begin
    Inc(score, val);
    Inc(liveBonus, val);
    if (liveBonus >= LIFE_BONUS) then begin
        Inc(lives);
        UpdateLives;
        msx.Sfx(3, 2, 24);
        Dec(liveBonus, LIFE_BONUS);
    end;
    UpdateScore;
end;

procedure CheckBoardAction;
var cell: byte;
begin
    cell := GetBoard(pac.x, pac.y);
    case cell of
        TILE_DOT: begin
            AddScore(10);
            if dotCount<>0 then begin
				Dec(dotCount);
				if dotCount=0 then msx.Sfx(4, 2, 12);
			end;
            UpdateFood;
            SetBoard(pac.x, pac.y, TILE_EMPTY);
        end;
        TILE_PILL: begin
            AddScore(50);
            SetBoard(pac.x, pac.y, TILE_EMPTY);
            gameState := GAME_ESCAPE;
            GhostColorsEscape(COLOR_ESCAPE);
            pillCounter := pillTime;
            pillBonus := 0;
            SongStart(SONG_PILL);
        end;
        TILE_WARP_LEFT: begin
            pac.x := 20;
        end;
        TILE_WARP_RIGHT: begin
            pac.x := 0;
        end;
        TILE_EXIT: begin
            if dotCount = 0 then begin
                gameState := GAME_WIN;
                frame := 0;
            end;
        end;
        TILE_BONUS, TILE_BONUS+1, TILE_BONUS+2: begin
            AddScore(500);
            bonusCountdown:=100;
            SetBoard(bonusX,bonusY,TILE_500);
            msx.Sfx(5, 2, 12);
        end;
    end;
end;

procedure BoardRect(x, y, w, h, f: byte);
begin
    Dec(h);
    Dec(w);
    for i := x to x + w do begin
        SetBoard(i, y, f);
        SetBoard(i, y + h, f);
    end;
    if h > 0 then begin
        Dec(h);
        for i := y + 1 to y + h do begin
            SetBoard(x, i, f);
            SetBoard(x+w ,i, f);
        end;
    end;
end;

procedure PaintBoard;
var row, col, cell, t: byte;
    voffset, boffset, tile: word;
begin
    voffset := GFX_RAM;
    boffset := 0;
    boardLastLine := 0;
    dotCount := 0;
    for row := 0 to BOARDHEIGHT - 1 do begin
        if (board[boffset] = TILE_VOID) then begin
            tile := fences[GetNeighbours(0, row) and 15];
			if (Hi(tile) = $4f) and canMoveTo(1, row+1) then tile := fences[16];
        end else
            tile := tiles[board[boffset]];
        Poke(voffset, Hi(tile));
        Inc(voffset);
        Inc(boffset);
        for col := 1 to BOARDWIDTH - 2 do begin
            cell := board[boffset];
            if cell = TILE_VOID then begin
				t := GetNeighbours(col,row) and 15;
                tile := fences[t];
                if (Hi(tile) = $4f) and CanMoveTo(col+1, row+1) then
					tile := (tile and $00ff) or $5000;
            end else begin
                tile := tiles[cell];
                if (cell = TILE_DOT) then Inc(dotCount);
                boardLastLine := row;
            end;
            Dpoke(voffset, tile);
            _COLOR0 := Lo(bOffset);
            Inc(voffset, 2);
            Inc(boffset);
        end;
        if (board[boffset] = TILE_VOID) then
            tile := fences[GetNeighbours(BOARDWIDTH - 1,row) and 15]
        else
            tile := tiles[board[boffset]];
        Poke(voffset, Lo(tile));
        Inc(voffset);
        Inc(boffset);
    end;
    Inc(boardLastLine,2);
    if GetBoard(level.exitX,level.exitY) = TILE_DOT then Dec(dotCount);
    SetBoard(level.exitX,level.exitY,TILE_EXIT);
end;

procedure ClearFeatures;
begin
    for i := 0 to SPAWNERS_NUM - 1 do spawners[i] := -1;
end;

procedure InitTables;
var row: byte;
    voffset: word;
    boffset: word;
begin
    voffset := GFX_RAM;
    boffset := 0;
    for row := 0 to BOARDHEIGHT - 1 do begin
        dlOffset[row] := voffset;
        boardOffset[row] := boffset;
        Inc(voffset, SCREEN_WIDTH);
        Inc(boffset, BOARDWIDTH);
    end;
    ghosts[0] := @ghost1;
    ghosts[1] := @ghost2;
    ghosts[2] := @ghost3;
    ghosts[3] := @ghost4;
    hiscore := 0;
    levelCount := 0;
    repeat
        Inc(levelCount)
    until levels[levelCount] = 0;
    msx.player := pointer(rmt_player);
    msx.modul := pointer(rmt_modul);
    music := false;
    secret_id := 0;
	secret[0] := 0;
	cheat_mode := false;
	startingLevel := 0;
end;

procedure MoveViewport;
begin
    if (viewportMoveDir <> 0) then begin     // if vscroll in progress jump to another line
        vscrollstep := (vscrollstep + viewportMoveDir) and 7;
        if (vscrollstep = 7) and (viewportMoveDir = -1) then begin // if vscroll starts up
            viewportTop := viewportTop + viewportMoveDir;
        end;
        if (vscrollstep = 0) and (viewportMoveDir = 1) then begin // if vscroll ends
            viewportTop := viewportTop + viewportMoveDir;
        end;
    end;
    dltop := dlOffset[viewportTop];
end;

procedure BlinkExit;
begin
    if (frame and 4) = 0 then PaintOnBoard(level.exitX, level.exitY, TILE_EXIT)
    else PaintOnBoard(level.exitX, level.exitY, TILE_EXIT_OPEN);
end;

procedure PickBonusPos;
var x,y:byte;
begin
    x:=random(BOARDWIDTH);
    y:=random(BOARDHEIGHT);
    if GetBoard(x,y) = TILE_EMPTY then begin
        bonusX := x;
        bonusY := y;
        bonusPosPicked := true;
    end;
end;

procedure RemoveBonus;
begin
    SetBoard(bonusX,bonusY,TILE_EMPTY);
    bonusPosPicked := false;
    bonusDelay := BONUS_DELAY * 50;
end;

procedure PlaceBonus;
begin
    i:=TILE_BONUS + Random(BONUS_COUNT);
    SetBoard(bonusX,bonusY,i);
    bonusCountdown := BONUS_COUNTDOWN * 50;
end;


{********************************************** GHOST ROUTINES ******************************************}


procedure ClearGhosts;
begin
    for i := 0 to GHOST_NUM-1 do begin
        g := ghosts[i];
        g^.dir := DIR_NONE;
        g^.deadCount := 0;
    end;
    ghostCount := 0;
end;

procedure SpawnGhost(ghostNumber, x, y: byte);
var dir, nx, ny: byte;
begin
    g := ghosts[ghostNumber];
    g^.x := x;
    g^.y := y;
    repeat
        nx := x;
        ny := y;
        dir := Random(4);
        if (dir = DIR_UP) then Dec(ny);
        if (dir = DIR_DOWN) then Inc(ny);
        if (dir = DIR_LEFT) then Dec(nx);
        if (dir = DIR_RIGHT) then Inc(nx);
    until CanMoveTo(nx, ny);
    g^.dir := dir;
    g^.deadCount := 0;
    g^.despawn := 0;
    ghostSpritesheets[ghostNumber] := ghost_sprites[dir];
    g^.step := 0;
    g^.level := level.ai[ghostNumber];
    Inc(ghostCount);
end;

procedure KillGhost(ghostNumber: byte);
begin
    g := ghosts[ghostNumber];
    g^.dx := g^.x;
    if g^.dx = 0 then g^.dx := 1
    else if g^.dx = 20 then g^.dx := 19;
    g^.dy := g^.y;
    g^.deadCount := 150;
    if pillBonus = 100 then g^.reward := TILE_100;
    if pillBonus = 200 then g^.reward := TILE_200;
    if pillBonus = 300 then g^.reward := TILE_300;
    if pillBonus = 400 then g^.reward := TILE_400;
    if pillBonus = 500 then g^.reward := TILE_500;
    PaintOnBoard(g^.dx, g^.dy, g^.reward);
    FillChar(pointer(PMGBASE + 512 + (ghostNumber shl 7)), 128, 0);
end;

procedure DespawnGhost(ghostNumber: byte);
begin
    g := ghosts[ghostNumber];
    g^.deadCount := 0;
    g^.dir := DIR_NONE;
    Dec(ghostCount);
    FillChar(pointer(PMGBASE + 512 + (ghostNumber shl 7)), 128, 0);
end;

function RandomDir(mask: byte): byte;
var a:array[0..3] of byte;
    ai:byte;
begin
	ai:=0;
	for result:=0 to 3 do
		if dirs[result] and mask <> 0 then begin
			a[ai]:=dirs[result];
			inc(ai)
		end;
    result := n2dir[a[Random(ai)]];
end;

function Reverse(dir: byte): byte;
begin
    result := dir;
    if (dir and 3 <> 0) then result := result xor 3;
    if (dir and 12 <> 0) then result := result xor 12;
end;

function FollowPac(ghostNumber, mask: byte): byte;
var dx, dy: byte;
    bestdir1, bestdir2: byte;
begin
    g := ghosts[ghostNumber];
    if Random(g^.level) = 0 then exit(RandomDir(mask));
    dx := Abs(shortInt(pac.x - g^.x));
    dy := Abs(shortInt(pac.y - g^.y));
    if dy > dx then begin
        if g^.y < pac.y then bestdir1 := JOY_DOWN
            else bestdir1 := JOY_UP;
        if g^.x < pac.x then bestdir2 := JOY_RIGHT
            else bestdir2 := JOY_LEFT;
    end else begin
        if g^.x < pac.x then bestdir1 := JOY_RIGHT
            else bestdir1 := JOY_LEFT;
        if g^.y < pac.y then bestdir2 := JOY_DOWN
            else bestdir2 := JOY_UP;
    end;
    result := Random(4);  // how often choose second choice
    if result = 0 then begin
        result := bestdir2;
        bestdir2 := bestdir1;
        bestdir1 := result;
    end;

    if gameState = GAME_ESCAPE then begin
        bestdir1 := Reverse(bestdir1); // reverse directions when ghost escapes
        bestdir2 := Reverse(bestdir2);
    end;

    result := DIR_NONE;
    if (bestdir2 and mask) <> 0 then result := n2dir[bestdir2];
    if (bestdir1 and mask) <> 0 then result := n2dir[bestdir1];
    if result = DIR_NONE then result := RandomDir(mask);

end;

procedure MoveGhost(ghostNumber: byte);
var exitMask, exitCount, step: byte;
begin
    g := ghosts[ghostNumber];
    if (g^.deadCount > 0) then begin
        PaintOnBoard(g^.dx, g^.dy, g^.reward);
        g^.deadCount := g^.deadCount - 1;
        if g^.deadCount = 0 then begin
            PaintOnBoard(g^.dx, g^.dy, GetBoard(g^.dx, g^.dy));
            g^.dir := DIR_NONE;
            Dec(ghostCount);
        end;
    end else
    if (g^.dir <> DIR_NONE) then begin
        g^.sy := shortInt(g^.y - viewportTop) shl 3;
        g^.sy := g^.sy + 16;
        g^.sy := g^.sy - vscrollstep;
        g^.sx := PMG_LEFT_OFFSET + g^.x shl 3;

        if Odd(g^.dir) then g^.sx := g^.sx + g^.step
        else g^.sy := g^.sy + g^.step;

        g^.spriteHeight := SPRITE_HEIGHT;
        g^.spriteOffset := 0;

        if g^.sy < BOARD_TOP then begin   // sprite out of top boundry
            vOffset := BOARD_TOP - g^.sy;
            if vOffset > SPRITE_HEIGHT then g^.spriteHeight := 0
            else begin  // if part visible
                g^.sy := BOARD_TOP;
                g^.spriteOffset := vOffset;
                g^.spriteHeight := SPRITE_HEIGHT - vOffset;
            end;
        end;
        if g^.sy > BOARD_BOTTOM then begin    // sprite out of bottom boundry
            vOffset := g^.sy - BOARD_BOTTOM;
            if vOffset > SPRITE_HEIGHT then g^.spriteHeight := 0
            else g^.spriteHeight := g^.spriteHeight - vOffset;
        end;

        step:=1;
        if gameState = GAME_ESCAPE then step := frame and 1; // slow down by skipin steps in escape mode
        if step<>0 then begin
			if ((g^.dir = DIR_RIGHT) or (g^.dir = DIR_DOWN)) then g^.step := g^.step + step;
			if ((g^.dir = DIR_LEFT) or (g^.dir = DIR_UP)) then g^.step := g^.step - step;

			if Abs(g^.step) = 8 then begin // moved into new position
				if (Abs(shortInt(g^.y-pac.y))<GHOST_DESPAWN_DISTANCE) then g^.despawn := 0
				else g^.despawn := g^.despawn + 1;
				if g^.despawn = GHOST_DESPAWN_DELAY then DespawnGhost(ghostNumber)
				else begin
					if g^.step > 0 then g^.step := 1 else g^.step := -1;
					if Odd(g^.dir) then begin // horizontal
						g^.x := g^.x + g^.step;
						if not CanMoveTo(g^.x + g^.step,g^.y) then g^.dir := DIR_NONE; // on turns try to follow pac
					end else begin                // vertical
						g^.y := g^.y + g^.step;
						if not CanMoveTo(g^.x,g^.y + g^.step) then g^.dir := DIR_NONE; // on turns try to follow pac
					end;
					g^.step := 0;

					exitMask := GetNeighbours(g^.x, g^.y);
					exitCount := exitMask shr 4;
					 // if more than 3 exits or cannot continue move then take decision
					if (exitCount > 2) or (g^.dir = DIR_NONE) then g^.dir := FollowPac(ghostNumber,exitMask);
				end;
			end;
		end;
        ghostSpritesheets[ghostNumber] := ghost_sprites[g^.dir];
    end;
end;

procedure ShowGhost(ghostNumber: byte);
var s: array[0..0] of word;
begin
    g := ghosts[ghostNumber];
    if gameState = GAME_ESCAPE then s := @ghost_escape
    else s := ghostSpritesheets[ghostNumber];
    if (g^.dir <> DIR_NONE) and (g^.deadCount = 0) then begin
        if (g^.spriteHeight <> 0) then
           Move(pointer(s[ghostFrame] + g^.spriteOffset), pointer(PMGBASE + 512 + (ghostNumber shl 7) + g^.sy), g^.spriteHeight)
        else
           g^.sx := 0;
        Poke($d000+ghostNumber, g^.sx); // hpos
    end;
end;

procedure MoveGhosts;
begin
    MoveGhost(0);
    MoveGhost(1);
    MoveGhost(2);
    MoveGhost(3);
end;

procedure ShowGhosts;
begin
    ShowGhost(0);
    ShowGhost(1);
    ShowGhost(2);
    ShowGhost(3);
    ghostFrame := (frame shr 4) and 1;
end;

function FreeGhostSlot:byte;
begin
    for i := 0 to GHOST_NUM - 1 do begin
        g := ghosts[i];
        if g^.dir = DIR_NONE then exit(i);
    end;
end;

function SelectSpawner: byte;
var i,min,dist:byte;
begin
    min:=100;
    for i:=0 to spawnerCount-1 do begin
        dist := Abs(shortint(Lo(spawners[i]) - pac.y));
        if dist < min then begin
            result := i;
            min := dist;
        end;
    end;
end;

procedure CloseAllSpawners;
begin
    for i := 0 to spawnerCount-1 do
        PaintOnBoard(Hi(spawners[i]),Lo(spawners[i]),TILE_SPAWNER);
end;

procedure TryToSpawnGhost;
var ghostNumber: byte;
begin
    if ghostCount < 4 then begin
        ghostNumber := FreeGhostSlot;
        if spawnCounter = 80 then begin
            spawnerActive := SelectSpawner;
            PaintOnBoard(Hi(spawners[spawnerActive]),Lo(spawners[spawnerActive]),TILE_SPAWNER_OPEN1);
        end;
        if spawnCounter = 40 then begin
            PaintOnBoard(Hi(spawners[spawnerActive]),Lo(spawners[spawnerActive]),TILE_SPAWNER_OPEN2);
        end;
        if (spawnCounter = 0) then begin
			Inc(spawnCounter);
			if (pac.frame = ghostNumber + 1) then begin
				PaintOnBoard(Hi(spawners[spawnerActive]),Lo(spawners[spawnerActive]),TILE_SPAWNER);
				SpawnGhost(ghostNumber,Hi(spawners[spawnerActive]),Lo(spawners[spawnerActive]));
				spawnCounter := spawnDelay;
            end;
        end;
        Dec(spawnCounter);
    end;
end;


{********************************************** PAC ROUTINES ******************************************}


procedure InitPac(x, y: byte);
begin
    pac.x := x;
    pac.y := y;
    pac.step := 0;
    pac.frame := 0;
    pac.dir := DIR_NONE;
    pac_sprites[DIR_NONE] := pac_sprites[DIR_UP];
    pac.sprite := pac_sprites[pac.dir];
    viewportTop := pac.y - 6;
    if (pac.y > byte(boardLastLine - 6)) then viewportTop := viewportTop + (boardLastLine-6-pac.y);
    if (pac.y < 6) then viewportTop := 0;
end;

procedure ShowPac;
begin
    _HPOSM3 := pac.sx;
    _HPOSM2 := pac.sx+2;
    _HPOSM1 := pac.sx+4;
    _HPOSM0 := pac.sx+6;
    Move(pac.sprite[pac.frame], pointer(PMGBASE + 384 + pac.sy), SPRITE_HEIGHT);
end;

procedure MovePac;
begin
    pac.sy := 16 + byte((pac.y - viewportTop) shl 3) - vscrollstep;  // count coordinates relative to viewport
    pac.sx := PMG_LEFT_OFFSET + pac.x shl 3;

    if Odd(pac.dir) then pac.sx := pac.sx + pac.step  // increment coordinates by current pac step
    else pac.sy := pac.sy + pac.step;

    pac.frame:=(pac.frame + 1) and 7; // jump to next animation frame

    if ((pac.dir = DIR_RIGHT) or (pac.dir = DIR_DOWN)) then Inc(pac.step); // increment step for right or down movement
    if ((pac.dir = DIR_LEFT) or (pac.dir = DIR_UP)) then Dec(pac.step); // decrement for remaining directions

    if abs(pac.step) = 8 then begin // moved into new position
        if pac.step > 0 then pac.step := 1 else pac.step := -1;   // get position increment
        if Odd(pac.dir) then  // horizontal
            pac.x := pac.x + pac.step // increment absolute position
        else                // vertical
            pac.y := pac.y + pac.step; // increment absolute position
        pac.step := 0;
        CheckBoardAction;
    end;
end;

procedure CheckIfPacTurnsBack;
begin
    if _STICK0 <> 15 then begin    // if stick moved then check if pac wants turn back
        joy := not (_STICK0 or %11110000);
        if joy2dir[joy] = pac.dir then begin
            viewportMoveDir := -viewportMoveDir;
            pac.dir := (pac.dir + 2) and 3;
        end;
    end;
end;

procedure CheckIfPacTurns;
begin
    if (pac.dir <> DIR_NONE) then begin; // if pac was, moving check if it's able to continue movement
        case pac.dir of
            DIR_UP: if (not canMoveTo(pac.x, pac.y - 1)) then pac.dir := DIR_NONE;
            DIR_DOWN: if (not canMoveTo(pac.x, pac.y + 1)) then pac.dir := DIR_NONE;
            DIR_LEFT: if (not canMoveTo(pac.x - 1, pac.y)) then pac.dir := DIR_NONE;
            DIR_RIGHT: if (not canMoveTo(pac.x + 1, pac.y)) then pac.dir := DIR_NONE;
        end;
    end;

    if joy <> 0 then begin    // if stick is moved try to turn pac
                            // for diagonal stick movement, turning sides has bigger priority than fwd/bck movement
        dir := pac.dir;
        flag := pac.dir = DIR_NONE;
        if (joy and JOY_UP <> 0) then // up
            if canMoveTo(pac.x, pac.y-1) then
                if Odd(pac.dir) or flag then dir := DIR_UP;

        if (joy and JOY_DOWN <> 0) then // down
            if canMoveTo(pac.x, pac.y+1) then
                if Odd(pac.dir) or flag then dir := DIR_DOWN;

        if (joy and JOY_LEFT <> 0) then // left
            if canMoveTo(pac.x-1, pac.y) then
                if not Odd(pac.dir) or flag then dir := DIR_LEFT;

        if (joy and JOY_RIGHT <> 0) then // right
            if canMoveTo(pac.x+1, pac.y) then
                if not Odd(pac.dir) or flag then dir := DIR_RIGHT;
        pac.dir := dir;
    end;

    pac.sprite := pac_sprites[pac.dir];    // set sprite sheet based on direction
    pac_sprites[DIR_NONE] := pac.sprite;   // set current sprite sheet for idle
    viewportMoveDir := 0;                    // reset vscroll

    if (pac.dir <> DIR_NONE) and not Odd(pac.dir) then begin // if pac moves verticaly
        if (pac.dir = DIR_DOWN) and (pac.y > 5) and (pac.y < byte(boardLastLine - 6)) then begin  // and up scroll needed
            viewportMoveDir := 1; // start scroll screen up
        end;
        if (pac.dir = DIR_UP) and (pac.y > 6) and (pac.y < boardLastLine - 5) then begin  // or scroll down needed
            viewportMoveDir := -1; // start scroll screen down
        end;
    end;
end;

function PacColider: byte;
begin
    result := _SIZEP0 or _SIZEP1 or _SIZEP2 or _SIZEP3;
end;

function TouchedGhostNum(collider:byte):byte;
begin
    if (collider and %0001) <> 0 then result := 0;
    if (collider and %0010) <> 0 then result := 1;
    if (collider and %0100) <> 0 then result := 2;
    if (collider and %1000) <> 0 then result := 3;
end;

procedure PacDies;
begin
    Dec(lives);
    UpdateLives;
    frame := 1;
    pac.sprite := @pac_dies;
    pac.frame := 0;
end;


{********************************************** GAME ROUTINES ******************************************}


procedure GrabGui;
begin
    PMG_init(Hi(PMGBASE));
    _GPRIOR_ := 1 + 16; // 5th player
end;

procedure ReadSecret;
var lk:byte;
begin
	if secret[0] <> 0 then begin
		if _KBCODE < 64 then  begin
			lk := keycodes[_KBCODE];
			if lk = secret[secret_id] then begin
				inc(secret_id);
				if secret_id = SECRET_LEN then begin
					secret_id:=0;
					cheat_mode := not cheat_mode;
					if cheat_mode then poke(TXT_RAM,32)
					else poke(TXT_RAM,0);
				end;
			end;
		end;
	end;
end;

procedure ShowTitleScreen;
var selectState,selectState_:byte;
	selectFrame:word;
begin
    Pause;
    setDli(@Dli1T);
    _CHBASE := Hi(CHARSET_TITLE_ADDRESS);
    Move(DL_title,pointer(DL),64);
    _SDLSTL_ := DL;
    _COLOR4_ := 0;
    PMG_clear;
    ClearTxT;
	secret_id:=0;
	if cheat_mode then poke(TXT_RAM,32)
	else poke(TXT_RAM,0);

    UpdateHiScore;
    Move(strings[11],pointer(TXT_RAM+12),9);
    if hiscore = 0 then Move(strings[1],pointer(TXT_RAM+5),30);
	selectState_ := _CONSOL and 2;
	selectFrame := 0;

    GhostColorsDefault;
    for i:=0 to 3 do begin
        g := ghosts[i];
        g^.dir := DIR_RIGHT;
        g^.spriteHeight := 12;
        g^.spriteOffset := 0;
        g^.deadCount := 0;
        ghostSpritesheets[i] := ghost_sprites[DIR_RIGHT];
        g^.step := 0;
        g^.sy := 53 + i * 12;
        g^.sx := 0;
    end;

    titleStage := 0;
    repeat
        if music then msx.Play;
        Pause;
        ghostFrame := (frame shr 4) and 1;

        if selectFrame = 0 then begin
			Move(strings[12],pointer(TXT_RAM+40*15+8),23);
			UpdateLevel
		end;
        if selectFrame = 150 then Move(strings[2],pointer(TXT_RAM+40*15+11),19);
        if (selectFrame = 100) or (selectFrame = 250) then FillByte(pointer(TXT_RAM+40*15+8),26,0);

		Inc(selectFrame);
		if selectFrame=300 then selectFrame:=0;

		ReadSecret;

        case titleStage of
            0: begin
                for i:=0 to 3 do begin
                    g := ghosts[i];
                    g^.sx := g^.sx + 1;
                    if byte(g^.sx) = 106 then titleStage:=1;
                    ShowGhost(i);
                end;
            end;
            1: begin
                frame := 0;
                Move(strings[4],pointer(TXT_RAM+40*2+18),8);
                Move(strings[5],pointer(TXT_RAM+40*5+18),7);
                Move(strings[6],pointer(TXT_RAM+40*8+18),7);
                Move(strings[7],pointer(TXT_RAM+40*11+18),6);
                titleStage:=2;
            end;
            2: begin
                ShowGhosts;
                if frame = 0 then titleStage:=3;
            end;
            3: begin
                FillByte(pointer(TXT_RAM+40*2),400,0);
                titleStage:=6;
            end;
            6: begin
                for i:=0 to 3 do begin
                    g := ghosts[i];
                    g^.sx := g^.sx + 1;
                    if byte(g^.sx) = 0 then titleStage:=7;
                    ShowGhost(i);
                end;
            end;
            7: begin
                frame := 0;
                pac.step := 0;
                pac.frame := 0;
                pac.sprite := pac_sprites[DIR_RIGHT];
                pac.sy := 69;
                Move(strings[3],pointer(TXT_RAM+40*2+5),31);
                Move(strings[8],pointer(TXT_RAM+40*4+8),25);
                Move(strings[9],pointer(TXT_RAM+40*8+8),25);
                Move(strings[10],pointer(TXT_RAM+40*11+3),35);
                titleStage:=8;
            end;
            8: begin
                pac.frame:=(pac.frame + 1) and 7;
                pac.sx := frame;
                ShowPac;
                if frame = 0 then titleStage:=9;
            end;
            9: begin
                if frame = 200 then titleStage:=10;
            end;
            10: begin
                FillByte(pointer(TXT_RAM+40*2),400,0);
                titleStage:=0;
            end;

        end;
		selectState := _CONSOL and 2;
		if (selectState_ <> selectState) and (selectState = 0) then begin
			Inc(startingLevel);
			if startingLevel=levelCount then startingLevel := 0;
			selectFrame:=0;
		end;
		selectState_ := selectState;

    until (_STRIG0 = 0) or (_CONSOL and 1 = 0);
    repeat until _STRIG0 = 1
end;

procedure ShowLevelScreen;
begin
    ClearTxT;
    Pause;
    Move(DL_LEVEL,pointer(DL),Length(DL_LEVEL));
    _SDLSTL_ := DL;
    _COLOR4_ := 15;
    PMG_clear;
end;

procedure ShowDM;
var vptr,data:word;
    row,col,b:byte;
    chunk: array[0..0] of byte;
begin
    data := DM_DATA + $100;
    vptr := TXT_RAM + 2;
    row := 0;
    repeat
        col := 0;
        repeat
            chunk := pointer(data);
            b := chunk[0];
            b := b shl 2;
            b := b or chunk[1];
            b := b shl 2;
            b := b or chunk[2];
            b := b shl 2;
            b := b or chunk[3];
            Poke(vptr,b);
            Inc(data,4);
            Inc(col,4);
            Inc(vptr);
        until col = DM_SIZE;
        Inc(row);
        Inc(vptr,4);
    until row = DM_SIZE;
    Poke(708,0);
end;

procedure PutCharPM(c:byte;offset:word);
var src1:word;
    x:byte;
begin
    src1:=CHARSET_TITLE_ADDRESS+c*8;
    for x:=0 to 7 do begin
        Poke(offset+x,Peek(src1));
        Inc(src1);
    end;
end;

procedure ShowScorePM;
var offset:word;
    digit:byte;
begin
    offset:=PMGBASE + 512 + 64 - byte(length(s) * 5);
    for i:=1 to Length(s) do begin
        digit:=byte(s[i])+16;
        PutCharPM(digit,offset);
        PutCharPM(digit,offset+128);
        Inc(offset,10);
    end;
end;

procedure RandomizeSecret;
var i:byte;
begin
	for i:=0 to SECRET_LEN-1 do begin
		secret[i]:=Random(26)+97;
	end;
end;

procedure ShowDataMatrix(score:cardinal);
var p,x,c:byte;
var sine:array [0..31] of byte = (2,2,3,3,3,4,4,4,4,4,4,4,3,3,3,2,2,2,1,1,1,0,0,0,0,0,0,0,1,1,1,2);
begin
    p := 0;
    ShowLevelScreen;
    if score < 100 then begin
		RandomizeSecret;
		for c := 0 to SECRET_LEN-1 do s[c+1] := char(secret[c]);
		s[0] := char(SECRET_LEN);
		SetMessage(s, DM_DATA);
    end else begin
		if cheat_mode then begin
			s := 'No Hiscore For Cheaters!!!';
			SetMessage(s, DM_DATA);
			Str(score,s);
		end else begin
			Str(score,s);
			SetMessage(HSC_URI, DM_DATA);
			SetMessage(s, DM_DATA + 26);
		end;
		ShowScorePM;
    end;
    CalculateMatrix;
    ShowDM;
    _SIZEP0 := 1;
    _SIZEP1 := 1;
    repeat
        c:=p+_VCOUNT;
        x:=48 + sine[c and 31];
        _WSYNC := 0;
        _PCOLR0 := c;
        _PCOLR1 := c;
        _HPOS0 := x;
        _HPOS1 := 140 + x;
        if _vcount=126 then inc(p);
    until (_STRIG0 = 0) or (_CONSOL and 1 = 0); // or (_SKSTAT and 4 = 0);

    repeat until _STRIG0 = 1;
    _SIZEP0 := 0;
    _SIZEP1 := 0;
end;

procedure InitGameScreen;
begin
    Pause;
    setDli(@Dli1);
    Move(DL_game,pointer(DLG),Length(DL_game));
    _SDLSTL_ := DLG;
    _VSCROL := 0;
    PMG_clear;
end;

function ReadLevelData(ptr: word): word;
var tile,count,tileSize:byte;
    p:word;
begin
    tile := levelData[0];
    count := levelData[1];
    p := 2;
    tileSize := 2;

    case tile of

        TILE_DOT, TILE_EMPTY, TILE_VOID: begin
            tileSize := 4;
            repeat
                BoardRect(levelData[p], levelData[p+1], levelData[p+2], levelData[p+3], tile);
                p := p + tileSize;
                Dec(count)
            until count = 0;
        end;

        TILE_PILL: begin
            repeat
                SetBoard(levelData[p], levelData[p+1], tile);
                p := p + tileSize;
                Dec(count)
            until count = 0;
        end;

        TILE_SPAWNER: begin
            spawnerCount := 0;
            repeat
                SetBoard(levelData[p], levelData[p+1], tile);
                spawners[spawnerCount] := (levelData[p] shl 8) + levelData[p+1];
                p := p + tileSize;
                Inc(spawnerCount);
                Dec(count);
            until count = 0;
        end;

        TILE_WARP_LEFT: begin
            tileSize := 1;
            repeat
                SetBoard(0, levelData[p], TILE_WARP_LEFT);
                SetBoard(20, levelData[p], TILE_WARP_RIGHT);
                p := p + tileSize;
                Dec(count);
            until count = 0;
        end;

    end;
    result:=ptr+p;
end;

procedure LoadLevel(levelNum: byte);
var levelPtr: word;
begin
    ClearFeatures;
    levelPtr := levels[levelNum];
    Move(pointer(levelPtr), level, SizeOf(level));
    spawnDelay := level.delay * 50;
    pillTime := level.pillTime * 50;
    levelPtr := levelPtr + SizeOf(level);
    levelData := pointer(levelPtr);

    Fillchar(@board, BOARDSIZE, TILE_VOID);

    repeat
        levelPtr := ReadLevelData(levelPtr);
        levelData := pointer(levelPtr);
    until levelData[0]=$ff;
end;

procedure InitGame;
begin
    lives := GAME_LIVES;
	if cheat_mode then lives := 99;
    score := 0;
    liveBonus := 0;
    currentLevel := startingLevel;
end;

procedure InitView;
begin
    vscrollstep := 0;
    viewportMoveDir := 0;
    InitPac(level.startX, level.startY);
    ClearGhosts;
    spawnCounter := spawnDelay;
    GhostColorsDefault;
    gameState := GAME_NORMAL;
end;

procedure InitLevel(lvl: byte);
begin
    ShowLevelScreen;
    PutArray(0,2,5,word(@txt_level));
    Str(lvl+1,s);
    PutNumber(5-byte(s[0]),14,s);
    LoadLevel(lvl);
    _COLOR0_ := level.colors[0];
    _COLOR1_ := level.colors[1];
    _COLOR2_ := level.colors[2];
    _COLOR3_ := level.colors[3];
    _COLOR4_ := level.colors[4];

    PaintBoard;
    InitView;
    dotCount := dotCount - level.dotLimit;
    ClearTxT;
    bonusPosPicked := false;
    bonusDelay := BONUS_DELAY * 50;

    Move(strings[0],pointer(TXT_RAM+1),36); // score topbar
    UpdateScore;
    UpdateFood;
    UpdateLives;
end;

procedure GameRestore;
begin
    InitView;
    if bonusPosPicked then RemoveBonus;
    CloseAllSpawners;
    PMG_clear;
    SongStart(SONG_GAME);
end;

procedure VFrame(vtop: word; hsize: byte);
begin
	repeat
		poke(dltop + word(vtop - 1), $60);
		poke(dltop + vtop + 24, $60);
		Inc(vtop,40);
		Dec(hsize)
	until hsize=0;
end;

procedure ShowGetReady;
const   top = 80;
        height = 120;
var count:byte;
begin
    SongStart(SONG_READY);
    MoveViewport;
    Move(pointer(dltop + top), pointer(TXT_RAM + $100), height);
	VFrame(top + 8, 3);
    fillbyte(pointer(dltop + top + 8),24,$3c);
    fillbyte(pointer(dltop + top + 88),24,$3d);
    frame := 0;
    count := 0;
    repeat
        if (frame and 7 = 0) then Inc(count);
        if music then msx.Play;
        if (frame and 16 = 0) then fillbyte(pointer(dltop+top+48),24,0)
        else move(txt_ready_q,pointer(dltop+top+53),14);
        Pause;
    until (_STRIG0 = 0) or (_CONSOL and 1 = 0) or (count = 40);
    Move(pointer(TXT_RAM+$100), pointer(dltop+top), height);
    SongStart(SONG_GAME);
    CheckBoardAction;
end;

procedure ShowGameOver;
const   top = 40;
var count:byte;
begin
    Move(strings[13],pointer(TXT_RAM+31),8); // level topbar
	UpdateEndLevel;
    count:=0;
    MoveViewport;
    PMG_clear;
    if not cheat_mode then
		if score >= hiscore then begin
			hiscore := score;
		end;
	VFrame(top + 8, 7);
    fillbyte(pointer(dltop+top+8),24,$3c);
    fillbyte(pointer(dltop+top+48),24,0);
    fillbyte(pointer(dltop+top+88),24,0);
    fillbyte(pointer(dltop+top+128),24,0);
    fillbyte(pointer(dltop+top+168),24,0);
    fillbyte(pointer(dltop+top+208),24,0);
    fillbyte(pointer(dltop+top+248),24,$3d);
    move(txt_game,pointer(dltop+top+50),8);
    move(txt_over,pointer(dltop+top+62),8);
    move(txt_high,pointer(dltop+top+170),8);
    move(txt_score,pointer(dltop+top+180),10);
    Str(hiscore,s);
    PutNumber2(20-byte(s[0]),viewportTop+6,s);
    if score < hiscore then begin
		VFrame(top + 248, 4);
        fillbyte(pointer(dltop+top+248),24,0);
        fillbyte(pointer(dltop+top+288),24,0);
        fillbyte(pointer(dltop+top+328),24,0);
        fillbyte(pointer(dltop+top+368),24,$3d);
        move(txt_your,pointer(dltop+top+290),8);
        move(txt_score,pointer(dltop+top+300),10);
        Str(score,s);
        PutNumber2(20-byte(s[0]),viewportTop+9,s);
    end;

    Str(hiscore,s);
    repeat
        if (frame and 7 = 0) then Inc(count);
        if (score = hiscore) and (count<10) then
            if (frame and 8 = 0) then PutNumber2(20-byte(s[0]),viewportTop+6,s)
            else fillbyte(pointer(dltop+top+208),24,0);
        Pause;
    until (_STRIG0 = 0) or (_CONSOL and 1 = 0); // or (count = 50);
    repeat until _STRIG0 = 1
end;

procedure LevelAdvance;
begin
    repeat until _STRIG0 = 1;
    Inc(currentLevel);
    if currentLevel = levelCount then begin     // end of levels
        level.colors[4] := 2;
        _COLOR4_ := 2;        // blink colors
        level.colors[1] := 6;
        _COLOR1_ := 6;        // blink colors
        _COLOR0_ := $a;
        gameState := GAME_OVER;
    end else begin      // jump to next level
        Pause;
        PMG_clear;
        SongStop;
        InitLevel(currentLevel);
        InitGameScreen;
        ShowGetReady;
    end;
end;


{***************************************************************************************}
{************************************** MAIN *******************************************}
{***************************************************************************************}

begin
    setDli(@Dli1T);
    vblVector := @VBlank;
    SystemOff;
    Randomize;
    InitTables;
    GrabGui;

    repeat
        SongStart(SONG_TITLE);
        ShowTitleScreen;
        SongStop;
        InitGame;
        InitLevel(currentLevel);
        InitGameScreen;
        ShowGetReady;

        repeat          // ***************************** GAME LOOP

            if music then msx.Play;

            case gameState of


                GAME_NORMAL, GAME_ESCAPE: begin   // NORMAL or ESCAPE
                    _HITCLR := 1; // reset collision detector
                    if gameState = GAME_ESCAPE then begin
                        if pillCounter < 150 then
                            if (pillCounter and 8) <> 0 then GhostColorsEscape(COLOR_ESCAPE_BLINK)
                            else GhostColorsEscape(COLOR_ESCAPE);
                        Dec(pillCounter);
                        if pillCounter = 0 then begin
                            GhostColorsDefault;
                            gameState := GAME_NORMAL;
                            SongStart(SONG_GAME)
                        end;
                    end;

                    MoveViewport;
                    MovePac;
                    MoveGhosts;

                    Pause; // wait for VBLI
                    ShowPac;
                    ShowGhosts;

                    CheckIfPacTurnsBack;
                    if pac.step = 0 then begin // pac enters new field

                        CheckIfPacTurns;
                    end;


                    collider := PacColider;       // detect collisions
                    if collider <> 0 then begin
                        if gameState = GAME_NORMAL then begin // pac dies
                            gameState := GAME_DEAD;
                            SongStart(SONG_DIED);
                            PacDies;
                        end;
                        if gameState = GAME_ESCAPE then begin // ghost dies
                            if pillBonus < 500 then
                                pillBonus := pillBonus + 100;
                            AddScore(pillBonus);
                            msx.Sfx(2, 2, 24);
                            KillGhost(TouchedGhostNum(collider));
                        end;
                    end;

                    TryToSpawnGhost;

                end;

                GAME_WIN: begin   // REACHED LEVEL EXIT
                    if frame < 2 then begin
                        ClearGhosts;
                        SongStart(SONG_WIN)
                    end;
                    level.colors[1] := ((frame shl 2) and %11110000) or 6;
                    pac.frame := 2;                 // spin pac
                    pac.dir := (frame shr 2) and 3;
                    pac.sprite := pac_sprites[pac.dir];
                    Pause;
                    ShowPac;
                    if (frame = 168) or (_STRIG0 = 0) then LevelAdvance;      // animation ends
                end;

                GAME_DEAD: begin      // PAC DIED
                    if (pac.frame < 17) and ((frame and 3) = 0) then begin  // animate pac
                        Inc(pac.frame);
                        ShowPac;
                    end;
                    if frame = 200 then begin         // animation end
                        if lives = 0 then gameState := GAME_OVER
                        else GameRestore;
                    end;
                    Pause; // wait for VBLI
                    MoveGhosts;
                    ShowGhosts;
                end;

            end;

            if bonusDelay>0 then Dec(bonusDelay);
            if not bonusPosPicked then PickBonusPos
            else begin
                if bonusCountdown>0 then begin
                    dec(bonusCountdown);
                    if bonusCountdown=0 then RemoveBonus;
                end;
                if (bonusDelay=0) and (bonusCountdown=0) then PlaceBonus;
            end;

            if dotCount = 0 then BlinkExit;

        until gameState = GAME_OVER;
        SongStart(SONG_OVER);
        ShowGameOver;
        SongStop;
        ShowDataMatrix(score);
    until FALSE;

end.
