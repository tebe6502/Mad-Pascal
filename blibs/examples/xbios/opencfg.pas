program xbios_opencfg;
{$librarypath '../..'}
uses xbios, crt;

var conf: TxBiosConfig;
    filename: TString;

begin
    if keypressed then readkey;
    
    if xBiosCheck = 0 then begin 
        Writeln('xBios not found at address: $', HexStr(xBIOS_ADDRESS,4));
        readkey;
        exit;
    end;
    
    Writeln('Trying to open TEST.CFG file');
    filename := 'TEST    CFG';
    xBiosOpenFile(filename);
    if xBiosIOresult <> 0 then Writeln('IOerror: ', xBiosIOerror);

    Writeln('Trying to load data from xbios.cfg');
    xBiosSetLength(sizeOf(conf));
    xBiosLoadData(@conf);
    if xBiosIOresult <> 0 then Writeln('IOerror: ', xBiosIOerror);

    Writeln;
    Writeln('version: ', conf.version shr 4, '.', conf.version and 7);
    move(@conf.autorun, @filename[1], 11);
    Writeln('autorun file: ', filename);
    Writeln('xbios address: $', HexStr(conf.xBiosAddress,2), '00');
    Writeln('buffer address: $', HexStr(conf.bufferAddress,2), '00');
    Writeln('initAD: $', HexStr(conf.initAd, 4));
    Writeln('runAD: $', HexStr(conf.runAd, 4));
    Writeln('AOSV: $', HexStr(conf.aosv, 4));
    Writeln('AOSV_RELOC: $', HexStr(conf.aosv_reloc, 4));
    Writeln('PORTB: $', HexStr(conf.portb, 2));
    Writeln('NMIEN: $', HexStr(conf.nmien, 2));
    Writeln('IRQEN: $', HexStr(conf.irqen, 2));
    
    Writeln;
    Writeln('Press any key to continue...');
    readkey
end.
