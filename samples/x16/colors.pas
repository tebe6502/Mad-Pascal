uses x16, crt;

var
    i : byte;
    color :array[0..15] of byte = (
        PETSCII_COLOR_BLACK,
        PETSCII_COLOR_BROWN,
        PETSCII_COLOR_PURPLE,
        PETSCII_COLOR_RED,
        PETSCII_COLOR_PINK,
        PETSCII_COLOR_ORANGE,
        PETSCII_COLOR_YELLOW,
        PETSCII_COLOR_GREEN,
        PETSCII_COLOR_LIGHT_GREEN,
        PETSCII_COLOR_BLUE,
        PETSCII_COLOR_CYAN,
        PETSCII_COLOR_LIGHT_BLUE,
        PETSCII_COLOR_DARK_GREY,
        PETSCII_COLOR_GREY,
        PETSCII_COLOR_LIGHT_GREY,
        PETSCII_COLOR_WHITE 
    );

begin
    // TextMode($00);
    writeln('press any key');
    repeat until keypressed;
    writeln;
    // TextBackground(PETSCII_COLOR_GREY);
    for i:=0 to 15 do begin
        TextBackground(PETSCII_COLOR_GREY);
        TextColor(color[i]);
        writeln('text color ', color[i]);
        Delay(3000);
    end;

end.