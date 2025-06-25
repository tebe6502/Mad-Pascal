// 06_plasma.ras, Turbo Rascal example
// TEDzakker demo music

{$r msx.rc}

uses fastmath;

//-----------------------------------------------------------------------------

const
  COLOURRAM_ADDR = $0800; SCREEN_ADDR = $0c00;
  SCR_W = 40; SCR_H = 25;

  MUSIC = $4000;

  DATA_CHAR: array [0..127] of byte = (
    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $10, $00, $00, $00, $00,
    $00, $00, $18, $18, $00, $00, $00, $00,
    $00, $00, $38, $38, $38, $00, $00, $00,
    $00, $00, $3c, $3c, $3c, $3c, $00, $00,
    $00, $7c, $7c, $7c, $7c, $7c, $00, $00,
    $00, $7e, $7e, $7e, $7e, $7e, $7e, $00,
    $fe, $fe, $fe, $fe, $fe, $fe, $fe, $00,
    $00, $7f, $7f, $7f, $7f, $7f, $7f, $7f,
    $00, $7e, $7e, $7e, $7e, $7e, $7e, $00,
    $00, $7c, $7c, $7c, $7c, $7c, $00, $00,
    $00, $00, $3c, $3c, $3c, $3c, $00, $00,
    $00, $00, $38, $38, $38, $00, $00, $00,
    $00, $00, $18, $18, $00, $00, $00, $00,
    $00, $00, $00, $08, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00
  );

//-----------------------------------------------------------------------------

var
  DETIRQSRC         : byte absolute $ff09;  //detect IRQ source, and clear IRQ flag
  SETIRQSRC         : byte absolute $ff0a;  //set IRQ source
  RC                : byte absolute $ff0b;  //raser counter bits 0-7
  RAMROMSEL         : byte absolute $ff12;
  CHBAS             : byte absolute $ff13;
  BACKGROUND        : byte absolute $ff15;
  BORDER            : byte absolute $ff19;
  VCOUNT            : byte absolute $ff1d;  //vertical line bits 0-7
  IRQVEC            : word absolute $fffe;

//-----------------------------------------------------------------------------

var
  c1A               : byte = 1;
  c1B               : byte = 5;

  scrn              : PByte absolute $60;

  charset           : array [0..0]   of byte absolute $3000;
  sinusTable        : array [0..255] of byte absolute $3100;
  lookupDiv16       : array [0..255] of byte absolute $3200;
  xbuf              : array [0..39]  of byte absolute $3300;

//-----------------------------------------------------------------------------

procedure InitDivision16;
var x: byte;
begin
  for x:=0 to 255 do lookupDiv16[x] := x shr 4; // Simply store values divided by 16
end;


procedure InitCharset;
begin
  Move(DATA_CHAR, charset, SizeOf(DATA_CHAR));

  // set bit 2
  RAMROMSEL := RAMROMSEL and %11111011;

  // 12 = $3000 / $400 on 2-7 bits
  CHBAS := (CHBAS and %11) or 12 shl 2;
end;

//-----------------------------------------------------------------------------

procedure doPlasma;
var
  _c1a, _c1b : byte;
  i, ii, tmp : byte;
begin
  scrn := pointer(SCREEN_ADDR);
  _c1a := c1A; _c1b := c1B;

  for i := (SCR_W - 1) downto 0 do begin
    xbuf[i] := sinusTable[_c1a] + sinusTable[_c1b];
    Inc(_c1a, 3); Inc(_c1b, 7);
  end;

  for ii := (SCR_H - 1) downto 0 do begin

    tmp := sinusTable[_c1a] + sinusTable[_c1b];
    Inc(_c1a, 4); Inc(_c1b, 9);

    for i := (SCR_W - 1) downto 0 do
      scrn[i] := lookupDiv16[xbuf[i] + tmp];

    Inc(scrn, 40);
  end;

  Inc(c1A, 3); Dec(c1B, 5);
end;

//-----------------------------------------------------------------------------

procedure vbi; assembler; interrupt;
asm {
        phr
        mva #2 DETIRQSRC

        inc c4p_time+2
        bne off
        inc c4p_time+1
        bne off
        inc c4p_time
  off:

        jsr MUSIC+3;
        plr
};
end;

//-----------------------------------------------------------------------------

begin
  asm {
    sei \ sta $ff3f
    txa:pha \ lda #0 \ jsr MUSIC \ pla:tax
  };

  RC := $d8; SETIRQSRC := 2; DETIRQSRC := 2;
  IRQVEC := word(@vbi);

  FillSinHigh(@sinusTable); InitDivision16; InitCharset;

  asm { cli };

  repeat
    Pause; doPlasma;
  until false;

end.

