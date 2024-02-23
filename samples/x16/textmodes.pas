uses crt;

begin
    TextMode($00);
    writeln('mode $00 - 80x60');
    writeln('press any key');
    repeat until keypressed;

    TextMode($01);
    writeln('mode $01 - 80x30');

    repeat until keypressed;

    TextMode($02);
    writeln('mode $02 - 40x60');

    repeat until keypressed;

    TextMode($03);
    writeln('mode $03 - 40x30');

    repeat until keypressed;

    TextMode($09);
    writeln('mode $09 - 64x25');

    repeat until keypressed;

    TextMode($80);
    writeln('mode $80');

    repeat until keypressed;
    ClrScr;
end.