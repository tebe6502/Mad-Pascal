program zilch;
uses atari, sysutils, mypmg, joystick, crt, rmt;
{$r assets.rc}
{$I defines.inc}
{$I memory.inc}
{$I types.inc}
{$I assets/assets.inc}

//{$DEFINE speedMode}
//{$DEFINE debug}

var
    player,player1,player2,player3,player4,showPlayer:Tplayer;
    scoreTemp,sc1,sc2,sc3,sc4:Tscore;
    gamePlayers: array [0..3] of pointer = (@player1, @player2, @player3, @player4);
    scores: array [0..3] of pointer = (@sc1, @sc2, @sc3, @sc4);
    values: array [0..6] of byte = (0,100,20,30,40,50,60);

    bank,winingScore: smallInt;
    banked: byte;
    canRoll, canBank, gameOn, lastRound, quitGame: boolean;

    dices: array [0..5] of byte;
    freeDices, blinkDices, playerCurrent, scoresCount, menuchoice, lastScore: byte;
    menupos: byte;  // 1-4 score, $00 none, $10 roll, $20 bank

    key: char;
    s:string;

    msx: TRMT;

    oldDli: pointer = @bank;
    oldVbli: pointer = @bank;


(***************************************)
(**************************************** DATA OPERATIONS *)
(***************************************)

procedure pushScore(score: smallInt; dices: byte; name: Tstring);
begin
    scoreTemp.score := score;
    scoreTemp.dices := dices;
    move(name, scoreTemp.name, 32);
    move(scoreTemp, scores[scoresCount], sizeof(Tscore));
    Inc(scoresCount);
end;

procedure getScore(i:byte);
begin
    move(scores[i], scoreTemp, sizeof(Tscore));
end;

procedure swapScore(i:byte);
var tmp: pointer;
begin
    tmp:=scores[i];
    scores[i]:=scores[i+1];
    scores[i+1]:=tmp;
end;

procedure sortScores;
var i,m:byte;
    max: smallInt;
begin
    if scoresCount>1 then begin
        repeat
            m:=0;
            for i:=0 to scoresCount-1 do begin
                getScore(i);
                max:=scoreTemp.score;
                getScore(i+1);
                if max<scoreTemp.score then begin
                    swapScore(i);
                    inc(m);
                end;
            end;
        until m=0;
    end;
end;

function getScoreMask:byte;
var i:byte;
begin
    result:=0;
    if scoresCount>0 then
        for i:=0 to scoresCount-1 do begin
            getScore(i);
            result:=result or scoreTemp.dices;
        end;
end;

procedure clearPlayerScores;
begin
    player1.score := 0;
    player2.score := 0;
    player3.score := 0;
    player4.score := 0;
    player1.zilchRow := 0;
    player2.zilchRow := 0;
    player3.zilchRow := 0;
    player4.zilchRow := 0;
end;


function countBits(b:byte):byte;
var mask,i:byte;
begin
    mask:=1;
    result:=0;
    for i:=0 to 5 do begin
        if (mask and b) = 0 then result:=result+1;
        mask:=mask shl 1;
    end
end;

function countOnDices(num:byte):word;
var mask,i,dice:byte;
begin
    mask:=1;
    dice:=0;
    result:=0;
    for i:=0 to 5 do begin
        if ((mask and freeDices) = 0) and (dices[i] = num) then begin
            Inc(result);
            dice := dice or mask;
        end;
        mask := mask shl 1;
    end;
    result:=(dice shl 8) + result;
end;

procedure findScores;
var i,c,d,m:byte;
    cd:word;
    pairs:byte;
    singles:byte;
    s: Tstring;
begin
    scoresCount:=0;
    pairs:=0;
    singles:=0;
    for i:=1 to 6 do begin
        cd:=countOnDices(i);
        c:=Lo(cd);
        d:=Hi(cd);
        case c of
            3..6: begin
                s := IntToStr(c);
                s := concat(s,'&');
                s := concat(s, numStrings[i-1]);
                m := 1 shl (c-3);
                pushScore(10 * m * values[i], d, s);
            end;
            1..2: begin
                if (i=1) or (i=5) then begin
                    s := IntToStr(c);
                    s := concat(s,'&');
                    s := concat(s,numStrings[i-1]);
                    m := 1 shl (c-3);
                    pushScore(c * values[i], d, s);
                end;
                if c=1 then inc(singles);
                if c=2 then inc(pairs);
            end;
        end;
    end;

    if pairs = 3 then pushScore(1500,%00111111,  '3 pairs  ');
    if singles = 6 then pushScore(1500,%00111111,'1 to 6   ');
    if (freeDices = 0) and (scoresCount = 0) then pushScore(500,%00111111,'null     ');
    sortScores;
