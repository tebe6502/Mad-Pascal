program rainbow;

//------------------------------------------------------------------------------

uses crt, neo6502;

//------------------------------------------------------------------------------

{*
    (0, 0, 0),      # Black
    (255, 0, 0),    # Red
    (255, 165, 0),  # Orange
    (255, 255, 0),  # Yellow
    (0, 255, 0),    # Green
    (0, 255, 255),  # Cyan
    (0, 0, 255),    # Blue
    (128, 0, 128),  # Purple
    (255, 192, 203),# Pink
    (128, 128, 128),# Gray
    (255, 255, 255),# White
    (255, 99, 71),  # Tomato
    (255, 140, 0),  # Dark Orange
    (218, 165, 32), # Goldenrod
    (34, 139, 34),  # Forest Green
    (70, 130, 180)  # Steel Blue
*}

//------------------------------------------------------------------------------

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

//------------------------------------------------------------------------------

var
    i, ii: byte;

//------------------------------------------------------------------------------

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

//------------------------------------------------------------------------------

begin
    NeoWaitForVblank;
    clrscr;
    createPalette;

    for i := 0 to 239 do begin
        NeoSetColor(i + 16);
        NeoDrawLine(0, i, 319, i);
    end;

    repeat until false;
end.