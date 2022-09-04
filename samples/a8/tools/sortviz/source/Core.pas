unit Core;

interface

const
  FONT_ADDR = $6400;
  IMAGE_1_ADDR = $6800;
  PM_ADDR: Word = $8000;
  PM_P0_ADDR = PM_ADDR + $400;
  PM_P1_ADDR = PM_ADDR + $500;
  PM_P2_ADDR = PM_ADDR + $600;
  PM_P3_ADDR = PM_ADDR + $700;
  IMAGE_ADDR: Word = $8800;
  DISPLAY_LIST_ADDR: Word = $8000;
  TABLE_SIZE: Byte = 160;
  MAX_INDEX: Byte = TABLE_SIZE - 1;
  
  LINE_STEP: Byte = 32;
  IMAGE_SIZE: Word = TABLE_SIZE * LINE_STEP;

  SPLASH_LINES: Byte = 120;
  SPLASH_ADDR: Word = IMAGE_ADDR;

  TEXT_LINE_STEP: Byte = 40;
  TEXT_LINE_COUNT: Byte = 2;
  TEXT_ADDR: Word = IMAGE_ADDR + IMAGE_SIZE;
  TEXT_LINE_1_ADDR: Word = TEXT_ADDR;
  TEXT_LINE_2_ADDR: Word = TEXT_LINE_1_ADDR + TEXT_LINE_STEP;
  SCROLL_LINE_ADDR: Word = TEXT_LINE_2_ADDR + TEXT_LINE_STEP;
  SCROLL_LINE_LENGTH: Word = 512;
  TEXT_SIZE: Word = TEXT_LINE_COUNT * TEXT_LINE_STEP + SCROLL_LINE_LENGTH;
  
  CAPTIONS_COUNT = 36;
  CAPTIONS_ADDR = TEXT_ADDR + TEXT_SIZE;
  CAPTIONS_LENGTHS_ADDR = CAPTIONS_ADDR + 2 * CAPTIONS_COUNT;

  MAX_INDEX_DELAYS: Byte = 7;
  SET_VALUE_DELAYS: array[0..MAX_INDEX_DELAYS] of Byte = (
    0, 1, 2, 5, 10, 20, 50, 100);

  PAUSE_SCROLL_ADDR: Byte = $E8;
  RESET_SCROLL_ADDR: Byte = $E9;
  SCROLL_END_ADDR_ADDR: Byte = $EA;

var
  pauseScroll: Boolean absolute PAUSE_SCROLL_ADDR;
  resetScroll: Boolean absolute RESET_SCROLL_ADDR;
  scrollEndAddr: Word absolute SCROLL_END_ADDR_ADDR;

  RTCLOK: Byte absolute $0014;
  SDMCTL: Byte absolute $022F;
  SDLSTL: Word absolute $0230;
  PCOLR0: Byte absolute $02C0;
  PCOLR1: Byte absolute $02C1;
  PCOLR2: Byte absolute $02C2;
  PCOLR3: Byte absolute $02C3;
  COLOR0: Byte absolute $02C4;
  COLOR1: Byte absolute $02C5;
  COLOR2: Byte absolute $02C6;
  CHBAS:  Byte absolute $02F4;
  CH:     Byte absolute $02FC;
  HPOSP0: Byte absolute $D000;
  HPOSP1: Byte absolute $D001;
  HPOSP2: Byte absolute $D002;
  HPOSP3: Byte absolute $D003;
  SIZEP0: Byte absolute $D008;
  SIZEP1: Byte absolute $D009;
  SIZEP2: Byte absolute $D00A;
  SIZEP3: Byte absolute $D00B;
  PALNTS: Byte absolute $D014;
  COLPF1: Byte absolute $D017;
  COLPF2: Byte absolute $D018;
  GRACTL: Byte absolute $D01D;
  DMACTL: Byte absolute $D400;
  HSCROL: Byte absolute $D404;
  PMBASE: Byte absolute $D407;
  NMIEN:  Byte absolute $D40E;

  ImageLineLoAddr, ImageLineHiAddr: array[0..MAX_INDEX] of Byte;
  DisplayListLineAddr: array[0..MAX_INDEX] of Word;
  Table: array[0..MAX_INDEX] of Byte;
  accessDelay: Byte;

  RedColor: Byte;
  GreenColor: Byte;

implementation

initialization
begin
  pauseScroll := True;
  resetScroll := True;
  if PALNTS = 15 then
  begin
    RedColor := $44;
    GreenColor := $B4;
  end
  else begin
    RedColor := $22;
    GreenColor := $A4;
  end;
end;

end.