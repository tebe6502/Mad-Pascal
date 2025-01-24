program xbios_check;
{$librarypath '../..'}
uses xbios, crt;
var v:byte;
    hex:TString;
begin
    if keypressed then readkey;
    v := xBiosCheck;
    hex := HexStr(xBIOS_ADDRESS,4);
    if v = 0 then Writeln('xBios not found at address: $', hex)
    else begin 
        Write('xBios v.');
        write(v shr 4);
        write('.');
        write(v and 7);
        writeLn(' found at address: ', hex);
    end;
    Writeln;
    Writeln('Press any key to continue...');
    readkey
end.
