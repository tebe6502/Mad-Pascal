program starydom;
uses atari, crt, graph, rmt;

type String40 = string[40];

const
{$i const.inc}
{$r resources.rc}
{$i io.inc}
{ $i lang_pl.inc}
{$i lang_en.inc}

var
    msx: TRMT;
    inventory, currentPassword, weaponName: TString;
    aStr, bStr: TString; // reusable temporary strings
    x, y: byte; // player Position
    i: byte; // common iterator
    monster: byte;
    consecutiveWaits, seenPassword: byte;
    currentRoomTile, keycode, roomDifficulty, maxDifficulty: byte;
    q, r: byte;  // randoms
    weapon, wounds: shortInt;
    moves, gold: smallInt;
    score: cardinal;
    pconsol: byte;
    strength, energy, monsterStrength, monsterSize: real;
    gameEnded: boolean;
    musicOn: boolean = false;
    lootHistory: array[0..ITEMS_COUNT-2] of byte;

procedure Vbl;interrupt;
begin
asm { phr ; store registers };
    if (consol = 5) and (pconsol <> 5) then begin
        msx.Stop;
        musicOn := not musicOn;
    end;
    pconsol := consol;
    if musicOn then msx.Play;
asm {
    plr ; restore registers
    jmp $E462 ; jump to system VBL handler
    };
end;

procedure Dli; assembler;interrupt;
asm {
    pha
@   sta wsync
    lda vcount
    cmp #82
    bmi @-
    lda #0          ; stats top
    sta colpf2
    lda #12
    sta colpf1
@   sta wsync
    lda vcount
    cmp #102
    bmi @-
    lda #$fe        ; dialog top
    sta wsync
    sta colbak
    sta colpf2
    lda #2
    sta colpf1
@   sta wsync
    lda vcount
    cmp #113
    bmi @-
    lda #0          ; dialog bottom
    sta wsync
    sta colbak
    sta colpf2
    pla
};
end;

procedure StartMusic(pattern: byte);
begin
    msx.Init(pattern);
    musicOn := true;
end;

procedure StopMusic;
begin
    musicOn := false;
    msx.Stop;
end;

// ************************************* helpers

function StrCmp(a, b: TString): boolean;
var i:byte;
begin
    result:= true;
    for i:=0 to length(a)-1 do
        if a[i]<>b[i] then exit(false);
end;

function FormatFloat(num: real):TString;
var m: cardinal;
    ms: TString;
begin
    Str(Trunc(num), result);
    m := Trunc(Frac(num) * 1000.0);
    if m > 0 then begin
        Str(m, ms);
        while (length(ms) < 3) do ms := concat('0', ms);
        result := concat(result, '.');
        result := concat(result, ms);
        while (result[byte(result[0])]='0') do dec(result[0]);
    end;
end;


// ************************************* initializers

procedure VarInit;
begin
    x := 6;
    y := 1;
    roomDifficulty := 1;
    maxDifficulty := 15 * 8;
    fillchar(@inventory[1], 4, TILE_EMPTY_SLOT);
    inventory[0] := char(4);
    currentPassword := passwords[Random(9)];
    consecutiveWaits := 0;
    weapon := 1;
    gold := 0;
    wounds := 0;
    energy := 3;
    seenPassword := 0;
    moves := 0;
    currentRoomTile := TILE_ROOM;
    weaponName := weapons[weapon - 1];
    fillByte(@lootHistory, ITEMS_COUNT - 1, 0);
end;

// ************************************* GUI

procedure PromptAny;
begin
   Position(19 - (Length(s_PRESS_ANY) shr 1), 23);
   Write(s_PRESS_ANY);
   ReadKey;
   fillbyte(pointer(savmsc),24*40,0);
   Position(0,0);
end;

procedure TitleScreen;
var i:byte;
begin
    InitGraph(8);
    Pause;
    nmien := $40;
    color2 := 0;
    color1 := 0;
    Move(pointer(TITLE_BASE),pointer(savmsc + (40 * 8)),5840);
    for i:=0 to 12 do begin
        color1 := i;
        Pause(2);
    end;
    readkey;
    for i:=12 to 0 do begin
        color1 := i;
        Pause;
    end;
