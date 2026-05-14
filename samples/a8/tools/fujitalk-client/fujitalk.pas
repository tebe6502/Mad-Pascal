{$librarypath 'blibs'}

// See https://gitlab.com/bocianu/fujitalk-client
program fujitalk;

uses atari, http_client, crt, b_system, efast, fn_cookies, joystick;

const 
{$i const.inc}
{$r resources.rc}
{$i interrupts.inc}
{$i types.inc}


   
var
    url: string[120];
    server: string[60] = 'fujinet.pl:2137';
       
    responseBuffer: array [0..0] of byte absolute BUFFER_ADDRESS;
    strTemp: string;
    bufPtr: word;
    theme: array [0..THEME_LEN-1] of byte;
    themes: array [0..THEME_COUNT-1,0..THEME_LEN-1] of byte = (
    //  bg  menu    head    HEAD    content spinner
      ( $00,$04,$08,$02,$06,$92,$9f,$92,$9a,$04,$08 ),
      ( $00,$02,$06,$00,$06,$06,$0a,$00,$0a,$02,$04 ),
      ( $0c,$0a,$06,$0a,$06,$0f,$02,$0c,$02,$04,$08 ),
      ( $c0,$c0,$c4,$c2,$c6,$cc,$c2,$c2,$ca,$c4,$c8 ),
      ( $f0,$f0,$f4,$f2,$f6,$fc,$f2,$f2,$fa,$f4,$f8 )
    );
    config: TConfig;
    user: TUser;
    status: TStatus;
    tabNames: array [0..4] of ^string = (@status.name0, @status.name1, @status.name2, @status.name3, @status.name4); 
    state: TState;
    inputDelay: byte;
    input: byte;
    upass,unick: TString;
    inputfg: byte;

    oldvbl: pointer;
    HELPFG: byte absolute $2DC;
    VDELAY: byte absolute $D01C;    

    hdrstemp: string = 'Content-Type: text/plain'#0'Cache-Control: no-cache'#0'userKey: ########'#0#0;
    hdrs: string[120];

    tabVram: array [0..4] of word = (
        VRAM_TAB0, VRAM_TAB1, VRAM_TAB2, VRAM_TAB3, VRAM_TAB4
    );
    inputsVram: array [0..4] of word = (
        VRAM_INPUT0, VRAM_INPUT1, VRAM_INPUT2, VRAM_INPUT3, VRAM_INPUT4 
    );

    mul40: array [0..74] of word = (
    0000, 0040, 0080, 0120, 0160, 0200, 0240, 0280, 0320, 0360,  0400, 0440, 0480, 0520, 0560, 0600, 0640, 0680, 0720, 0760,  0800, 0840, 0880, 0920, 0960, 
    1000, 1040, 1080, 1120, 1160, 1200, 1240, 1280, 1320, 1360,  1400, 1440, 1480, 1520, 1560, 1600, 1640, 1680, 1720, 1760,  1800, 1840, 1880, 1920, 1960, 
    2000, 2040, 2080, 2120, 2160, 2200, 2240, 2280, 2320, 2360,  2400, 2440, 2480, 2520, 2560, 2600, 2640, 2680, 2720, 2760,  2800, 2840, 2880, 2920, 2960
    );
        
    strPtr: ^string;
    
    tabCarret: array [0..4] of byte;
    tabLines: array [0..4] of byte;
    
    loggedIn: boolean;
    lastKey: char;

    refreshDelay: word;
    tabUpScroll: byte;

procedure StateCheck;forward;keep;
procedure TryAutoLogin;forward;keep;

procedure DrawScrollBar(tab:byte);
var ps,pe,b,i:byte;
begin
    if tabLines[tab]<=VIEW_HEIGHT then begin
        fillByte(pointer(PAGER_OFFSET),PAGER_HEIGHT+1,1);
    end else begin
        ps := (((tabLines[tab] - VIEW_HEIGHT) - tabUpScroll) * PAGER_HEIGHT) div tabLines[tab];;
        pe := PAGER_HEIGHT - ((tabUpScroll * PAGER_HEIGHT) div tabLines[tab]); 
        for i:=0 to PAGER_HEIGHT do begin
            b:=1;
            if (i>=ps) and (i<=pe) then b:=4;
            poke(PAGER_OFFSET + i, b);
        end;
    end;
