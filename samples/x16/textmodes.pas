uses crt;

begin
    writeln;
    writeln('press any key');
    repeat until keypressed;

    TextMode(CX16_80x60);
    writeln('mode $00 - 80x60');
    repeat until keypressed;

    TextMode(CX16_80x30);
    writeln('mode $01 - 80x30');
    repeat until keypressed;

    TextMode(CX16_40x60);
    writeln('mode $02 - 40x60');
    repeat until keypressed;

    TextMode(CX16_40x30);
    writeln('mode $03 - 40x30');
    repeat until keypressed;

    TextMode(CX16_64x25);
    writeln('mode $09 - 64x25');
    repeat until keypressed;

    ClrScr;
end.