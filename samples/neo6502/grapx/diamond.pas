program diamond;
uses graph, crt; 
const m = 2;
var col: byte;

procedure Draw(x: word; y,s: byte);
begin
    SetColor(col);
    if s >= m then
        beginmp.exe %NAME%.pas -target:neo -code:%ORG%
@if %ERRORLEVEL% == 0 mads %NAME%.a65 -x -i:D:\atari\MadPascal\base -o:%NAME%.bin
@if %ERRORLEVEL% == 0 python %NEOPATH%\exec.zip %NAME%.bin@%ORG% run@%ORG% -o%NAME%.neo
@if %ERRORLEVEL% == 0 neo.exe %NAME%.bin@%ORG% run@%ORG%
            s := s shr 1;
            MoveTo(x, y+s);
            LineTo(x+s, y);
            LineTo(x, y-s);
            LineTo(x-s, y);
            LineTo(x, y+s);
            Draw(x+s, y, s);
            Draw(x-s, y, s);
            Draw(x, y-s, s);
            Draw(x, y+s, s);
        end;
    col := (col + 1) and 15;
end;

begin
    InitGraph(0);
    col := 1;
    Draw(ScreenWidth shr 1, ScreenHeight shr 1, ScreenHeight shr 1);
    repeat until keypressed;
    ClrScr;
    asm jmp $800 end;    
end.
