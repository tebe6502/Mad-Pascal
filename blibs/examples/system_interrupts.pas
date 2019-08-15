program system_interrupts;
{$librarypath '../'}
uses atari, b_system, b_crt, b_dl;

procedure vbli;assembler;interrupt;
asm {
    pha 
    lda 20 
    :2 lsr
    and #%00001111
    sta $D01A
    inc $ff
    pla
};
end;

procedure dli;assembler;interrupt;
asm {
    pha 
    lda vcount 
    add $ff
    sta wsync
    sta $D018
    lsr
    sta $D01A
    pla
};
end;

var 
    l: byte;
  

begin
    // store system charset before turning system off
    move(pointer($e000),pointer($8000),1024);
    SystemOff;
    // set stored charset back
    SetCharset($80);
    
    DL_Attach;
    DL_Poke(2, DL_Seek(2) + DL_DLI);    // Set DLI bits on display list lines
    DL_Poke(3, DL_Seek(3) + DL_DLI);    
    // skip 4th and 5th byte of DL - (memory address)
    for l := 6 to 28 do                 // Set DLI bits on remaining display list lines
        DL_Poke(l, DL_Seek(l) + DL_DLI);

    EnableVBLI(@vbli);
    EnableDLI(@dli);

    CRT_Init;
    CRT_Clear;
    CRT_WriteCentered(2,'Hello'~);
    CRT_WriteCentered(4,'INTERRUPTS!'~);
    CRT_WriteCentered(20,'PRESS ANY KEY  TO STOP THIS MADNESS'~);
    CRT_ReadChar;

    DisableDLI;
    DisableVBLI;
    SystemReset;
end.
