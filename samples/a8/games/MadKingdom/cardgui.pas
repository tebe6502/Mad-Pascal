unit cardgui;
interface
uses cardlib, crt, joystick, sysutils, rmt;

{$r 'rmt_play.rc'}

procedure ShowStats;
procedure ShowTitleScreen;
procedure ShowGameScreen;
procedure InitGui;
procedure ReleaseGui;
procedure ShowResponse(choice: byte);
procedure ShowCard;
procedure ShowIncome;
procedure ShowTable;
function ShowEndOfYear: char;
function SelectCard: byte;
function ReadUserChoice: byte;
function ReadKeyOrFire: char;
procedure musicStart(ptrn: byte);
function showEnding(ending: byte): char;

implementation
{$I display_lists.inc}
{$I memory_map.inc}

var
        c: char;
        i,j,t,x: byte;
        count, value: byte;
        choice: byte;
        w1, w2: word;
        screenMode: byte;

        cursorColor: byte;
        cursorBlink: boolean;
        cursorPos: byte;
        cursorX: byte;

        old_dli, old_vbl: pointer;
        dliCounter : byte;

        images : array [0..0] of word absolute IMG_ADDRESS;

        titleTextColor: byte;
        titlePage: byte;
        titleWait: word;
        msx: TRMT;

// ************************************************ UTILS

procedure ClrTxt;
begin
    FillChar(pointer(TXT_RAM),TXT_RAM_SIZE,0); // clrtxt
end;

procedure ClrGfx;
begin
    FillChar(pointer(GFX_RAM),GFX_RAM_SIZE,0); // clrgfx
end;

procedure WritelnCentered(str: string);
begin
    Writeln(Space(( 40 - Length(str) ) div 2),str);
end;

procedure WaitForFireRelease;
begin
    repeat until strig0 = 1;
end;

procedure MoveCursor(pos: byte);
begin
    cursorPos := pos mod 4;
    cursorX := (cursorPos * 40) + 49;
    GotoXY(1,3);
    DelLine;
    if (table[cursorPos]<>EMPTY_TABLE_SLOT) then begin
        ReadCard(table[cursorPos]);
        GotoXY(1,3);
        WritelnCentered(NullTermToString(card.actorPtr+2));
    end;
end;

procedure ExpandRLE(src: word; dest: word);
begin
    value := peek(src);
    while value<>0 do begin
        Inc(src);
        count := (value shr 1) + 1;
        if Odd(value) then begin // just repeat data
            Move(pointer(src),pointer(dest),count);
            Inc(src,count);
        end else begin  // expand
            FillChar(pointer(dest),count,peek(src));
            Inc(src);
        end;
        Inc(dest,count);
        value := peek(src);
    end;
end;

procedure ShowTitlePage(page: byte);
begin
    ClrTxt;
    GotoXY(1,1);
    WritelnCentered(getString(12));
    case page of
        0: begin
            GotoXY(0,4);
            WritelnCentered(getString(0));
            WritelnCentered(getString(1));
            WritelnCentered(getString(2));
            Writeln;
            WritelnCentered(getString(3));
            WritelnCentered(getString(4));
            WritelnCentered(getString(5));
        end;
        1: begin
            GotoXY(0,3);
            WritelnCentered(getString(11));
            GotoXY(3,5);
            Write(Char(ICON_MONEY),' - ',getString(13));
            GotoXY(23,5);
            Write(Char(ICON_POPULATION),' - ',getString(14));
            GotoXY(3,6);
            Write(Char(ICON_ARMY),' - ',getString(15));
            GotoXY(23,6);
            Write(Char(ICON_HEALTH),' - ',getString(16));
            GotoXY(3,7);
            Write(Char(ICON_HAPPINES),' - ',getString(17));
            GotoXY(23,7);
            Writeln(Char(ICON_CHURCH),' - ',getString(18));
            GotoXY(0,9);
            WritelnCentered(getString(19));
            WritelnCentered(getString(20));
            WritelnCentered(getString(21));
        end;
        2: begin
            GotoXY(0,3);
            WritelnCentered(getString(22));
            WritelnCentered(getString(23));
            Writeln;
            WritelnCentered(getString(24));
            WritelnCentered(getString(25));
            Writeln;
            WritelnCentered(getString(26));
            WritelnCentered(getString(27));
            Writeln;
            WritelnCentered(getString(28));
        end;
    end;
end;

{$I interrupts.inc}

// ************************************************ INIT

procedure InitGui;
begin
    GetIntVec(iVBL, old_vbl);
    GetIntVec(iDLI, old_dli);
    SetIntVec(iVBL, @VBlank);
    _lmargin := 0;

    _cursor := 1; // cursor off
    _bgcolrs := 6; // colors
    _brcolrs := 0;
    _c1colrs := 10;
    _c2colrs := 14;
    _savmsc := TXT_RAM;
    _charsetS := hi(CHARSET_ADDRESS); // set font
    msx.player:=pointer(rmt_player);
    msx.modul:=pointer(rmt_modul);
    msx.Stop;
    //msx.Init(MSX_TITLE);