end;

function Atascii2Antic(c: char): char; overload;
begin
    asm {
        lda c
        asl
        php
        cmp #2*$60
        bcs @+
        sbc #2*$20-1
        bcs @+
        adc #2*$60
@       plp
        ror
        sta result;
    };
end;

function Antic2Atascii(c: char):char;overload;
begin
    asm {
        lda c
        asl
        php
        cmp #2*$60
        bcs @+
        sbc #2*$40-1
        bcs @+
        adc #2*$60
@       plp
        ror
        sta result;
    };
end;


procedure InitPMG;
begin
    SDMCTL := %00101110;    
    GPRIOR := $21;    
    PMBASE := Hi(PMG_ADDRESS);
    GRACTL := %00000011;
    sizep0 := 0;
    sizep1 := 0;
    sizem  := 0;
    //hposp0 := SPINNER_LEFT;
    //hposp1 := SPINNER_LEFT;
    hposm0 := VBAR_LEFT;
    hposm1 := VBAR_LEFT;
    vdelay := $0f;
end;

procedure Str2Antic(var s: string);
var i:byte;
begin
    for i:=1 to byte(s[0]) do s[i] := Atascii2Antic(s[i]);
end;

function Str2Atascii(var s: string):string;
var i:byte;
begin
    result[0] := s[0];
    for i:=1 to byte(s[0]) do result[i] := Antic2Atascii(s[i]);
end;

function isResponse(c:char):boolean;
begin
    result := responseBuffer[0] = byte(c);
end;

procedure strFlush;
begin
    Str(0,strTemp);
    Concat(strTemp,'');
end;

procedure updateHeader;
var i,c:byte;
begin
    move(hdrstemp,hdrs,byte(hdrstemp[0])+1);
    i:=1;
    c:=1;
    while(hdrs[i]<>'#') do inc(i);
    while(c<9) do begin
        hdrs[i]:=user.key[c];
        inc(i);
        inc(c);
    end;
end;

procedure InitInput(tab:byte);overload;
begin
    fillByte(pointer(inputsVram[state.activeTab]-1), INPUT_SIZE+1 ,0);
    state.xcur[tab]:=0;
    state.ycur[tab]:=0;
end;

