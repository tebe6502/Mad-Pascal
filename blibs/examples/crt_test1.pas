program crt_test1;
{$librarypath '../'}
uses atari, b_system, b_crt;

var
    b: byte;
    age: integer;
    weight: real;
    name: string;

    frameMSB: byte absolute 20;
    frameLSB: byte absolute 19;

begin
    // store system charset before turning system off
    move(pointer($e000),pointer($8000),1024);
    SystemOff;

    // set stored charset back
    SetCharset($80);

    CRT_Init;
    CRT_Clear;
    CRT_Write('Frame:'~*);
    CRT_GotoXY(0,23);
    CRT_WriteRightAligned('Right aligned text'~*);
    CRT_WriteCentered(2, 'CRT display test screen'~);
    CRT_WriteCentered(4, 'Press any key to continue'~*);

    repeat
        WaitFrame;
        CRT_Gotoxy(7, 0);
        CRT_Write(frameMSB + frameLSB * 256);
        CRT_Write('  '~);
    until CRT_KeyPressed;

    CRT_ClearRow(0);

    CRT_WriteCentered(7, 'Press any key to read'~);
    CRT_WriteCentered(12, 'Press ESCAPE to finish'~*);

    repeat
        b := CRT_ReadCharI;
        CRT_WriteXY(13, 9, 'key code: '~);
        CRT_Write(b);
        CRT_Write('  '~);
        CRT_WriteXY(13, 10 ,'symbol: '~);
        CRT_Put(b);
    until b = byte(ICHAR_ESCAPE);

    CRT_Clear;
    CRT_NewLine(2);
    CRT_Write('Enter Your Name: '~);
    name := CRT_ReadStringI(12);
    CRT_ClearRow;
    CRT_Write('Hello '~);
    CRT_Write(name);
    CRT_Write(', how old are you?'~);
    CRT_NewLine;
    age := CRT_ReadInt;
    CRT_NewLine;
    CRT_Write('Wow '~);
    CRT_Write(age);
    CRT_Write(' is not so much!'~);
    CRT_NewLines(2);
    CRT_Write('How much do you weigh?'~);
    CRT_NewLine;
    weight := CRT_ReadFloat;
    CRT_NewLines(2);
    CRT_Write('Not bad...'~);
    CRT_NewLine;
    CRT_Write(weight);
    CRT_Write(' is still less than me.'~);

    CRT_NewLines(4);
    CRT_WriteCentered('Press ENTER to finish'~*);
    repeat until CRT_ReadCharI = byte(ICHAR_RETURN);

    colpf2 := 0;
    CRT_Clear(0);
    CRT_WriteCentered(11, 'TEST OVER'~*);
end.
