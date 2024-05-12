program bubbleuniverse;

//----------------------------------------------------------

uses crt, neo6502system, neo6502;

//----------------------------------------------------------

const
    n = 200;
    r = float((PI * 2) / 255);

//----------------------------------------------------------

var
    a     : float     absolute $54;
    b     : float     absolute $58;
    x     : float     absolute $60;
    y     : float     absolute $64;
    v     : float     absolute $68;
    u     : float     absolute $70;
    i     : byte      absolute $74;
    j     : byte      absolute $75;
    s     : byte      absolute $76;
    c     : byte      absolute $77;
    d     : byte      absolute $78;
    time1 : cardinal  absolute $80;
    time2 : cardinal  absolute $84;

//----------------------------------------------------------

begin
    x := 0; y := 0; v := 0; s := 60;

    // prepare palette
    for i := 0 to 14 do
        for j := 0 to 14 do
            NeoSetPalette((i shl 4) or j, i * 16, j * 16, 100);

    NeoSetDefaults(0, 255, 1, 0, 0);
    NeoSetPalette(255, 0, 0, 0);
    NeoSetColor(255);
    NeoDrawRect(0, 0, 319, 239);

    // draw
    time1 := NeoGetTimer;
    for i := 0 to n do
        for j := 0 to n do begin
            a := i + v;
            b := r * i + x;
            u := sin(a) + sin(b);
            v := cos(a) + cos(b);
            x := u;

            a := u * s;
            b := v * s;
            NeoWritePixel(Trunc(a) + 160, Trunc(b) + 120, (c shl 4) or (j div 14));
        end;
    time2 := NeoGetTimer;

    NeoSetTextColor(16, 15);
    GotoXY(1,1); write((time2 - time1) / 100);
    repeat until false;
end.
