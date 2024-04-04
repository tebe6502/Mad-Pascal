uses crt;

const
    NEWFONT = $1F00;    // default address for font in ram

{$r resource.rc}

var
    i,j: byte;

begin
    write(X16_ISO_ON);
    TextCharset(pointer(NEWFONT));

    writeln;
    writeln('printable characters $20 - $7f');
    writeln;
    j:=1;
    for i:=$20 to $7f do begin
        write(HexStr(i,2));write(':',chr(i));write(' ');
        inc(j);
        if (j>10) then begin
            writeln;
            j:=1;
        end;
    end;
    
    writeln;
    writeln;
    writeln('printable characters $c0 - $ff');
    writeln;
    j:=1;
    for i:=$c0 to $ff do begin
        write(HexStr(i,2));
        write(':');
        // write(X16_REVERSE_ON);
        write(chr(i));
        // write(X16_REVERSE_OFF);
        write(' ');
        inc(j);
        if (j>10) then begin
            writeln;
            j:=1;
        end;
    end;
    repeat until keypressed;
end.