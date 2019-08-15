program xbios_subdir;
{$librarypath '../..'}
uses xbios, crt;

var 
    filename: TString;

begin
    if keypressed then readkey;
    
    if xBiosCheck = 0 then begin 
        Writeln('xBios not found at address: $', HexStr(xBIOS_ADDRESS,4));
        readkey;
        exit;
    end;
    
    Writeln('Program from subdirectory launched!');
    Writeln;
    Writeln('Press any key to exit');
    readkey;
    xBiosOpenDefaultDir;
    filename := 'XBIOS   COM';
    xBiosOpenFile(filename);
    if xBiosIOresult <> 0 then Writeln('IOerror: ', xBiosIOerror);
    xBiosLoadBinaryFile;
end.
