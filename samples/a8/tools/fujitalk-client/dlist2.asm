; Here is place for your custom display list definition.
; Handy constants are defined first:

DL_BLANK1 = 0; // 1 blank line
DL_BLANK2 = %00010000; // 2 blank lines
DL_BLANK3 = %00100000; // 3 blank lines
DL_BLANK4 = %00110000; // 4 blank lines
DL_BLANK5 = %01000000; // 5 blank lines
DL_BLANK6 = %01010000; // 6 blank lines
DL_BLANK7 = %01100000; // 7 blank lines
DL_BLANK8 = %01110000; // 8 blank lines

DL_DLI = %10000000; // Order to run DLI
DL_LMS = %01000000; // Order to set new memory address
DL_VSCROLL = %00100000; // Turn on vertical scroll on this line
DL_HSCROLL = %00010000; // Turn on horizontal scroll on this line

DL_MODE_40x24T2 = 2; // Antic Modes
DL_MODE_40x24T5 = 4;
DL_MODE_40x12T5 = 5;
DL_MODE_20x24T5 = 6;
DL_MODE_20x12T5 = 7;
DL_MODE_40x24G4 = 8;
DL_MODE_80x48G2 = 9;
DL_MODE_80x48G4 = $A;
DL_MODE_160x96G2 = $B;
DL_MODE_160x192G2 = $C;
DL_MODE_160x96G4 = $D;
DL_MODE_160x192G4 = $E;
DL_MODE_320x192G2 = $F;

DL_JMP = %00000001; // Order to jump
DL_JVB = %01000001; // Jump to begining
    
; It's always useful to include you program global constants here
    icl 'const.inc'

; and declare display list itself

dlist_category
  dta $70, $70 + DL_DLI, $42, a(vram_menu), $30 + DL_DLI, $42, a(vram_date0), $42, a(vram_head0), $02
  dta $20 + DL_DLI, $42, a(vram_date1), $42, a(vram_head1), $02, $10 + DL_DLI, $42
  dta a(vram_date2), $42, a(vram_head2), $02, $20 + DL_DLI, $42, a(vram_date3), $42, a(vram_head3)
  dta $02, $10 + DL_DLI, $42, a(vram_date4), $42, a(vram_head4), $02, $20 + DL_DLI
  dta $42, a(vram_date5), $42, a(vram_head5), $02, $10 + DL_DLI, $42, a(vram_date6), $42
  dta a(vram_head6), $02, $20 + DL_DLI, $42, a(vram_status), $41, a(dlist_category)
  
