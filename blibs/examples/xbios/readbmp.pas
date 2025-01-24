program xbios_readmbp;
{$librarypath '../..'}
uses atari, xbios, crt, graph;

var filename: TString;
    vram: word;
    b: byte;
    
begin
    if keypressed then readkey;

    if xBiosCheck = 0 then begin 
        Writeln('xBios not found at address: $', HexStr(xBIOS_ADDRESS,4));
        readkey;
        exit;
    end;
        
    InitGraph(8);

    Writeln('Trying to open XBIOS.BMP file');
    filename := 'XBIOS   BMP';
    xBiosOpenFile(filename);
    if xBiosIOresult <> 0 then Writeln('IOerror: ', xBiosIOerror);

    xBiosSetLength(3960);
    Writeln('Trying to load data at once');
    xBiosLoadData(pointer(savmsc+400));
    if xBiosIOresult <> 0 then Writeln('IOerror: ', xBiosIOerror);

    Writeln('Press any key to continue...');
    readkey;
    ClrScr;
    fillByte(pointer(savmsc+400),3960,0);

    xBiosOpenFile(filename);
    if xBiosIOresult <> 0 then Writeln('IOerror: ', xBiosIOerror);

    Writeln('Trying to load data byte by byte');
    vram := savmsc + 400;
    repeat 
        b := xBiosGetByte xor $ff; // invert
        if xBiosIOresult = 0 then poke(vram,b);
        inc(vram);
    until xBiosIOresult <> 0;
        
    Writeln('Press any key to continue...');
    readkey;
    ClrScr;
    fillByte(pointer(savmsc+400),3960,0);

    Writeln('Trying to open XBIOS.LZ4 file');
    filename := 'XBIOS   LZ4';
    xBiosOpenFile(filename);
    if xBiosIOresult <> 0 then Writeln('IOerror: ', xBiosIOerror);

    Writeln('Trying to decompress data');
    xBiosLoadLz4Data(pointer(savmsc+400));
    if xBiosIOresult <> 0 then Writeln('IOerror: ', xBiosIOerror);

    Writeln('Press any key to continue...');
    readkey;
    
end.
