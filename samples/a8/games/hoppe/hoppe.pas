program hoppe;
{$librarypath 'blibs'}
uses atari, crt, b_pmg, joystick;

const
{$i const.inc}
{$r resources.rc}
{$i dlist.inc}
{$i sprites.inc}

var
    planesSpeeds: array [0..4] of byte = ( 1, PLANE_1_SPEED, PLANE_2_SPEED, PLANE_3_SPEED, 1);
    planesLengths: array [0..4] of byte = ( 1, 5, 5, 1, 1);
    planesStarts: array [0..4] of byte = (PLANE_0_START, PLANE_1_START, PLANE_2_START, PLANE_3_START, PLANE_4_START);
    planesX: array [0..4] of shortInt;
    planesH: array [0..4] of byte;
    planesC: array [0..4] of byte;
    plane:byte;

var frame:byte;
    y:byte;
    sy:smallInt=0;
    cy:byte;
    bottom:byte;
    fly:boolean;
    jump:boolean;
    gameover:boolean;
    countscore:boolean;
    jumpforce:byte = 0;
    line,x,b:byte;
    count:byte;
    vram:word;
    wallPosX: array [0..3] of byte;
    wallWait: array [0..3] of byte;
    bonusX,bonusW:byte;
    score:cardinal=0;
    hiscore:cardinal=0;
    energy:byte;
    lastWall:byte;
    difficulty:byte;
    fxvol, fxfreq:byte;
    damagecount:byte;
    rnd: byte absolute ($D20A);

procedure putCloud(cloud:pointer);
begin
    repeat
        move(cloud, pointer(vram + rnd and %00011101), 10);
        dec(count)
    until count = 0;
end;

procedure drawbackground;
var sh,lh:byte;
begin
    //fences
    count := 0;
    vram := GFX_RAM + (SCREENLINEWIDTH * 18);
    repeat
        move(tile_fence[0], pointer(vram + count), 4);
        move(tile_fence[4], pointer(vram + SCREENLINEWIDTH + count), 4);
        count := count+4;
    until count >= SCREENLINEWIDTH;
    //water
    for line := 0 to 5 do begin
        count := 0;
        repeat
            vram := GFX_RAM + (SCREENLINEWIDTH * (line + 9)) + Random(SCREENLINEWIDTH - 48) ;
            poke(vram, $4F + (count and %11));
            Inc(count);
        until count > 15 - (line * 3);
    end;
    // boat
    vram:=GFX_RAM + (SCREENLINEWIDTH * 15);
    move(boat[0], pointer(vram), 3);
    move(boat[3], pointer(vram + SCREENLINEWIDTH - 1), 5);
    //houses
    lh:=0;
    vram := GFX_RAM + SCREENLINEWIDTH * 8;
    for x := 0 to SCREENLINEWIDTH - 1 do begin
        b := $59;
        if x and %111 = 0 then b:=$60;
        poke(vram + x, b);
        poke(vram + x - SCREENLINEWIDTH, $56);
    end;
    for x:=0 to (SCREENLINEWIDTH div 2) - 2 do begin
        vram := GFX_RAM + SCREENLINEWIDTH * 6 + x;
        line := Random(3) + 1;
        sh := line;
        repeat
            poke(vram, $53 + rnd and %11);
            poke(vram + 1, $5b);
            dec(line);
            dec(vram, SCREENLINEWIDTH);
        until line = 0;
        // put roof
        if sh >= lh then begin
            poke(vram, $57 + rnd and %1);
            poke(vram+1, $5a);
        end;
        lh := sh;
    end;
    //clouds
    vram := GFX_RAM;
    count := 5;
    putCloud(@cloud1);
    vram := GFX_RAM + SCREENLINEWIDTH;
    count := 2;
    putCloud(@cloud2);

    vram := GFX_RAM ;
    for line := 0 to 16 do begin
        move(pointer(vram), pointer(vram + SCREENLINEWIDTH - 48), 48);
        inc(vram, SCREENLINEWIDTH);
    end;
end;

procedure moveplane;
var p, planeOffset: byte;
    planeStart: word;
