{*
    https://aeriform.itch.io/minicube64
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

procedure palette; assembler;
asm
    ; PICO-8
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

procedure init;
begin
    asm { sei };
        vblank_irq := word(@vbi);
        colors     := hi(word(@palette));
        video      := VIDEO_PAGE; 
    asm { cli };   
end;

//-----------------------------------------------------------------------------

begin
    init;
    
    for j := 0 to SCREEN_SIZE - 1 do
        for i := 0 to SCREEN_SIZE - 1 do
            poke(SCREEN + (j * SCREEN_SIZE) + i, (i and %00111111) shr 1);
    
    repeat until false;
end.

//-----------------------------------------------------------------------------
