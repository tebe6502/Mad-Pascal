program crt_test1;
{$librarypath '../'}
uses atari, b_system, b_crt;

var
    b: byte;
 
begin
    // store system charset before turning system off
    move(pointer($e000),pointer($8000),1024);
    SystemOff;
    // set stored charset back
    SetCharset($80);

    CRT_Init;
    CRT_Clear;
    CRT_WriteCentered(1, ' CONSOLE KEYS TEST '~*);

    repeat 
        WaitFrame;

        CRT_GotoXY(4,5);
        if CRT_OptionPressed then CRT_Write(' OPTION '~*)
        else CRT_Write(' OPTION '~);

        CRT_GotoXY(4,7);
        if CRT_SelectPressed then CRT_Write(' SELECT '~*)
        else CRT_Write(' SELECT '~);

        CRT_GotoXY(4,9);
        if CRT_StartPressed then CRT_Write(' START '~*)
        else CRT_Write(' START '~);

        CRT_GotoXY(4,11);
        if CRT_HelpPressed then CRT_Write(' HELP '~*)
        else CRT_Write(' HELP '~);

    until false;

end.
