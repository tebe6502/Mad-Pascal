uses x16, crt;

var
    i : byte;
    color :array[0..15] of byte = (
        X16_COLOR_BLACK,
        X16_COLOR_BROWN,
        X16_COLOR_PURPLE,
        X16_COLOR_RED,
        X16_COLOR_PINK,
        X16_COLOR_ORANGE,
        X16_COLOR_YELLOW,
        X16_COLOR_GREEN,
        X16_COLOR_LIGHT_GREEN,
        X16_COLOR_BLUE,
        X16_COLOR_CYAN,
        X16_COLOR_LIGHT_BLUE,
        X16_COLOR_DARK_GREY,
        X16_COLOR_GREY,
        X16_COLOR_LIGHT_GREY,
        X16_COLOR_WHITE 
    );

begin
    // TextMode($00);
    writeln('press any key');
    repeat until keypressed;
    TextBackground(X16_COLOR_GREY);
    ClrScr;
    writeln;
    for i:=0 to 15 do begin
        // TextBackground(X16_COLOR_GREY);
        TextColor(color[i]);
        writeln('text color ', color[i]);
        // Delay(3000);
        Pause(10);
    end;

end.