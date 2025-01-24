program xbios_getdir;
{$librarypath '../..'}
uses atari, xbios, crt;
var filename: TString;
    s:char;
    fcount: byte;
    i:shortint;
    names: array [0..31,0..10] of char;

begin
    if keypressed then readkey;
    
    if xBiosCheck = 0 then begin 
        Writeln('xBios not found at address: $', HexStr(xBIOS_ADDRESS,4));
        readkey;
        exit;
    end; 

    lmargin:=0;
    cursoroff;
    clrscr;
    Write('  Mad-Pascal xBios Example Launcher     '*);
    Writeln(StringOfChar(char($12),40));
    
    xBiosOpenDefaultDir;
    fcount:=0;
    repeat
        xBiosGetEntry;
        if xBiosIOresult=0 then begin
            if DosHasEntryExt('XEX') then begin
                filename := formatFilename(DosGetEntryName, false);
                GotoXY(3 + (fcount div 4) * 13, 4 + ((fcount mod 4)*2));
                Write(char(65+fcount),' ');
                Writeln(filename);
                DosReadEntryName(@names[fcount,0]);
                inc(fcount);
            end;
        end;
    until xBiosIOresult <> 0;

    GotoXY(3,20);
    Writeln('Press key to launch an application');

    repeat 
        s:=readkey;
        i:=byte(UpCase(s))-65;
    until (i>=0) and (i<fcount);
        
    filename[0] := char(11);
    move(@names[i,0],@filename[1],11);
    GotoXY(3,21);
    Writeln('Launching ',formatFilename(filename,true));
    Pause(50);
    ClrScr;
    xBiosOpenFile(filename);
    if xBiosIOresult <> 0 then Writeln('IOerror: ', xBiosIOerror)
    else xBiosLoadBinaryFile;
        
end.

