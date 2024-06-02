program twister;

//----------------------------------------------------------

uses crt, fastmath, neo6502system, neo6502; 

//----------------------------------------------------------

const
    SCREEN_WIDTH    = 260;
    SCREEN_HEIGHT   = 240;
    SCREEN_CENTER_X = SCREEN_WIDTH div 2;
    SCREEN_CENTER_Y = SCREEN_HEIGHT div 2;
    ANGLE_90        = 64;
    ANGLE_180       = 128;
    ANGLE_270       = 192;    

//----------------------------------------------------------

var
    sine: array[0..255] of byte absolute $f000;
    animationOffsetX, animationOffsetY: byte;

//----------------------------------------------------------

procedure DrawTwister(yOffset: byte);
var
    x1, x2, x3, x4         : byte; 
    minX, maxX, angle, row : byte;
begin
    for row := 0 to SCREEN_CENTER_Y - 1 do
    begin
        angle := sine[row + animationOffsetY] + animationOffsetX;

        x1 := SCREEN_CENTER_X + sine[angle] shr 1;
        x2 := SCREEN_CENTER_X + sine[byte(angle + ANGLE_90)] shr 1;
        x3 := SCREEN_CENTER_X + sine[byte(angle + ANGLE_180)] shr 1;
        x4 := SCREEN_CENTER_X + sine[byte(angle + ANGLE_270)] shr 1;

        minX := x1; maxX := x1;
        if x2 < minX then minX := x2 else if x2 > maxX then maxX := x2;
        if x3 < minX then minX := x3 else if x3 > maxX then maxX := x3;
        if x4 < minX then minX := x4 else if x4 > maxX then maxX := x4;  

        inc(yOffset, 2);

        NeoSetColor(0);
        NeoDrawLine(minX - 6, yOffset, minX, yOffset);
        NeoDrawLine(maxX, yOffset,  maxX + 6, yOffset);

        NeoSetColor(1); if x1 < x2 then NeoDrawLine(x1, yOffset, x2, yOffset);
        NeoSetColor(2); if x2 < x3 then NeoDrawLine(x2, yOffset, x3, yOffset);
        NeoSetColor(3); if x3 < x4 then NeoDrawLine(x3, yOffset, x4, yOffset);
        NeoSetColor(4); if x4 < x1 then NeoDrawLine(x4, yOffset, x1, yOffset);
    end;
end;

//----------------------------------------------------------

begin
    FillSinLow(@sine);

    animationOffsetX := 0;
    animationOffsetY := 65;

    clrscr;
    repeat
        NeoWaitForVblank;

        DrawTwister(0);
        Inc(animationOffsetX, 2); 
        Dec(animationOffsetY, 3); 

        DrawTwister(1);
        Inc(animationOffsetX, 3); 
        Dec(animationOffsetY, 2); 
    until false;
end.