begin
    inc(planesX[plane], 2);
    if plane = 4 then dec(planesX[plane], 4);
    if planesX[plane] <= 0 then planesX[plane] := 48 + planesX[plane];
    if planesX[plane] >= SCREENLINEWIDTH - 48 then planesX[plane] := 0;
    planeStart := GFX_RAM + planesX[plane] + SCREENLINEWIDTH * planesStarts[plane];
    planeOffset := DL_OFFSET + (3 * planesStarts[plane]);
    for p := 0 to planesLengths[plane] do begin
        DPoke(DL_MEM + PlaneOffset, PlaneStart);
        inc(planeOffset, 3);
        inc(planeStart, SCREENLINEWIDTH);
    end;
end;

procedure setWallH(wall, height:byte);
var y, mask: byte;
begin
    mask := %11 shl (wall * 2);
    for y:=0 to MAX_WALL_H do begin
        vram := PMGBASE + 768 + ROAD_LVL - y;
        if y < height then poke(vram,peek(vram) or mask)
        else poke(vram, peek(vram) and not mask)
    end;
end;

procedure moveplanes;
begin
    for plane := 0 to 3 do begin
        inc(planesC[plane]);
        if planesC[plane] = planesSpeeds[plane] then begin
            planesC[plane] := 0;
            dec(planesH[plane]);
            planesH[plane] := planesH[plane] and 7;
            if planesH[plane] = 7 then moveplane;

        end;
    end;
    inc(planesH[4]);
    planesH[4] := planesH[4] and 7;
    if planesH[4] = 0 then begin
        plane := 4;
        moveplane;
    end;

    // move walls
    for plane := 0 to 3 do
        if wallWait[plane] = 0 then begin
            dec(wallPosX[plane]);
            if (wallPosX[plane] = 0) and not gameover then begin
                wallPosX[plane] := 255;
                wallWait[plane] := lastWall + 9 + Random(byte(12 + difficulty));
                lastWall := wallWait[plane];
                setWallH(plane, (Random(3) + 1) * 24);
                if plane=3 then bonusW:=rnd and %00000111;
            end;
        end else dec(wallWait[plane]);

    move(wallPosX, @PMG_hposm0, 4);
    if lastWall > 0 then dec(lastWall);

    //splash water
    poke(GFX_RAM + (SCREENLINEWIDTH*16) + 47, (peek(20) and 1) * $49);

    //animate bonus
    plane := (peek(20) shr 3) and %11;
    move(b0frames[plane], pointer(PMGBASE + 1024 + 512 + BONUS_LVL), 12);
    move(b1frames[plane], pointer(PMGBASE + 1024 + 768 + BONUS_LVL), 12);

    //move bonus
    bonusX := 0;
    if bonusW < 4 then bonusX := wallPosX[bonusW];
    PMG_hpos2 := bonusX;
    PMG_hpos3 := bonusX;

end;

procedure showEnergy;
begin
    FillByte(pointer(TXT_RAM + 52), energy shr 1, $4e);
end;

procedure showHiscore; assembler;
asm {
        txa
        pha
        ldy #43
        jsr printScore
        pla
        tax
    };
end;

