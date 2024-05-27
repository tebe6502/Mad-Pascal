{*
    https://github.com/aeriform-io/minicube64
    https://aeriform.gitbook.io/minicube64
*}

//-----------------------------------------------------------------------------

program palette;

//-----------------------------------------------------------------------------

const
    VIDEO_PAGE  = $f;
    SCREEN      = VIDEO_PAGE * $1000;
    SCREEN_SIZE = 64;

//-----------------------------------------------------------------------------

var
    video       : byte absolute $100;
    colors      : byte absolute $101;    
    nmi_irq     : byte absolute $10c;
    vblank_irq  : word absolute $10e;

//-----------------------------------------------------------------------------

var
    i, j : byte;

//-----------------------------------------------------------------------------

procedure vbi; assembler; interrupt;
asm
  phr
  plr
end;

//-----------------------------------------------------------------------------

{$codealign proc = $100}

procedure palette_pico8; assembler;
asm
    .by $00,$00,$00
    .by $1D,$2B,$53
    .by $7E,$25,$53
    .by $00,$87,$51
    .by $AB,$52,$36
    .by $5F,$57,$4F
    .by $C2,$C3,$C7
    .by $FF,$F1,$E8
    .by $FF,$00,$4D
    .by $FF,$A3,$00
    .by $FF,$EC,$27
    .by $00,$E4,$36
    .by $29,$AD,$FF
    .by $83,$76,$9C
    .by $FF,$77,$A8
    .by $FF,$CC,$AA  
end;

{$codealign proc = 0}

//-----------------------------------------------------------------------------

procedure init;
begin
    asm { sei };
        vblank_irq := word(@vbi);
        colors     := hi(word(@palette_pico8));
        video      := VIDEO_PAGE; 
    asm { cli };   
end;

//-----------------------------------------------------------------------------

begin
    init;
    
    for j := 0 to SCREEN_SIZE + 1 do
        for i := 0 to SCREEN_SIZE + 1 do
            poke(SCREEN + (j * SCREEN_SIZE) + i, (i and %00111111) shr 2);
    
    repeat until false;
end.

//-----------------------------------------------------------------------------
