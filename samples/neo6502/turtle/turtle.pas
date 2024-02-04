program api_tests;
uses neo6502, graph, crt;
var 
    b,c,o:byte;
    w:word;

begin
    // init palette
    for b := 1 to 15 do NeoSetPalette(b,10,200,250);
    // draw circles
    ClrScr;
    TurtleInit(0);
    TurtleRight(90);
    c:=1;
    for b := 0 to 35 do begin
        for w := 0 to 35 do begin
            TurtleMove(10,c,1);
            TurtleRight(10);
        end;
        Pause;
        TurtleRight(10);
        inc(c);
        if c=16 then c:=1;
    end;
    TurtleHome;
    // rotate palette
    o:=0;
    repeat 
        c:=1 + o;
        for b:=0 to 14 do begin
            if c>15 then c:=1;
            w:=18 * b;
            NeoSetPalette(c,w,w,w);
            inc(c);
        end;
        inc(o);
        if o>14 then o:=0;
    until keypressed;
end.
