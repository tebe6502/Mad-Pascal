program pong;
uses atari, crt, math, joystick, b_pmg, b_dl;

const
    NONE = $ff;
    PAD1X = 48;
    PAD2X = 204;
    WINSCORE = 15;
    BOUNDTOP = 30;
    BOUNDBOT = 224;
    PADDLEMODE = 1;
    JOYMODE = 2;
    BALLHEIGHT = 5;
    PADDLEHEIGHT = 28;
    PADDLEHALF = PADDLEHEIGHT div 2;
    DOTLINESIZE = BOUNDBOT;
    BALLSPEED = 2;

    VRAMBASE = $7800; // RAM locations
    DLBASE = $7F00;
    PMGBASE = $8000;

{$i assets.inc}

var
    i: byte;
    pad1y, pad2y: byte;
    ballx, bally: byte;
    pbally, ppad1y, ppad2y: byte;
    ballsx, ballsy: smallInt;
    balldy, cpudy: byte;
    score1, score2: byte;
    controlMode, playersNum: byte;
    dotline: array [0..DOTLINESIZE-1] of byte;

procedure ShowBall;
var y:byte;
begin
    for y:=pbally to pbally + BALLHEIGHT do poke(PMGBASE+768+y,dotline[y]);
    for y:=bally to bally + BALLHEIGHT do poke(PMGBASE+768+y,dotline[y] or 3);
    PMG_hposm0:=ballx;
end;

procedure ShowPaddles;
var y:byte;
begin
    for y := ppad1y to ppad1y + PADDLEHEIGHT do poke(PMGBASE+1024+y,0);
    for y := pad1y to pad1y + PADDLEHEIGHT do poke(PMGBASE+1024+y,3);
    for y := ppad2y to ppad2y + PADDLEHEIGHT do poke(PMGBASE+1024+256+y,0);
    for y := pad2y to pad2y + PADDLEHEIGHT do poke(PMGBASE+1024+256+y,3);
end;

procedure HidePaddles;
begin
    PMG_hpos0 := 0;
    PMG_hpos1 := 0;
end;

procedure ShowScores;
begin
    move(digits[score1], pointer(PMGBASE + 1024 + 512 + 40), 25);
    move(digits[score2], pointer(PMGBASE + 1024 + 768 + 40), 25);
end;

procedure SetGameMode(mode,players:byte);
begin
    controlMode := mode;
    playersNum := players;
end;

procedure Serve(x:byte; sx:smallInt);
begin
    ballx := x;
    ballsx := sx;
    ballsy := 6 - random(13);
    bally := RandomRange(BOUNDTOP, BOUNDBOT);
    sound(0,128,$c,$8);
    pause(10);
    sound(0,0,0,0);
end;

procedure PaddleBounce(pady:byte);
begin
    ballsy := bally - (pady + PADDLEHALF);
    ballsx := -ballsx;
    sound(0,64,$a,$f);
end;

procedure WallBounce;
begin
    ballsy := -ballsy;
    sound(0,64,$a,$f);
end;

procedure ShowTitle;
begin
    GotoXY(1,1);
    lmargin := 0;
    Writeln('Just Pong!');
    Writeln;
    Writeln('bocianu');
    Writeln('2018');
    lmargin := 22;
    GotoXY(23,15);
    Writeln('Press ','FIRE'*);
    Write('in joy or paddle 1');
    Writeln('for 1 player game');
    Writeln;
    Writeln;
    Writeln('Press ','FIRE'*);
    Write('in joy or paddle 2');
    Writeln('for 2 players game');

    repeat until (strig0 = 1) and  (strig1 = 1) and (ptrig0 = 1) and (ptrig1 = 1);
    controlMode := NONE;
    repeat
        atract := 11;  // disable attract mode
        if strig0 = 0 then SetGameMode(JOYMODE, 1);
        if strig1 = 0 then SetGameMode(JOYMODE, 2);
        if ptrig0 = 0 then SetGameMode(PADDLEMODE, 1);
        if ptrig1 = 0 then SetGameMode(PADDLEMODE, 2);
    until controlMode <> NONE;
end;

procedure ClearVram;
begin
    FillByte(pointer(VRAMBASE), 1040, 0);
end;

procedure Dli;assembler;interrupt;
// DLI draws white horizontal bars on top and bottom
asm {
    pha
    lda #15
    :2 sta wsync
    sta $d018
    lda #0
    :5 sta wsync
    sta $d018
    pla
};
end;

procedure MakeDL;
begin
    ClearVram;
    DL_Init(DLBASE);
    DL_Push(DL_BLANK8,1);
    DL_Push(DL_BLANK8 + DL_DLI);
    DL_Push(DL_MODE_40x24T2 + DL_LMS, VRAMBASE);
    DL_Push(DL_MODE_40x24T2 , 23);
    DL_Push(DL_MODE_40x24T2 + DL_DLI);
    DL_Push(DL_MODE_40x24T2);
    DL_Push(DL_BLANK8 + DL_JVB, DLBASE);
    DL_Start;
    savmsc := VRAMBASE + 80; // set VRAM origin
    SetIntVec(iDLI, @Dli);
    nmien := %11000000; // start DLi
    TextBackground(0);
    TextColor(10);
end;

