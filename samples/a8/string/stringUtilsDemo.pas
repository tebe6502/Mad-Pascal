program stringUtilsDemo;

uses
    atari, crt, graph, stringUtils;

var
    str1, str2 : string;

begin

    InitGraph(0);

    Writeln('strCat(''Atari '', ''rulez!'')');
    Writeln(strCat('Atari ', 'rulez!'));

    Writeln;

    Writeln('strCat(''Atari rulez'', ''!'')');
    Writeln(strCat('Atari rulez', '!'));

    Writeln;

    Writeln('str1 := ''Atari '';');
    Writeln('str2 := ''rulez!'';');
    Writeln('strAdd(str1, str2)');

    str1 := 'Atari ';
    str2 := 'rulez!';
    strAdd(str1, str2);
    Writeln(str1);

    Writeln;

    Writeln('strLeft(''Atari rulez and Commodore rulez'', 11)');
    Writeln(strLeft('Atari rulez and Commodore rulez', 11));

    Writeln;

    Writeln('strRight(''Commodore and Atari rulez'', 11)');
    Writeln(strRight('Commodore and Atari rulez', 11));

    Writeln;

    Writeln('strMid(''Commodore and Atari rulez and Spectrum too'', 15, 11)');
    Writeln(strMid('Commodore and Atari rulez and Spectrum too', 15, 11));

    Writeln ('Press key to advance.');
    Readkey;

    Writeln;

    Writeln('strPos(''Atari'', ''Commodore, Atari, Spectrum'')');
    Writeln(strPos('Atari', 'Commodore, Atari, Spectrum'));

    Writeln;

    Writeln('strLastPos(''Atari'', ''Commodore, Atari, Spectrum, Amiga and Atari once again'')');
    Writeln(strLastPos('Atari', 'Commodore, Atari, Spectrum, Amiga and Atari once again'));

    Writeln ('Press key to advance.');
    Readkey;

    Writeln;

    Writeln('strIsPrefix(''Atari is the best!'', ''Atari'')');
    Writeln(strIsPrefix('Atari is the best!', 'Atari'));
    Writeln('strIsPrefix(''Atari is the best!'', ''hAtari'')');
    Writeln(strIsPrefix('Atari is the best!', 'hAtari'));

    Writeln ('Press key to exit.');
    Readkey;

end.
