program text_scroll;

uses crt, graph, neo6502;

const
    s0         = 'Lorem ipsum dolor sit amet, cons'; // 32 chars
    s1         = 'ectetur adipiscing elit, sed do '; // 32 chars
    s2         = 'eiusmod tempor incididunt ut lab'; // 32 chars
    s3         = 'ore et dolore magna aliqua.     '; // 32 chars
    rowSize    = 53 * 6;                             // in pixels
    stringSize = 32 * 6;                             // in pixels

var
    posX :word = 0;

procedure CallBasic; assembler; inline;
asm
    jmp $800
end;

begin
    NeoSetColor(0,127,1,1,0);

    repeat
        NeoWaitForVblank;
        
        NeoDrawString((rowSize + stringSize * 0) - posX, 0, s0);
        NeoDrawString((rowSize + stringSize * 1) - posX, 0, s1);
        NeoDrawString((rowSize + stringSize * 2) - posX, 0, s2);
        NeoDrawString((rowSize + stringSize * 3) - posX, 0, s3);

        if posX < (6 * stringSize) then inc(posX) else posX := 0;
    until Keypressed;
    
    CallBasic;
end.
