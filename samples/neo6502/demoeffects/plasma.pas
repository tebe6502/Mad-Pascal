program plasma;

//------------------------------------------------------------------------------

uses crt, fastmath, neo6502;

//------------------------------------------------------------------------------

const
    SCR_W     = 53;
    SCR_H     = 29;
    CHARS     = 16;
    CHARS_W   = 7;
    NEW_CHARS = 192;
    PAGE      = $100;
    TABLES    = $F000;

    DATA_CHAR: array [0..(CHARS * CHARS_W - 1)] of byte = (
        $00, $00, $00, $00, $00, $00, $00, // $00,
        $00, $00, $00, $10, $00, $00, $00, // $00,
        $00, $00, $18, $18, $00, $00, $00, // $00,
        $00, $00, $38, $38, $38, $00, $00, // $00,
        $00, $00, $3c, $3c, $3c, $3c, $00, // $00,
        $00, $7c, $7c, $7c, $7c, $7c, $00, // $00,
        $00, $7e, $7e, $7e, $7e, $7e, $7e, // $00,
        $fe, $fe, $fe, $fe, $fe, $fe, $fe, // $00,
        $00, $7f, $7f, $7f, $7f, $7f, $7f, // $7f,
        $00, $7e, $7e, $7e, $7e, $7e, $7e, // $00,
        $00, $7c, $7c, $7c, $7c, $7c, $00, // $00,
        $00, $00, $3c, $3c, $3c, $3c, $00, // $00,
        $00, $00, $38, $38, $38, $00, $00, // $00,
        $00, $00, $18, $18, $00, $00, $00, // $00,
        $00, $00, $00, $08, $00, $00, $00, // $00,
        $00, $00, $00, $00, $00, $00, $00  // $00
    );

//------------------------------------------------------------------------------

var
    c1A               : byte = 1;
    c1B               : byte = 5;
    x, y, tmp         : byte;

    sinusTable        : array [0..255]   of byte absolute TABLES + PAGE * 0;
    lookupDiv16       : array [0..255]   of byte absolute TABLES + PAGE * 1;
    xbuf              : array [0..SCR_W] of byte absolute TABLES + PAGE * 2;

//------------------------------------------------------------------------------

procedure InitDivision16;
begin
    for x := SizeOf(lookupDiv16) - 1 downto 0 do lookupDiv16[x] := x shr 4 + NEW_CHARS;
end;

//----

procedure init;
begin
    FillSinHigh(@sinusTable);
    InitDivision16;
    for x := 0 to (CHARS - 1) do NeoSetChar(NEW_CHARS + x, @DATA_CHAR + x * 7);
end;

//----

procedure doPlasma;
var
    _c1a, _c1b : byte;

begin
    _c1a := c1A;
    _c1b := c1B;

    for x := SCR_W downto 0 do begin
        xbuf[x] := sinusTable[_c1a] + sinusTable[_c1b];
        Inc(_c1a, 3); Inc(_c1b, 7);
    end;

    for y := SCR_H downto 0 do begin
        tmp := sinusTable[_c1a] + sinusTable[_c1b];
        Inc(_c1a, 4); Inc(_c1b, 9);
        for x := SCR_W downto 0 do begin
            GotoXY(x, y); Write(chr(lookupDiv16[xbuf[x] + tmp]));
        end;
    end;

  Inc(c1A, 3); Dec(c1B, 5);
end;

//------------------------------------------------------------------------------

begin
    init;
    repeat NeoWaitForVblank; doPlasma until false;
end.