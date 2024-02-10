uses crt, neo6502;

var
    second  :word = 1;
    vcount  :byte = 0;

procedure CallBasic; assembler; inline;
asm
    jmp $800
end;

begin
    repeat
        if vcount = 0 then begin
            write(second, ' '); inc(second);
            vcount := 59;
        end;
        NeoWaitForVblank; dec(vcount);        
    until Keypressed;
    CallBasic;
end.
