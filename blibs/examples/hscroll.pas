program hscroll;
{$librarypath blibs}
uses atari, b_dl;

const
  dlist = $5000;
  vmem = $5100;

var hscroll:byte = 3;
    offset:byte = 0;
    blankSize:byte = 0;
    s:string = 'hello! it is an jumping pascal scroll!!'~;
    blanks:array[0..15] of byte = (
        DL_BLANK8, DL_BLANK7, DL_BLANK6, DL_BLANK5, DL_BLANK4, DL_BLANK3, DL_BLANK2, DL_BLANK1,
        DL_BLANK1, DL_BLANK2, DL_BLANK3, DL_BLANK4, DL_BLANK5, DL_BLANK6, DL_BLANK7, DL_BLANK8
    );

begin

  DL_Init(dlist);
  DL_Push(DL_BLANK8, 12); // 12 blank lines
  DL_Push(DL_MODE_40x24T2 + DL_HSCROLL + DL_LMS, vmem); // textline
  DL_Push(DL_JVB, dlist); // jump back
  DL_Start;

  move(s[1],pointer(vmem+42),sizeOf(s)); // copy text to vram
  color2:=0;

  repeat
    pause;
    if hscroll = $ff then begin // $ff is one below zero
        hscroll := 3;
        offset := (offset + 1) mod 80; // go trough 0-79
        DL_PokeW(13, vmem + offset); // set new memory offset
    end;
    hscrol := hscroll; // set hscroll
    dec(hscroll);
    blankSize := (blankSize + 1) and 15; // go trough 0-15
    DL_Poke(10, blanks[blankSize]); // set new blankline height
  until false;

end.
