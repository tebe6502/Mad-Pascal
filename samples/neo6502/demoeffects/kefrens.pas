program rainbow;

//------------------------------------------------------------------------------

uses crt, fastmath, neo6502;

//------------------------------------------------------------------------------

const
    BAR_W_OUTER = 6;
    BAR_W_INNER = BAR_W_OUTER - 2;
    BAR_H = 200;
    BAR_COL1 = 4;
    BAR_COL2 = 11;

//------------------------------------------------------------------------------

var
    i, ii      : byte;
    sinusTable : array [0..255] of byte absolute $F000;

//------------------------------------------------------------------------------

procedure drawBar(n :byte; x: word); register;
var
    size : word absolute $54;
    h    : byte absolute $56;
begin
    size := BAR_H + n;
    if size > 239 then h := 239 else h := size;

    NeoSetColor(BAR_COL1);
    NeoDrawRect(x, n , x + BAR_W_OUTER, h);
    NeoSetColor(BAR_COL2);
    NeoDrawRect(x + 1, n, x + 1 + BAR_W_INNER, h);
end;

//------------------------------------------------------------------------------

begin
    FillSinHigh(@sinusTable);
    repeat
        NeoWaitForVblank;
        clrscr;
        NeoSetSolidFlag(1);
        for ii := 0 to 59  do
            drawBar(ii, ii + sinusTable[i + (ii shl 1)]);
        inc(i);
    until false;
end.