end;

procedure ReleaseGui;
begin
    _nmien:=$40;
    SetIntVec(iVBL, old_vbl);
    SetIntVec(iDLI, old_dli);
    _nmien:=$c0;
end;

procedure musicStart(ptrn: byte);
begin
    msx.Init(ptrn);
end;

// ************************************************ PMG

procedure setupPMG;
begin
    _pmbase := Hi(PMG_BASE);
    _gractl := 3;
    _gprior_ := 1;
end;

procedure fillPMG;
begin
    w1 := PMG_BASE+512+16;
    FillChar(pointer(PMG_BASE+512+37),46,%01000000);  // p0 - cursor vertical bar
    FillChar(pointer(PMG_BASE+640+37),46,%00000010);  // p1 - cursor vertical bar
    for i:=0 to 2 do begin
        FillChar(pointer(w1),4,%11110000);   // resources line 1
        FillChar(pointer(w1+6),4,%11110000); // resources line 2
        Poke(w1+22,%11111111); // cursor top bar
        Poke(w1+65,%11111111); // cursor bottom bar
        Inc(w1,128);
    end;
end;

procedure PmgShowResp(src: word);   // set pmg image to YES/NO
begin
    Pause;
    w1 := PMG_BASE+512+99;
    for i:=0 to 3 do begin
        Move(pointer(src),pointer(w1),12);
        Inc(src,12); inc(w1,128);
    end;
end;

procedure SetResponseTak;
begin
    PmgShowResp(images[4]);
    dliColbg[5] := COLOR_YES;
    cursorColor := COLOR_YES - 2;
    choice := CHOICE_YES;
end;

procedure SetResponseNie;
begin
    PmgShowResp(images[5]);
    dliColbg[5] := COLOR_NO;
    cursorColor := COLOR_NO - 2;
    choice := CHOICE_NO;
end;

procedure PmgResponseClear;
begin
    PmgShowResp(PMG_BASE);
    dliColbg[5] := COLOR_NEUTRAL;
end;

// ************************************************ GUI

procedure ShowGameScreen;
begin
    _dmactl := 0;
    _nmien := $00;
    SetIntVec(iDLI, @IngameDli);
    _dlist := word(@DL_game);

    fillPMG;
    setupPMG;

    cursorColor := COLOR_CURSOR_SELECT;
    cursorPos := 0;
    screenMode := SCREEN_INGAME;
    choice := CHOICE_YES;

    _nmien := $c0;
    _dmactl := 46;
end;

procedure ShowFrames;
begin
    ExpandRLE(images[0],RLE_BUFFER);
    w1:=RLE_BUFFER; w2:=GFX_RAM;
    for i:=0 to 47 do begin
        j:=0;
        repeat
            Move(pointer(w1),pointer(w2+j),10);
            Inc(j,10);
        until j=40;
        Inc(w2,40);
        if (i<4) or (i>42) then Inc(w1,10);
    end;
end;

function SelectCard: byte;
begin
    WaitForFireRelease;
    i := stick0;
    cursorBlink := true;
    repeat
        if i <> stick0 then begin
            if stick0 = joy_right then MoveCursor(cursorPos+1);
            if stick0 = joy_left then MoveCursor(cursorPos-1);
        end;
        c := ' ';
        i := stick0;
        if (keyPressed) then begin
            c:=ReadKey;
            if c='1' then MoveCursor(0);
            if c='2' then MoveCursor(1);
            if c='3' then MoveCursor(2);
            if c='4' then MoveCursor(3);
        end;
    until (table[cursorPos]<>EMPTY_TABLE_SLOT) and ((strig0 = 0) or (byte(c)=155));
    Pause;
    cursorBlink := false;
    cursorColor := COLOR_CURSOR_SELECT;
    Result := cursorPos;
end;

function ReadUserChoice: byte;
begin
    WaitForFireRelease;
    if choice = CHOICE_NO then SetResponseNie
    else SetResponseTak;
    i := stick0;
    c := ' ';
    repeat
        if (i<>15) and (i <> stick0) then begin
            if choice = CHOICE_NO then SetResponseTak
            else SetResponseNie;
        end;
        i := stick0;
        if (keyPressed) then begin
            c:=ReadKey;
            if c='t' then SetResponseTak;
            if c='n' then SetResponseNie;
        end;
    until ((strig0 = 0) or (byte(c)=155));
    PmgResponseClear;
    Result := choice;
end;

function ReadKeyOrFire: char;
begin
    WaitForFireRelease;
    Result := char(0);
    i := stick0;
    repeat
        if (keyPressed) then begin
            Result := ReadKey;
        end;
    until ((strig0 = 0) or (Result <> char(0)));
