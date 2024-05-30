{*
    https://aeriform.itch.io/minicube64
    https://github.com/aeriform-io/minicube64
    https://aeriform.gitbook.io/minicube64
*}

//-----------------------------------------------------------------------------

program plasma;

//-----------------------------------------------------------------------------

uses fastmath;

//-----------------------------------------------------------------------------

const
    VIDEO_PAGE  = $e;
    SCREEN      = VIDEO_PAGE * $1000;
    TABLES      = VIDEO_PAGE + $1000;
    SCREEN_SIZE = 63;
    PAGE        = $100;

//-----------------------------------------------------------------------------

var
    video       : byte absolute $100;
    colors      : byte absolute $101;    
    nmi_irq     : byte absolute $10c;
    vblank_irq  : word absolute $10e;
    frame_count : byte absolute $ff;

//-----------------------------------------------------------------------------

var
    c1A          : byte = 1;
    c1B          : byte = 5;
    x, y, tmp    : byte;

    sinusTable   : array [0..PAGE - 1]    of byte absolute TABLES + PAGE * 0;
    lookupDiv16  : array [0..PAGE - 1]    of byte absolute TABLES + PAGE * 1;
    xbuf         : array [0..SCREEN_SIZE] of byte absolute TABLES + PAGE * 2;

    scr          : array [0..SCREEN_SIZE, 0..SCREEN_SIZE] of byte absolute SCREEN;

//-----------------------------------------------------------------------------

procedure vbi; assembler; interrupt;
asm
  ;phr
  inc frame_count
  ;plr
end;

//-----------------------------------------------------------------------------

{$codealign proc = $100}

procedure palette; assembler;
asm
    ; DARKSEED
    .by $00,$00,$00
    .by $00,$14,$18
    .by $00,$20,$24
    .by $00,$2c,$38
    .by $14,$34,$44
    .by $44,$34,$44
    .by $58,$3c,$48
    .by $6c,$4c,$44
    .by $80,$60,$58
    .by $6c,$70,$6c
    .by $88,$80,$78
    .by $a4,$94,$84
    .by $c4,$ac,$9c
    .by $d8,$b0,$a8
    .by $ec,$d4,$d0
    .by $fc,$fc,$fc
end;

{$codealign proc = 0}

//-----------------------------------------------------------------------------

procedure waitVBL; assembler;
asm
    lda frame_count
@   cmp frame_count
    beq @-
end;

//-----------------------------------------------------------------------------

procedure init;
begin
    asm { sei };
        vblank_irq := word(@vbi);
        colors     := hi(word(@palette));
        video      := VIDEO_PAGE; 
    asm { cli };   
end;

//-----------------------------------------------------------------------------

procedure doPlasma;
var
    _c1a, _c1b : byte;

begin
    _c1a := c1A;
    _c1b := c1B;

    for x := SCREEN_SIZE downto 0 do begin
        xbuf[x] := sinusTable[_c1a] + sinusTable[_c1b];
        Inc(_c1a, 3); Inc(_c1b, 7);
    end;

    for y := SCREEN_SIZE downto 0 do begin
        tmp := sinusTable[_c1a] + sinusTable[_c1b];
        Inc(_c1a, 4); Inc(_c1b, 9);
        for x := SCREEN_SIZE downto 0 do
            //poke(SCREEN + x + (y * (SCREEN_SIZE + 1)), lookupDiv16[xbuf[x] + tmp]);
            scr[y,x] := lookupDiv16[xbuf[x] + tmp];
    end;

  Inc(c1A, 3); Dec(c1B, 5);
end;

//-----------------------------------------------------------------------------

begin
    init;

    FillSinHigh(@sinusTable);
    for x := SizeOf(lookupDiv16) - 1 downto 0 do lookupDiv16[x] := x shr 4;

    repeat waitVBL; doPlasma until false;
end.

//-----------------------------------------------------------------------------
