program xbios_subdir;
{$librarypath '../..'}
uses xbios, crt;

var text: string;
    filename: TString;

begin
    if keypressed then readkey;
    
    if xBiosCheck = 0 then begin 
        Writeln('xBios not found at address: $', HexStr(xBIOS_ADDRESS,4));
        readkey;
        exit;
    end;
    
    Writeln('Trying to enter directory _SUBDIR');
    filename := '_SUBDIR    ';
    xBiosOpenDir(filename);
    if xBiosIOresult <> 0 then Writeln('IOerror: ', xBiosIOerror);

    filename := 'TEST    TXT';
    Writeln('Trying to open TEST.TXT file');
    xBiosOpenFile(filename);
    if xBiosIOresult <> 0 then Writeln('IOerror: ', xBiosIOerror);
    Writeln('Reading data');
    xBiosLoadData(@text[1]);
    text[0] := char(xNOTE);
    Writeln('File contents:');
    Writeln(text);
    Writeln;
    Writeln('Press any key to launch ');
    Writeln('program located in subdirectory');
    readkey;
    ClrScr;
    filename := 'SUBFILE XEX';
    xBiosLoadFile(filename);
end.
