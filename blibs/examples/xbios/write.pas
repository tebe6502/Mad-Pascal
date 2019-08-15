program xbios_write_data;
{$librarypath '../..'}
uses xbios, crt;

var filename: TString;
    filecontents: string[16];
    i:byte;

begin
    if keypressed then readkey;

    if xBiosCheck = 0 then begin 
        Writeln('xBios not found at address: $', HexStr(xBIOS_ADDRESS,4));
        readkey;
        exit;
    end;
    
    filename := 'TEST    DAT';
    Writeln('Trying to open TEST.DAT file');
    xBiosOpenFile(filename);
    if xBiosIOresult <> 0 then Writeln('IOerror: ', xBiosIOerror);

    xBiosSetLength(16);
    Writeln('Trying to load data');
    filecontents[0]:=char(16);
    xBiosLoadData(@filecontents[1]);
    if xBiosIOresult <> 0 then Writeln('IOerror: ', xBiosIOerror);

    Writeln;
    Writeln(filecontents);

    Writeln('Trying to write random data to file');
    for i:=1 to 16 do filecontents[i]:=char(65+Random(24));
    Writeln(filecontents);

    xBiosOpenFile(filename);
    xBiosSetLength(16);
    xBiosWriteData(@filecontents[1]);
    if xBiosIOresult <> 0 then Writeln('IOerror: ', xBiosIOerror);
    xBiosFlushBuffer;
        
    Writeln;
    Writeln('Press any key to continue...');
    readkey;
end.
