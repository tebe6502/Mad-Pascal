// U. S. Flag

program usflag1;

uses crt, graph;

const
//  Rst : byte =  0;

//  C3_ : byte =  1;
//  C3s : byte =  2;
//  D3_ : byte =  3;
//  D3s : byte =  4;
//  E3_ : byte =  5;
//  F3_ : byte =  6;
//  F3s : byte =  7;
//  G3_ : byte =  8;
//  G3s : byte =  9;
//  A3_ : byte = 10;
//  A3s : byte = 11;
//  B3_ : byte = 12;

    C4_ : byte = 13;
//  C4s : byte = 14;
//  D4_ : byte = 15;
//  D4s : byte = 16;
    E4_ : byte = 17;
//  F4_ : byte = 18;
    F4s : byte = 19;
    G4_ : byte = 20;
//  G4s : byte = 21;
    A4_ : byte = 22;
//  A4s : byte = 23;
    B4_ : byte = 24;

    C5_ : byte = 25;
//  C5s : byte = 26;
    D5_ : byte = 27;
//  D5s : byte = 28;
    E5_ : byte = 29;
    F5_ : byte = 30;
//  F5s : byte = 31;
    G5_ : byte = 32;
//  G5s : byte = 33;
//  A5_ : byte = 34;
//  A5s : byte = 35;
//  B5_ : byte = 36;

//  C6_ : byte = 37;
//  C6s : byte = 38;
//  D6_ : byte = 39;
//  D6s : byte = 40;
//  E6_ : byte = 41;
//  F6_ : byte = 42;
//  F6s : byte = 43;
//  G6_ : byte = 44;
//  G6s : byte = 45;
//  A6_ : byte = 46;
//  A6s : byte = 47;
//  B6_ : byte = 48;

//  N1  : byte =160; //            whole note
//  N2d : byte =120; // dotted      half note
    N2_ : byte = 80; //             half note
    N4d : byte = 60; // dotted   quarter note
    N4_ : byte = 40; //          quarter note (3/4 measure, so 2/3 of a second long)
//  N8d : byte = 30; // dotted    eighth note
    N8_ : byte = 20; //           eighth note
//  NGd : byte = 15; // dotted sixteenth note
//  NG_ : byte = 10; //        sixteenth note

//  The Star Spangled Banner in C Major spans from a low C4 to a high G5.

var
    Freq : array [0..48] of byte = (  0,
                                    243,230,217,204,193,182,172,162,153,144,136,128,
                                    121,114,108,102, 96, 91, 85, 81, 76, 72, 68, 64,
                                     60, 57, 53, 50, 47, 45, 42, 40, 37, 35, 33, 31,
                                     30, 28, 26, 25, 23, 22, 21, 19, 18, 17, 16, 15);

    NF : array[0..100] of byte = (G4_,E4_,C4_,E4_,G4_,C5_,E5_,D5_,C5_,E4_,F4s,G4_,G4_,G4_,
                                  E5_,D5_,C5_,B4_,A4_,B4_,C5_,C5_,G4_,E4_,C4_,G4_,E4_,
                                  C4_,E4_,G4_,C5_,E5_,D5_,C5_,E4_,F4s,G4_,G4_,G4_,
                                  E5_,D5_,C5_,B4_,A4_,B4_,C5_,C5_,G4_,E4_,C4_,E5_,E5_,
                                  E5_,F5_,G5_,G5_,F5_,E5_,D5_,E5_,F5_,F5_,F5_,
                                  E5_,D5_,C5_,B4_,A4_,B4_,C5_,E4_,F4s,G4_,G4_,
                                  C5_,C5_,C5_,B4_,A4_,A4_,A4_,D5_,F5_,E5_,D5_,C5_,C5_,B4_,G4_,G4_,
                                  C5_,D5_,E5_,F5_,G5_,C5_,D5_,E5_,F5_,D5_,C5_);

    ND : array[0..100] of byte = (N8_,N8_,N4_,N4_,N4_,N2_,N8_,N8_,N4_,N4_,N4_,N2_,N8_,N8_,
                                  N4d,N8_,N4_,N2_,N8_,N8_,N4_,N4_,N4_,N4_,N4_,N8_,N8_,
                                  N4_,N4_,N4_,N2_,N8_,N8_,N4_,N4_,N4_,N2_,N8_,N8_,
                                  N4d,N8_,N4_,N2_,N8_,N8_,N4_,N4_,N4_,N4_,N4_,N8_,N8_,
                                  N4_,N4_,N4_,N2_,N8_,N8_,N4_,N4_,N4_,N2_,N4_,
                                  N4d,N8_,N4_,N2_,N8_,N8_,N4_,N4_,N4_,N2_,N4_,
                                  N4_,N4_,N8_,N8_,N4_,N4_,N4_,N4_,N8_,N8_,N8_,N8_,N4_,N4_,N8_,N8_,
                                  N4d,N8_,N8_,N8_,N2_,N8_,N8_,N4d,N8_,N4_,N2_);

    red,white,blue,c: byte;
    i,j,k: shortint;
    x,y: smallint;

procedure SetPFColor(index: word; hue,shade: byte);
begin
    Poke(708+index,(hue*16)+shade);
end;

procedure Plot(px,py: smallint);
begin
    PutPixel(px,py);
    MoveTo(px,py);
end;

