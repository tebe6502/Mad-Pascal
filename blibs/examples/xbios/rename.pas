program xbios_rename;
{$librarypath '../..'}
uses xbios, crt;

var filename: TString;

begin
    if keypressed then readkey;

    if xBiosCheck = 0 then begin 
        Writeln('xBios not found at address: $', HexStr(xBIOS_ADDRESS,4));
        readkey;
        exit;
    end;
    
    xBiosOpenDefaultDir;
    filename := 'FILENAMEOLDFILENAMENEW';
    if DOSFileExists(filename) then begin
        Writeln('Renaming FILENAME.OLD to FILENAME.NEW');
    end 
    else begin
        filename := 'FILENAMENEWFILENAMEOLD';
        if DOSFileExists(filename) then begin
            Writeln('Renaming FILENAME.NEW to FILENAME.OLD');
        end else exit;
    end;
    
    xBiosRenameEntry(filename);
    if xBiosIOresult <> 0 then Writeln('IOerror: ', xBiosIOerror)
    else Writeln('DONE!');
        
    Writeln;
    Writeln('Press any key to continue...');
    readkey;
end.
