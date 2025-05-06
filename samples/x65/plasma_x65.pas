program plasma;

uses fastmath;

//-----------------------------------------------------------------------------

const
  SCR_W       = 48;
  SCR_H       = 30;

  LMS         = $2000; // Memory address for character data (first text row)
  LFS         = $2600; // Memory address for character color data (first text row)
  LBS         = $2c00; // Memory address for background color data (first text row)
  LCG         = $3800; // Character generator memory address (8x8 font, font file must include a header)

  DL: array [0..41] of byte = (             // Display List memory address
    $f3,                                    // LMS + LFS + LBS + LCG
    lo(LMS),hi(LMS),
    lo(LFS),hi(LFS),
    lo(LBS),hi(LBS),
    lo(LCG),hi(LCG),
    $a, $a, $a, $a, $a, $a, $a, $a, $a, $a, // MODE2
    $a, $a, $a, $a, $a, $a, $a, $a, $a, $a, // MODE2
    $a, $a, $a, $a, $a, $a, $a, $a, $a, $a, // MODE2
    $82,lo(word(@DL)),hi(word(@DL))         // JMP to begin of DL and wait for Vertical BLank
  );

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
  CGIA_RASTER            : byte absolute $FF10;
  CGIA_PLANES            : byte absolute $FF30;
  CGIA_OFFSET0           : word absolute $FF38;
  CGIA_PLANE0            : byte absolute $FF40;
  CGIA_PLANE0_ROW_HEIGHT : byte absolute $FF42;

  c1A                    : byte = 1;
  c1B                    : byte = 5;

  scr                    : PByte absolute $60;
  col                    : PByte absolute $62;

  charset                : array [0..127] of byte absolute LCG;
  sinusTable             : array [0..255] of byte absolute $4000;
  lookupDiv16            : array [0..255] of byte absolute $4100;
  xbuf                   : array [0..47]  of byte absolute $4200;

//-----------------------------------------------------------------------------

procedure InitDivision16;
var x: byte;
begin
  for x:=0 to 255 do lookupDiv16[x] := x shr 4; // Simply store values divided by 16
end;


procedure Init;
begin

  asm
    sei       ; disable IRQ
    sec \ xce ; switch to native mode
    cld       ; turn off decimal mode
  end;

  CGIA_PLANES := 0; // disable all planes, so CGIA does not go haywire during reconfiguration

  Move(DATA_CHAR, charset, SizeOf(DATA_CHAR));
  FillByte(pointer(CGIA_PLANE0), 10, 0); // clear CGIA_PLANE0 registers
  CGIA_PLANE0_ROW_HEIGHT := 7;           // 8 rows per character
  CGIA_OFFSET0 := word(@DL);             // point plane0 to DL

  CGIA_PLANES := 1; // activate plane0

end;

//-----------------------------------------------------------------------------

procedure doPlasma;
var
  _c1a, _c1b : byte;
  i, ii, tmp : byte;
begin
  scr := pointer(LMS);
  col := pointer(LFS);

  _c1a := c1A; _c1b := c1B;

  for i := (SCR_W - 1) downto 0 do begin
    xbuf[i] := sinusTable[_c1a] + sinusTable[_c1b];
    Inc(_c1a, 3); Inc(_c1b, 7);
  end;

  for ii := (SCR_H - 1) downto 0 do begin

    tmp := sinusTable[_c1a] + sinusTable[_c1b];

    Inc(_c1a, 4); Inc(_c1b, 9);

    for i := (SCR_W - 1) downto 0 do
    begin
      scr[i] := lookupDiv16[xbuf[i] + tmp];
      col[i] := scr[i];
    end;
    Inc(scr, SCR_W);
    Inc(col, SCR_W);
  end;

  Inc(c1A, 3); Dec(c1B, 5);
end;

//-----------------------------------------------------------------------------

begin
  Init;
  FillSinHigh(@sinusTable);
  InitDivision16;

  repeat
    repeat until CGIA_RASTER < 240;
    doPlasma;
  until false;
end.