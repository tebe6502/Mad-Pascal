program util_textalign;
{$librarypath '../'}
uses atari, b_utils, sysutils, crt;

var i:byte;

begin
    lmargin := 0;
    CursorOff;
    ClrScr;
    WritelnCentered('press any key to start.');
    Writeln;
    ReadKey;
    
    for i:=0 to 255 do begin
        Write('Number ');
        WriteRightAligned(3, IntToStr(i));
        Writeln(' has ', IntToStr(CountBits(i)), ' bits turned on');   
    end;
    
    ReadKey;
end.
