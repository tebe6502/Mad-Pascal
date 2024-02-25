uses crt;
var i,j: byte;
begin
    write(X16_SWAP_CHARSET);
    writeln('press any key to continue');
    repeat until keypressed;
    
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
        write(HexStr(i,2));write(':',chr(i));write(' ');
        inc(j);
        if (j>10) then begin
            writeln;
            j:=1;
        end;
    end;
//   write(X16_SWAP_CHARSET);
//   writeln('hello world !');
    repeat until keypressed;
end.
