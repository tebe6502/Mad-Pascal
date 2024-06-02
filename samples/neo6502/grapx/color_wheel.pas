program color_wheel;

//-----------------------------------------------------------------------------

uses math, neo6502system, neo6502;

//-----------------------------------------------------------------------------

const
    SCREEN_WIDTH  = 320;
    SCREEN_HEIGHT = 240;
    SCREEN_SIZE   = SCREEN_WIDTH * SCREEN_HEIGHT;

//-----------------------------------------------------------------------------

const
    BASE_R: array [0..15] of byte = (
        0, 255, 255, 255, 0, 0, 0, 128, 255, 128, 255, 255, 255, 218, 34, 70
    );
    BASE_G: array [0..15] of byte = (
        0, 0, 165, 255, 255, 255, 0, 0, 192, 128, 255, 99, 140, 165, 139, 130
    );
    BASE_B: array [0..15] of byte = (
        0, 0, 0, 0, 0, 255, 255, 128, 203, 128, 255, 71, 0, 32, 34, 180
    );


//-----------------------------------------------------------------------------

var
	i, ii : byte;
    x, y  : integer;
    t     : real = 0.0;

//-----------------------------------------------------------------------------

procedure createPalette;
var
    r, g, b: byte;
    v: real;
begin
    for i := 15 downto 0 do begin
        r := BASE_R[i]; g := BASE_G[i]; b := BASE_B[i];
        for ii := 15 downto 0 do begin
            v := (ii / 15);
            NeoSetPalette(i * 16 + ii, round(r * v), round(g * v), round(b * v));
        end;
    end;
end;

//-----------------------------------------------------------------------------

procedure DrawColorwheel;
begin
	for y := 0 to SCREEN_HEIGHT-1 do
		for x := 0 to SCREEN_WIDTH-1 do
			NeoWritePixel(x, y, round(255 * (arctan2(y - SCREEN_HEIGHT/2, x - SCREEN_WIDTH/2) / (2*pi) + 0.5 + t)) and 255);
end;

//-----------------------------------------------------------------------------

begin
	createPalette;
    repeat
        DrawColorwheel;
        t := t + 0.01;
    until false;
end.

//-----------------------------------------------------------------------------