procedure DrawTo(dx,dy: smallint);
begin
    LineTo(dx,dy);
    MoveTo(dx,dy);
end;

procedure GoSub_1000;
begin
    {
        1000 REM DRAW 1 STAR CENTERED AT X,Y
        1010 PLOT X-1,Y:DRAWTO X+1,Y
        1020 PLOT X,Y-1:DRAWTO X,Y+1
        1030 RETURN
    }

    // Draw 1 star centered at x,y
    Plot(x-1,y);Drawto(x+1,y);
    Plot(x,y-1);Drawto(x,y+1);
end;

begin
    // Here is the BASIC listing from the 130XE user manual:

    {
        10 REM DRAW THE UNITED STATES FLAG
        20 REM HIGH RESOLUTION GRAPHICS
        25 REM 4 COLORS, NO TEXT WINDOW
        30 GRAPHICS 7+16
        40 REM SETCOLOR 0 CORRESPONDS
        41 REM TO COLOR 1
        50 SETCOLOR 0,4,4:RED=1
        60 REM SETCOLOR 1 CORRESPONDS
        61 REM TO COLOR 2
        70 SETCOLOR 1,0,14:WHITE=2
        80 REM SETCOLOR 2 CORRESPONDS
        81 REM TO COLOR 3
        90 BLUE=3:REM DEFAULTS TO BLUE
        100 REM DRAW 13 RED AND WHITE STRIPES
        110 C=RED
        120 FOR I=0 TO 12
        130 COLOR C
        140 REM EACH STRIPE HAS SEVERAL
        141 REM HORIZONTAL LINES
        150 FOR J=0 TO 6
        160 PLOT 0,I*7+J
        170 DRAWTO 159,I*7+J
        180 NEXT J
        190 REM SWITCH COLORS
        200 C=C+1:IF C>WHITE THEN C+RED
        210 NEXT I
        300 REM DRAW BLUE RECTANGLE
        310 COLOR BLUE
        320 FOR I=0 TO 48
        330 PLOT 0,I
        340 DRAWTO 79,I
        350 NEXT I
        360 REM DRAW 9 ROWS OF WHITE STARS
        370 COLOR WHITE
        380 K=0:REM START WITH ROW OF 6 STARS
        390 FOR I=0 TO 8
        395 Y=4+I*5
        400 FOR J=0 to 4:REM 5 STARS IN A ROW
        410 X=K+5+J*14:GOSUB 1000
        420 NEXT J
        430 IF K<>0 THEN K=0:GOTO 470
        440 REM ADD 6TH STAR EVERY OTHER LINE
        450 X=5+5*14:GOSUB 1000
        460 K=7
        470 NEXT I
        500 REM IF KEY HIT THEN STOP
        510 IF PEEK(764)=255 THEN 510
        515 REM OPEN TEXT WINDOW WITHOUT
        516 REM CLEARING SCREEN
        520 GRAPHICS 7+32
        525 REM CHANGE COLORS BACK
        530 SETCOLOR 0,4,4:SETCOLOR 1,0,14
        550 STOP
    }

    { Here is the equivalent Pascal listing: }

    // Draw the United States flag
    // High resolution graphics
    // 4 colors, no text window
    InitGraph(7+16);
    // SetPFColor 0 corresponds
    // to color 1
    SetPFColor(0,4,4);red:=1;
    // SetPFColor 1 corresponds
    // to color 2
    SetPFColor(1,0,14);white:=2;
    // SetPFColor 2 corresponds
    // to color 3
    blue:=3;// Defaults to blue
    // Draw 13 red and white stripes
    c:=red;
    for i:=0 to 12 do begin
    SetColor(c);
    // Each stripe has several
    // horizontal lines
    for j:=0 to 6 do begin
    Plot(0,(i*7)+j);
    Drawto(159,(i*7)+j);
    end;
    // Switch colors
    c:=c+1;if c>white then c:=red;
    end;
    // Draw blue rectangle
    SetColor(blue);
    for i:=0 to 48 do begin
    Plot(0,i);
    DrawTo(79,i);
    end;
    // Draw 9 rows of white stars
    SetColor(white);
    k:=0;// Start with row of 6 stars
    for i:=0 to 8 do begin
    y:=4+(i*5);
    for j:=0 to 4 do begin // 5 stars in a row
    x:=k+5+(j*14);GoSub_1000;
    end;
    if k<>0 then k:=0 else begin
    // Add 6th star every other line
    x:=5+(5*14);GoSub_1000;
    k:=7;
    end;
    end;

    { -------------------------------------------------------------------- }

    { The manual suggested adding "The Star Spangled Banner" }

    {
        475 FOR I=0 TO 100
        481 J=NF(I)
        482 K=FREQ(J)
        483 SOUND(0,K,14,8)
        484 POKE 20,0
        485 IF PEEK(20)<ND(I) THEN 485
        490 NEXT I
        495 SOUND(0,0,0,0)
    }

    for i:=0 to 100 do begin
    j:=NF[i];
    k:=Freq[j];
    Sound(0,k,14,8);
    Poke(20,0);
    while Peek(20)<ND[i] do;
    end;
    Sound(0,0,0,0);

    { -------------------------------------------------------------------- }

    // If key hit then stop
    while Peek(764)=255 do;
    // Open text window without
    // clearing screen
    InitGraph(7+32);
    // Change color back
    SetPFColor(0,4,4);SetPFColor(1,0,14);
end.