procedure InitInput;overload;
begin
    pause();
    fillByte(pointer(inputsVram[state.activeTab]-1), INPUT_SIZE+1 ,0);
    cursorOn;
    savmsc := inputsVram[state.activeTab];
    rowcrs := 0;
    colcrs := 0;
    Write(#31#30);
    inputfg := theme[2];
end;

procedure RestoreInput;
begin
    pause();
    savmsc := inputsVram[state.activeTab];
    rowcrs := state.ycur[state.activeTab];
    colcrs := state.xcur[state.activeTab];
    CursorOn();
    Write(#31#30);
    inputfg := theme[2];
end;


procedure TabShow(tnum:byte);
var carret:shortInt;
    row:byte;
    dest,dlist:word;
begin
    carret := tabCarret[tnum] - VIEW_HEIGHT - tabUpScroll;
    dlist := DISPLAY_LIST_ADDRESS + 7;
    if carret < 0 then carret := TAB_LINES + carret; 
    for row := 0 to VIEW_HEIGHT - 1 do begin
        dest := tabVram[tnum] + mul40[carret];
        dpoke(dlist, dest);
        inc(carret);
        inc(dlist, 3);
        if carret = TAB_LINES then carret := 0;
    end;
    inc(dlist, 1);
    dpoke(dlist, inputsVram[tnum]);
    DrawScrollBar(tnum);
end;


procedure ClearStatus();
begin
    FillByte(@status, sizeof(status), 0);
    status.tabCount := 1;
    status.name0 := '*';
end;

procedure StateInit;
begin
    FillByte(@state,sizeOf(state),0);
    FillByte(@state.lastLine[1],4*4,$ff);
    state.tabCount := 1;
end;

procedure TabsDraw;
var tab,i :byte;
    tabOffsets: array [0..4] of byte = (1,3,12,21,30);
    dest:word;
    off:byte;
begin
    fillbyte(pointer(VRAM_STATUS),80,0);
    for tab := 0 to state.tabCount - 1 do begin
        dest := VRAM_STATUS + tabOffsets[tab];
        strPtr := tabNames[tab];
        off := 0;
        if tab = state.activeTab then off := 128;
        for i:=1 to strPtr[0] do begin
            if i>8 then break;
            poke(dest, byte(Atascii2Antic(strPtr[i]))+off);
            if state.unreadTab[tab] = 0 then poke(dest+LINE_WIDTH, byte(Atascii2Antic(strPtr[i]))+off);
            inc(dest);
        end;
    
    end;
end;


procedure UnAuth;
begin
    FillByte(user,sizeOf(user),0);
    loggedIn := false;
    StateInit();
    ClearStatus();
end;

procedure InitAll;
begin
    FillByte(pointer(VRAM_ADDRESS),$2000,0);
    UnAuth();
    TabShow(0);
    TabsDraw();
end;


procedure Tabs14Clear();
begin
    FillByte(pointer(VRAM_TAB1),BUFFER_ADDRESS-VRAM_TAB1,0);
    FillByte(@tabCarret[1],4,0);
    FillByte(@tabLines[1],4,0);
    fillByte(@state.lastLine[1],4*4,$ff);
end;

procedure TabClear(tab: byte);
begin
    FillByte(pointer(tabVram[tab]),TAB_SIZE,0);
    tabCarret[tab] := 0;
    tabLines[tab] := 0;
    InitInput(tab);
end;


procedure TabCarretPush(tnum:byte);
begin
    tabCarret[tnum] := tabCarret[tnum] + 1;
    if (tabCarret[tnum] = TAB_LINES) then tabCarret[tnum]:=0;
    if tabLines[tnum]<TAB_LINES then tabLines[tnum] := tabLines[tnum] + 1;
end;



procedure TabAppendLines(tnum,count:byte;src:pointer);
var doubleWrite:boolean;
    dest,dest2:word;
    i,b:byte;
begin
    doubleWrite := (tnum = 0) and (config.consoleEveryTab = 1) and (state.activeTab <> 0); 

    while count>0 do begin
        
        dest  := tabVram[tnum] + mul40[tabCarret[tnum]];
        if doubleWrite then dest2 := tabVram[state.activeTab] + mul40[tabCarret[state.activeTab]];
        
        for i:=0 to 39 do begin
            b := byte(Atascii2Antic(char(peek(word(src)+i))));
            poke(dest+i,b);
            if doubleWrite then poke(dest2+i,b);
        end;
        TabCarretPush(tnum);
        if doubleWrite then TabCarretPush(state.activeTab);
        Inc(src,40);
        Dec(count);
    end;
    if (state.activeTab = tnum) or doubleWrite then TabShow(state.activeTab);
end;

procedure TabAppendStr(tnum:byte;s:string);
var len,count:byte;
    off:byte;
    dest:word;
begin
    off:=0;
    count:=0;
    dest := word(@responseBuffer[0]);
    while off<Length(s) do begin
        len := Length(s) - off;
        if len>40 then len:=40;
        fillbyte(pointer(dest),40,32);
        move(s[off+1], pointer(dest), len);
        off:=off+40;
        inc(count);
    end;
    TabAppendLines(tnum,count,@responseBuffer[0]);
end;

function ShowError:byte;
var tmpstr:Tstring;
    err:byte;
begin
    err := responseBuffer[1];
    //if (err > 40) and (err < 44) then UnAuth;
    strTemp := '! ERROR ';
    Str(err,tmpstr);
    strTemp := Concat(strTemp, tmpstr);
    strTemp := Concat(strTemp, ' : ');
    strPtr := pointer(@responseBuffer[2]);
    strTemp := Concat(strTemp, strPtr);
    TabAppendStr(0,strTemp);
    result := err;
end;

procedure ShowIOerror(errCode:byte);
var tmpstr:Tstring;
begin
    strTemp := '! IO ERROR: ';
    Str(errCode,tmpstr);
    strTemp := Concat(strTemp, tmpstr);
    TabAppendStr(0,strTemp);
end;


// *************************************************************************************** COOKIE ROUTINES

procedure SaveConfig;
begin
    InitCookie(APPKEY_CREATOR_ID, APPKEY_APP_ID, APPKEY_CONFIG_KEY);
    SetCookie(@config, sizeOf(config));
    strFlush();
end;    

procedure InitConfig;
begin
    config.currentTheme := 0;
    config.sioAudio := 0;
    config.consoleEveryTab := 1;
    SaveConfig;
end;

procedure LoadConfig;
begin
    InitConfig();
    InitCookie(APPKEY_CREATOR_ID, APPKEY_APP_ID, APPKEY_CONFIG_KEY);
    if GetCookie(pointer(BUFFER_ADDRESS)) = 1 then Move(responseBuffer[0], config, sizeOf(config));
    if config.currentTheme>=THEME_COUNT then config.currentTheme := 0;
    strFlush();
end;

procedure SaveAuth;
begin
    InitCookie(APPKEY_CREATOR_ID, APPKEY_APP_ID, APPKEY_AUTH_KEY);
    SetCookie(@user, sizeOf(user));
    strFlush();
end;    

procedure LoadAuth;
begin
    InitCookie(APPKEY_CREATOR_ID, APPKEY_APP_ID, APPKEY_AUTH_KEY);
    if GetCookie(pointer(BUFFER_ADDRESS)) = 1 then Move(responseBuffer[0], user, sizeOf(user));
    strFlush();
end;


procedure SaveServer;
begin
    InitCookie(APPKEY_CREATOR_ID, APPKEY_APP_ID, APPKEY_SERVER_KEY);
    SetCookie(@server, sizeOf(server));
    strFlush();
end;    

procedure LoadServer;
begin
    InitCookie(APPKEY_CREATOR_ID, APPKEY_APP_ID, APPKEY_SERVER_KEY);
    if GetCookie(pointer(BUFFER_ADDRESS)) = 1 then Move(responseBuffer[0], @server, sizeOf(server));
    strFlush();
end;
      
        
// **************************************************************************************** HELPERS  
// ****************************************************************************************
    
     
    
procedure SetScreen();
begin
    Pause;
    SDLSTL := DISPLAY_LIST_ADDRESS;
    savmsc := VRAM_STATUS;
    nmien := $c0;
end;    


procedure SetTheme(tnum:byte);
begin
    Pause;
    Move(themes[tnum][0],@theme,THEME_LEN);
    color4:=theme[0];
end;

procedure SwitchTheme;
begin
    Inc(config.currentTheme);
    if config.currentTheme = THEME_COUNT then config.currentTheme := 0;
    SetTheme(config.currentTheme);
    SaveConfig;
end;




// *********************************************************************************************** IO
// ***********************************************************************************************
// ***********************************************************************************************

function GetUserInput:byte;
var key:char;
begin
    result := INPUT_IDLE;
    lastKey := #$ff;
    
    if inputDelay>0 then begin
        Dec(inputDelay);
    end else begin
        
        if HELPFG = 17 then begin         // HELP
            result := INPUT_HELP;
            HELPFG := 0;
        end;

        if (CONSOL and 1) = 0 then begin  // START
            result := INPUT_START;
        end;

        if (CONSOL and 2) = 0 then begin  // SELECT
            result := INPUT_SELECT;
        end;

        if (CONSOL and 4) = 0 then begin  // OPTION
            result := INPUT_OPTION;
        end;
        
        if result <> INPUT_IDLE then inputDelay := INPUT_DELAY;
                
        if keypressed then begin
            key := ReadKey();
            result := INPUT_KEY;
            lastKey := key;
            case key of

                char(21): result := I_UP;  // ctrl-u
                char(4): result := I_DOWN; // ctrl-d
                char(27): result := I_BOTTOM; // esc
                char(155): result := INPUT_ENTER;
                char(127): result := INPUT_TAB;
                char(8): result := INPUT_HIDE;
            end;
            
        end;
        
    end;

end;

procedure RequestInit;
begin
    HTTP_SetDefaults;
    updateHeader;
    HTTP_headers := @hdrs[1];
    Poke(65,config.sioAudio);
end;

procedure PostUrlData(var s: string);
begin
    RequestInit();
    Pause;
    HTTP_Post(@url[1], @responseBuffer[0], @s[1], word(s[0]));
    strFlush();
    if HTTP_error <> 1 then begin
        showIOError(HTTP_error);
    end;
end;

procedure BuildUrl;
begin
    strFlush();
    url := 'N:http://';
    url := Concat(url, server);
    url := Concat(url, '/');
end;

procedure SendInput(strAddress:word);
var tabnum:string[3];
begin
    BuildUrl;
    Str(state.activeTab,tabnum);
    url := Concat(url, 'say/');
    url := Concat(url, tabnum);
    url := Concat(url, #0);
    strPtr := pointer(strAddress);
    strPtr := Str2Atascii(strPtr);
    PostUrlData(strPtr);
end;


procedure ProcessResponse;
var targetTab: byte;
    lineCount: byte;
    errCode: byte;
    lastLine: cardinal;
begin
    //if HTTP_reqSize = 0 then exit;
    strFlush;

    if isResponse(TOKEN_USER) then begin
        move(@responseBuffer[1], @user, sizeOf(user));
        strTemp := '* Logged as ';
        strTemp := Concat(strTemp, user.nick);
        loggedIn := true;
        TabAppendStr(0,strTemp);
        SaveAuth;
    end;
    
    if isResponse(TOKEN_ERROR) then begin
        errCode := ShowError;
        case errCode of
            ERROR_LOGIN_FAILED,
            ERROR_SIGNUP_FAILED,
            ERROR_UNAUTHORIZED: begin
                loggedIn := false;
                if errCode = ERROR_UNAUTHORIZED then TryAutoLogin();
            end;
            
        end;
    end;

    if isResponse(TOKEN_STATUS) then begin
        move(@responseBuffer[1], @status, sizeOf(status));
        StateCheck();
    end;

    if isResponse(TOKEN_LINES) then begin
        targetTab:=responseBuffer[1];
        lineCount:=responseBuffer[2];
        move(@responseBuffer[3],@lastLine,4);
        TabAppendLines(targetTab,lineCount,@responseBuffer[7]);
        state.lastLine[targetTab] := lastLine;
        state.unreadTab[targetTab] := 0;
    end;

    responseBuffer[0] := 0;
end;


procedure GetUrlData();
begin
    RequestInit();
    Pause;
    HTTP_GetWithHeaders(@url[1], @responseBuffer[0]);
    strFlush();
    //showIOError(HTTP_errorCode);
    if HTTP_error <> 1 then begin
        ShowIOError(HTTP_error);
    end;
end;


procedure GetStatus();
begin
    BuildUrl;
    url := Concat(url, 'status'#0);
    GetUrlData();
    ProcessResponse();
    refreshDelay := STATUS_REFRESH_INTERVAL;                
end;

procedure GetLines(tab:byte;lastLine:cardinal);
begin
    BuildUrl;
    Str(tab, strTemp);
    url := Concat(url, 'lines/');
    url := Concat(url, strTemp);
    url := Concat(url, '/');
    Str(lastLine, strTemp);
    url := Concat(url, strTemp);
    url := Concat(url, #0);
    url := Concat(url, 'status'#0);
    state.unreadTab[tab]:=0;
    state.lastLine[tab]:=status.lastLine[tab];
    GetUrlData();
    ProcessResponse();
end;


procedure TabOpen(tnum: byte);
begin
    state.xcur[state.activeTab] := colcrs;
    state.ycur[state.activeTab] := rowcrs;
    state.activeTab := tnum;
    tabUpScroll := 0;
    TabShow(tnum);
    RestoreInput;
    TabsDraw();
    if state.unreadTab[state.activeTab] > 0 then begin
        GetLines(state.activeTab, state.lastLine[state.activeTab]);
    end;
   
end;

procedure StateCheck;
var tab:byte;
    changed:boolean;
begin
    changed := false;

    if state.activeTab > status.tabCount - 1 then status.forceTabOpen := 0;

    if state.tabCount <> status.tabCount then begin
        changed := true;
        if state.tabCount > status.tabCount then Tabs14Clear(); // one or more windows closed - refresh all tabs
        state.tabCount := status.tabCount;    
    end;
    for tab:=0 to status.tabCount-1 do begin
        if state.lastLine[tab] <> status.lastLine[tab] then begin
            state.unreadTab[tab] := 1;
            changed := true;
        end;
    end;

    if status.forceTabOpen <> NONE then begin
        if status.forceTabOpen <> state.activeTab then TabOpen(status.forceTabOpen);
        status.forceTabOpen := NONE;
        changed := true;
    end;

    TabsDraw();
    
    if (state.unreadTab[state.activeTab] > 0) then begin
       GetLines(state.activeTab, state.lastLine[state.activeTab]);
    end;
    
    if ((state.unreadTab[0]>0) and (config.consoleEveryTab = 1)) then begin
       GetLines(0, state.lastLine[state.activeTab]);
    end;
    
    
end;


procedure TabNext;
var npage:byte;
begin
    npage := state.activeTab + 1;
    if npage = status.tabCount then npage := 0;
    TabOpen(npage);
end;


procedure LogIn(var nick:string; var pass:string);
begin
    if (Length(nick) = 0) or (Length(pass) = 0) then begin
        TabAppendStr(0,'! missing parameter ');            
        TabAppendStr(0,'* usage: /login username password ');            
        exit;
    end;

    BuildUrl;
    url := Concat(url, 'login/');
    url := Concat(url, nick);
    url := Concat(url, '/');
    url := Concat(url, pass);
    url := Concat(url, #0);
    GetUrlData();
    ProcessResponse();
end;


procedure RegisterUser(var nick:string; var pass:string);
begin
    if (Length(nick) = 0) or (Length(pass) = 0) then begin
        TabAppendStr(0,'! missing parameter ');            
        TabAppendStr(0,'* usage: /register username password ');            
        exit;
    end;

    BuildUrl;
    url := Concat(url, 'register/');
    url := Concat(url, nick);
    url := Concat(url, '/');
    url := Concat(url, pass);
    url := Concat(url, #0);
    GetUrlData();
    ProcessResponse();
end;

procedure GetAuth();
begin
    BuildUrl;
    url := Concat(url, 'auth/');
    url := Concat(url, user.nick);
    url := Concat(url, #0);
    GetUrlData();
    ProcessResponse();
end;


// *********************************************************************************************** UI DRAW
// ***********************************************************************************************
// ***********************************************************************************************
// ***********************************************************************************************

procedure ShowWelcomeScreen;
begin
    TabAppendStr(0, '  '+#$20#$20#$20#$20#$20#$1a#$1b#$1c#$20#$20#$20#$20#$20);
    TabAppendStr(0, '  '+#$00#$01#$02#$03#$04#$14#$15#$16#$0a#$0b#$0c#$0d#$0e+' FujiTalk client'); 
    TabAppendStr(0, '  '+#$05#$06#$07#$08#$09#$17#$18#$19#$0f#$10#$11#$12#$13+' by bocianu@gmail.com');
    TabAppendStr(0, '  '+#$20#$20#$20#$20#$20#$20#$1d#$1e#$1f#$20#$20#$20#$20);
    TabAppendStr(0, '  ');
    TabAppendStr(0, '  version 0.3.3');
    TabAppendStr(0, '  ');
    TabAppendStr(0, '  ');
    TabAppendStr(0, '  Type /help to learn more commands.');
    TabAppendStr(0, '  ');
end;    

procedure ShowHelp;
begin
    TabAppendStr(0, '*** Basic Commands:');
    TabAppendStr(0, '  Change server address:');
    TabAppendStr(0, '    '+'/server address:port'*);
    TabAppendStr(0, '  Register new account:');
    TabAppendStr(0, '    '+'/register nick password'*);
    TabAppendStr(0, '  Login:');
    TabAppendStr(0, '    '+'/login nick password'*);
    TabAppendStr(0, '  ');
    TabAppendStr(0, '  '+'SELECT'*+' next tab  '+'START'*+' server tab  ');
    TabAppendStr(0, '  '+'OPTION'*+' theme');
    TabAppendStr(0, '  ');
    TabAppendStr(0, '  After logging in, ask for /help again');
end;    


function commandIs(cmd:Tstring):boolean;
var c:byte;
begin
    result := true;
    strPtr := pointer(inputsVram[state.activeTab]-1);
    c := 0;
    while c < Length(cmd) do begin
        if cmd[c+1]<>char(strPtr[c+2]) then exit(false);
        Inc(c);
    end;
    if (char(strPtr[c+2])<>' '~) and (c < Length(strPtr^)-1) then exit(false);
end;

procedure FetchArg(count:byte;var s:string);
var bptr:byte;
begin
    s[0] :=  #0;
    bptr := 1;
    strPtr := pointer(inputsVram[state.activeTab]-1);
    while count>0 do begin
        if strPtr[bptr] = ' '~ then dec(count);
        Inc(bptr);
        if bptr>INPUT_MAX then exit;
    end;
    while strPtr[bptr] <> ' '~ do begin
        inc(s[0]);
        s[byte(s[0])] := Antic2Atascii(strPtr[bptr]);
        inc(bptr);
        if bptr>INPUT_MAX then exit;
    end;
       
end;


procedure TryAutoLogin;
begin
    LoadAuth;
    if(user.key[0]<>#0) then begin
        TabAppendStr(0, '* Trying to autologin ');
        GetAuth;
    end;
end;

function getOptVal(var opt:string):byte;
begin
    result := NONE;
    if opt[1] = '0' then result := 0;
    if opt[1] = '1' then result := 1;
end;

procedure SetConfig(var opt:string;var value:string);
var success,show0,show1:boolean;
    optval:byte;

procedure ShowOption(o:byte);
begin
    o := o + $30;
    strTemp[Length(strTemp)] := char(o);
    TabAppendStr(0,strTemp);
end;
    
begin
    optval := getOptVal(value);
    success := false;
    show0 := false;
    show1 := false;
    if opt = '' then begin
        show0 := true;
        show1 := true;
        strTemp := '* Current Configuration:';
        TabAppendStr(0,strTemp);
    end;
    if opt = 'sioaudio' then begin
        success := true;
        if optval <> NONE then config.sioAudio := optval;
        show0 := true;
    end;
    if opt = 'console' then begin
        success := true;
        if optval <> NONE then config.consoleEveryTab := optval;
        show1 := true;
    end;
    if show0 then begin
        strTemp := '* sioaudio  ';
        ShowOption(config.sioAudio);
    end;
    if show1 then begin
        strTemp := '* console  ';
        ShowOption(config.consoleEveryTab);
    end;

    if success then begin
        SaveConfig();
    end else begin;
        //TabAppendStr(0,'* invalid parameters');
        SendInput(inputsVram[state.activeTab]-1);
        exit;
    end;
    
end;


procedure ProcessInput;

begin
    strPtr := pointer(inputsVram[state.activeTab]-1);
    if strPtr[1] = '/'~ then begin

        if commandIs('conf'~) then begin
            FetchArg(1, unick);
            FetchArg(2, upass);
            SetConfig(unick, upass);
            exit;
        end;

        if commandIs('reload'~) then begin
            if state.activeTab>0 then begin
                //TabClear(state.activeTab);
                FillByte(pointer(tabVram[state.activeTab]),TAB_SIZE,0);
                tabCarret[state.activeTab] := 0;
                tabLines[state.activeTab] := 0;
                GetLines(state.activeTab,0);
            end;
            exit;
        end;

        if commandIs('login'~) then begin
            TabAppendStr(0,'* Trying to authenticate');
            FetchArg(1, unick);
            FetchArg(2, upass);
            LogIn(unick, upass);
            exit;
        end;

        if commandIs('register'~) then begin
            TabAppendStr(0,'* Registering new user');
            FetchArg(1, unick);
            FetchArg(2, upass);
            RegisterUser(unick, upass);
            exit;
        end;

        if commandIs('logout'~) then begin
            SendInput(word(@strPtr));  
            UnAuth();
            Tabs14Clear();
            TabsDraw();
            TabAppendStr(0, '* Logged out');
            exit;
        end;

        if commandIs('auth'~) then begin
            TryAutoLogin();
            exit;
        end;

        if commandIs('help'~) then begin
            if not loggedIn then ShowHelp();
        end;

        if commandIs('server'~) then begin
            FetchArg(1, strTemp);
            if Length(strTemp)>0 then begin
                FetchArg(1, server);
                SaveServer;
            end;
            strTemp := '* server: ';
            strTemp := ConCat(strTemp, server);
            TabAppendStr(0, strTemp);
            exit;
        end;
    
    end;
    if loggedIn then SendInput(inputsVram[state.activeTab]-1);
    
end;

procedure scrollUp();
var linesup:byte;
begin
    linesup:=0;
    if tabLines[state.activeTab]>VIEW_HEIGHT then linesup:=tabLines[state.activeTab]-VIEW_HEIGHT;
    if tabUpScroll<linesup then Inc(tabUpScroll);
    TabShow(state.activeTab);
end;

procedure scrollDown();
begin
    if tabUpScroll>0 then Dec(tabUpScroll);
    TabShow(state.activeTab);
end;

procedure scrollReset();
begin
    tabUpScroll:=0;
    TabShow(state.activeTab);
end;

procedure ProcessKey(key:byte);
var cmd: Tstring;
begin
    case key of
        INPUT_START: begin
            TabOpen(0);                
            
        end;
        INPUT_TAB,
        INPUT_SELECT: begin
            TabNext();                
        end;
        INPUT_OPTION: begin
            SwitchTheme();                
        end;
        
        I_UP: begin
            scrollUp();
        end;

        I_DOWN: begin
            scrollDown();
        end;

        I_BOTTOM: begin
            scrollReset();
        end;
        
        INPUT_HIDE: begin
            cmd := '/conf verbose X'~;
            SendInput(word(@cmd));
            GetStatus();
        end;
        
        INPUT_KEY: begin

            if (lastKey = #27) then begin
                scrollUp;
                exit;
            end;

            if (lastKey = #129) then begin
                scrollReset;
                exit;
            end;
            
            //if lastKey = #$ff then exit; // no
            if byte(lastKey) and %01111111 < $1b then exit;
            if (byte(lastKey) and %01111111 > $7a) and (byte(lastKey) and %01111111 < $7e) then exit;
            
            if (colcrs = 39) and (rowcrs = 3) and (lastKey>#$20) and (lastKey<>#$7E) then begin // last position
                Write(#253); // beep
                exit;
            end;
            
            Write(lastKey);
            if rowcrs <> rowcrs and 3 then begin // cursor out of screen
                rowcrs := rowcrs and 3; 
                Write(#30#31);
            end;
        end;
        
    end;
end;

function GetInputLength:byte;
var b:byte;
begin
    CursorOff;
    poke(93,0); //clear cursor content
    result := INPUT_SIZE ;
    repeat 
        dec(result);
        b := peek(inputsVram[state.activeTab] + result) and 127;
        if b <> byte(' '~) then exit(byte(result+1));
    until result = 0;
end;

// ************************************************************************************************************
// ************************************************************************************************************
// ************************************************************************************************************
// ************************************************************************************************************
// ************************************************************************************************************

begin
    // copy system charset to user location
    Move(pointer($e000), pointer(CHARSET), $400);
    // update with Fujinet logo characters
    Move(pointer(LOGO_CHARSET), pointer(CHARSET + $200), $100);

    Pause; 
    portb:=$ff;
    nmien := $0;
    GetIntVec(iVBL, oldvbl);
    SetIntVec(iVBL, @vbl);
    chbas := Hi(CHARSET); 
    nmien := $40;
    Poke(702,0); // shift up
    lmargin := 0;
    SetScreen();
    InitAll();
    strFlush();
    InitPMG();
    ShowWelcomeScreen();


    TabAppendStr(0,'* Loading configuration ');
    LoadConfig();
    Poke(65, config.sioaudio);
    SetTheme(config.currentTheme);
    LoadServer();
    strTemp := '* Server: ';
    strTemp := Concat(strTemp,server);
    TabAppendStr(0,strTemp);

    loggedIn:=false;
    TryAutoLogin();

    GetStatus();

    InitInput();

    repeat
        repeat 
            repeat 

                Pause();
                input := GetUserInput();
                
                if refreshDelay = 0 then begin
                    if loggedIn then GetStatus();
                end else Dec(refreshDelay);
            
            until input <> INPUT_IDLE;
            
            ProcessKey(input);
            if refreshDelay < (STATUS_REFRESH_INTERVAL div 2) then Inc(refreshDelay,20);

        until input = INPUT_ENTER;
        
        strPtr := pointer(inputsVram[state.activeTab]-1);
        strPtr[0] := char(GetInputLength());
        
        if Length(strPtr^) > 0 then begin
            inputfg := theme[1]+2;
            ProcessInput();
            InitInput();
            GetStatus();
        end else InitInput();
        
    until false;
    
    Pause;
    SDMCTL := %00100010;    
    GRACTL := %00000000;    
    SetIntVec(iVBL, oldvbl);
    nmien := $40;
    TextMode(0);

end.