end;

procedure ShowManual;
begin
    InitGraph(0);
    pause;
    nmien := $40;
    color2 := 0;
    CursorOff;
    chbas := Hi(CHARSET_BASE);
    Writeln;
    Writeln(s_WANT_MANUAL);
    keycode := GetKey;
    if keycode <> k_YES then exit;
    ManualPage1;
    PromptAny;
    ManualPage2;
    PromptAny;
    ManualPage3;
    PromptAny;
end;

function GetRandomEntranceV:byte;
var r: byte;
begin
    result := TILE_ENTRANCE_V;
    r := Random(5);
    if r = 0 then result := TILE_DOOR_V;
    if r = 1 then result := TILE_WALL_V;
end;

function GetRandomEntranceH:byte;
var r: byte;
begin
    result := TILE_ENTRANCE_H;
    r := Random(5);
    if r = 0 then result := TILE_DOOR_H;
    if r = 1 then result := TILE_WALL_H;
end;

procedure PaintBoard;
var row, room:byte;
begin

    //initGraph(0);
    CursorOff;
    color2 := 0;
    color1 := 0;
    savmsc := SCREEN_BASE;

    VarInit;
    fillbyte(pointer(SCREEN_BASE),40*17,128);
    fillbyte(pointer(SCREEN_BASE+40*17),5,$ff);
    fillbyte(pointer(SCREEN_BASE+40*17+36),4,$ff);

    Position(5, 0); // top row of board
    Print(#17);
    for room:=1 to 14 do
        Print(char(TILE_BORDER_H),#23);
    Print(char(TILE_BORDER_H), #5);

    for row:=0 to 7 do begin

        // rooms
        Position(5, row * 2 + 1);
        Print(char(TILE_BORDER_V));
        for room:=1 to 14 do
            Print(char(TILE_ROOM), char(GetRandomEntranceV));
        Print(char(TILE_ROOM), char(TILE_BORDER_V));

        // inner walls
        Position(5, row * 2 + 2);
        Print(#1);
        for room:=1 to 14 do
            Print(char(GetRandomEntranceH), #19);
        Print(char(GetRandomEntranceH), #4);

    end;


    Position(5, 16); // bottom row of board
    Print(#26);
    for room:=1 to 14 do Print(char(TILE_BORDER_H), #24);
    Print(char(TILE_BORDER_H), #3);

    Position(7, 1); Print(char(TILE_ENTRANCE_V));
    Position(6, 2); Print(char(TILE_ENTRANCE_H));
    Position(x, y); Print(TILE_PLAYER);
    Position(34, 15); Print(char(TILE_EXIT),char(TILE_EXIT2));

    Pause;
    chbas := Hi(CHARSET_BASE);
    SDLSTL := DISPLAY_LIST_BASE;
    nmien := $c0; // set $80 for dli only (without vbl)
    color2 := $10;
    color1 := $10;
    for i:=$10 to $1a do begin
        pause(2);
        color2 := i;
    end;

end;

procedure ShowStats;
var z: real;
begin
    if energy < 0 then energy := 0;
    Position(2, 18); Write(s_ENERGY, ' = ', formatFloat(energy), '    ');
    Position(22, 18); Write(s_WOUNDS, ' = ', wounds, '    ');
    z := energy - wounds;
    if z < 0 then z := 0.1;
    Position(2, 19); Write(s_TREASURE,' = ', gold, '$   ');
    Position(22, 19); Write(s_ITEMS,' = ',inventory);
    Position(2, 20); Write(s_WEAPON, ' ', weaponName,'     ');
    strength := z * (1 + weapon * 0.25);
    Position(2, 21); Write(s_ATTACK, ' = ', formatFloat(strength), '          ');
    Position(22, 21); Write(s_MOVES, ' = ', moves,' ');
end;

procedure KeyAndShowStat;
begin
    Readkey;
    ShowStats;
end;


// ************************************* inventory operations


function HasItem(c: char):boolean;
var i: byte;
begin
    result := false;
    for i := 1 to 4 do
        if inventory[i] = c then exit(true);
end;

procedure DelItem(c: char);
var i: byte;
begin
    for i := 1 to 4 do
        if inventory[i] = c then begin
            inventory[i] := TILE_EMPTY_SLOT;
            exit;
        end;
end;

procedure AddItem(c: char);
var i: byte;
begin
    for i := 1 to 4 do
        if inventory[i] = TILE_EMPTY_SLOT then begin
            inventory[i] := c;
            exit;
        end;
end;

function HasAnythingToUse:boolean;
begin
    result := HasItem(itemSymbols[6]) or HasItem(itemSymbols[7]);
end;

// ********************************************** main turn logic

procedure MakeMove;
var door, room: byte;
    dx, dy: shortInt;
    isIn, stepFinished, waited, skipMonster: boolean;
    itemLost: char;


procedure PayRansom;
begin
    gold := round(gold - round(monsterSize * Random));  // pay ransom
    if gold < 0 then gold := 0;
    stepFinished := true;
    ShowStats;
end;

procedure FoundWeapon;
begin
    r := Random(10) + 1;    // 1-10
    StatusLine(s_FOUND);
    Writeln(weapons[r - 1]);
    Write(s_TAKE, s_OR, s_LEAVE,' ?');
    keycode := getKey(k_TAKE, k_LEAVE);
    if keycode = k_TAKE then begin
        weaponName := weapons[r - 1];
        weapon := r;
        ShowStats;
    end;
end;

procedure FoundPassword;
begin
    if seenPassword < 3 then begin
        StatusLine(s_FOUND_PASS);
        Writeln(currentPassword, '.');
        Write(s_REMEMBER);
        Pause(200);
        inc(seenPassword);
    end;
end;

procedure DecLootCounters;
var item:byte;
begin
    for item:=0 to ITEMS_COUNT-2 do
        if lootHistory[item]>0 then Dec(lootHistory[item]);
end;

function GetMonster: byte;
var monsterLevel: shortInt;
begin
    monsterLevel := (roomDifficulty * MONSTERS_COUNT) div maxDifficulty;
    monsterLevel := monsterLevel - 4 + Random(8);
    if monsterLevel < 0 then monsterLevel := 0;
    monsterStrength := Round(Random(byte((monsterLevel * 2) + 1)) + (roomDifficulty + strength / 10)) + 1;
    monsterSize := monsterStrength;
    if monsterLevel >= MONSTERS_COUNT then monsterLevel := MONSTERS_COUNT - 1;
    result := monsterLevel;
end;

procedure FoundItem;
var
    item:byte;
begin
    DecLootCounters;
    repeat
        item := Random(ITEMS_COUNT-1);
    until lootHistory[item] = 0;
    lootHistory[item] := 6;
    StatusLine(s_FOUND);
    Writeln(items[item]);
    Write(s_TAKE, s_OR, s_LEAVE,' ?');
    keycode := GetKey(k_TAKE, k_LEAVE);
    if keycode = k_LEAVE then begin
        foundWeapon;
    end else begin
        if (item = 4) or (item = 5) then begin
            case item of
                4: energy := energy + 3;
                5: energy := energy + 1;
            end;
            ShowStats;
        end else begin
            if hasItem(TILE_EMPTY_SLOT) then begin
                addItem(itemSymbols[item]);
                ShowStats;
            end else begin
                stepFinished := false;
                repeat
                    StatusLine2(s_LEAVE_WHAT);
                    repeat
                        keycode := getKey;
                    until (keycode > 65) and (keycode < 90);
                    if hasItem(char(keycode)) then begin
                        DelItem(char(keycode));
                        addItem(itemSymbols[item]);
                        ShowStats;
                        stepFinished:=true;
                    end else begin
                        StatusLine2(s_DONT_HAVE);
                        Write(#39, char(keycode), #39'         ');
                        KeyAndShowStat;
                    end;
                until stepFinished;
            end;
        end;
    end;
end;

procedure GetLoot();
begin
    r := Random(11) + 1;
    case r of
        1,2,3,4,5,6,7,8: foundItem;
        9: foundWeapon;
        10: FoundPassword;
    end;
end;

procedure MovePlayer(nx, ny:byte);
begin
    consecutiveWaits := 0;
    Position(x, y);
    Print(char(currentRoomTile));
    x := nx;
    y := ny;
    currentRoomTile := Locate(x, y);
    Position(x, y);
    Print(char(TILE_PLAYER));
    roomDifficulty := ((x - 4) shr 1) * ((y + 1) shr 1);
end;

begin
    ShowStats;
    isIn := false;
    stepFinished := false;
    skipMonster := false;
    waited := false;

    ClearLine;
    Position(10, 22); Write(s_WAIT, s_OR, s_MOVE, ' ?');
    keycode := getKey(k_REST, k_MOVE);

    if keycode = k_REST then begin      // ************* waiting
        if gold < 5 then begin
            energy := energy + 0.5;
        end else begin
            gold := gold - 5;
            energy := energy + 2;
        end;
        waited := true;
        stepFinished := true;
        ShowStats;
        Inc(consecutiveWaits);

    end else begin                  // ************* moving
        Inc(consecutiveWaits);
        Position(7, 22);
        Write(s_LEFT,', ',s_RIGHT,', ',s_UP,', ',s_DOWN,' ?');
        keycode := getKey(k_LEFT, k_RIGHT, k_UP, k_DOWN);
        ClearLine;
        dx := 0;
        dy := 0;
        case keycode of
            k_LEFT: dx := -1;
            k_RIGHT: dx := 1;
            k_DOWN: dy := 1;
            k_UP: dy := -1;
        end;

        door := Locate(x + dx, y + dy);
        //Position(1,1); Write(door);

        if (door <> TILE_BORDER_H) and (door <> TILE_BORDER_V) then begin // not a border ?

            if (door = TILE_ENTRANCE_H) or (door = TILE_ENTRANCE_V) then begin     // ***********************  check doors
                StatusLine(s_DOOR_OPENED);
                isIn := true;
            end else begin
                if (door = TILE_DOOR_H) or (door = TILE_DOOR_V) then begin
                    StatusLine(s_DOOR_CLOSED);
                    if hasItem(itemSymbols[2]) then begin
                        Write(s_USED, s_KEY, '.');
                        isIn := true;
                    end else begin
                        Write(s_DONT_HAVE, s_BYKEY, '.');
                    end;
                end;
                if (door = TILE_WALL_H) or (door = TILE_WALL_V) then begin
                    StatusLine(s_WALL);
                    if hasItem(itemSymbols[0]) then begin
                        Write(s_USED, s_HAMMER, '.');
                        isIn := true;
                    end else begin
                        Write(s_DONT_HAVE, s_BYHAMMER, '.');
                    end;
                end;
                if isIn then begin
                    energy := energy - 0.5;
                    Position(x + dx, y + dy);
                    if dy=0 then door := TILE_ENTRANCE_V
                    else door := TILE_ENTRANCE_H;
                    Print(char(door));
                end;
            end;

            ReadKey;

            if isIn then begin  // *******************************   check room
                room := Locate(x + 2 * dx, y + 2 * dy);
                if room = TILE_ROOM then begin
                    q := Random(2);
                    if not waited and (x > 8) and (y > 3) and (Random(10) >= 4) then begin
                        if q = 0 then room := TILE_DARK
                        else room := TILE_HOLE;
                    end else begin
                        r := Random(6);
                        if r = 0 then begin
                            if q = 0 then room := TILE_DARK
                            else room := TILE_HOLE;
                        end;
                    end;
                end;

                if room = TILE_DARK then begin    //  ********************* dark room
                    Position(x + 2 * dx, y + 2 * dy);
                    Print(char(TILE_DARK));
                    StatusLine(s_ROOM_DARK);
                    Writeln;
                    if hasItem(itemSymbols[1]) then begin
                        Write(s_USED, s_LANTERN, '.');
                        isIn := true;
                    end else begin
                        Write(s_DONT_HAVE, s_BYLANTERN, '.');
                        isIn := false;
                    end;
                    ReadKey;
                    clearLine;
                end;
                if room = TILE_HOLE then begin    //  ********************* no floor
                    Position(x + 2 * dx, y + 2 * dy);
                    Print(char(TILE_HOLE));
                    StatusLine(s_ROOM_HOLE);
                    Writeln;
                    if hasItem(itemSymbols[3]) then begin
                        Write(s_USED, s_PLANK, '.');
                        isIn := true;
                    end else begin
                        Write(s_DONT_HAVE, s_BYPLANK, '.');
                        isIn := false;
                    end;
                    ReadKey;
                end;
                if room = TILE_EXIT then begin  //  ********************* exit reached
                    Position(x, y);
                    Print(char(TILE_ROOM));
                    Position(34, 15);
                    Print(TILE_PLAYER);
                    StatusLine(s_EXIT_PASS);
                    aStr:='';
                    Position(2, 23);
                    for i := 1 to 4 do begin
                        keycode := getKey;
                        aStr[i] := char(keycode);
                        Print(char(keycode));
                    end;
                    aStr[0] := chr(4);
                    if strCmp(aStr, currentPassword) then begin
                        StatusLine(s_EXIT_PAY);
                        ReadKey;
                        if gold >= 100 then begin
                            gold := gold - 100;
                            score := Trunc(gold * weapon);
                            StatusLine(s_EXIT_LEAVE);
                            Writeln(gold,'$');
                            Write(s_AND,weaponName,s_EXIT_SCORE,score);
                            Pause(3);
                            KeyAndShowStat;
                            gameEnded := true;
                        end else begin
                            StatusLineln(s_EXIT_POOR);
                            Write(s_EXIT_FATAL);
                            Pause(3);
                            Readkey;
                            gameEnded := true;
                        end;
                    end else begin
                        StatusLine(s_EXIT_WRONG_PASS);
                        WriteLn(currentPassword, '.');
                        Write(s_EXIT_FATAL);
                        Pause(3);
                        Readkey;
                        gameEnded := true;
                    end;

                end;

            end;

            if isIn and not gameEnded then begin // ***********   entered new room, update map
                MovePlayer(x + 2 * dx, y + 2 * dy);
                energy := energy - 0.5;
                stepFinished := true;
            end;


        end else begin  // **********************************   hit the wall
            StatusLineln(s_BUMP);
            Write(s_NO_PASARAN);
            energy := energy - 0.5;
            KeyAndShowStat;
        end;

    end;

    if stepFinished and not gameEnded then begin  // ********************  Random events

        r := Random(40)+3;
        if r < consecutiveWaits then begin
            StatusLine(s_BACK_TO_START);
            MovePlayer(6, 1);
            Readkey;
            ShowStats;
        end else begin
            r := Random(15);
            itemLost := TILE_EMPTY_SLOT;
            case r of
                0,1,2,3,4,5,6,7:
                   if hasItem(itemSymbols[r]) then begin
                        StatusLineln(s_ITEM_BROKE[r]);
                        itemLost := itemSymbols[r];
                   end;
                8: if Random(10) >= 5 then begin
                        FoundPassword;
                        skipMonster := true;
                   end;
                9,10:
                    begin
                        if weapon > 1 then begin
                            StatusLine(s_BROKE);
                            Writeln(weaponName, ', ');
                            weapon := weapon - 4;
                            if weapon < 1 then weapon := 1;
                            weaponName := weapons[weapon - 1];
                            Write(s_FOUND, weaponName, '.');
                            Readkey;
                            ShowStats;
                        end;
                    end;
            end;

            if itemLost <> TILE_EMPTY_SLOT then begin
                Write(s_DROPPED);
                DelItem(itemLost);
                Readkey;
                ShowStats;
            end;
        end;

    end;

    if not skipMonster and not gameEnded then begin
        r := Random(4);
        if r>0 then begin  // ********************************** encounter !!!
            monster := GetMonster;
            aStr := monsters[monster];
            bStr := s_YOU_M;
            if needPostfix(monster) then bStr := s_YOU_F;
            StatusLine(s_ATTACKED);
            Writeln(bStr, aStr);
            Write(s_MONSTER_STR, formatFloat(monsterStrength), '  ');

            stepFinished := false;
            repeat

                if ((strength = 0) or (wounds > 4)) and (gold = 0) then begin
                    Position(2,23);
                    Print(s_TOO_WEAK_POOR);
                    Readkey;
                    StatusLine(s_BACK_TO_START);
                    MovePlayer(6, 1);
                    stepFinished := true;
                    wounds := 0;
                    KeyAndShowStat;
                end else begin
                    if (strength = 0) or (wounds > 4) then begin // ***********     too weak ?
                        Position(2,23);
                        Write(s_TOO_WEAK);
                        keycode := k_RANSOM;
                        KeyAndShowStat;
                    end else if gold = 0 then begin             // ************** no gold ?
                        Position(2,23);
                        Print(s_TOO_POOR);
                        keycode := k_FIGHT;
                        KeyAndShowStat;
                    end else begin
                        //Position(12,23);
                        Write(s_FIGHT, s_OR, s_RANSOM, ' ?');
                        keycode := getKey(k_FIGHT, k_RANSOM);
                    end;
                end;

                if keycode = k_FIGHT then begin  // ************** fight choosen
                    // get hurt
                    if (strength < monsterStrength * 1.2) and (Random(10) >= 4) then
                        wounds := wounds + 1;
                    // hit monster
                    monsterStrength := round(monsterStrength - ((Random * 2) + 1) * strength * 0.57);

                    ShowStats;

                    if (monsterStrength <= 0) or (Random(10) >= 5) then begin // ********* monster killed
                        r := Random(5) + 1;  // loot size
                        StatusLine(aStr);
                        Write(s_HAS_BEEN);
                        if needPostfix(monster) then Writeln(s_DEFEATED_F)
                        else Writeln(s_DEFEATED_M);
                        Write(s_EARNED, treasures[r - 1]);
                        gold := gold + round(r * (1.25 * (1 + monsterSize / 15) + Random));
                        stepFinished := true;
                        KeyAndShowStat;
                    end else begin
                        StatusLine(aStr);
                        Writeln(s_HAS_STR, formatFloat(monsterStrength));
                    end;
                end else  PayRansom // ************** pay ranson
            until stepFinished;

        end;

        GetLoot;

    end;

    if not gameEnded then begin // *********************************** use items
        stepFinished := false;
        if HasAnythingToUse then
            repeat
                StatusLine(s_WANNA_USE);
                keycode := getKey(k_YES, k_NO);
                if keycode = k_YES then begin
                    StatusLine2(s_WHICH);
                    repeat
                        keycode := getKey;
                    until (keycode > 65) and (keycode < 90);
                    if not hasItem(char(keycode)) then begin
                        StatusLine2(s_DONT_HAVE);
                        Write(#39, chr(keycode), #39);
                        ReadKey;
                    end else
                        if (keycode = k_BANDAGE) or (keycode = k_MEDKIT) then begin
                            DelItem(char(keycode));
                            case keycode of
                                k_BANDAGE: wounds := wounds - 1;
                                k_MEDKIT: wounds := wounds - 3;
                            end;
                            if wounds < 0 then wounds := 0;
                            ShowStats;
                            if Random(10)>=6 then stepFinished := true;
                        end else begin
                            StatusLine2(s_CAN_USE_ONLY);
                            Write( char(byte(itemSymbols[6])+128),' ',char(byte(itemSymbols[7])+128));
                            ReadKey;
                        end;
                end else stepFinished := true;
            until stepFinished or not HasAnythingToUse;
    end;
    Inc(moves);
end;


// *********************************** MAIN PROGRAM

begin
    msx.player := pointer(RMT_PLAYER);
    msx.modul := pointer(RMT_MODULE);
    InitIO;
    Randomize;
    SetIntVec(iDLI, @Dli);
    SetIntVec(iVBL, @Vbl);

    repeat
        StartMusic(0);
        TitleScreen;
        ShowManual;

        StopMusic;
        PaintBoard;
        StartMusic(7);

        gameEnded := false;
        while not gameEnded do MakeMove;
    until false;

    Close(fscr);
end.
