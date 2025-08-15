program foxmode_2;

{$r foxmode.rc}

{$define romoff}

uses
  crt,
  atari,
  gr4pp,
  fastmath;

const

  DISPLAY_LIST_ADDRESS = $d800;
  CHARSET_RAM_ADDRESS = $c000;
  VIDEO_RAM_ADDRESS = $c400;

var
  lookupDiv: array [0..255] of Byte absolute $bd00;
  lookupMul: array [0..255] of Byte absolute $be00;
  sinustable: array [0..255] of Byte absolute $bf00;
  xbuf0: array [0..39] of Byte absolute $0600;
  xbuf1: array [0..39] of Byte absolute $0630;

  c1A: Byte = 1;
  c1B: Byte = 5;


  procedure Vbl; assembler; interrupt;
  asm
{
  lda VS_Upper
  sta vscrol

  mva >CHARSET_RAM_ADDRESS  chbase

  jmp xitvbv
};
  end;


  procedure InitMulDiv;
  var
    x: Byte;
    s: Word;
  begin
    s := 0;

    for x := 0 to 127 do
    begin
      lookupDiv[x] := hi(s);
      lookupDiv[255 - x] := lookupDiv[x];

      s := s + 22;      // (11/128) * 256 = 22
    end;

    for x := 0 to 255 do lookupMul[x] := lookupDiv[x] * 11;
  end;


  procedure DoPlasma;
  var
    _c1a, _c1b: Byte;
    i, ii: Byte;
    scrn: Pbyte absolute $e0;
    tmp: Byte absolute $e2;
  begin
    scrn := pointer(VIDEO_RAM_ADDRESS + 8 + 10 * 40);  // X=8 ; Y=10

    _c1a := c1A;
    _c1b := c1B;

    for i := 23 downto 0 do
    begin
      xbuf0[i] := sinustable[_c1a] + sinustable[_c1b];
      Inc(_c1a, 3);
      Inc(_c1b, 7);

      xbuf1[i] := sinustable[_c1a] + sinustable[_c1b];
      Inc(_c1a, 3);
      Inc(_c1b, 7);
    end;


    for ii := 19 downto 0 do
    begin

      tmp := xbuf0[ii];

      for i := 23 downto 0 do
        scrn[i] := lookupMul[xbuf1[i] + tmp] + lookupDiv[xbuf0[i] + tmp];

      Inc(scrn, 40);


      tmp := xbuf1[ii];

      for i := 23 downto 0 do
        scrn[i] := lookupMul[xbuf1[i] + tmp] + lookupDiv[xbuf0[i] + tmp];

      Inc(scrn, 40);

    end;

    Inc(c1A, 3);
    Dec(c1B, 5);
  end;



begin

  FillSinHigh(@sinustable);

  InitMulDiv;

  Gr4Init(DISPLAY_LIST_ADDRESS, VIDEO_RAM_ADDRESS, 60, 4, 0);

  SetIntVec(iVBL, @Vbl);

  colbk := $00;

  color0 := $22;
  color1 := $36;
  color2 := $96;

  repeat
    DoPlasma;

  until keypressed;

end.
// 5324