begin
    // init planes
    FillByte(@planesX, 5, 0);
    FillByte(@planesH, 5, 7);
    FillByte(@planesC, 5, 0);
    // clear vram
    FillByte(pointer(TXT_RAM), $2400, 0);
    // mixup charsets
    move(pointer($e000), pointer($8000), 1024);
    move(pointer($8400), pointer($8200), 33*8);
    chbas:=$80;

    // set display list
    Pause;
    SDLSTL := DL_MEM;
    SetIntVec(iDLI, @dli);
    nmien := $c0;

    // init pmg
    PMG_Init(Hi(PMGBASE),PMG_sdmctl_DMA_both or PMG_sdmctl_oneline or PMG_sdmctl_screen_wide or PMG_sdmctl_DMA_both);

    PMG_pcolr0_S := $24;
    PMG_pcolr1_S := $1a;
    PMG_pcolr2_S := $e6;
    PMG_pcolr3_S := $ea;

    PMG_hpos0 := 60;
    PMG_hpos1 := 60;

    PMG_gprior_S := 1 + PMG_5player + PMG_overlap;
    PMG_sizem := $ff;

    // show title
    move(pointer(STRINGS), pointer(TXT_RAM+4), 40);

    drawbackground;

    poke($d20f,3);
    poke($d208,0);

    repeat

        // show press fire
        move(pointer(STRINGS + 74),pointer(TXT_RAM + 62), 19);
        // clear player1
        fillbyte(pointer(PMGBASE + 1024), 512, 0);
        gameover:=true;
        bonusW:=10;

        repeat
            pause;
            moveplanes;
        until strig0 = 0;

        if score>=hiscore then begin
            hiscore:=score;
            showHiscore
        end;
        // show score bar
        move(pointer(STRINGS + 40), pointer(TXT_RAM+4), 34);
        //showHiscore;

        FillByte(@wallPosX, 4, 1);
        FillByte(@wallWait, 4, 100);
        bonusX:=1;     //            -- might be unnecesary
        moveplanes;

        lastWall := 0;
        score := 0;
        difficulty := 0;
        cy := 0;
        energy := 80;
        y := 32;
        fly := true;
        jump := false;
        sy := 1;
        gameover := false;
        countscore := false;
        bottom := BOTTOM_LVL;
        damagecount:=0;

        fxvol := $28;
        fxfreq := 0;

        showEnergy;

        repeat

            if damagecount=0 then begin
                frame:=(peek(20) shr 2) and %11;
                if fly then frame := 4;
            end else dec(damagecount);

            // check collision

            // with walls
            if ((PMG_sizep0 or PMG_sizep1 or PMG_sizep2 or PMG_sizep3) <> 0) and (energy > 0) then begin
                fxvol := $64;
                fxfreq := rnd and %00001111;
                dec(energy);
                poke(TXT_RAM + 52 + (energy shr 1), 0);
                frame := 5;
                damagecount := 10;
                if energy=0 then begin
                    bottom := 240;
                    countscore := false;
                    if sy<1 then sy:=1;
                    fxvol := $ca;
                    fxfreq := 255;
                    fly := true;
                end;
            end;

            // with bonus
            if (PMG_p2pl or PMG_p3pl) and 3 <> 0 then begin
                fxvol := $28;
                fxfreq := 0;
                bonusW := 10;
                bonusX := 0;
                energy := energy + 10;
                if energy > 80 then begin
                    energy := 80;
                    asm {
                      lda #250
                      sta count
                      jsr addScore
                    };
                end;
                showEnergy;
            end;


            PMG_hitclr:=$ff;
            atract:=0;

            // draw player
            fillbyte(pointer(PMGBASE + 1024 - 4 + y), 38, 0);
            move(p0frames[frame], pointer(PMGBASE + 1024 + y), 29);

            fillbyte(pointer(PMGBASE + 1024 + 256 - 4 + y), 38, 0);
            move(p1frames[frame], pointer(PMGBASE + 256 + 1024 + y), 29);

            // count planes
            moveplanes;

            if not fly then begin
                // fire pressed on ground
                if (strig0 = 0) then begin
                    if not jump then begin
                        jump := true;
                        jumpforce := MIN_JUMP_FORCE;
                    end;
                    // fire kept on ground - increase jump force
                    if jump and (jumpforce < MAX_JUMP_FORCE) then inc(jumpforce, 3);
                end;

                // fire released on ground - jump!
                if jump and (strig0 = 1) then begin
                    countscore := true;
                    jump := false;
                    fly := true;
                    sy := -jumpforce;
                    fxvol := $aa;
                end;
            end;

            // add and display score
            if fly and countscore then begin
                asm {
                  lda #1
                  sta count
                  jsr addScore
                };
                difficulty := peek(word(@score)+1) shr 4;
                //poke(TXT_RAM+20,difficulty+48);
            end;

            // calculate player's vertical movement
            if sy > 0 then begin  // fall
                cy := cy + sy;
                y := y + cy shr 5;
                if (y >= bottom) then begin // reached ground
                    sy := 0;
                    cy := 0;
                    fly := false;
                    y := bottom;
                    if bottom > BOTTOM_LVL then gameover := true;
                end;
            end;

            if sy < 0 then begin // jump up
                cy := cy - sy;
                y := y - cy shr 5;
                if sy = 0 then sy := 1; // reached top = start falling
                if fxfreq > 16 then fxfreq := y + 40;
            end;

            if not fly and (y = BOTTOM_LVL) and (damagecount = 0) then begin
                fxvol:= $80 or (peek(20) and 4);
                fxfreq := 120 + (frame shl 4);
            end;

            cy := cy and %11111;
            inc(sy);

            // play sfx
            poke($D206,fxfreq);
            poke($D207,fxvol);
            if (fxvol and 15 <> 0) and (peek(20) and %10 <> 0) then dec(fxvol);

            Pause;

        until gameover;
        poke($D207,0);
    until false;
end.
