{*
    https://aeriform.itch.io/minicube64
    https://github.com/aeriform-io/minicube64
    https://aeriform.gitbook.io/minicube64
*}

//-----------------------------------------------------------------------------

program twister;

//-----------------------------------------------------------------------------

uses fastmath;

//-----------------------------------------------------------------------------

const
    VIDEO_PAGE  = $e;
    SCREEN      = VIDEO_PAGE * $1000;
    PAGE        = $100;

//-----------------------------------------------------------------------------    

const
    SCREEN_WIDTH    = 64; 
    SCREEN_HEIGHT   = 64; 
    SCREEN_CENTER_X = 16;
    SCREEN_CENTER_Y = 30;
    ANGLE_90        = 64; 
    ANGLE_180       = 128; 
    ANGLE_270       = 192;

//-----------------------------------------------------------------------------

var
    video       : byte absolute $100;
    colors      : byte absolute $101;    
    nmi_irq     : byte absolute $10c;
    vblank_irq  : word absolute $10e;
    frame_count : byte absolute $ff;

//-----------------------------------------------------------------------------

var
    sine: array[0..255] of byte absolute $f000; // Tablica wartości sinusa umieszczona w pamięci $f000
    animationOffsetX, animationOffsetY: byte; // Zmienne przechowujące offsety animacji

//-----------------------------------------------------------------------------

procedure drawHLine(x0, x1, y, c: byte);
var
    i     : byte absolute $fe;
    start : word absolute $fc;
begin
    start := SCREEN + (SCREEN_WIDTH * y) + x0;
    for i := (x1 - x0) downto 0 do poke(start + i, c);
end;

//-----------------------------------------------------------------------------

procedure clrscr; inline;
begin
    FillByte(pointer(SCREEN), $1000, 0);
end;


//-----------------------------------------------------------------------------

procedure vbi; assembler; interrupt;
asm
  ;phr
  inc frame_count
  ;plr
end;

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
        video      := VIDEO_PAGE; 
    asm { cli };   
end;

//-----------------------------------------------------------------------------

procedure DrawTwister(yOffset: byte);
var
    x1, x2, x3, x4         : byte;
    minX, maxX, angle, row : byte;
begin
    for row := 0 to SCREEN_CENTER_Y - 1 do
    begin
        angle := sine[row + animationOffsetY] + animationOffsetX;

        x1 := SCREEN_CENTER_X + sine[angle] shr 2;
        x2 := SCREEN_CENTER_X + sine[byte(angle + ANGLE_90)] shr 2;
        x3 := SCREEN_CENTER_X + sine[byte(angle + ANGLE_180)] shr 2;
        x4 := SCREEN_CENTER_X + sine[byte(angle + ANGLE_270)] shr 2;

        minX := x1; maxX := x1;
        if x2 < minX then minX := x2 else if x2 > maxX then maxX := x2;
        if x3 < minX then minX := x3 else if x3 > maxX then maxX := x3;
        if x4 < minX then minX := x4 else if x4 > maxX then maxX := x4;

        inc(yOffset, 2);

        drawHLine(minX - 6, minX, yOffset, 0);
        drawHLine(maxX, maxX + 6, yOffset, 0);

        if x1 < x2 then drawHLine(x1, x2, yOffset, 10);
        if x2 < x3 then drawHLine(x2, x3, yOffset, 20);
        if x3 < x4 then drawHLine(x3, x4, yOffset, 30);
        if x4 < x1 then drawHLine(x4, x1, yOffset, 40);
    end;
end;


//-----------------------------------------------------------------------------

begin
    init;

    FillSinLow(@sine);

    animationOffsetX := 0;
    animationOffsetY := 65;

    clrscr;
    repeat
        waitVBL;

        DrawTwister(0); 
        Inc(animationOffsetX, 2);
        Dec(animationOffsetY, 3); 

        DrawTwister(1); 
        Inc(animationOffsetX, 3); 
        Dec(animationOffsetY, 2);
    until false;
end.

//-----------------------------------------------------------------------------
