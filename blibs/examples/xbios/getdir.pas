program xbios_getdir;
{$librarypath '../..'}
uses xbios, crt;

var filename: TString;
    s:char;

begin
    if keypressed then readkey;
    
    if xBiosCheck = 0 then begin 
        Writeln('xBios not found at address: $', HexStr(xBIOS_ADDRESS,4));
        readkey;
        exit;
    end; 
    
    Writeln('Trying to get directory');
    xBiosOpenDefaultDir;
    Writeln;
    Writeln('S'*,' ','NAME       '*,' ','SIZE'*);
    filename[0] := char(11);

    repeat
        xBiosGetEntry;
        if xBiosIOresult=0 then begin
            if DosIsFile(xBiosDirEntryStatus) then s:='F';
            if DosIsDir(xBiosDirEntryStatus) then s:='D';
            if DosIsLocked(xBiosDirEntryStatus) then s:='L';
            if DosIsDeleted(xBiosDirEntryStatus) then s:='-';
            Write(s,' ');
            move(pointer(xBufferH*256+xBiosDirEntryIndex), @filename[1], 11);
            Write(filename);
            Writeln(' ', DOSGetEntrySize); 
        end;
    until xBiosIOresult <> 0;
        
    Writeln;
    Writeln('Press any key to continue...');
    readkey
end.

