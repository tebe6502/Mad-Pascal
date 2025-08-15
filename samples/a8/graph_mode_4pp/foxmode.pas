program foxmode;

{$r foxmode.rc}

{$define romoff}

uses
  crt,
  atari,
  gr4pp;

const

  DISPLAY_LIST_ADDRESS = $d800;
  CHARSET_RAM_ADDRESS = $c000;
  VIDEO_RAM_ADDRESS = $c400;


  procedure vbl; assembler; interrupt;
  asm
{
  lda VS_Upper
  sta vscrol

  mva >CHARSET_RAM_ADDRESS  chbase

  jmp xitvbv
};
  end;


begin

  Gr4Init(DISPLAY_LIST_ADDRESS, VIDEO_RAM_ADDRESS, 60, 4, 0);

  SetIntVec(iVBL, @vbl);

  colbk := $00;

  color0 := $22;
  color1 := $36;
  color2 := $96;

  repeat
  until keypressed;

end.
