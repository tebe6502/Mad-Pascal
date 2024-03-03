program api_tests;
uses neo6502, neo6502math, graph, crt;
const 
    TILE_MAP_ADDRESS = $A000;
{$r resources.rc}

var b,c: byte;
    i,j,y,w,h: byte;
    dx:shortInt;
    by,dy:float;
    xacc:shortInt;
    x: word;
    k: char;
    s: TString;
    char1: array [0..6] of byte = 
    (
        %00111100,
        %01000000, 
        %10010000,
        %10000000,
        %10011100,
        %01000000,
        %00111100
    );
    char2: array [0..6] of byte = 
    (
        %11100000,
        %00010000,
        %01001000,
        %00001000,
        %11001000,
        %00010000,
        %11100000
    );
    tmap:TTileMapHeader absolute TILE_MAP_ADDRESS;

procedure WaitForAnyKeyAndClear;
begin
    Writeln;
    Writeln('Press any key to continue.');
    ReadKey;
    ClrScr;
end;

procedure DrawBall(x,y,f:byte);
    begin
        f:=(f shl 2)+64;
        NeoUpdateSprite(0,x,y,f+0,0,0);
        NeoUpdateSprite(1,x+32,y,f+1,0,0);
        NeoUpdateSprite(2,x,y+32,f+2,0,0);
        NeoUpdateSprite(3,x+32,y+32,f+3,0,0);
    end;

begin
    NeoSetDefaults(0,0,1,1,0);
    NeoLoad('neo_api.gfx',NEO_GFX_RAM);
    TextMode(0);
    Writeln('Hello Neo6502!');
    Writeln('Let''s try some API routines.');
    WaitForAnyKeyAndClear;

    Writeln('Group: 1 Function: 1');
    Writeln('System Timer: ',NeoGetTimer);
    WaitForAnyKeyAndClear;

    Writeln('Group: 1 Function: 4');
    Writeln('Credits: ');
    NeoCredits;
    WaitForAnyKeyAndClear;

    Writeln('Group: 2 Function: 5');
    Writeln('Define new font.');

    NeoSetChar(192,@char1);
    NeoSetChar(193,@char2);
    Writeln(#192#193#32#192#193#32#192#193#32);
    WaitForAnyKeyAndClear;

    Writeln('Group: 2 Function: 7');
    Writeln('Set Cursor Position.');
    GotoXY(5,5);
    Write('5,5');
    GotoXY(10,10);
    Write('10,10');
    GotoXY(15,15);
    Write('15,15');
    Writeln;
    WaitForAnyKeyAndClear;

(*  
    Writeln('Group: 2 Function: 8');
    Writeln('Display settings of function keys.');
    Writeln;
    
    NeoGetFunctionKeys;
    WaitForAnyKeyAndClear;
*)
  
    Writeln('Group: 7 Function: 1');
    Writeln('Controller test: ');
    Writeln;
    Writeln('Move Your controller or press Space to finish.');
    repeat 
        k:=#0;
        if keypressed then k:=ReadKey;
        b:=NeoGetJoy(1);
        s:='';
        if b and 1 <> 0 then s:=concat(s,'left ');
        if b and 2 <> 0 then s:=concat(s,'right ');
        if b and 4 <> 0 then s:=concat(s,'up ');
        if b and 8 <> 0 then s:=concat(s,'down ');
        if b and 16 <> 0 then s:=concat(s,'butA ');
        if b and 32 <> 0 then s:=concat(s,'butB ');
        Write(#20#19#4#4#4#4#4#4#4#4#4#4#4#4#4#4#4#4#4);
        Write(s,'                    ');
        Delay(3);
    until k=#32;
    ClrScr;

    Writeln('Group: 5');
    Writeln('Various graphics routines ');
    WaitForAnyKeyAndClear;
    Randomize;
    InitGraph(0);
    
    s := 'Neo6502';
    
    for j:=0 to 4 do
        begin
            for i:=0 to 50 do
                begin
                    x := NeoIntRandom(270)+10;
                    y := NeoIntRandom(200)+10;
                    w := NeoIntRandom(30)+20;
                    h := NeoIntRandom(30)+10;
                    c := NeoIntRandom(16);
                    //NeoSetColor(0,c,Random(2),1,0);
                    NeoSetColor(c);
                    NeoSetSolidFlag(NeoIntRandom(2));
                    case j of 
                        0: NeoDrawLine(x,y,x+w,y+h);
                        1: NeoDrawRect(x,y,x+w,y+h);
                        2: NeoDrawEllipse(x,y,x+w,y+h);
                        3: NeoDrawString(x,y,s);
                        4: NeoDrawImage(x,y,NeoIntRandom(4));
                    end;
                    Pause;
                end;
        end;
    WaitForAnyKeyAndClear;

    Writeln('Group: 5');
    Writeln('Tilemaps: ');
    Writeln;
    Writeln('Tilemap - width: ',tmap.width,' height: ',tmap.height);
    WaitForAnyKeyAndClear;

    ClrScr;

    x:=0;
    repeat
        y:=Trunc(sin(x*0.05)*20)+30;
        if x>320 then begin 
            NeoSelectTileMap(TILE_MAP_ADDRESS,x-320,0); 
            NeoWaitForVblank;
            ClrScr;
            NeoDrawTileMap(0,y,320,160+y);
        end else begin
            NeoSelectTileMap(TILE_MAP_ADDRESS,0,0); 
            NeoWaitForVblank;
            ClrScr;
            NeoDrawTileMap(320-x,y,320,160+y);
        end;
        inc(x,1);
        if x>980 then x:=0;
    until keypressed;
    WaitForAnyKeyAndClear;
 
    Writeln('Group: 6');
    Writeln('Sprites: ');

    b:=0;
    x:=100;
    by:=80;
    dy:=0;
    dx:=2;
    xacc:=1;
    repeat

        NeoWaitForVblank;
        NeoWaitForVblank;
        DrawBall(x,Round(by),b);

        dy:=dy+0.1;
        x := x + dx;
        by := by + dy;
        if (x>=250) or (x<=40) then dx:=-dx;
        if (by>170) and (dy>0) then dy:=-dy;
        b:=(b+1) and 3;

    until keypressed;
    WaitForAnyKeyAndClear;

    s := 'That''s all Folks';
    b := 0;
    c := 0;
    repeat
        TextColor((b+c) and $0f);
        Write(s[b+1]);
        Inc(b);
        if b=Length(s) then
            begin
                Delay(10);
                b := 0;
                Write(#20);
                Inc(c);
            end;
    until Keypressed;
    WaitForAnyKeyAndClear;

end.