procedure PreparePMG;
begin
    PMG_Init(Hi(PMGBASE), PMG_sdmctl_oneline + PMG_sdmctl_default);
    PMG_Clear;

    // draw vertical dotted line
    for i := 0 to 255 do dotline[i] := 0;
    for i := BOUNDTOP to DOTLINESIZE do begin
        if i mod 10 < 5 then dotline[i] := 0
        else dotline[i] := %1100;
    end;
    move(dotline, pointer(PMGBASE + 768), DOTLINESIZE);

    PMG_pcolr0_S := 15;
    PMG_pcolr1_S := 15;
    PMG_pcolr2_S := 15;
    PMG_pcolr3_S := 15;

    PMG_sizep0 := 1;
    PMG_sizep1 := 1;
    PMG_sizep2 := 1;
    PMG_sizep3 := 1;
    PMG_sizem := %01010101;

    PMG_hposm1 :=126; // dotted line
    PMG_hpos2 :=104;  // left score
    PMG_hpos3 :=130;  // right score
end;

procedure InitGame;
begin
    pad1y := 120;
    pad2y := 120;
    bally := 120;
    ballsx := BALLSPEED;
    if random(2) = 0 then ballsx := -BALLSPEED;
    if ballsx > 0 then ballx := PAD1X
        else ballx := PAD2X;
    ballsy := 6 - random(13);
    score1 := 0;
    score2 := 0;
    PMG_hpos0 := PAD1X - 12; // left paddle
    PMG_hpos1 := PAD2X - 12 ; // right paddle
end;

(************************** MAIN *****************************)

begin
    Randomize;
    CursorOff;
    MakeDL;
    PreparePMG;

    repeat
        HidePaddles;
        ShowTitle;
        ClearVram;
        InitGame;
        ShowScores;

        // main game loop
        repeat
            atract := 11;   // disable attract mode
            sound(0,0,0,0); // mute
            
            // move paddle1
            if controlMode = JOYMODE then begin
                if (stick0 = joy_down) then begin
                    if (pad1y < BOUNDBOT - PADDLEHEIGHT + 4) then inc(pad1y, 2);
                end;
                if (stick0 = joy_up) then begin
                    if (pad1y > BOUNDTOP - 4) then dec(pad1y, 2);
                end;
            end else begin // paddle mode
                pad1y := paddl0;
                if (pad1y > BOUNDBOT - PADDLEHEIGHT + 4) then pad1y := BOUNDBOT - PADDLEHEIGHT + 4;
                if (pad1y < BOUNDTOP - 4) then pad1y := BOUNDTOP - 4;
            end;

            // move paddle2
            if playersNum = 2 then begin                // human player
                if controlMode = JOYMODE then begin
                    if (stick1 = joy_down) then begin
                        if (pad2y < BOUNDBOT - PADDLEHEIGHT + 4) then inc(pad2y, 2);
                    end;
                    if (stick1 = joy_up) then begin
                        if (pad2y > BOUNDTOP - 4) then dec(pad2y, 2);
                    end;
                end else begin // paddle mode
                    pad2y := paddl1;
                    if (pad2y > BOUNDBOT - PADDLEHEIGHT + 4) then pad2y := BOUNDBOT - PADDLEHEIGHT + 4;
                    if (pad2y < BOUNDTOP - 4) then pad2y := BOUNDTOP - 4;
                end;
            end else begin                              // cpu player
                cpudy := 1;
                if (ballsx > 0) and (Abs(pad2y + PADDLEHALF - bally) > 20) then cpudy := 2;
                if pad2y + PADDLEHALF > bally then
                    if (pad2y > BOUNDTOP - 4) then dec(pad2y, cpudy);
                if pad2y + PADDLEHALF < bally then
                    if (pad2y < BOUNDBOT - PADDLEHEIGHT + 4) then inc(pad2y, cpudy);
            end;


            // move ball;
            ballx := ballx + ballsx; // move ball horizontaly
            balldy := balldy + abs(ballsy); // count ball vertical increment

            if ballsy > 0 then begin // if ball moves down
                bally := bally + (balldy shr 3);
                // check bottom bounce
                if bally >= BOUNDBOT - BALLHEIGHT then WallBounce;
            end else

            if ballsy < 0 then begin // if ball moves up
                bally := bally - (balldy shr 3);
                // check top bounce
                if bally <= BOUNDTOP then WallBounce;
            end;

            balldy:=balldy and %111; // clear moved bits

            // check paddle collision - left
            if (ballx <= PAD1X + 3) and (ballx > PAD1X) and (ballsx < 0) and (bally > pad1y-BALLHEIGHT) and (bally < pad1y+PADDLEHEIGHT) then PaddleBounce(pad1y);
            // check paddle collision - right
            if (ballx >= PAD2X - 3) and (ballx < PAD2X)  and (ballsx > 0) and (bally > pad2y-BALLHEIGHT) and (bally < pad2y+PADDLEHEIGHT) then PaddleBounce(pad2y);

            // check ball out on left edge
            if (ballx < PAD1X - 4) and (ballsx < 0) then begin
                Inc(score2);
                ShowScores;
                Serve(PAD2X+24, -BALLSPEED)
            end;
            // check ball out on right edge
            if (ballx > PAD2X+8)  and (ballsx > 0) then begin
                Inc(score1);
                ShowScores;
                Serve(PAD1X-24, BALLSPEED);
            end;

            Pause;
            ShowBall;
            ShowPaddles;

            ppad1y := pad1y; // remember previous positions
            ppad2y := pad2y;
            pbally := bally;

        until (score1 = WINSCORE) or (score2 = WINSCORE);
    until false;
end.
