uses x16, crt;

var
    i : byte;
    color :array[0..15] of byte = (
        BLACK,
        BROWN,
        PURPLE,
        RED,
        LIGHT_RED,
        ORANGE,
        YELLOW,
        GREEN,
        LIGHT_GREEN,
        BLUE,
        CYAN,
        LIGHT_BLUE,
        DARK_GREY,
        GREY,
        LIGHT_GREY,
        WHITE 
    );

begin
    // TextMode($00);
    writeln('press any key');
    repeat until keypressed;
    TextBackground(GREY);
    ClrScr;
    writeln;
    for i:=0 to 15 do begin
        // TextBackground(GREY);
        TextColor(color[i]);
        writeln('text color ', color[i]);
        // Delay(3000);
        Pause(10);
    end;

end.