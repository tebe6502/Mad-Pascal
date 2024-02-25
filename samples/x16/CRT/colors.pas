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
    writeln;
    TextBackground(PETSCII_COLOR_GREY);
    for i:=0 to 15 do begin
        // TextBackground(PETSCII_COLOR_GREY);
        TextColor(color[i]);
        writeln('text color ', color[i]);
        Delay(3000);
    end;

end.