end;

procedure keepScore(i:byte);
begin
    getScore(i);
    bank:= bank + scoreTemp.score;
    msx.Sfx(6, 1, 48);
    freeDices:= freeDices or scoreTemp.dices;
    blinkDices:=0;
end;

procedure setMenupos(pos:byte);
begin
	menupos:=pos;
	if (pos and %1111) <> 0 then begin
		getScore(pos-1);
		blinkDices:=scoreTemp.dices;
	end else blinkDices:=0;
end;

procedure getPlayer(i:byte);
begin
    move(GamePlayers[i], player, sizeof(Tplayer));
end;

procedure setPlayer(i:byte);
begin
    move(player, GamePlayers[i], sizeof(Tplayer));
end;

procedure Write8R(s:TString);forward;

procedure bankPlayer;
var s:TString;
begin
    player.score:=player.score + bank;
    player.zilchRow:=0;
    GotoXY(10*playerCurrent+2,21);
    s:=Concat('+',IntToStr(bank));
    msx.Sfx(4, 1, 32);
    msx.Sfx(4, 5, 32);
    Write8R(s);
    setPlayer(playerCurrent);
end;

procedure zilchPlayer;
begin
    player.zilchRow:=player.zilchrow+1;
    GotoXY(10*playerCurrent+2,21);
    if player.zilchRow = 3 then begin
        player.score:=player.score - 500;
        Write8R('-500');
    end else Write8R('      ');
    msx.Sfx(3, 1, 12);
    msx.Sfx(3, 5, 12);
    setPlayer(playerCurrent);
end;





(***************************************)
(**************************************** USER I/O ROUTINES *)
(***************************************)

procedure PauseT(n:byte);
begin
    while n>0 do begin
        pause;
        dec(n);
    end;
end;

procedure userDelay;
begin
	{$IFNDEF speedMode}
	if player.ptype <> PLAYER_HUMAN then pauseT(40);
	pauseT(10);
	{$ENDIF}
end;

