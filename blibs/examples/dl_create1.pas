program dl_create1;
{$librarypath '../'}
uses b_dl, atari, fastgraph, crt;

const 
    DL_MEM = $5a00;
    TXT_RAM = $5b00;
    GFX_RAM = $6000;
    
    blankLineHeights: array [0..7] of byte = (DL_BLANK1, DL_BLANK2, DL_BLANK3, DL_BLANK4, DL_BLANK5, DL_BLANK6, DL_BLANK7, DL_BLANK8);
    
{$R dl_create1.res} 

var 
    h:byte = 0;
    dh:shortInt = 1;
    bl1, bl2: byte;
            
begin
    ClrScr;
    Writeln('press any key,');
    Writeln('to create and set new display list...');
    Readkey;
    
    (*** DISPLAY LIST DEFINITION ***)   
    DL_Init(DL_MEM);
    DL_Push(DL_BLANK8,3);                               // 3x 8 blank lines
    DL_Push(DL_MODE_20x12T5 + DL_LMS, TXT_RAM);         // mode 2 line + text memory start
    DL_Push(DL_MODE_20x24T5);                           // mode 1 line 
    DL_Push(DL_BLANK8);                                 // 8 blank lines
    DL_Push(DL_BLANK4);                                 // 4 blank lines
    DL_Push(DL_MODE_40x24T2 + DL_HSCROLL,3);            // 2x mode 0 lines
    DL_Push(DL_MODE_160x192G4 + DL_LMS, GFX_RAM);       // gfx line + graphics memory start
    DL_Push(DL_MODE_160x192G4,65);                      // 65x graphics line
    DL_Push(DL_MODE_40x24T2 + DL_LMS, TXT_RAM + 160);   // mode2 line + text memory continues
    DL_Push(DL_MODE_40x24T2 + DL_HSCROLL,2);            // 2x mode 0 lines
    DL_Push(DL_BLANK4);                                 // 4 blank lines
    DL_Push(DL_BLANK8);                                 // 8 blank lines
    DL_Push(DL_MODE_20x24T5);                           // mode 1 line 
    DL_Push(DL_MODE_20x12T5);                           // mode 2 line 
    DL_PUSH(DL_JVB,DL_MEM);                             // jump to beginning
    DL_Start;   // Set & Start custom Display List

    savmsc := TXT_RAM; // set screen (text) memory origins. gotoxy and write won't work without it!
    lmargin := 0;
    CursorOff;
    fillbyte(pointer(TXT_RAM),400,0); // clear text ram
    GotoXy(1,1);

    Write('     NEW  fancy         display LIST');
    GotoXy(22,3);
    Write('hello textmode lines!');
    GotoXy(18,6);
    Write('hello again!');
    GotoXy(17,8);
    Write('   press ANY key     to GET more FANCY');
    Readkey;
    
    DL_Seek(0);                 // set cursor at begining of DL
    bl1 := DL_Find(DL_BLANK4);  // find first blank4 offset
    DL_Seek(bl1+1);             // set cursor after this blank4
    bl2 := DL_Find(DL_BLANK4);  // find second blank4 offset
    repeat 

        pause;                  // wait for vblank

        h := h + dh;            // h fluctuates from 0 to 7 and then backwards
        if (h = 7) or (h = 0) then dh := -dh;
        
        hscrol := h;            // set hscroll
        
        DL_Seek(bl1);
        DL_Push(blankLineHeights[h]);       // change height of first blank
        DL_Seek(bl2);
        DL_Push(blankLineHeights[7 - h]);   // change height of second blank to compensate offset
        
    until keypressed;
end.
