unit DisplayList;

interface

var
  color0Value: Byte;
  color1Value: Byte;
  color2Value: Byte;

procedure InitScreen;
procedure InitColors;
procedure CloseScreen;
procedure ChangeToMode(mode: Byte);

implementation

uses
  Core, Status;

const
  ANTIC_EMPTY_3 = $20;
  ANTIC_EMPTY_8 = $70;
  ANTIC_MODE_2 = $02;
  ANTIC_MODE_E = $0e;
  ANTIC_MODE_F = $0f;
  ANTIC_HS = $10;
  ANTIC_LMS = $40;
  ANTIC_DLI = $80;
  ANTIC_EMPTY_3_DLI = ANTIC_EMPTY_3 or ANTIC_DLI;
  ANTIC_MODE_2_LMS = ANTIC_MODE_2 or ANTIC_LMS;
  ANTIC_MODE_2_LMS_HS = ANTIC_MODE_2 or ANTIC_LMS or ANTIC_HS;
  ANTIC_MODE_F_LMS = ANTIC_MODE_F or ANTIC_LMS;
  ANTIC_MODE_E_LMS = ANTIC_MODE_E or ANTIC_LMS;
  ANTIC_JVB = $41;

var
  oldSDMCTL: Byte;
  oldSDLSTL: Byte;
  oldPMBase: Byte;
  oldChBase: Byte;
  oldDli: Pointer;
  oldVbl: Pointer;

procedure Dli; interrupt; assembler;
asm
{
  pha
  lda #%00111001
  sta DMACTL
  lda color0Value
  sta COLPF0
  lda color1Value
  sta COLPF1
  lda color2Value
  sta COLPF2
  lda #32
  sta HPOSP0
  sta HPOSP1
  pla
};
end;

var
  scrollDelay: Byte;
  horScroll: Byte;
  horScrollAddr: Word;

procedure Vbl; interrupt; assembler;
const
  ADDR: Word = DISPLAY_LIST_ADDR
    + 3 // empty lines
    + 5; // text field
  START_ADDR = SCROLL_LINE_ADDR;
  RESTART_ADDR = SCROLL_LINE_ADDR + TEXT_LINE_STEP;
  PAUSE_SCROLL = PAUSE_SCROLL_ADDR;
  RESET_SCROLL = RESET_SCROLL_ADDR;
  END_ADDR = SCROLL_END_ADDR_ADDR;
asm
{
  lda #138
  sta HPOSP0
  lda #78
  sta HPOSP1

  ; check if reset scroll
  lda RESET_SCROLL
  beq after_reset

  lda #2
  sta scrollDelay
  lda #0
  sta RESET_SCROLL  
  lda #15
  sta HSCROL
  sta horScroll
  lda #.lo(START_ADDR)
  sta ADDR
  lda #.hi(START_ADDR)
  sta ADDR+1

after_reset

  ; check if pause scroll
  lda PAUSE_SCROLL
  bne after_scroll

  ; slow down the scroll
  ;dec scrollDelay
  ;bne after_scroll
  ;lda #2
  ;sta scrollDelay

  ; perform fine scroll
  ldx horScroll
  dex
  stx HSCROL
  stx horScroll
  cpx #11
  bne after_scroll

  ; perform coarse scroll
  ldx #15
  stx HSCROL
  stx horScroll

  inc ADDR
  sne
  inc ADDR+1
  
  lda ADDR
  cmp END_ADDR
  bne after_scroll
  lda ADDR+1
  cmp END_ADDR+1
  bne after_scroll

  lda #.lo(RESTART_ADDR)
  sta ADDR
  lda #.hi(RESTART_ADDR)
  sta ADDR+1

after_scroll
  
  jmp xitvbv
};
end;

procedure FillImageLineAddresses;
var
  addr: Word;
  i: Byte;
begin
  addr := IMAGE_ADDR;
  for i := 0 to MAX_INDEX do
  begin
    ImageLineLoAddr[i] := Lo(addr);
    ImageLineHiAddr[i] := Hi(addr);
    Inc(addr, LINE_STEP);
  end;
end;

procedure FillDisplayListLineAddresses;
var
  addr: Word;
  i: Byte;
begin
  addr:= DISPLAY_LIST_ADDR + 16;
  for i := 0 to MAX_INDEX do
  begin
    DisplayListLineAddr[i] := addr;
    Inc(addr, 3);
  end;
end;