end;

procedure ShowFace(ptr: word;xPos: byte);
begin
    ExpandRLE(ptr,RLE_BUFFER);
    Pause;
    for i:=0 to 39 do begin
        Move(pointer(RLE_BUFFER+(i*8)),pointer(GFX_RAM+(xPos*10)+161+(i*40)),8);
    end;
end;

procedure ShowTable;
begin
    showFrames;
    for t:=0 to 3 do begin
        if table[t]<>EMPTY_TABLE_SLOT then begin
            ReadCard(table[t]);
            ShowFace(card.imgPtr, t);
        end else begin
            ShowFace(images[3], t);
        end;
    end;
    MoveCursor(cursorPos);
end;

procedure ShowCard;
begin
    GotoXY(1,3);
    WritelnCentered(NullTermToString(card.actorPtr+2));
    WritelnCentered(NullTermToString(card.descPtr));
    WritelnCentered(NullTermToString(card.sentPtr));
end;

procedure ShowResponse(choice: byte);
begin
    if choice = CHOICE_NO then
        WritelnCentered(NullTermToString(card.noPtr))
    else
        WritelnCentered(NullTermToString(card.yesPtr));
    Writeln;
end;

procedure showIncome;
begin
    WritelnCentered(kingdom.income);
end;

procedure ShowStats;
begin
    ClrTxt;
    ExpandRLE(images[6],TXT_RAM);
    GotoXY(3,1);    Write(kingdom.resources.money);
    GotoXY(11,1);   Write(kingdom.resources.population);
    GotoXY(19,1);   Write(kingdom.resources.army);
    GotoXY(3,2);    Write(kingdom.resources.health);
    GotoXY(11,2);   Write(kingdom.resources.happines);
    GotoXY(19,2);   Write(kingdom.resources.church);
    GotoXY(24,1);   Write(kingdom.kingdomName);
    GotoXY(24,2);   Write('Rok:',GetYear,'  ');
    Write(getString(6 + GetSeason));
end;

procedure ShowTitleScreen;
begin
    Pause;
    _dmactl := 0;   // DMACTL
    titleTextColor := 0;
    titlePage := 0;
    titleWait := 0;
    _nmien := 0;
    screenMode := SCREEN_TITLE;
    _dlist := word(@DL_title);
    SetIntVec(iDLI, @TitleDli);

    ClrTxt;
    ClrGfx;

    ExpandRLE(images[1],GFX_RAM); // show logo

    ShowTitlePage(0);

    _nmien := $c0;
    _gractl := 0; // GRACTL
    _dmactl := 34;   // DMACTL
end;

procedure prepareInfo(color:byte);
begin
    ClrGfx;
    ExpandRLE(images[1],GFX_RAM+160);
    cursorX := 0;
    cursorColor := 0;
    dliColbg[5] := 0;
    dliColbg[2] := color;
end;

function ShowEndOfYear: char;
var s:string[40];
    tax:smallint;
    salary:smallint;
begin
    prepareInfo(COLOR_YEAR_END);

    tax := (kingdom.resources.population * kingdom.tax) div 100;
    salary := kingdom.resources.army * kingdom.salary;
    ChangeAndKeepAboveZero(@kingdom.resources.money, tax-salary, ICON_MONEY);


    GotoXY(14,3);
    Writeln(GetString(29),GetYear-1);
    Writeln('    ',GetString(30),' (', kingdom.tax,'%',char(ICON_POPULATION),'): ',tax,'$');
    Writeln('      ',GetString(31),' (',kingdom.salary,'x',char(ICON_ARMY),'): ',salary,'$');
    WritelnCentered(GetString(32));
    Writeln;
    showRandomEvent;
    Result:= ReadKeyOrFire;
    dliColbg[2] := $F0;
    dliColbg[5] := COLOR_NEUTRAL;
end;

function getScore: smallInt;
begin
    Result:= (kingdom.resources.happines - 50) * 8;
    Result:= Result + ((kingdom.resources.health - 50) * 8);
    Result:= Result + ((kingdom.resources.church - 50) * 8);
    Result:= Result + kingdom.resources.money;
    Result:= Result + kingdom.resources.population;
    Result:= Result + kingdom.resources.army;
end;

function showEnding(ending: byte): char;
begin
    prepareInfo(COLOR_GAME_OVER);

    FillChar(pointer(TXT_RAM+80),TXT_RAM_SIZE-80,0); // clrtxt
    GotoXY(1,3);
    WritelnCentered(GetString(36));
    Writeln;
    WritelnCentered(GetString(ending));
    Writeln;
    Writeln('       ',GetString(37),getScore,GetString(38));

    Result:=ReadKeyOrFire;
    dliColbg[2] := $F0;
    dliColbg[5] := COLOR_NEUTRAL;
end;

end.
