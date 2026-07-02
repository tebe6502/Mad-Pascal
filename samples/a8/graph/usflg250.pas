// U. S. Flag



program usflg250;



uses crt, graph;



const
    Rst : byte =  0;

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

    Freq08bit : array [0..48] of byte = (
                                            0,
                                          243, 230, 217, 204, 193, 182, 172, 162, 153, 144, 136, 128,
                                          121, 114, 108, 102,  96,  91,  85,  81,  76,  72,  68,  64,
                                           60,  57,  53,  50,  47,  45,  42,  40,  37,  35,  33,  31,
                                           30,  28,  26,  25,  23,  22,  21,  19,  18,  17,  16,  15
                                        );

    Freq16bit : array [0..48] of word = (
                                            0,
                                         6834,6450,6088,5746,5423,5118,4830,4559,4303,4061,3832,3617,
                                         3414,3222,3040,2869,2708,2555,2412,2276,2148,2027,1913,1805,
                                         1703,1607,1517,1431,1350,1274,1202,1134,1070,1010, 953, 899,
                                          848, 800, 755, 712, 672, 634, 598, 564, 532, 501, 473, 446
                                        );

    NF : array[0..100] of byte = (
                                     G4_,E4_,C4_,E4_,G4_,C5_,E5_,D5_,C5_,E4_,F4s,G4_,G4_,G4_,
                                     E5_,D5_,C5_,B4_,A4_,B4_,C5_,C5_,G4_,E4_,C4_,G4_,E4_,
                                     C4_,E4_,G4_,C5_,E5_,D5_,C5_,E4_,F4s,G4_,G4_,G4_,
                                     E5_,D5_,C5_,B4_,A4_,B4_,C5_,C5_,G4_,E4_,C4_,E5_,E5_,
                                     E5_,F5_,G5_,G5_,F5_,E5_,D5_,E5_,F5_,F5_,F5_,
                                     E5_,D5_,C5_,B4_,A4_,B4_,C5_,E4_,F4s,G4_,G4_,
                                     C5_,C5_,C5_,B4_,A4_,A4_,A4_,D5_,F5_,E5_,D5_,C5_,C5_,B4_,G4_,G4_,
                                     C5_,D5_,E5_,F5_,G5_,C5_,D5_,E5_,F5_,D5_,C5_
                                 );

    ND : array[0..100] of byte = (
                                     N8_,N8_,N4_,N4_,N4_,N2_,N8_,N8_,N4_,N4_,N4_,N2_,N8_,N8_,
                                     N4d,N8_,N4_,N2_,N8_,N8_,N4_,N4_,N4_,N4_,N4_,N8_,N8_,
                                     N4_,N4_,N4_,N2_,N8_,N8_,N4_,N4_,N4_,N2_,N8_,N8_,
                                     N4d,N8_,N4_,N2_,N8_,N8_,N4_,N4_,N4_,N4_,N4_,N8_,N8_,
                                     N4_,N4_,N4_,N2_,N8_,N8_,N4_,N4_,N4_,N2_,N4_,
                                     N4d,N8_,N4_,N2_,N8_,N8_,N4_,N4_,N4_,N2_,N4_,
                                     N4_,N4_,N8_,N8_,N4_,N4_,N4_,N4_,N8_,N8_,N8_,N8_,N4_,N4_,N8_,N8_,
                                     N4d,N8_,N8_,N8_,N2_,N8_,N8_,N4d,N8_,N4_,N2_
                                 );

//  The Star Spangled Banner in C Major spans from a low C4 to a high G5.



procedure NextJiffy;

const
    RTCLOK: word = $0014;

var r: byte;

begin
    r:=Peek(RTCLOK);
    while r=Peek(RTCLOK) do;
end;



procedure PlaySong;

const
    AUDF1 : word = $D200;
    AUDC1 : word = $D201;
    AUDF2 : word = $D202;
    AUDC2 : word = $D203;
    AUDF3 : word = $D204;
    AUDC3 : word = $D205;
    AUDF4 : word = $D206;
    AUDC4 : word = $D207;
    AUDCTL: word = $D208;
    SKCTL : word = $D20F;

    Dist1 : byte = %11100000; // pure tone
    Dist2 : byte = Dist1;
    Dist3 : byte = %11100000;
    Dist4 : byte = %11100000;

