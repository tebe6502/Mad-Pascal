program xbios_finditem;
{$librarypath '../..'}
uses xbios, crt;

var 
    filename0: TString = 'TEST    DAT';
    filename1: TString = 'XBIOS   BMP';
    filename2: TString = '_SUBDIR    ';
    filename3: TString = 'DONOTFINDME';

    filenames: array [0..3] of pointer = ( @filename0, @filename1, @filename2, @filename3);
    filename: TString;
    i: byte;

procedure findFile(var fname:TString);
begin
    if DOSFileExists(fname) then Writeln('File found: ', fname, ' ($', HexStr(DosGetEntryStatus, 2),')')
    else Writeln('File not found: ', fname);
end;

procedure findDir(var fname:TString);
begin
    if DOSDirExists(fname) then Writeln('Directory found: ', fname, ' ($', HexStr(DosGetEntryStatus, 2),')')
    else Writeln('Directory not found: ', fname);
end;

begin
    if keypressed then readkey;

    if xBiosCheck = 0 then begin 
        Writeln('xBios not found at address: $', HexStr(xBIOS_ADDRESS,4));
        readkey;
        exit;
    end;
    
    xBiosOpenDefaultDir;
    
    Writeln('Find files:');
    for i:=0 to 3 do begin
        filename := filenames[i];
        findFile(filename);
    end;
    Writeln;
    
    Writeln('Find directories:');
    for i:=0 to 3 do begin
        filename := filenames[i];
        findDir(filename);
    end;

    Writeln;
    Writeln('Press any key to continue...');
    readkey;
end.