procedure FillDisplayList;
var
  addr: Word;

  procedure InsertEmpty3;
  begin
    Poke(addr, ANTIC_EMPTY_3);
    Inc(addr);
  end;

  procedure InsertEmpty3Dli;
  begin
    Poke(addr, ANTIC_EMPTY_3_DLI);
    Inc(addr);
  end;

  procedure InsertEmpty8;
  begin
    Poke(addr, ANTIC_EMPTY_8);
    Inc(addr);
  end;

  procedure InsertLine(line: Byte);
  begin
    Poke(addr, ANTIC_MODE_F_LMS);
    Inc(addr);
    Poke(addr, ImageLineLoAddr[line]);
    Inc(addr);
    Poke(addr, ImageLineHiAddr[line]);
    Inc(addr);
  end;

  procedure InsertTextField;
  begin
    Poke(addr, ANTIC_MODE_2_LMS);
    Inc(addr);
    Poke(addr, Lo(TEXT_LINE_1_ADDR));
    Inc(addr);
    Poke(addr, Hi(TEXT_LINE_1_ADDR));
    Inc(addr);
    InsertEmpty3;
    Poke(addr, ANTIC_MODE_2_LMS_HS);
    Inc(addr);
    Poke(addr, Lo(SCROLL_LINE_ADDR));
    Inc(addr);
    Poke(addr, Hi(SCROLL_LINE_ADDR));
    Inc(addr);
    InsertEmpty3;
    Poke(addr, ANTIC_MODE_2_LMS);
    Inc(addr);
    Poke(addr, Lo(TEXT_LINE_2_ADDR));
    Inc(addr);
    Poke(addr, Hi(TEXT_LINE_2_ADDR));
    Inc(addr);
  end;

  procedure InsertJvb;
  begin
    Poke(addr, ANTIC_JVB);
    Inc(addr);
    Poke(addr, Lo(DISPLAY_LIST_ADDR));
    Inc(addr);
    Poke(addr, Hi(DISPLAY_LIST_ADDR));
    Inc(addr);
  end;

var
  i: Byte;
begin
  FillDisplayListLineAddresses;
  FillImageLineAddresses;

  addr := DISPLAY_LIST_ADDR;
  InsertEmpty8;
  InsertEmpty8;
  InsertEmpty8;
  InsertTextField;
  InsertEmpty3Dli;
  for i := 0 to MAX_INDEX do
  begin
    InsertLine(i);
  end;
  InsertJvb;
end;

procedure ChangeToMode(mode: Byte);
const
  FIRST_ADDR = DISPLAY_LIST_ADDR + 15;
var
  i: Byte;
  addr: Word;
begin
  mode := mode and $0F;
  mode := mode or ANTIC_LMS;
  addr := FIRST_ADDR;
  for i := 0 to MAX_INDEX do
  begin
    Poke(addr, mode);
    addr := addr + 3;
  end;
end;

procedure InitPM;
const
  OFFSET = 54;
  P0_ADDR: Word = PM_P0_ADDR + OFFSET;
  P1_ADDR: Word = PM_P1_ADDR + OFFSET;
begin
  FillChar(Pointer(PM_P0_ADDR), 1024, 0);
  FillChar(Pointer(P0_ADDR), 8, %11111100);
  FillChar(Pointer(P1_ADDR), 8, %11111100);
end;

procedure InitScreen;
begin
  oldSDMCTL := SDMCTL;
  SDMCTL := 0;

  FillDisplayList;

  oldSDLSTL := SDLSTL;
  SDLSTL := Word(DISPLAY_LIST_ADDR);

  oldChBase := CHBAS;
  CHBAS := Hi(FONT_ADDR);

  oldPMBase := PMBASE;
  PMBASE := Hi(PM_ADDR);
  InitPM;

  GRACTL := %00000011;

  SIZEP0 := %00000011;
  HPOSP0 := 32;
  PCOLR0 := 0;

  SIZEP1 := %00000011;
  HPOSP1 := 32;
  PCOLR1 := 0;

  SIZEP2 := %00000011;
  HPOSP2 := 192;
  PCOLR2 := 0;

  SIZEP3 := %00000011;
  HPOSP3 := 192;
  PCOLR3 := 0;

  COLOR1 := 12;
  COLOR2 := 0;

  oldDli := nil;
  GetIntVec(iDli, oldDli);
  SetIntVec(iDli, @Dli);

  oldVbl := nil;
  GetIntVec(iVbl, oldVbl);
  SetIntVec(iVbl, @Vbl);

  NMIEN := $C0;

  SDMCTL := %00111010;
end;

procedure CloseScreen;
begin
  NMIEN := 0;
  SetIntVec(iVbl, oldVbl);
  SetIntVec(iDli, oldDli);

  HPOSP0 := 0;
  HPOSP1 := 0;
  HPOSP2 := 0;
  HPOSP3 := 0;

  SDLSTL := oldSDLSTL;
  SDMCTL := oldSDMCTL;
  PMBASE := oldPMBase;
  CHBAS := oldChBase;
end;

procedure InitColors;
begin
  PCOLR0 := RedColor;
  PCOLR1 := GreenColor;
  PCOLR2 := RedColor;
  PCOLR3 := GreenColor;
end;

initialization
begin
  scrollDelay := 2;
  horScroll := 15;
end;

end.