var d, dm, f, flb, fub, i, v: byte;

begin
    v:=3; // volume

    Poke(AUDCTL,%00000000);
    Poke(SKCTL, %00000011);
    Poke(AUDCTL,%01010000); // pair channels 1 and 2, set clock to 1.79 MHz
    Poke(AUDC1, Dist1);
    Poke(AUDC2, Dist2);
    Poke(AUDC3, Dist3);
    Poke(AUDC4, Dist4);

    NextJiffy;

    for i:=0 to High(ND) do
    begin
        f:=NF[i];
        d:=ND[i];

        dm:=d div 10;
        if i=High(ND) then dm:=d div 15;

        if f<>Rst then
        begin
            fub:=Freq16bit[f] shr 8;
            flb:=Freq16bit[f] and %0000000011111111;

            Poke(AUDC2,Dist2);
            Poke(AUDC3,Dist3);
            Poke(AUDC4,Dist4);
            Poke(AUDF1,flb);
            Poke(AUDF2,fub);
            Poke(AUDF3,Freq08bit[f]-1);
            Poke(AUDF4,Freq08bit[f]+1);

            v:=0;

            repeat
                Inc(v,3);
                Poke(AUDC2,Dist2+v);
                Poke(AUDC3,Dist3+v);
                Poke(AUDC4,Dist4+v);
                NextJiffy;
                Dec(d);
            until v=15;
        end;

        while d>0 do
        begin
            if (d mod dm)=0 then
            begin
                if v>0 then Dec(v);
                Poke(AUDC2,Dist2+v);
                Poke(AUDC3,Dist3+v);
                Poke(AUDC4,Dist4+v);
            end;

            NextJiffy;
            Dec(d);
        end;
    end;

    NoSound;
end;



procedure DrawStar(const x, y: smallint);
begin
    Line(x-2,y,x+2,y);
    Line(x,y-3,x,y+2);
    Line(x-1,y,x-1,y+4);
    Line(x+1,y,x+1,y+4);
end;



procedure DrawFlag;

const
    bpl    : byte = 40;     // bytes per line
    sh     : byte = 12;     // stripe height
    SDMCTL : word = $022F;  // DMA enable
    SAVMSC : word = $0058;  // location points to start of screen data
    oavmsc : word = bpl*18; // offset to add to address SAVMSC returns

var sd, bps: word;
    i, j, k: shortint;
    x, y: smallint;

begin
    InitGraph($1F); // 160x192, 4 colors, no text window

    Poke(SDMCTL,$00);   // turn screen off

    Poke(708,$44);  // red
    Poke(709,$0E);  // white
    Poke(710,$92);  // blue

    sd:=DPeek(SAVMSC)+oavmsc;
    bps:=bpl*sh;    // bytes per stripe


    // draw the stripes

    for i:=1 to 13 do
    begin
        if Odd(i)
        then
            FillChar(pointer(sd),bps,%01010101)
        else
            FillChar(pointer(sd),bps,%10101010);

        Inc(sd,bps);
    end;

    sd:=DPeek(SAVMSC)+oavmsc;


    // draw the blue area

    for i:=1 to (7*sh) do
    begin
        FillChar(pointer(sd),16,%11111111);
        Inc(sd,bpl);
    end;


    // draw the stars

    SetColor(2);
    k:=0;

    for i:=0 to 1 do
    begin
        y:=23+(i*9);

        for j:=0 to 4 do
        begin
            x:=6+(j*10)+k;
            DrawStar(x,y);
        end;

        if k<>0 then k:=0 else
        begin
            x:=6+(5*10);
            DrawStar(x,y);
            k:=5;
        end;
    end;

    sd:=DPeek(SAVMSC)+oavmsc+bpl;

    for i:=2 to 8 do
    begin
        for j:=1 to 8 do
        begin
            Inc(sd,bpl);
            Move(pointer(sd),pointer(sd+oavmsc),16);
        end;

        Inc(sd,bpl);
    end;


    Poke(SDMCTL,$22);   // turn screen on
    PlaySong;
end;



begin
    DrawFlag;
    readkey;
end.