procedure waitUserInput;
begin
    if player.ptype = PLAYER_HUMAN then begin
		if keypressed then key:=Readkey;
        repeat until strig0 = 1;
        key:=#0;
        repeat
            if keypressed then key:=readkey;
            pause;
        until (strig0 = 0) or (key<>#0);
    end else
    {$IFNDEF speedMode}
        PauseT(50);
    {$ENDIF}
end;

function getUserChoice:byte;
var joyRepeat,s: byte;
begin
	if keypressed then key:=Readkey;
    joyRepeat:= 0;
    repeat until strig0 = 1;
    repeat
        if stick0 = joy_none then joyRepeat:=0;
        if joyRepeat>0 then dec(joyRepeat)
        else begin
            if (stick0 = joy_up) or (stick0 = joy_down) then begin
                if (menupos<MENU_ROLL) and canRoll then begin
                    menupos:=MENU_ROLL;
                   	blinkDices:=0;
                end else
                if scoresCount>0 then begin
                    if lastScore>scoresCount then lastScore:=1;
                    menupos:=lastScore;
                    getScore(menupos-1);
					blinkDices := scoreTemp.dices;
                end;
              	msx.Sfx(6, 1, 24);
                joyRepeat:=20;
            end;
            if (stick0 = joy_left) or (stick0 = joy_right) then begin
                if menupos>=MENU_ROLL then begin
                    if menupos=MENU_ROLL then menupos:=MENU_BANK
                        else menupos:=MENU_ROLL;
                end else begin
                    if stick0 = joy_left then Dec(menupos)
                    else Inc(menupos);
                    if menupos>scoresCount then menupos:=1;
                    if menupos=0 then menupos:=scoresCount;
                    lastScore:=menupos;
                    getScore(menupos-1);
					blinkDices := scoreTemp.dices;
                end;
                msx.Sfx(6, 1, 24);
                joyRepeat:=20;
            end;
        end;
        if keypressed then begin
            key:=readkey;
            case key of
                '1'..'8': begin
                        s:=StrToInt(key);
                        if scoresCount>=s then begin
                            exit(s);
                        end;
                    end;
                'R','r': if canRoll then exit(MENU_ROLL);
                'B','b': if canBank then exit(MENU_BANK);
                #27: exit(MENU_QUIT);
            end;
           	msx.Sfx(6, 1, 24);
        end;
        pause;

    until strig0 = 0;
    result:=menupos;
end;




(***************************************)
(**************************************** GUI ROUTINES *)
(***************************************)

procedure fillPlayerTabs;
begin
    FillChar(pointer(PMGBASE+512-128+82),32,$ff);
    FillChar(pointer(PMGBASE+512+82),32,$ff);
    FillChar(pointer(PMGBASE+512+(1*128)+82),32,$ff);
    FillChar(pointer(PMGBASE+512+(2*128)+82),32,$ff);
    FillChar(pointer(PMGBASE+512+(3*128)+82),32,$ff);
    poke(PMGBASE+512+90-128,0);
    poke(PMGBASE+512+90,0);
    poke(PMGBASE+512+90+(1*128),0);
    poke(PMGBASE+512+90+(2*128),0);
    poke(PMGBASE+512+90+(3*128),0);
end;

procedure fillMenu;
begin
    // bank&roll
    FillChar(pointer(PMGBASE+512+49),17,$ff);
    FillChar(pointer(PMGBASE+512-128+49),17,$3);

    // scores
    FillChar(pointer(PMGBASE+512+71),10,$ff);
    FillChar(pointer(PMGBASE+512-128+71),10,$3);
end;

procedure fillDiceMarkers;
begin
    FillChar(pointer(PMGBASE+512-128+25),16,$ff);
	FillChar(pointer(PMGBASE+512+25),16,%11110000);
	FillChar(pointer(PMGBASE+512+(1*128)+25),16,%11110000);
	FillChar(pointer(PMGBASE+512+(2*128)+25),16,%11110000);
	FillChar(pointer(PMGBASE+512+(3*128)+25),16,%11110000);
end;

procedure fillGamePMG;
begin
	fillPlayerTabs;
	fillDiceMarkers;
	fillMenu;
end;

procedure gamePMGInit;
begin
    PMG_gprior_S:=1;

    PMG_sizep0:=3;
    PMG_sizep1:=3;
    PMG_sizep2:=3;
    PMG_sizep3:=3;
    PMG_sizem:=$ff;

    PMG_pcolr0_S:= P1COLOR;
    PMG_pcolr1_S:= P2COLOR;
    PMG_pcolr2_S:= P3COLOR;
    PMG_pcolr3_S:= P4COLOR;
end;

procedure bankShow;
begin
    gotoxy(16,1);
    Writeln('Bank: ',bank,'     ');
end;

procedure WritelnCentered(str: string);
begin
    Writeln(Space((40 - Length(str)) div 2), str);
end;

procedure Write8R(s:TString);
var len:byte;
begin
    len:=8-Length(s);
    Write(Space(len),s);
end;

procedure clearMenu;
begin
	fillchar(pointer(savmsc+320),320,0);
end;

procedure clearDices;
begin
    fillByte(pointer(savmsc + 80),200,0);
end;

procedure drawDiceTile(x,y,num:byte);
var voffset:word;
    i,d:byte;
    a,t:array[0..0] of byte;
begin
    i:=0;
    d:=0;
    voffset:=savmsc + (y*40) + x;
    a:=numberTiles[num-1];
    if num=1 then t:=diceTiles[Random(4)]
    else t:=diceTiles[Random(8)];
    repeat
        move(t[i], pointer(voffset), 5);
        if (i>4) and (i<20) then begin
            move(a[d], pointer(voffset+1), 3);
            inc(d,3);
        end;
        Inc(voffset,40);
        Inc(i,5);
    until (i>24)
end;

procedure putDiceTile(x,num:byte);
begin
	drawDiceTile(x,2,num);
end;

procedure dicesThrow;
var d,mask,x,i:byte;
begin
	clearDices;
    mask:=1;
    x:=2;
    for d:=0 to 5 do begin
        if (freeDices and mask) = 0 then begin
            {$IFDEF speedMode}
            dices[d]:=Random(6)+1;
            putDiceTile(x,dices[d]);
            {$ELSE}
            for i:=0 to 10-d do begin
                dices[d]:=Random(6)+1;
                putDiceTile(x,dices[d]);
              	msx.Sfx(5, 1, 48);
              	msx.Sfx(5, 5, 32);
                pauseT(d);
            end;
            {$ENDIF}
        end;
        mask:=mask shl 1;
        inc(x,6);
    end;
    canRoll:=false;
    canBank:=false;
end;

procedure dicesShow;
var d,mask,x:byte;
begin
	pause;
    fillByte(pointer(savmsc + 80),200,0);
    mask:=1;
    x:=2;
    for d:=0 to 5 do begin
        if (freeDices and mask) = 0 then putDiceTile(x,dices[d]);
        mask:=mask shl 1;
        inc(x,6);
    end;
end;

procedure putTile(x,y,w,h:byte; tile:pointer);
var voffset:word;
    i:byte;
    a:array[0..0] of byte;
begin
    i:=0;
    voffset:=savmsc;
    voffset:=voffset + (y*40) + x;
    a:=tile;
    while(h>0) do begin
        move(a[i], pointer(voffset), w);
        Inc(voffset,40);
        Inc(i,w);
        Dec(h);
    end;
end;

procedure invertScore(n: byte);
var offs:word;
    i:byte;
begin
    offs:=savmsc+561+n*10;
    poke(offs+8,8);
    poke(offs+48,8);
    for i:=0 to 7 do begin
        poke(offs+i, peek(offs+i)+128);
        poke(offs+40+i, peek(offs+40+i)+128);
    end;
end;

procedure showScores;
var i,o:byte;
begin
    if scoresCount > 0 then begin
        o:=1;
        for i:=0 to scoresCount-1 do begin
            getScore(i);
            GotoXy(o,15);
            Write(#168,scoreTemp.score);
            GotoXy(o,16);
            Write(#168,scoreTemp.name);
            Inc(o,10);
            invertScore(i);
        end;
    end;
end;

procedure showPlayerScore(idx:byte);
var x:byte;
    s:TString;
begin
    move(GamePlayers[idx], showPlayer, sizeOf(Tplayer));
    if showPlayer.ptype <> PLAYER_NONE then begin
        x:=10*idx+2;
        GotoXY(x,18);
        Write(showPlayer.name);
        GotoXY(x,20);
        Write('score:');
        GotoXY(x,22);
        s:=IntToStr(showPlayer.score);
        Write8R(s);
        GotoXY(x,24);
        if showPlayer.zilchRow =3 then Write('-500    ')
        else if showPlayer.zilchRow > 0 then Write('ZILCH x', showPlayer.zilchRow)
                else Write('        ');
    end;
end;

procedure showPlayerTitle(idx:byte);
var x:byte;
    s:TString;
begin
    move(GamePlayers[idx], showPlayer, sizeOf(Tplayer));
    x:=10*idx+2;
    GotoXY(x,18);
    Write(showPlayer.name);
    GotoXY(x,21);
    case showPlayer.ptype of
		PLAYER_HUMAN: s:='HUMAN';
		PLAYER_NONE:  s:='OFF';
		PLAYER_CPU1: s:='CPU 1';
		PLAYER_CPU2: s:='CPU 2';
		PLAYER_CPU3: s:='CPU 3';
	end;
    Write8R(s);
end;

procedure showPlayers;
var i:byte;
begin
    for i:=0 to PLAYERS_NUM-1 do showPlayerScore(i);
end;

procedure showPlayersTitle;
var i:byte;
begin
    for i:=0 to PLAYERS_NUM-1 do showPlayerTitle(i);
end;

procedure endGame;
var p,r,place:byte;
score: smallInt;
s,pname: TString;
winstr: string;
begin
	winstr:='';
    gameOn:=false;
    setMenupos(MENU_NONE);
    clearMenu;
    showPlayers;
    for p:=0 to 3 do begin
        getPlayer(p);
        if player.ptype<>PLAYER_NONE then begin
            score:=player.score;
            pname:=player.name;
            place:=0;
            for r:=0 to 3 do
                if p<>r then begin
                    getPlayer(r);
                    if score<player.score then Inc(place);
                end;
            GotoXY(10*p+2,24);
            s:=placeStrings[place];
            Write(s);
            if place=0 then
				if Length(winstr)=0 then winstr:=pname
				else begin
					winstr:=concat(winstr,' and ');
					winstr:=concat(winstr,pname);
				end;
        end;
    end;
    clearDices;
    gotoxy(1,4);
    WritelnCentered('Congratulations!');
    winstr:=concat(winstr,' wins the game');
	WritelnCentered(winstr);
	if keypressed then key:=readkey;
	player.ptype:=PLAYER_HUMAN;
	waitUserInput;
end;

procedure nextPlayer;
var i:byte;
begin
    if player.score>=10000 then begin
        lastRound:=true;
        if player.score>winingScore then winingScore:=player.score;
    end;

    i:=(playerCurrent+1) mod PLAYERS_NUM;
    playerCurrent:=PLAYER_NONE;
    repeat
        getPlayer(i);
        if player.ptype <> PLAYER_NONE then playerCurrent:=i;
        i:=(i+1) mod PLAYERS_NUM;
    until playerCurrent <> PLAYER_NONE;
    if player.zilchRow = 3 then player.zilchRow:=0;
    setPlayer(playerCurrent);
    scoresCount:=0;
    freeDices:=0;
    bank:=0;
    banked:=0;
    canRoll:=false;
    canBank:=false;
    setMenupos(0);
    clearMenu;
    if player.score>=10000 then endGame
    else begin
		clearDices;
		gotoxy(1,3);
		s:=Concat('Turn of the ',player.name);
		WritelnCentered(s);
		putTile(16,4,8,3,@roll);
		waitUserInput;
	end;
end;

procedure initPlayer;
begin
    playerCurrent:=3;
    nextPlayer;
end;

procedure drawTitleScreen;
begin
	HELPFG:=0;
	playerCurrent:=PLAYER_NONE;
	ClrScr;
	setMenupos(MENU_NONE);
	PMG_clear;
	fillPlayerTabs;
	gotoxy(1,1);
	WritelnCentered('bocianu hereby presents');
	Writeln;
	WritelnCentered('THE GAME OF');
	putTile(15,4,9,3,@zilch);
	putDiceTile(1,5);
	putDiceTile(7,1);
	putDiceTile(27,1);
	putDiceTile(34,5);

	gotoxy(1,9);
	WritelnCentered('code: bocianu     music: LiSU');
	Writeln;
	Writeln;
	Writeln('   press ','HELP'*,'  for game instructions');
	Writeln;
	Writeln('  use ','SELECT'*,' ','OPTION'*,' to adjust players');

	showPlayersTitle;

end;

procedure showHelpScreen;
begin
	player.ptype := PLAYER_HUMAN;
	HELPFG:=0;
	nmien:=64;
	playerCurrent:=PLAYER_NONE;
	ClrScr;
	setMenupos(MENU_NONE);
	PMG_clear;

	// screen 1

	WritelnCentered('How to play the fine game of');
	putTile(15,2,9,3,@zilch);
	Gotoxy(1,6);
	Writeln(StringOfChar(#18,40));
	Writeln('1. Roll the dice'*);
	Writeln('You start your turn');
	Writeln('by rolling all six dice.');
	Writeln;
	Writeln('2. Scoring dice - Take some points!'*);
	Writeln('If you rolled some scoring dice then,');
	Writeln('you need to take some of those points');
	Writeln('before you can roll again.');
	Writeln;
	Writeln('3. No scoring dice - You zilched!'*);
	Writeln('This means that all the points you took');
	Write('so far are wiped out. You bank no points');
	Writeln('and it''s the end of your turn.');
	Writeln;
	Writeln('If this is your third zilch in a row');
	Writeln('then you lose 500 points.');
	waitUserInput;

	// screen 2

	FillChar(pointer(savmsc+280),680,0);
	Gotoxy(1,8);
	Writeln('4. Scored 300 or more - Bank the points.'*);
	Writeln('Once you have taken at least 300 points');
	Writeln('you can choose to bank them or keep');
	Writeln('on rolling the dice. If you bank');
	Writeln('the points then they are added');
	Writeln('to your score and your turn is over.');
	Writeln('If you decide to carry on rolling,');
	Writeln('then you could roll more scoring dice,');
	Writeln('but you could zilch out.');
	Writeln;
	Writeln('5. Re-roll the remaining dice'*);
	Writeln;
	Write('You can re-roll any dice that you didn''t');
	Writeln('score with. Once you have scored points');
	Writeln('from all six dice you get a free roll!');
	waitUserInput;

	// screen 3

	ClrScr;
	putTile(15,0,9,3,@zilch);
	Gotoxy(1,4);
	WritelnCentered('SCORING GUIDE');
	Write(StringOfChar(#18,40));
	Writeln('Ones and Fives:'*);
	drawDiceTile(0,7,1);
	Gotoxy(7,9);
	Write('100 points');
	Gotoxy(7,10);
	Write('each');
	drawDiceTile(20,7,5);
	Gotoxy(27,9);
	Write('50 points');
	Gotoxy(27,10);
	Write('each');
	Gotoxy(1,14);
	Writeln('Three of a kind:'*);
	drawDiceTile(0,15,2);
	drawDiceTile(5,15,2);
	drawDiceTile(10,15,2);
	Gotoxy(17,17);
	Write('200 points');
	Gotoxy(1,22);
	Write  ('3&one '*,' 1000   ','3&two '*,' 200   ','3&three'*,' 300');
	Writeln;
	Writeln;
	Write  ('3&four'*,' 400    ','3&five'*,' 500   ','3&six  '*,' 600');
	waitUserInput;

	// screen 4

	FillChar(pointer(savmsc+240),720,0);
	Gotoxy(1,6);
	Writeln('Four or more of a kind:'*);
	Writeln('For each extra dice over three that you');
	Write('roll, the score is doubled. For example:');
	drawDiceTile(0,9,3);
	drawDiceTile(5,9,3);
	drawDiceTile(10,9,3);
	drawDiceTile(15,9,3);
	Gotoxy(22,11);
	Write('300&2');
	Gotoxy(22,12);
	Write('600 pts');
	drawDiceTile(0,14,3);
	drawDiceTile(5,14,3);
	drawDiceTile(10,14,3);
	drawDiceTile(15,14,3);
	drawDiceTile(20,14,3);
	Gotoxy(27,16);
	Write('300&4');
	Gotoxy(27,17);
	Write('1200 pts');
	drawDiceTile(0,19,3);
	drawDiceTile(5,19,3);
	drawDiceTile(10,19,3);
	drawDiceTile(15,19,3);
	drawDiceTile(20,19,3);
	drawDiceTile(25,19,3);
	Gotoxy(32,21);
	Write('300&8');
	Gotoxy(32,22);
	Write('2400 pts');
	waitUserInput;

	// screen 5

	FillChar(pointer(savmsc+200),760,0);
	Gotoxy(1,6);
	Writeln('Special rolls:'*);
	drawDiceTile(0,7,3);
	drawDiceTile(5,7,2);
	drawDiceTile(10,7,5);
	drawDiceTile(15,7,4);
	drawDiceTile(20,7,1);
	drawDiceTile(25,7,6);
	Gotoxy(32,8);
	Write('1 to 6');
	Gotoxy(32,9);
	Write('1500 pts');
	Gotoxy(32,11);
	Write('FREEROLL'*);
	drawDiceTile(0,13,1);
	drawDiceTile(5,13,1);
	drawDiceTile(10,13,4);
	drawDiceTile(15,13,4);
	drawDiceTile(20,13,3);
	drawDiceTile(25,13,3);
	Gotoxy(32,14);
	Write('3 pairs');
	Gotoxy(32,15);
	Write('1500 pts');
	Gotoxy(32,17);
	Write('FREEROLL'*);
	drawDiceTile(0,19,2);
	drawDiceTile(5,19,6);
	drawDiceTile(10,19,3);
	drawDiceTile(15,19,4);
	drawDiceTile(20,19,6);
	drawDiceTile(25,19,3);
	Gotoxy(32,20);
	Write('no score');
	Gotoxy(32,21);
	Write('500 pts');
	Gotoxy(32,23);
	Write('FREEROLL'*);
	waitUserInput;

	nmien:=192;
	drawTitleScreen;
end;

procedure showTitleScreen;
begin
    msx.Init(0);
	drawTitleScreen;
	repeat
		pause;
		if ((consol and 2) = 0) then begin // SELECT
			if playerCurrent=PLAYER_NONE then playerCurrent:=0
			else playerCurrent:=(playerCurrent+1) mod PLAYERS_NUM;
			getPlayer(playerCurrent);
			repeat until consol = %111;
		end;
		if ((consol and 4) = 0) and (playerCurrent<PLAYER_NONE) then begin // OPTION
			player.ptype:=(player.ptype+1) mod PLAYER_TYPES;
			setPlayer(playerCurrent);
			showPlayerTitle(playerCurrent);
			repeat until consol = %111;
		end;
		if keypressed then begin
			key:=readkey;
			if key=#27 then quitGame:=true;
		end;
		if HELPFG=17 then showHelpScreen;

	until (strig0=0) or ((consol and 1) = 0) or quitGame;
    repeat until strig0=1;
end;



(***************************************)
(**************************************** CPU PLAYERS *)
(***************************************)

function getCpuChoice:byte;
var diceCount,i,scoreMask:byte;
begin

    (********* common strategy *)

    // if throw is safe, throw always
    if freeDices=%00111111 then exit(MENU_ROLL);

    // if bankin wins game, then bank
    if canBank and ((player.score + bank) > winingScore) then exit(MENU_BANK);

    // last round rules
    if lastRound then begin
        if scoresCount>0 then exit(MENU_SCORE1);
        if canRoll then exit(MENU_ROLL);
    end;

    diceCount:=countBits(freeDices);
    scoreMask:=getScoreMask;

    // debug info
    {$IFDEF debug}
    gotoxy(1,2);
    write('sc:',scoresCount);
    write(' fd:',freeDices);
    write(' dc:',dicecount);
    write(' sm:',scoremask);
    write(' cb:',canBank);
    write(' cr:',canRoll);
    {$ENDIF}

    case player.ptype of

    (********* easy strategy *)

        PLAYER_CPU1: begin

            // if can get score, get always
            if scoresCount>0 then exit(MENU_SCORE1);

            // if can Bank and less than 3 dice to throw, then bank
            if canBank and (diceCount<3) then exit(MENU_BANK);

            // roll when nothing above fits
            if canRoll then exit(MENU_ROLL);
        end;

    (********* advanced strategy *)

        PLAYER_CPU2: begin

            // if can get score, calculate...
            if scoresCount>0 then begin

                // if all scoring clears table, get always
                if (diceCount-countBits(not scoremask))=0 then exit(MENU_SCORE1);

                getScore(0);
                // if best score is better than 200, get it
                if scoreTemp.score>200 then exit(MENU_SCORE1);

                // if less and can roll - roll it!
                if canRoll and (player.zilchRow=0) then exit(MENU_ROLL);

                // if cannot roll take scoring anyway
                exit(MENU_SCORE1);
            end;

            // if can Bank
            if canBank then begin

                // always try to bank if zilched last time
                if player.zilchRow>0 then exit(MENU_BANK);

                if (diceCount<5) and (bank>=1000) then exit(MENU_BANK);

                // and less than 3 dice to throw and banked more then 500 already, then bank
                if (diceCount<3) and (bank>=500) then exit(MENU_BANK);

            end;

            // roll when nothing above fits
            if canRoll then exit(MENU_ROLL);
        end;

    (********* risky strategy *)

        PLAYER_CPU3: begin

            // if can get score, calculate...
            if scoresCount>0 then begin

                // if all scoring clears table, get always
                if (diceCount-countBits(not scoremask))=0 then exit(MENU_SCORE1);

                getScore(0);
                // if best score is better than 200, get it
                if scoreTemp.score>200 then exit(MENU_SCORE1);

                // if less and can roll - roll it!
                if canRoll and (player.zilchRow=0) then exit(MENU_ROLL);

				if scoresCount>1 then exit(MENU_SCORE2);

                // if cannot roll take scoring anyway
                exit(MENU_SCORE1);
            end;

            // if can Bank
            if canBank then begin

				// always try to bank if zilched last time
                if (diceCount<5) and (player.zilchRow>0) then exit(MENU_BANK);

                if (diceCount<5) and (bank>=1000) then exit(MENU_BANK);

                // sometimes take a risk when less than 3 dice
                if (diceCount<3) and (Random(4)=0) then exit(MENU_ROLL);

                // and less than 3 dice to throw and banked more then 500 already, then bank
                if (diceCount<3) and (bank>=500) then exit(MENU_BANK);

            end;

            // roll when nothing above fits
            if canRoll then exit(MENU_ROLL);
        end;

    end;
end;

{$I interrupts.inc}

(***************************************)
(**************************************** MAIN PROGRAM *)
(***************************************)
begin
    Randomize;
    poke(712,BGCOLOR);
    poke(710,BGCOLOR);
    poke(709,14);

    poke(dpeek(560)+2, peek(dpeek(560)+2) + 128); // inject DLI
	PMG_Init(Hi(PMGBASE));
    PMG_Clear;

    msx.player := pointer(RMT_PLAYER);
    msx.modul := pointer(RMT_MODULE);
    msx.Init(3);

    GetIntVec(iDLI,oldDli);
    GetIntVec(iVBL,oldVbli);
    SetIntVec(iDLI,@dli);
    SetIntVec(iVBL,@vbli);
    nmien:=192;

    chbas:=Hi(CHARSET_TILE_ADDRESS);
    lmargin:=0;
    CursorOff;

    player1.ptype := PLAYER_HUMAN;
    player2.ptype := PLAYER_CPU1;
    player3.ptype := PLAYER_NONE;
    player4.ptype := PLAYER_NONE;

    player1.name := 'Albert';
    player2.name := 'Cedric';
    player3.name := 'Eugene';
    player4.name := 'Maurice';


	quitGame:=false;
	gamePMGInit;

	repeat;
		showTitleScreen;
		msx.Init(3);

		if not quitGame then begin
			fillGamePMG;
			clrScr;
			showPlayers;
			blinkDices:=0;
			bankShow;
			initPlayer;
			gameOn:=true;
			lastRound:=false;
			winingScore:=10000;
			clearPlayerScores;

			repeat
				setMenupos(MENU_NONE);
				clearMenu;
				lastScore:=1;
				banked:=0;
				blinkDices:=0;
				showPlayers;
				bankShow;
				dicesThrow;
				findScores;
				if (scoresCount = 0) then begin // ZILCHED!
					zilchPlayer;
					showPlayers;
					fillchar(pointer(savmsc+320),320,0);
					putTile(14,8,11,5,@zilchTile);
					waitUserInput;
					nextPlayer;

				end else begin
					repeat
						blinkDices:=0;
						atract:=11;
						bankShow;
						fillchar(pointer(savmsc+320),320,0);

						showScores;
						if banked>0 then begin
							canRoll := true;
							putTile(10,8,10,5,@rollTile);
							if (bank>=300) then begin
								canBank := true;
								putTile(20,8,10,5,@bankTile);
							end;
						end;

						if scoresCount>0 then setMenupos(MENU_SCORE1)
							else if canRoll then setMenupos(MENU_ROLL);

						if freeDices=%00111111 then begin
							clearDices;
							gotoxy(1,3);
							WritelnCentered('FREE  ');
							putTile(16,4,8,3,@roll);
						end;

						if player.ptype = PLAYER_HUMAN then menuchoice:=getUserChoice
							else menuchoice:=getCpuChoice;

						if menuchoice = MENU_QUIT then gameOn:=false
						else begin
							setMenupos(menuchoice);
							userDelay;
						end;
						if keypressed then begin
							key:=readkey;
							if (key=#27) then gameOn:=false;
						end;

						case menuchoice of
							1..8: begin
								if scoresCount>=menuchoice then begin
									inc(banked);
									keepScore(menuchoice-1);
									dicesShow;
									findScores;
								end;
							end;
						end;
					until ((menuchoice = MENU_ROLL) and canRoll)
						or ((menuchoice = MENU_BANK) and canBank)
						or not gameOn;

					if menuchoice = MENU_BANK then begin
						bankPlayer;
						showPlayers;
						nextPlayer;
					end;

					if freeDices=%00111111 then freeDices:=0;
				end;
			until not gameOn;
			if keypressed then key:=Readkey;
		end;
	until quitGame;

	ClrScr;
	WritelnCentered('Thanks for playing ZILCH!');
    setIntVec(iDLI,oldDli);
    setIntVec(iVBL,oldVbli);
    PMG_gractl:=0;
    PMG_sdmctl_S:=0;
	chbas:=$e0;
    nmien:=64;
end.
